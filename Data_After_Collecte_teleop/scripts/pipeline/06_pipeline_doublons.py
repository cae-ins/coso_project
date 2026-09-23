# -*- coding: utf-8 -*-
"""
06_pipeline_doublons.py
=======================
PIPELINE DE DEDOUBLONNAGE + LIVRABLES

Chaine complete :
  1) recalcul de la completude (relance 01_completude_logique.py,
     qui reecrit resultats/Questionnaire_COSO_VF_avec_completude.dta)
  2) detection des doublons (nom + telephone)
  3) constitution de la liste des EXCLUSIONS (343 retirees - 14 doublons)
  4) sorties :
       - QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta  : base finale CORRIGEE
             = 1032 interviews - 14 doublons = 1018, + colonnes
               doublon_de / doublon_classe / a_retraiter / consentement_lbl
       - 329_a_retraiter_avec_consentement.xlsx   : les 329 a trancher
             (classe, cle, id, nom, tel, consentement, ...)
       - 114_a_recontacter.xlsx                   : les 114 qui ont
             consenti OUI -> a reprendre sur le terrain
"""
import os
import subprocess
import numpy as np
import pandas as pd
import pyreadstat

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(os.path.dirname(ICI))     # racine du projet
DOSSIER_RES = os.path.join(RACINE, "resultats")

def rempli(v):
    if v is None:
        return False
    if isinstance(v, float) and np.isnan(v):
        return False
    return str(v).strip() not in ("", "nan", "None", ".")

def consentement_lbl(v):
    if v is None or (isinstance(v, float) and np.isnan(v)):
        return "NA"
    return "OUI" if int(v) == 1 else "NON"

print("=" * 70)
print("ETAPE 1/4 : calcul de la completude (01_completude_logique.py)")
print("=" * 70)
subprocess.run(["python3", "01_completude_logique.py"], cwd=ICI, check=True)

base, meta = pyreadstat.read_dta(
    f"{DOSSIER_RES}/Questionnaire_COSO_VF_avec_completude.dta")

print()
print("=" * 70)
print("ETAPE 2/4 : detection des doublons (nom + telephone)")
print("=" * 70)
P = base[base.apply(lambda x: rempli(x["telephone"]) and rempli(x["nom"]),
                    axis=1)].copy()
P["tel"] = P["telephone"].astype(str).str.replace("[^0-9]", "", regex=True)
P["nom2"] = P["nom"].astype(str).str.strip().str.lower()
P["dbl"] = P.duplicated(subset=["tel", "nom2"], keep=False)
D = P[P["dbl"]]
print(f"Paires de doublons detectees : {D.groupby(['tel','nom2']).ngroups}")

a_exclure = []          # (cle a exclure, classe, cle jumeau garde)
jumeaux_a_garder = []   # paires a conserver dans les classes gardees
for (t, n), ix in D.groupby(["tel", "nom2"]):
    g = base[base["interview__key"].isin(set(ix["interview__key"]))]
    garde = g[g["classe_completude"].isin(["1-COMPLET", "2-QUASI_COMPLET"])]
    double = g[~g["classe_completude"].isin(["1-COMPLET", "2-QUASI_COMPLET"])]
    if len(garde) >= 1 and len(double) == 0:
        # les deux interviews sont gardables -> on conserve la paire
        jumeaux_a_garder.append(tuple(g["interview__key"]))
    elif len(garde) > 0:
        # le jumeau complet existe deja -> on exclut la version incomplète
        for _, rr in double.iterrows():
            a_exclure.append((rr["interview__key"], rr["classe_completude"],
                              garde.iloc[0]["interview__key"]))
    elif len(double) == 2:
        # deux interviews doubles dans la meme classe non gardee (ex 2 VIDE)
        # -> on garde la plus avancee, on exclut l'autre
        double = double.sort_values("n_rempli", ascending=False)
        a_exclure.append((double.iloc[1]["interview__key"],
                          double.iloc[1]["classe_completude"],
                          double.iloc[0]["interview__key"]))
    else:
        # tous gardes (ex: deux COMPLET) -> rien a exclure
        jumeaux_a_garder.append(tuple(g["interview__key"]))

exkeys = {k for k, _, _ in a_exclure}
print(f"Interviews a exclure (doublons nom+tel) : {len(a_exclure)}")
for k, c, why in sorted(a_exclure):
    print(f"   Exclu  {k}  {c:16s} <- jumeau garde : {why}")
print(f"Paires conservees (deja complete) : {len(jumeaux_a_garder)}")

print()
print("=" * 70)
print("ETAPE 2bis/4 : dedoublonnage par CANDIDAT (cover_id)")
print("   -> on garde UNE SEULE fiche par candidat : la plus complete")
print("=" * 70)
ordre_classe = {"1-COMPLET": 4, "2-QUASI_COMPLET": 3,
                "3-MOYEN": 2, "4-INCOMPLET": 1, "5-VIDE": 0}
