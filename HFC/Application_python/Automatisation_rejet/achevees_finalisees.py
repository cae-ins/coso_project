# -*- coding: utf-8 -*-
"""
============================================================================
SUIVI DE LA COLLECTE : INTERVIEWS ACHEVEES vs FINALISEES (HFC COSO)
============================================================================
  Auteur : Jaures MANOUAN
  Version: 1.0
  Source : API Survey Solutions (aucun besoin de Stata)

BUT
---
Interroge directement l'API Survey Solutions et produit un etat de la
collecte repondant a la question : "combien d'interviews ont ete faites
et ne restent plus a corriger ?".

DEFINITIONS (statuts Survey Solutions)
---------------------------------------
  * Achevees      : statut == 100 (Completed)    -> soumis par l'enqueteur
  * Finalisees    : statut == 120 (ApprovedBySupervisor)
                   ou statut == 130 (ApprovedByHeadquarters)
                   -> validees, plus rien a corriger (reellement terminees)
  * Finalisees_sans_erreur : finalisees dont l'interview ne figure dans
                   AUCUNE erreur encore non corrigee (approx.)

Le script distingue donc clairement :
  - Interviews TOTALES (toutes statuts confondus, y compris en cours)
  - Achevees (100) : "finies et soumises"
  - Finalisees (120/130) : "finies, validees, tout est ok"

UTILISATION
-----------
  # Tableau de bord complet + export Excel/CSV :
  python achevees_finalisees.py

  # Personnaliser la connexion :
  python achevees_finalisees.py --url ... --workspace ... --api-user ...

SORTIES
-------
  - Suivi_finalise_du_<date>.xlsx : etat de la collecte
  - affichage d'un recapitulatif dans la console

DEPENDANCES : pip install pandas openpyxl ssaw
============================================================================
"""

import os
import sys
import time
from datetime import datetime
from collections import Counter

try:
    import pandas as pd
except ImportError:
    sys.exit("Module 'pandas' requis : pip install pandas openpyxl ssaw")

try:
    from ssaw import Client, InterviewsApi
except ImportError:
    sys.exit("Module 'ssaw' requis : pip install ssaw")

try:
    from dotenv import load_dotenv
except ImportError:
    load_dotenv = None

# =============================================================================
# CONSTANTES / DEFAUTS (identiques a automatiser_rejet.py)
# =============================================================================

DEFAULT_SURVEY_URL   = "http://154.68.47.214:9700"
DEFAULT_WORKSPACE    = "enemenage"
DEFAULT_API_USER     = "UserAPIEEC"
DEFAULT_API_PASSWORD = "UserAPIEEC1"
DEFAULT_HQ_USERNAME  = "SupDaouda"
DEFAULT_HQ_PASSWORD  = "SupDaouda01"

# Statuts Survey Solutions pertinents pour ce suivi
STATUT_ACHEVEE      = 100   # Completed
STATUTS_FINALISEES  = {120, 130}   # ApprovedBySupervisor / ApprovedByHeadquarters

# Questionnaire COSO a suivre (identifiant API Survey Solutions).
# Questionnaire_COSO_V5 = la vague de collecte active (1022 interviews le 1 Sep 2026).
# V2/V4 sont des vagues precedentes, V6 un pilote.
QUESTIONNAIRES_COSO = {
    "V2": "b9613e3e-f471-4019-bc72-e2fcc3dc6afc",
    "V4": "f74744b7-62ea-4cba-8853-b4e4d4657a39",
    "V5": "b45c5c46-7df7-4929-a8f0-08bf3972fcc3",
    "V6": "4f91c7ac-f8e0-4400-8a4d-86ffeb0b53dc",
}
DEFAULT_QUESTIONNAIRE = "V5"

# Correspondance code -> libelle lisible
LIBELLE_STATUT = {
    20:  "Created",
    40:  "SupervisorAssigned",
    60:  "InterviewerAssigned",
    65:  "RejectedBySupervisor",
    80:  "ReadyForInterview",
    85:  "SentToCapi",
    95:  "Restarted",
    100: "Completed",
    120: "ApprovedBySupervisor",
    125: "RejectedByHeadquarters",
    130: "ApprovedByHeadquarters",
}


