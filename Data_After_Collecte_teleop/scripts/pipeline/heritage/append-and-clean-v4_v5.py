#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 15 16:37:06 2026

@author: macbookair
"""

# ============================================================
# Complétion de la base V5 à partir de la base V4
#
# Objectif : V5 est la base de référence. Pour les ménages
# présents dans les deux fichiers, si une information manque
# dans V5, on la récupère depuis V4.
# ============================================================

# 1. Outils nécessaires
import pyreadstat      # pour lire/écrire les fichiers Stata (.dta)
import pandas as pd    # pour les tableaux de données

# 2. Lire les deux fichiers (avec leurs labels)
v4, meta_v4 = pyreadstat.read_dta("Questionnaire_COSO_V4.dta")
v5, meta_v5 = pyreadstat.read_dta("Questionnaire_COSO_V5.dta")

# 3. Créer une clé "ménage" (nom + téléphone + localité) harmonisée
v4["cle_menage"] = v4["nom"].str.strip().str.lower() + "_" + \
                   v4["telephone"].str.strip().str.lower() + "_" + \
                   v4["localite"].str.strip().str.lower()

v5["cle_menage"] = v5["nom"].str.strip().str.lower() + "_" + \
                   v5["telephone"].str.strip().str.lower() + "_" + \
                   v5["localite"].str.strip().str.lower()

menages_communs = set(v5["cle_menage"]) & set(v4["cle_menage"])


# 4. Fonction qui détecte une valeur "vide"
#    (NaN, ou chaîne vide, ou point) dans une colonne
def est_vide(serie):
    vide = serie.isna()            # valeurs manquantes classiques
    if serie.dtype == object:      # si colonne texte : "" et "." sont aussi vides
        vide = vide | (serie == "") | (serie == ".")
    return vide


# 5. Préparer un V4 "propre" : UNE ligne par ménage
#    S'il y a 2 lignes pour le même ménage (doublon interne),
#    on garde la plus complète.
v4_propre = v4.copy()
v4_propre["nb_rempli"] = v4_propre.notna().sum(axis=1)  # nb de cases remplies
v4_propre = v4_propre.sort_values("nb_rempli", ascending=False) \
                      .drop_duplicates("cle_menage", keep="first") \
                      .set_index("cle_menage")

# 6. Colonnes à imputer : colonnes communes SAUF les identifiants
#    techniques et les horodatages (chaque passage a les siens)
colonnes_exclues = {
    "cle_menage", "nb_rempli",
    "interview__key", "interview__id", "assignment__id",
    "ssys_irnd", "has__errors", "interview__status",
    "A2_date", "A2_heure", "A5_date", "A5_heure",
}
colonnes_exclues |= {c for c in v5.columns if c.startswith("HH")}  # blocs de durée

colonnes_a_imputer = [c for c in v5.columns
                      if c in v4_propre.columns and c not in colonnes_exclues]

# 7. L'imputation : V4 complète les cases vides de V5
#    IMPORTANT : on utilise l'INDEX de V5 (clé ménage) pour aligner les
#    valeurs de V4. Passer une Série à reindex() ne marche pas.
v5i = v5.set_index("cle_menage")       # V5 indexé par la clé ménage

bilan = {}
for col in colonnes_a_imputer:
    # valeurs V4 alignées sur l'index de V5 (les clés ménage)
    v4_alignees = v4_propre[col].reindex(v5i.index)

    # on impute si V5 est vide ET que V4 a une valeur
    a_imputer = est_vide(v5i[col]) & (~est_vide(v4_alignees))
    if a_imputer.any():
        v5i.loc[a_imputer, col] = v4_alignees[a_imputer]
        bilan[col] = int(a_imputer.sum())

# Récupérer V5 sans la colonne index (elle redevient normale puis on l'enlève)
v5 = v5i.reset_index(drop=True)

# 8. Bilan de l'imputation
total = sum(bilan.values())
print(f"Ménages présents dans V4 ET V5 : {len(menages_communs)}")
print(f"Cases vides de V5 complétées depuis V4 : {total}\n")
print("Colonnes les plus complétées :")
for col, nb in sorted(bilan.items(), key=lambda x: -x[1])[:15]:
    print(f"   {col:15} : {nb} valeurs")

# 9. Nettoyer : cle_menage est déjà partie avec reset_index(drop=True)
colonnes_aux = [c for c in ["nb_rempli"] if c in v5.columns]
v5 = v5.drop(columns=colonnes_aux)

# ============================================================
# 10. Complétion des variables de localisation depuis le COVER
#
# Le cover contient des infos préchargées à 100 % :
#   cover_district (ex : "SAVANES")  →  B1 (code district, ex : 111)
#   cover_region   (ex : "SAVANES")  →  B2 (code région, ex : 11103)
# On ne complète QUE les lignes où la variable questionnaire est vide.
# ============================================================

# --- Construire les mappings {nom_en_texte : code_numerique} ---
# B1 labels : {105: "DENGUELE", 111: "SAVANES", 113: "WOROBA", 114: "ZANZAN"}
# On inverse : {"SAVANES": 111, ...}
b1_labels = meta_v5.variable_value_labels.get("B1", {})
b2_labels = meta_v5.variable_value_labels.get("B2", {})
b1_map = {label.strip(): code for code, label in b1_labels.items()}
b2_map = {label.strip(): code for code, label in b2_labels.items()}

print("\n--- Imputation B1 (District) depuis cover_district ---")
avant_b1 = est_vide(v5["B1"]).sum()
if avant_b1 > 0:
    source = v5["cover_district"].astype(str).str.strip().str.upper()
    v5["B1"] = pd.to_numeric(v5["B1"], errors="coerce")
    masque = v5["B1"].isna() & source.notna() & (source != "")
    codes = source.map(b1_map)
    v5.loc[masque, "B1"] = codes[masque]
    apres_b1 = est_vide(v5["B1"]).sum()
    print(f"  Avant : {avant_b1} manquants → Après : {int(apres_b1)} manquants "
          f"({int(avant_b1 - apres_b1)} imputés)")
else:
    print("  Aucune valeur manquante, rien à imputer.")

print("\n--- Imputation B2 (Région) depuis cover_region ---")
avant_b2 = est_vide(v5["B2"]).sum()
if avant_b2 > 0:
    source = v5["cover_region"].astype(str).str.strip().str.upper()
    v5["B2"] = pd.to_numeric(v5["B2"], errors="coerce")
    masque = v5["B2"].isna() & source.notna() & (source != "")
    codes = source.map(b2_map)
    v5.loc[masque, "B2"] = codes[masque]
    apres_b2 = est_vide(v5["B2"]).sum()
    print(f"  Avant : {avant_b2} manquants → Après : {int(apres_b2)} manquants "
          f"({int(avant_b2 - apres_b2)} imputés)")
else:
    print("  Aucune valeur manquante, rien à imputer.")

print("\n--- Imputation B3 (Département) depuis B4 ---")
avant_b3 = est_vide(v5["B3"]).sum()
if avant_b3 > 0:
    v5["B4"] = pd.to_numeric(v5["B4"], errors="coerce")
    v5["B3"] = pd.to_numeric(v5["B3"], errors="coerce")
    masque = v5["B3"].isna() & v5["B4"].notna()
    # Le département = les 6 premiers chiffres du code B4
    codes_b3 = v5.loc[masque, "B4"].apply(
        lambda x: int(str(int(x))[:6]) if pd.notna(x) and len(str(int(x))) >= 6 else None
    )
    v5.loc[masque, "B3"] = codes_b3
    apres_b3 = est_vide(v5["B3"]).sum()
    print(f"  Avant : {avant_b3} manquants → Après : {int(apres_b3)} manquants "
          f"({int(avant_b3 - apres_b3)} imputés)")
else:
    print("  Aucune valeur manquante, rien à imputer.")

# 11. Correction technique : les colonnes de codes (nombres) doivent
#     être de type "nombre" pour pouvoir être écrites
for col in v5.columns:
    if v5[col].dtype == object:
        valeurs = v5[col].dropna()
        if len(valeurs) > 0 and all(isinstance(v, (int, float)) for v in valeurs):
            v5[col] = v5[col].astype(float)

# 12. Labels de catégories : ceux de V5, + ceux de V4 si manquants
labels = meta_v5.variable_value_labels.copy()
for nom, dico in meta_v4.variable_value_labels.items():
    if nom not in labels:
        labels[nom] = dico

# 13. Sauvegarder la base finalisée
pyreadstat.write_dta(
    v5,
    "Questionnaire_COSO_VF.dta",
    column_labels=meta_v5.column_labels,
    variable_value_labels=labels,
)

print("\nFichier créé : Questionnaire_COSO_VF.dta")

vf, meta_vf = pyreadstat.read_dta("Questionnaire_COSO_VF.dta")