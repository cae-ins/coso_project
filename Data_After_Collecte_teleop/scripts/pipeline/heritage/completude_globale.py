# -*- coding: utf-8 -*-
"""
COMPLETUDE DES INTERVIEWS - CLASSEMENT 100% / PARTIEL / VIDE
=============================================================
Objectif : mesurer, ligne par ligne, le taux de reponses RENSEIGNEES dans le
questionnaire, en EXCLUANT les informations d'identification :
   - nom, prenom, telephone, localite
   - region, district (cover)
   - nom de l'agent / superviseur
   - identifiants techniques (interview__id, __key, assignment, etc.)
   - horodatages de debut/fin de sections (HHA_debut ... HHR_fin)
   - etat du dossier (statut, erreurs)

Les colonnes GARDES = les VRAIES questions du questionnaire : A, B, C, ... R.

Chaque interview est ensuite classee :
   - "1 - COMPLETE  (100 % des questions renseignees)"
   - "2 - Bien remplie   (>= 80 %)"
   - "3 - Partielle      (30 % a 79 %)"
   - "4 - Peu remplie    (1 % a 29 %)"
   - "5 - VIDE          (0 %)"

Fichiers de sortie :
   - rapport affiche a l'ecran
   - completude_par_interview.csv (detail pour chaque interview)
"""
import pyreadstat
import pandas as pd

# ---------------------------------------------------------------- 1. Lecture
vf, meta = pyreadstat.read_dta("Questionnaire_COSO_VF.dta")

# ----------------------- 2. Separation colonnes contenu / identification
exclusions = [
    "interview__key", "interview__id", "assignment__id",
    "cover_id", "cover_district", "cover_region",
    "localite", "nom", "telephone", "nom_sup", "nom_agent",
    "ssys_irnd", "sssys_irnd", "has__errors", "interview__status",
]
# + toutes les colonnes d'horodatage de section (HHA_debut, HHA_fin, ...)
exclusions += [c for c in vf.columns if c.endswith(("_debut", "_fin"))]

contenu = [c for c in vf.columns if c not in exclusions]
print(f"Colonnes d'identification / techniques exclues : {len(exclusions)}")
print(f"Colonnes de QUESTIONS analysees               : {len(contenu)}")
print("  Sections :", " ".join(sorted(set(c[:2].rstrip('_') for c in contenu))))
print()

# --------------------------------------------------- 3. Completude par ligne
vide = pd.DataFrame(index=vf.index, columns=contenu, dtype=bool)
for c in contenu:
    vide[c] = vf[c].isna()
    if vf[c].dtype == object:
        vide[c] = vide[c] | (vf[c] == "") | (vf[c] == ".")
vf["taux_completude"] = (1 - vide.mean(axis=1)) * 100

# ----------------------------------------------------------- 4. Classification
def classe(x, nb_questions):
    if x >= 99.9:
        return "1 - COMPLETE (100 %)"
    if x >= 80:
        return "2 - Bien remplie (80-99 %)"
    if x >= 30:
        return "3 - Partielle (30-79 %)"
    if x > 0:
        return "4 - Peu remplie (1-29 %)"
    return "5 - VIDE (0 %)"

vf["classe_completude"] = vf["taux_completude"].map(
    lambda x: classe(x, len(contenu)))

# ------------------------------------------------------------------ 5. Recap
print("=== CLASSEMENT DES 1032 INTERVIEWS ===")
recap = vf["classe_completude"].value_counts().sort_index()
recap = recap.reindex([
    "1 - COMPLETE (100 %)", "2 - Bien remplie (80-99 %)",
    "3 - Partielle (30-79 %)", "4 - Peu remplie (1-29 %)",
    "5 - VIDE (0 %)"])
print(recap.to_string())
print(f"  TOTAL : {int(recap.sum())}")
print()

# --------------------------------------------- 6. Completude selon statut / A4
print("=== Completude moyenne selon le STATUT ===")
tab = vf.groupby("interview__status")["taux_completude"].agg(["count", "mean"])
for idx, row in tab.iterrows():
    print(f"  Statut {int(idx):3} | n={int(row['count']):4} | moyenne {row['mean']:6.1f} %")
print()

print("=== Completude moyenne selon le resultat d'appel (A4) ===")
lbl = meta.variable_value_labels.get("A4", {})
def nom_a4(v):
    if pd.isna(v):
        return "(A4 vide)"
    return lbl.get(v, f"A4={v}")
vf["a4_nom"] = vf["A4"].map(nom_a4)
tab = vf.groupby("a4_nom")["taux_completude"].agg(["count", "mean"])
for idx, row in tab.iterrows():
    print(f"  {idx:42} | n={int(row['count']):4} | moyenne {row['mean']:6.1f} %")
print()

# ------------------------------------------- 7. Exemples de chaque classe
print("=== EXEMPLES CONCRETS PAR CLASSE ===")
for cl in recap.index:
    g = vf[vf["classe_completude"] == cl]
    if len(g):
        ex = g.head(3)[["interview__key", "interview__status", "A4",
                        "consentement", "taux_completude"]]
        print(f"\n  [{cl}]  ({len(g)} interviews) - 3 exemples :")
        print("     " + ex.round(1).to_string(index=False).replace("\n", "\n     "))

# ------------------------------------------------------------ 8. Exportation
vf[["interview__key", "interview__status", "A4", "consentement",
    "taux_completude", "classe_completude"]].to_csv(
    "completude_par_interview.csv", index=False)
print("\nDetail exporte dans : completude_par_interview.csv")