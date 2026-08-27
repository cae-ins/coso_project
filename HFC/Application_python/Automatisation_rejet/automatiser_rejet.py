# -*- coding: utf-8 -*-
"""
============================================================================
AUTOMATISATION DU REJET DES ENTRETIENS EN ERREUR (HFC COSO)
============================================================================
  Pipeline            : Stata (Main_COSO.do) -> Base_erreur_globale.xlsx
                        -> ce script : génération auto de la base de rejet
                        -> rejet automatique sur l'API Survey Solutions
  AUTEUR              : Jaures MANOUAN
  VERSION             : 1.0
============================================================================

PRINCIPE
--------
1. Lit automatiquement le dernier export "Base_erreur_globale_du_<date>.xlsx"
   produit par le dofile Stata (Suppression_doublons.do).
2. Regroupe les erreurs par entretien (interview__key).
3. Construit le commentaire de rejet : "[code] message" par ligne.
4. Enrichit chaque entretien depuis l'API Survey Solutions (id, statut,
   responsable) -> constitue la Base de rejet automatique.
5. Selon le statut de l'entretien, décide de l'action :
      COMPLETED / COMPLETEDBYSUPERVISOR   -> REJET (hqreject) avec commentaire
      REJECTEDBYHEADQUARTERS              -> Deja rejete (skip)
      REJECTEDBYSUPERVISOR                -> Deja rejete (skip)
      *ASSIGNED                           -> Deja chez l'agent (skip)
      autre                               -> a voir manuellement

   Le responsable de l'entretien (celui qui doit corriger) est conservé tel
   quel : le rejet renvoie automatiquement l'entretien à l'enquêteur qui l'a
   collecté. Aucune réaffectation n'est nécessaire.

UTILISATION
-----------
  # 1. Analyse uniquement (aucune écriture dans Survey Solutions) :
  python automatiser_rejet.py --dry-run

  # 2. Rejet automatique réel :
  python automatiser_rejet.py --execute

  Options utiles :
  --input  <chemin.xlsx>    : fichier base d'erreurs (sinon : dernier du dossier)
  --output <dossier>        : dossier de sortie de la base de rejet
  --url / --workspace / --api-user / --api-password / --hq-user / --hq-password

  Aucun paramètre n'est obligatoire en mode --dry-run (travail 100% local).
============================================================================
"""

import os
import re
import sys
import glob
import argparse
import time
import csv
import traceback
from datetime import datetime

try:
    import pandas as pd
except ImportError:
    sys.exit("Module 'pandas' requis : pip install pandas openpyxl")

try:
    import ssaw
    from ssaw import InterviewsApi, UsersApi
except ImportError:
    ssaw = None
    InterviewsApi = UsersApi = None

try:
    from dotenv import load_dotenv
except ImportError:
    load_dotenv = None

# =============================================================================
# CONSTANTES / DEFAUTS
# =============================================================================

DEFAULT_SURVEY_URL   = "http://154.68.47.214:9700"
DEFAULT_WORKSPACE    = "enemenage"
DEFAULT_API_USER     = "UserAPIEEC"
DEFAULT_API_PASSWORD = "UserAPIEEC1"
DEFAULT_HQ_USERNAME  = "SupDaouda"
DEFAULT_HQ_PASSWORD  = "SupDaouda01"