def charger_configuration():
    """Charge le .env du dossier script, puis renvoie la configuration
    de connexion. Priorite : variables d'env / .env > valeurs par defaut."""
    if load_dotenv is not None:
        load_dotenv(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env"))
    return {
        "url":           os.environ.get("SURVEY_URL", DEFAULT_SURVEY_URL),
        "workspace":     os.environ.get("WORKSPACE", DEFAULT_WORKSPACE),
        "api_user":      os.environ.get("API_USER", DEFAULT_API_USER),
        "api_password":  os.environ.get("API_PASSWORD", DEFAULT_API_PASSWORD),
        "hq_user":       os.environ.get("HQ_USERNAME", DEFAULT_HQ_USERNAME),
        "hq_password":   os.environ.get("HQ_PASSWORD", DEFAULT_HQ_PASSWORD),
    }


def today_str():
    return datetime.now().strftime("%d %b %Y")


def timestamp():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def statut_numerique(statut):
    """Convertit un statut (code numerique ou libelle) en code entier."""
    if statut is None:
        return None
    try:
        return int(statut)
    except (ValueError, TypeError):
        # statut sous forme de libelle -> cherche le code
        for code, lib in LIBELLE_STATUT.items():
            if lib.lower() == str(statut).lower():
                return code
        return None


def faire_client(url, workspace, api_user, api_password, hq_user, hq_password):
    """Connexion Survey Solutions (tente le compte API puis le compte HQ)."""
    try:
        return Client(url, api_user=api_user, api_password=api_password,
                      workspace=workspace)
    except Exception:
        try:
            return Client(url, api_user=hq_user, api_password=hq_password,
                          workspace=workspace)
        except Exception as e:
            raise RuntimeError(f"Connexion Survey Solutions impossible : {e}")


def recuperer_entretiens(interviews_api, questionnaire_id=None):
    """Recupere les entretiens (du questionnaire si fourni) avec id / statut /
    responsable / cle. Renvoie une liste de dicts et le nombre total.

    Sans questionnaire_id, l'API renvoie TOUTES les enquêtes du workspace :
    le workspace 'enemenage' melange COSO, EEC, ENE, etc. Il faut donc
    toujours filtrer sur le questionnaire COSO souhaite.
    """
    kwargs = {"fields": ["id", "status", "responsible_id",
                          "responsible_name", "key", "errors_count"]}
    if questionnaire_id:
        kwargs["questionnaire_id"] = questionnaire_id
    items = list(interviews_api.get_list(take=100000, **kwargs))
    return items


def construire_etat(items):
    """Construit le dataframe d'etat de la collecte a partir des entretiens."""
    rows = []
    for it in items:
        st = getattr(it, "status", None)
        code = statut_numerique(st)
        ec = getattr(it, "errors_count", None)
        err = 0 if ec is None else int(ec)
        rows.append({
            "key":            str(getattr(it, "key", "")),
            "interview__id":  str(getattr(it, "id", "")),
            "STATUT_CODE":    code,
            "STATUT_LIB":     LIBELLE_STATUT.get(code, str(st)),
            "ERREURS_COUNT":  err,
            "responsable":    str(getattr(it, "responsible_name", "")),
            "responsable_id": str(getattr(it, "responsible_id", "")),
        })
    df = pd.DataFrame(rows)
    if df.empty:
        df["STATUT_CODE"] = df["STATUT_CODE"].astype(object)
    return df


def produire_synthese(df, nb_erreurs=None, nb_interviews_erreur=None):
    """Calcule les indicateurs cles."""
    total = len(df)
    if total == 0:
        return df

    est_achevee   = df["STATUT_CODE"] == STATUT_ACHEVEE
    est_finalisee = df["STATUT_CODE"].isin(STATUTS_FINALISEES)
    sans_erreur   = df.get("ERREURS_COUNT", pd.Series(0, index=df.index)) == 0

    achevees       = int(est_achevee.sum())
    finalisees     = int(est_finalisee.sum())
    # "Tout est ok" = achevee (Completed) SANS erreur restante
    achevees_ok    = int((est_achevee & sans_erreur).sum())
    achevees_err   = int((est_achevee & ~sans_erreur).sum())

    synthese = {
        "Interviews_totales": total,
        "Achevees_Completed_100": achevees,
        "Achevees_sans_erreur": achevees_ok,
        "Achevees_avec_erreur": achevees_err,
        "Finalisees_120_130": finalisees,
        "Taux_completion_pct": round(100 * achevees / total, 1) if total else 0.0,
        "Taux_achevees_sans_erreur_pct": round(100 * achevees_ok / total, 1) if total else 0.0,
        "Taux_finalisees_pct": round(100 * finalisees / total, 1) if total else 0.0,
    }
    if nb_erreurs is not None:
        synthese["Erreurs"] = nb_erreurs
    if nb_interviews_erreur is not None:
        synthese["Interviews_avec_erreur"] = nb_interviews_erreur

    return synthese


def exporter(chemin, tableau):
    """Ecrit le tableau de bord dans un classeur Excel (2 feuilles)."""
    df_etat = tableau["etat"]
    df_synthese = tableau["synthese"]

    with pd.ExcelWriter(chemin, engine="openpyxl") as writer:
        # Feuille 1 : synthese (une ligne d'indicateurs)
        pd.DataFrame([df_synthese]).to_excel(
            writer, sheet_name="1.Synthese", index=False)

        # Feuille 2 : detail par entretien
        cols = ["key", "interview__id", "STATUT_CODE", "STATUT_LIB",
            "ERREURS_COUNT", "responsable"]
        df_etat[cols].to_excel(writer, sheet_name="2.Detail_entretiens", index=False)
    return chemin


def principale(questionnaire="V5"):
    cfg = charger_configuration()

    if questionnaire not in QUESTIONNAIRES_COSO:
        print(f"Questionnaire inconnu : {questionnaire}. Choisir parmi "
              f"{list(QUESTIONNAIRES_COSO)}")
        sys.exit(1)
    qid = QUESTIONNAIRES_COSO[questionnaire]

    print("=" * 70)
    print("  SUIVI COLLECTE : INTERVIEWS ACHEVEES vs FINALISEES (HFC COSO)")
    print("=" * 70)

    client = faire_client(cfg["url"], cfg["workspace"], cfg["api_user"],
                          cfg["api_password"], cfg["hq_user"], cfg["hq_password"])
    interviews_api = InterviewsApi(client)
    print(f"\n🔌 Connexion : {cfg['url']} / workspace '{cfg['workspace']}'")
    print(f"   Questionnaire : Questionnaire_COSO_{questionnaire}")

    items = recuperer_entretiens(interviews_api, qid)
    df = construire_etat(items)
    total = len(df)
    print(f"   {total} entretiens du questionnaire COSO_{questionnaire}")

    if total == 0:
        print("   Aucun entretien trouvé (vérifier workspace / compte).")
        sys.exit(1)

    synthese = produire_synthese(df)

    # Répartition par statut
    repartition = df["STATUT_LIB"].value_counts()

    n_interviews = synthese["Interviews_totales"]
    n_achevees   = synthese["Achevees_Completed_100"]
    n_achevees_ok = synthese["Achevees_sans_erreur"]
    n_fin        = synthese["Finalisees_120_130"]

    print(f"\n{'─' * 50}")
    print(f"  Interviews TOTALES (tous statuts)   : {n_interviews:>5}")
    print(f"  Achevees (Completed=100)            : {n_achevees:>5}  "
          f"({synthese['Taux_completion_pct']} %)")
    print(f"    └─ sans erreur (tout est ok)      : {n_achevees_ok:>5}  "
          f"({synthese['Taux_achevees_sans_erreur_pct']} %)")
    print(f"  FINALISEES (120/130, tout est ok)   : {n_fin:>5}  "
          f"({synthese['Taux_finalisees_pct']} %)")
    print(f"{'─' * 50}")

    print("\n  Répartition par statut :")
    for lib, n in repartition.items():
        print(f"    {lib:<26} : {n:>5}")

    # Export
    dossier_sortie = os.path.join(
        os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
        "Bases", "Suivi_enquete")
    os.makedirs(dossier_sortie, exist_ok=True)
    chemin = os.path.join(dossier_sortie, f"Suivi_finalise_du_{today_str()}.xlsx")
    tableau = {"etat": df, "synthese": synthese}
    exporter(chemin, tableau)
    print(f"\n💾 Exporté : {chemin}")


if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser(
        description="Suivi collecte COSO : interviews achevees vs finalisees "
                    "(via API Survey Solutions).")
    p.add_argument("--questionnaire", default=DEFAULT_QUESTIONNAIRE,
                   choices=sorted(QUESTIONNAIRES_COSO),
                   help="Vague COSO a suivre (défaut : V5, la collecte active)")
    args = p.parse_args()
    try:
        principale(args.questionnaire)
    except Exception as e:
        import traceback
        print(f"\n❌ ERREUR FATALE : {e}")
        print(traceback.format_exc())
        sys.exit(1)
