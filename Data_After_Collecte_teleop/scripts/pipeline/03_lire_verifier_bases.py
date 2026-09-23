# -*- coding: utf-8 -*-
"""
03_lire_verifier_bases.py
==========================
Lit toutes les bases .dta du dossier `bases/` et VERIFIE que chacune
correspond bien a ce qui est attendu (nombres de lignes / colonnes,
identifiants, colonnes ajoutees).

Pour chaque base, le script affiche une ligne "OK" ou "ERREUR". A la fin,
un bilan general indique si tout est coherent.

Utile apres l'analyse : machine a verifier que les bases sont les bonnes
avant de lancer les analyses dessus.
"""
import os
import glob
import pyreadstat

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(os.path.dirname(ICI))     # racine du projet
DOSSIER_BASES = os.path.join(RACINE, "bases")

def lire(nom):
    """Lit une base .dta et retourne (dataframe, meta)."""
    return pyreadstat.read_dta(os.path.join(DOSSIER_BASES, nom))

def cles(df):
    """Ensemble des identifiants d'interviews (interview__key)."""
    return set(df["interview__key"].astype(str))

def verifier(nom, attendu_lignes, attendu_colonnes, description):
    """Lit une base, compare ses dimensions a ce qui est attendu, affiche OK/ERREUR."""
    try:
        df, meta = lire(nom)
        erreurs = []
        if len(df) != attendu_lignes:
            erreurs.append(f"lignes {len(df)} != attendu {attendu_lignes}")
        if len(df.columns) != attendu_colonnes:
            erreurs.append(f"colonnes {len(df.columns)} != attendu {attendu_colonnes}")
        if "interview__key" not in df.columns:
            erreurs.append("pas de colonne interview__key")
        if erreurs:
            print(f"[ERREUR] {nom:45s} : {' ; '.join(erreurs)}")
            return None
        print(f"[OK]     {nom:45s} : {len(df):4d} x {len(df.columns):3d}  ({description})")
        return df
    except Exception as e:
        print(f"[ERREUR] {nom}: {e}")
        return None

print("=" * 75)
print("LECTURE ET VERIFICATION DES BASES")
print("=" * 75)

# 1. Les bases source (fusion V4 -> V5 -> VF)
v4 = verifier("Questionnaire_COSO_V4.dta",
              284, 214, "version 4, 284 interviews")
v5 = verifier("Questionnaire_COSO_V5.dta",
              1032, 218, "version 5, 1032 interviews")
vf = verifier("Questionnaire_COSO_VF.dta",
              1032, 218, "version finale fusionnee V4+V5")

# 2. Les bases derivees de VF
term = verifier("Questionnaire_COSO_TERMINES.dta",
                1032, 220, "VF + statut termine / categorie")
stat = verifier("Questionnaire_COSO_VF_avec_statut.dta",
                1032, 220, "VF + colonnes de statut")
util = verifier("Questionnaire_COSO_UTILISABLES.dta",
                841, 218, "VF filtree = interviews utilisables")
comp = verifier("Questionnaire_COSO_VF_avec_completude_logique.dta",
                1032, 222, "VF + 4 colonnes de completude (version logique)")
fina = verifier("Questionnaire_COSO_VF_avec_completude.dta",
                1032, 222, "BASE FINALE : VF + taux/classe de completude")

print("-" * 75)

# 3. Controles croises sur les identifiants (qui est dans qui ?)
if vf is not None and v5 is not None:
    kf, k5 = cles(vf), cles(v5)
    print(f"VF == V5 sur les cles ?  {kf == k5}")
if vf is not None and v4 is not None:
    print(f"(note) cles V4 dans VF ? {cles(v4) <= cles(vf)} : "
          f"normal, V4 est le protocole de depart (284 interviews), "
          f"les identifiants finals viennent de V5 -> {len(vf)} interviews")
if vf is not None and term is not None:
    print(f"TERMINES == VF sur les cles ? {cles(term) == cles(vf)}")
if vf is not None and util is not None:
    print(f"UTILISABLES <= VF ?          {cles(util) <= cles(vf)} "
          f"({len(util)} interviews)")
if vf is not None and fina is not None:
    print(f"BASE FINALE == VF (cles) ?   {cles(fina) == cles(vf)}")

# 4. Controle des colonnes ajoutees a la base finale
if fina is not None:
    ajoutees = sorted(set(fina.columns) - set(vf.columns))
    print(f"Colonnes ajoutees dans la base finale : {ajoutees}")
    requis = ["n_attendu", "n_rempli", "taux_completude", "classe_completude"]
    manque = [c for c in requis if c not in fina.columns]
    print("[OK]" if not manque else "[ERREUR]",
          "les 4 colonnes de completude sont presentes "
          if not manque else f"manquante(s) : {manque}")

print("=" * 75)
print("Bilan : lire 03_ (ce script) et regarder les [OK] / [ERREUR].")
print("Les 8 bases du dossier bases/ sont celles utilisees dans l'analyse.")
print("=" * 75)