base["_prio"] = base["classe_completude"].map(ordre_classe)
base = base.sort_values(
    ["taux_completude", "n_rempli", "_prio"], ascending=False)
doublons_cover = base.duplicated("cover_id", keep="first")
exkeys_by_cover = base.loc[doublons_cover, "interview__key"].tolist()
for k in exkeys_by_cover:
    a_exclure.append((k, "doublon cover_id", "fiche la plus complete"))
base = base[~doublons_cover].drop(columns="_prio")
exkeys |= set(exkeys_by_cover)
print(f"Fiches en double par candidat (cover_id) exclues : "
      f"{len(exkeys_by_cover)}")
print(f"Base apres dedoublonnage candidat : {len(base)} fiches "
      f"/ {base['cover_id'].nunique()} candidats")

print()
print("=" * 70)
print("ETAPE 3/4 : base finale CORRIGEE (sans doublons)")
print("=" * 70)
base["doublon_de"] = base["interview__key"].map(
    lambda k: next((why for kk, _, why in a_exclure if kk == k), ""))
base["doublon_classe"] = base["interview__key"].map(
    lambda k: next((c for kk, c, _ in a_exclure if kk == k), ""))
base["a_retraiter"] = base["classe_completude"].isin(
    ["3-MOYEN", "4-INCOMPLET", "5-VIDE"]) & (base["doublon_de"] == "")
base["consentement_lbl"] = base["consentement"].apply(consentement_lbl)
base_corrigee = base[~base["interview__key"].isin(exkeys)]
pyreadstat.write_dta(
    base_corrigee,
    f"{DOSSIER_RES}/QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta",
    variable_value_labels=meta.variable_value_labels)
print(f"Base corrigee ecrite : {len(base_corrigee)} interviews "
      f"({len(base)} - {len(exkeys)} doublons)")

print()
print("=" * 70)
print("ETAPE 4/4 : fichiers Excel de travail")
print("=" * 70)

def chaine(v):
    if isinstance(v, float) and np.isnan(v):
        return ""
    s = str(v).strip()
    return "" if s in ("nan", "None", "") else s

# --- fichier 1 : les 329 a retraiter (343 - 14 doublons) ---
retirer = base_corrigee[base_corrigee["classe_completude"].isin(
    ["3-MOYEN", "4-INCOMPLET", "5-VIDE"])].copy()
print(f"A retraiter : {len(retirer)} interviews")
fichier_329 = pd.DataFrame({
    "classe_completude": retirer["classe_completude"],
    "interview__key":    retirer["interview__key"].astype(str),
    "interview__id":     retirer["interview__id"].map(chaine),
    "nom":               retirer["nom"].map(chaine),
    "telephone":         retirer["telephone"].map(chaine),
    "localite":          retirer["localite"].map(chaine),
    "interview__status": retirer["interview__status"].map(chaine),
    "consentement":      retirer["consentement_lbl"],
    "n_attendu":         retirer["n_attendu"].map(chaine),
    "n_rempli":          retirer["n_rempli"].map(chaine),
    "taux_completude":   retirer["taux_completude"].round(4),
}).sort_values(["consentement", "classe_completude", "nom"])
fichier_329.to_excel(
    f"{DOSSIER_RES}/329_a_retraiter_avec_consentement.xlsx", index=False)
print(f"  -> 329_a_retraiter_avec_consentement.xlsx ({len(fichier_329)})")

# --- fichier 2 : les 114 a recontacter (consentement OUI) ---
a_recontacter = retirer[retirer["consentement_lbl"] == "OUI"].copy()
fichier_114 = pd.DataFrame({
    "classe_completude": a_recontacter["classe_completude"],
    "interview__key":    a_recontacter["interview__key"].astype(str),
    "interview__id":     a_recontacter["interview__id"].map(chaine),
    "nom":               a_recontacter["nom"].map(chaine),
    "telephone":         a_recontacter["telephone"].map(chaine),
    "localite":          a_recontacter["localite"].map(chaine),
    "interview__status": a_recontacter["interview__status"].map(chaine),
    "consentement":      a_recontacter["consentement_lbl"],
    "n_attendu":         a_recontacter["n_attendu"].map(chaine),
    "n_rempli":          a_recontacter["n_rempli"].map(chaine),
    "taux_completude":   a_recontacter["taux_completude"].round(4),
}).sort_values(["classe_completude", "n_rempli"], ascending=[True, False])
fichier_114.to_excel(
    f"{DOSSIER_RES}/114_a_recontacter.xlsx", index=False)
print(f"  -> 114_a_recontacter.xlsx ({len(fichier_114)})")
print()
print("Repartition des 114 a recontacter :")
print(a_recontacter["classe_completude"].value_counts().to_string())
print()
print("=" * 70)
print("PIPELINE TERMINE")
print("Livrables dans resultats/ :")
print("  - QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta   (base corrigee)")
print("  - 329_a_retraiter_avec_consentement.xlsx")
print("  - 114_a_recontacter.xlsx")
print("=" * 70)