def charger_configuration():
    """Charge le fichier .env (dans le dossier du script), puis renvoie la
    configuration de connexion Survey Solutions priorisee :
    variables d'environnement / .env > valeurs par defaut (code)."""
    if load_dotenv is not None:
        load_dotenv(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env"))
    return {
        "url":       os.environ.get("SURVEY_URL", DEFAULT_SURVEY_URL),
        "workspace": os.environ.get("WORKSPACE", DEFAULT_WORKSPACE),
        "api_user":  os.environ.get("API_USER", DEFAULT_API_USER),
        "api_password": os.environ.get("API_PASSWORD", DEFAULT_API_PASSWORD),
        "hq_user":   os.environ.get("HQ_USERNAME", DEFAULT_HQ_USERNAME),
        "hq_password": os.environ.get("HQ_PASSWORD", DEFAULT_HQ_PASSWORD),
    }

BASE_PROJET = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DOSSIER_ERREURS_EXCEL = os.path.join(BASE_PROJET, "Bases", "Base_erreurs",
                                     "Base_erreurs_excel")


def timestamp():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def today_str():
    return datetime.now().strftime("%d %b %Y")


# =============================================================================
# 1. LOCALISATION DE LA BASE D'ERREURS
# =============================================================================

def trouver_dernier_erreur_globale(dossier=DOSSIER_ERREURS_EXCEL):
    """Retourne le fichier Base_erreur_globale *.xlsx le plus récent."""
    pattern = os.path.join(dossier, "Base_erreur_globale_*.xlsx")
    fichiers = [f for f in glob.glob(pattern) if not os.path.basename(f).startswith("~$")]
    if not fichiers:
        raise FileNotFoundError(
            f"Aucun fichier 'Base_erreur_globale_*.xlsx' trouvé dans : {dossier}")
    plus_recent = max(fichiers, key=os.path.getmtime)
    return plus_recent


def charger_base_erreurs(chemin):
    """Charge la base d'erreurs et normalise les colonnes."""
    df = pd.read_excel(chemin, dtype=str).fillna("")
    df.columns = [str(c).strip() for c in df.columns]

    renommage = {"interview__key": "interview__key",
                 "interview__id":  "interview__id",
                 "nom_sup":        "nom_sup",
                 "nom_agent":      "nom_agent",
                 "commentaire":    "commentaire",
                 "variable":       "variable",
                 "section":        "section"}
    for cible in renommage:
        if cible not in df.columns:
            df[cible] = ""

    df["interview__key"] = df["interview__key"].astype(str).str.strip()
    df["interview__id"]  = df["interview__id"].astype(str).str.strip()
    df["variable"]       = df["variable"].astype(str).str.strip()
    df["commentaire"]    = df["commentaire"].astype(str).str.strip()
    df["nom_agent"]      = df["nom_agent"].astype(str).str.strip()
    df["nom_sup"]        = df["nom_sup"].astype(str).str.strip()

    # Ignorer les clés absentes / non conformes
    df["cle_valide"] = df["interview__key"].str.fullmatch(r"[0-9A-Za-z]{2}-[0-9A-Za-z]{2}-[0-9A-Za-z]{2}-[0-9A-Za-z]{2}")
    df = df[df["cle_valide"]].copy()
    df = df[(df["variable"] != "") & (df["commentaire"] != "")]
    if df.empty:
        raise ValueError("Aucune erreur exploitable (clé d'entretien valide + variable + commentaire).")
    return df


# =============================================================================
# 2. AGRÉGATION PAR ENTRETIEN -> COMMENTAIRE DE REJET
# =============================================================================

def agreger_erreurs(df):
    """Regroupe les erreurs par entretien et construit le commentaire de rejet."""
    blocs = []
    for key, g in df.groupby("interview__key", sort=False):
        erreurs = g.sort_values(["variable", "commentaire"])
        lignes = [f"[{r['variable']}] {r['commentaire']}" for _, r in erreurs.iterrows()]
        commentaire = "\n".join(lignes)
        # Contexte agent/superviseur (homogène pour un même entretien)
        nom_agent = erreurs["nom_agent"].dropna().iloc[0] if not erreurs["nom_agent"].eq("").all() else ""
        nom_sup   = erreurs["nom_sup"].dropna().iloc[0]   if not erreurs["nom_sup"].eq("").all()   else ""
        iid       = erreurs["interview__id"].dropna().iloc[0] if not erreurs["interview__id"].eq("").all() else ""
        blocs.append({"interview__key": key,
                      "interview__id":  iid,
                      "nom_sup":        nom_sup,
                      "nom_agent":      nom_agent,
                      "nb_erreurs":     len(erreurs),
                      "Commentaire_rejet": commentaire})
    return pd.DataFrame(blocs)


# =============================================================================
# 3. ENRICHISSEMENT VIA L'API SURVEY SOLUTIONS
# =============================================================================

def normalize_guid(s):
    if not s:
        return ""
    return re.sub(r"[{}\-\s]", "", str(s).strip())


def looks_like_guid(s):
    s = str(s or "").strip()
    return bool(re.fullmatch(r"[A-Fa-f0-9]{32}", s) or re.fullmatch(r"[A-Fa-f0-9\-]{36}", s))


def faire_client(url, workspace, api_user, api_password, hq_user, hq_password):
    if ssaw is None:
        raise RuntimeError("Module 'ssaw' manquant : pip install ssaw")
    try:
        client = ssaw.Client(url, api_user=api_user, api_password=api_password,
                             workspace=workspace)
        return client
    except Exception:
        try:
            client = ssaw.Client(url, api_user=hq_user, api_password=hq_password,
                                 workspace=workspace)
            return client
        except Exception as e:
            raise RuntimeError(f"Connexion Survey Solutions impossible : {e}")


def chercher_par_key(interviews_api, key):
    """Retourne id / statut / responsable d'un entretien par sa clé."""
    try:
        items = list(interviews_api.get_list(
            fields=["id", "status", "responsible_id", "responsible_name", "key"],
            key=key, take=1))
        if items:
            it = items[0]
            return {"interview__id":          str(getattr(it, "id", "")),
                    "status":                 str(getattr(it, "status", "")),
                    "responsible_id":         str(getattr(it, "responsible_id", "")),
                    "responsible_name":       str(getattr(it, "responsible_name", ""))}
    except Exception:
        pass
    return None


def enrichir_via_api(rejets, url, workspace, api_user, api_password,
                     hq_user, hq_password, max_retries=2):
    """Remplit id/statut/responsable pour chaque entretien depuis l'API."""
    client = faire_client(url, workspace, api_user, api_password, hq_user, hq_password)
    interviews_api = InterviewsApi(client)

    rejets["interview__id"]        = ""
    rejets["STATUS_ACTUEL"]        = ""
    rejets["Numero_agent_terrain"] = ""
    rejets["Numero_agent_terrain_ID"] = ""

    nb_trouves = 0
    for idx, row in rejets.iterrows():
        info = None
        for essai in range(1, max_retries + 1):
            try:
                info = chercher_par_key(interviews_api, row["interview__key"])
                break
            except Exception:
                time.sleep(1 * essai)
        if info:
            rejets.at[idx, "interview__id"]          = info["interview__id"]
            rejets.at[idx, "STATUS_ACTUEL"]          = info["status"]
            rejets.at[idx, "Numero_agent_terrain"]   = info["responsible_name"]
            rejets.at[idx, "Numero_agent_terrain_ID"]= info["responsible_id"]
            nb_trouves += 1
        time.sleep(0.3)
    return nb_trouves


# =============================================================================
# 4. DÉCISION D'ACTION SELON LE STATUT
# =============================================================================

STATUTS_REJETABLES_HQ = {"COMPLETED", "COMPLETEDBYSUPERVISOR"}
STATUTS_DEJA_REJETES  = {"REJECTEDBYHEADQUARTERS", "REJECTEDBYSUPERVISOR"}
STATUTS_AGENT_DEJA    = {"INTERVIEWERASSIGNED", "SUPERVISORASSIGNED",
                         "INTERVIEWERASSIGNEDART"}


def statut_norm(s):
    return re.sub(r"[^A-Z]", "", str(s or "").upper())


def decider_action(rejets):
    """Attribue l'action à chaque entretien selon son statut Survey Solutions."""
    def action(row):
        st = statut_norm(row.get("STATUS_ACTUEL", ""))
        if not st:
            return ("A_REVOIR", "Statut inconnu (enrichissement API impossible)")
        if st in STATUTS_REJETABLES_HQ:
            return ("REJETER", "Rejet HQ autorisé")
        if st in STATUTS_DEJA_REJETES:
            return ("SKIP", "Déjà rejeté, en cours de correction")
        if st in STATUTS_AGENT_DEJA:
            return ("SKIP", "Déjà chez l'agent : aucune action")
        return ("A_REVOIR", f"Statut non géré : {st}")

    actions = rejets.apply(lambda r: action(r), axis=1)
    rejets["Action"] = [a[0] for a in actions]
    rejets["Motif"]  = [a[1] for a in actions]
    return rejets


# =============================================================================
# 5. ÉCRITURE DE LA BASE DE REJET (fichier Excel + plan CSV)
# =============================================================================

def ecrire_base_rejet(rejets, dossier_sortie):
    os.makedirs(dossier_sortie, exist_ok=True)
    nom = f"Base_rejet_AUTO_du_{today_str()}.xlsx"
    chemin = os.path.join(dossier_sortie, nom)
    colonnes = ["interview__key", "interview__id", "nom_sup", "nom_agent",
                "nb_erreurs", "STATUS_ACTUEL", "Numero_agent_terrain",
                "Numero_agent_terrain_ID", "Commentaire_rejet", "Action", "Motif"]
    rejets[colonnes].to_excel(chemin, index=False)
    return chemin


# =============================================================================
# 6. EXÉCUTION DES REJETS SUR L'API
# =============================================================================

def executer_rejets(rejets, url, workspace, api_user, api_password,
                    hq_user, hq_password, dossier_sortie):
    """Rejette les entretiens marqués REJETER avec leur commentaire détaillé."""
    client = faire_client(url, workspace, api_user, api_password, hq_user, hq_password)
    interviews_api = InterviewsApi(client)

    os.makedirs(dossier_sortie, exist_ok=True)
    log_csv = os.path.join(dossier_sortie, "log_rejet_auto.csv")
    with open(log_csv, "w", newline="", encoding="utf-8") as f:
        csv.writer(f).writerow(["interview__key", "interview__id", "Numero_agent_terrain",
                                "STATUS_ACTUEL", "Action", "Resultat", "Message", "Timestamp"])

    a_traiter = rejets[rejets["Action"] == "REJETER"]
    resultats = []
    nb_ok = nb_err = nb_skip = 0
    total = len(rejets)

    for _, row in rejets.iterrows():
        if row["Action"] != "REJETER":
            nb_skip += 1
            with open(log_csv, "a", newline="", encoding="utf-8") as f:
                csv.writer(f).writerow([row["interview__key"], row["interview__id"],
                                        row["Numero_agent_terrain"], row["STATUS_ACTUEL"],
                                        row["Action"], "SKIP", row["Motif"], timestamp()])
            continue
        try:
            interviews_api.hqreject(row["interview__id"], row["Commentaire_rejet"])
            msg = "Rejeté avec commentaire détaillé"
            resultat = "OK"
            nb_ok += 1
        except Exception as e:
            em = str(e).lower()
            if any(k in em for k in ["not allowed", "invalid status", "already rejected",
                                     "cannot be rejected"]):
                msg = "Rejet non autorisé (statut incompatible) — vérifier manuellement"
                resultat = "SKIP"
                nb_skip += 1
            else:
                msg = f"{str(e)[:200]}"
                resultat = "ERROR"
                nb_err += 1
        with open(log_csv, "a", newline="", encoding="utf-8") as f:
            csv.writer(f).writerow([row["interview__key"], row["interview__id"],
                                    row["Numero_agent_terrain"], row["STATUS_ACTUEL"],
                                    row["Action"], resultat, msg, timestamp()])
        time.sleep(0.7)

    return {"total": total, "rejetes": nb_ok, "skips": nb_skip,
            "erreurs": nb_err, "log": log_csv}


# =============================================================================
# 7. MAIN / CLI
# =============================================================================

def principale(args):
    print("=" * 70)
    print("  AUTOMATISATION DU REJET DES ENTRETIENS EN ERREUR (HFC COSO)")
    print("=" * 70)

    # --- Base d'erreurs ---
    chemin_input = args.input or trouver_dernier_erreur_globale()
    print(f"\n📂 Base d'erreurs : {chemin_input}")
    df = charger_base_erreurs(chemin_input)
    print(f"   ✓ {len(df)} lignes d'erreurs, {df['interview__key'].nunique()} entretiens")

    # --- Agrégation par entretien ---
    rejets = agreger_erreurs(df)
    print(f"   ✓ {len(rejets)} entretiens distincts à examiner")

    # --- Enrichissement API (si demandé / si connexion autorisée) ---
    if not args.sans_api:
        print("\n🔌 Enrichissement via l'API Survey Solutions…")
        try:
            n = enrichir_via_api(rejets, args.url, args.workspace,
                                 args.api_user, args.api_password,
                                 args.hq_user, args.hq_password)
            print(f"   ✓ {n}/{len(rejets)} entretiens résolus")
        except Exception as e:
            print(f"   ⚠️  Enrichissement API impossible ({e}).\n"
                  "      La base de rejet sera générée SANS statut (Action = A_REVOIR).")
            rejets["STATUS_ACTUEL"] = ""
            rejets["Numero_agent_terrain"] = ""
            rejets["Numero_agent_terrain_ID"] = ""
    else:
        print("\nℹ️  Mode --sans-api : aucun appel Survey Solutions.")
        rejets["STATUS_ACTUEL"] = ""
        rejets["Numero_agent_terrain"] = ""
        rejets["Numero_agent_terrain_ID"] = ""

    # --- Décision d'action ---
    rejets = decider_action(rejets)

    # --- Base de rejet ---
    chemin_base = ecrire_base_rejet(rejets, args.output)
    print(f"\n💾 Base de rejet générée : {chemin_base}")

    print(f"\n{'─' * 50}")
    synth = rejets["Action"].value_counts()
    for act, n in synth.items():
        print(f"  {act:<10} : {n:>3}")
    print(f"{'─' * 50}")

    # --- Exécution ---
    if args.execute:
        if "ssaw" not in sys.modules and ssaw is None:
            print("❌ Module 'ssaw' manquant : pip install ssaw")
            sys.exit(1)
        print("\n⚙️  Exécution des rejets (--execute)…")
        bilan = executer_rejets(rejets, args.url, args.workspace,
                                args.api_user, args.api_password,
                                args.hq_user, args.hq_password, args.output)
        print(f"   ✅ Rejetés      : {bilan['rejetes']}")
        print(f"   ⏭️  Skips        : {bilan['skips']}")
        print(f"   ❌ Erreurs      : {bilan['erreurs']}")
        print(f"   📄 Log          : {bilan['log']}")
    else:
        print("\nℹ️  Mode --dry-run (défaut) : AUCUN rejet exécuté dans "
              "Survey Solutions.\n"
              "    Relancez avec --execute pour rejeter réellement.")


def parser():
    cfg = charger_configuration()
    p = argparse.ArgumentParser(
        description="Génération auto de la base de rejet + rejet Survey Solutions.")
    p.add_argument("--input", default=None,
                   help="Fichier Base_erreur_globale.xlsx (défaut : dernier du dossier)")
    p.add_argument("--output", default=None,
                   help="Dossier de sortie de la base de rejet (défaut : dossier Base_erreurs_excel)")
    p.add_argument("--dry-run", dest="execute", action="store_false", default=None)
    p.add_argument("--execute", dest="execute", action="store_true")
    p.add_argument("--sans-api", action="store_true",
                   help="Ne pas appeler l'API Survey Solutions (travail 100% local)")
    p.add_argument("--url", default=cfg["url"], help="(défaut : .env / code)")
    p.add_argument("--workspace", default=cfg["workspace"], help="(défaut : .env / code)")
    p.add_argument("--api-user", default=cfg["api_user"], help="(défaut : .env / code)")
    p.add_argument("--api-password", default=cfg["api_password"], help="(défaut : .env / code)")
    p.add_argument("--hq-user", default=cfg["hq_user"], help="(défaut : .env / code)")
    p.add_argument("--hq-password", default=cfg["hq_password"], help="(défaut : .env / code)")
    return p


if __name__ == "__main__":
    args = parser().parse_args()
    if args.execute is None:
        args.execute = False
    if not args.output:
        args.output = DOSSIER_ERREURS_EXCEL
    try:
        principale(args)
    except Exception as e:
        print(f"\n❌ ERREUR FATALE : {e}")
        print(traceback.format_exc())
        sys.exit(1)