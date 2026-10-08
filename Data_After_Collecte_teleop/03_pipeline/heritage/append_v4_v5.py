# ============================================================
# Fusion des bases Questionnaire_COSO_V4.dta et V5.dta
# ============================================================

# 1. Outils nécessaires
import pyreadstat      # pour lire/écrire les fichiers Stata (.dta)
import pandas as pd    # pour les tableaux de données

# 2. Lire les deux fichiers (avec leurs labels)
v4, meta_v4 = pyreadstat.read_dta("Questionnaire_COSO_V4.dta")
v5, meta_v5 = pyreadstat.read_dta("Questionnaire_COSO_V5.dta")

# 3. V4 n'a pas toutes les colonnes de V5 -> on les ajoute (vides)
colonnes_a_ajouter = [col for col in v5.columns if col not in v4.columns]
for col in colonnes_a_ajouter:
    v4[col] = None

# 4. Remettre les colonnes de V4 dans le même ordre que V5
v4 = v4[v5.columns]

# 5. Empiler : V5 d'abord, puis V4 en dessous
resultat = pd.concat([v5, v4])

# 6. Correction technique nécessaire pour l'écriture .dta :
#    les colonnes de codes (nombres) doivent être de type "nombre"
for col in resultat.columns:
    if resultat[col].dtype == object:
        valeurs = resultat[col].dropna()
        if len(valeurs) > 0 and all(isinstance(v, (int, float)) for v in valeurs):
            resultat[col] = resultat[col].astype(float)

# 7. Labels de catégories : on garde ceux de V5, + ceux de V4 si manquants
labels = meta_v5.variable_value_labels.copy()
for nom, dico in meta_v4.variable_value_labels.items():
    if nom not in labels:
        labels[nom] = dico

# 8. Créer le fichier final
pyreadstat.write_dta(
    resultat,
    "Questionnaire_COSO_VF.dta",
    column_labels=meta_v5.column_labels,          # libellés des colonnes
    variable_value_labels=labels,                 # libellés des réponses
)

print("Terminé !")
print(f"Lignes V5   : {len(v5)}")
print(f"Lignes V4   : {len(v4)}")
print(f"Total       : {len(resultat)}")
print(f"Fichier créé : Questionnaire_COSO_VF.dta")