# -*- coding: utf-8 -*-
"""
COMPLETUDE DES REPONSES LIGNE PAR LIGNE
========================================
Pour chaque interview, on calcule son taux de completude :
    % de questions renseignees (non vides) parmi les colonnes de contenu.

Puis on regarde les cas etranges : un A4 = refus/echec qui aurait quand meme
un questionnaire bien rempli (erreur de saisie possible), et a l'inverse des
statuts 'termines' dont le questionnaire est presque vide.

Regles de comptage :
    - colonne numerique : vide si NaN
    - colonne texte      : vide si NaN, "" ou "."
"""
import pyreadstat
import pandas as pd

# ---------------------------------------------------------------- 1. Lecture
vf, meta = pyreadstat.read_dta("Questionnaire_COSO_VF.dta")

# Colonnes 'contenu' = les vraies questions du questionnaire
tech = ["interview__id", "interview__key", "interview__status", "assignment__id",
        "ssys_irnd", "has__errors", "cover_id", "cover_district", "cover_region"]
contenu = [c for c in vf.columns
           if c not in tech and not c.startswith("HH")
           and c not in ("A2_date", "A2_heure", "A5_date", "A5_heure")]
print(f"Colonnes de contenu analysees : {len(contenu)}\n")

# ----------------------------------------------------- 2. Completude par ligne
# Taux de completion par colonne, puis moyenne par ligne
vide = pd.DataFrame(index=vf.index, columns=contenu, dtype=bool)
for c in contenu:
    vide[c] = vf[c].isna()
    if vf[c].dtype == object:
        vide[c] = vide[c] | (vf[c] == "") | (vf[c] == ".")
vf["taux_completude"] = (1 - vide.mean(axis=1)) * 100

# ------------------------------------------------- 3. Categories d'appel (label)
lbl = meta.variable_value_labels["A4"]
def nom_a4(v):
    if pd.isna(v):
        return "(A4 vide)"
    return lbl.get(v, f"A4={v}")
vf["a4_nom"] = vf["A4"].map(nom_a4)

# ------------------------------------------------------- 4. Vue d'ensemble
print("=== Taux de completude moyen selon le resultat d'appel (A4) ===")
tab = vf.groupby("a4_nom")["taux_completude"].agg(["count", "mean"])
tab["mean"] = tab["mean"].round(1)
print(tab.to_string())
print()

print("=== Taux de completude moyen selon le STATUT ===")
tab = vf.groupby("interview__status")["taux_completude"].agg(["count", "mean"])
tab["mean"] = tab["mean"].round(1)
for idx, row in tab.iterrows():
    print(f"  Statut {int(idx):3} | n={int(row['count']):4} | completude moyenne {row['mean']:5.1f} %")

# --------------------------------------------------------- 5. Classification
print("\n=== Classification de chaque interview ===")
def seuils(x):
    if x >= 70:  return "1 - BIEN rempli (>=70%)"
    if x >= 30:  return "2 - Partiellement rempli (30-70%)"
    return "3 - Quasi vide (<30%)"
vf["classe_completude"] = vf["taux_completude"].map(seuils)
print(vf["classe_completude"].value_counts().to_string())

# ----------------------------------------- 6. Les cas etranges (A4 echec/refus)
print("\n=== CAS ETRANGES 1 : résultat d'appel 'echec/refus' MAIS questionnaire rempli ===")
echec = [2, 3, 4, 5, 6, 7]
etranges = vf[vf["A4"].isin(echec) & (vf["taux_completude"] >= 30)]
cols = ["interview__key", "interview__status", "A4", "consentement",
        "taux_completude", "a4_nom"]
print(f"{len(etranges)} cas trouves :")
print(etranges[cols].sort_values("taux_completude", ascending=False).to_string(index=False))

# ------------------------------------------------- Dont le cas A4 = 6 refus
print("\n=== Detail des A4 = 6 (refus de participer) ===")
refus = vf[vf["A4"] == 6][cols + ["nom"]]
print(refus.to_string(index=False))

# --------------------------------------- 7. Les cas etranges (statut 100 vide)
print("\n=== CAS ETRANGES 2 : statut 100 'complet' MAIS questionnaire vide ===")
st100 = vf[(vf["interview__status"] == 100) & (vf["taux_completude"] < 30)]
print(f"{len(st100)} cas trouves :")
print(st100[["interview__key", "A4", "consentement", "taux_completude", "a4_nom"]].to_string(index=False))