# -*- coding: utf-8 -*-
"""
FILTRER LA BASE DES ENQUETES UTILISABLES
=========================================
Objectif : a partir de la base finale Terminees (1032 interviews), retirer
les interviews NON UTILISABLES pour l'analyse, c'est-a-dire celles dont le
resultat d'appel (question A4) indique que l'entretien n'a jamais eu lieu,
ainsi que les refus de consentement.

Les categories RETIREES (echecs d'appel + refus) :
    - A4 = 2  : Pas de reponse
    - A4 = 3  : Numero invalide ou incorrect
    - A4 = 4  : Ligne occupee
    - A4 = 5  : Rendez-vous fixe pour un rappel
    - A4 = 6  : Refus de participer
    - A4 = 7  : Appel interrompu en cours d'entretien
    - consentement = 0 : Refus du consentement

Ce qui RESTE = les interviews utilisables pour les analyses.

Fichier de sortie : Questionnaire_COSO_UTILISABLES.dta
"""
import pyreadstat
import pandas as pd

# ---------------------------------------------------------------- 1. Lecture
v5, meta = pyreadstat.read_dta("Questionnaire_COSO_VF.dta")
total = len(v5)
print(f"Base de depart (Terminees) : {total} interviews\n")

# ------------------------------------- 2. Definition des criteres d'exclusion
# Exception d'appel : l'entretien n'a pas eu lieu
echappel = v5["A4"].isin([2, 3, 4, 5, 6, 7])

# Refus du consentement (le menage a refuse de continuer)
refus_consent = v5["consentement"] == 0

# Une interview est a RETIRER si ELLE COCHE AU MOINS UN des deux criteres
exclure = echappel | refus_consent

nb_exclues = int(exclure.sum())
print(f"Interviews a RETIRER : {nb_exclues}")
print()

# -------------------------------------------- 3. Detail de ce qu'on retombe
tab_echappel = v5[echappel]["A4"].value_counts().to_dict()
print("Detail des interviews retirees :")
print("  - Pas de reponse           (A4=2) :", tab_echappel.get(2, 0))
print("  - Numero invalide          (A4=3) :", tab_echappel.get(3, 0))
print("  - Ligne occupee            (A4=4) :", tab_echappel.get(4, 0))
print("  - Rendez-vous fixe         (A4=5) :", tab_echappel.get(5, 0))
print("  - Refus de participer      (A4=6) :", tab_echappel.get(6, 0))
print("  - Raccroche / interrompu   (A4=7) :", tab_echappel.get(7, 0))
print("  - Refus du consentement              :", int(refus_consent.sum()))
print()

# ------------------------------------------------------------- 4. Base finale
kept = v5[~exclure].copy()
nb_kept = len(kept)
print(f"Interviews CONSERVEES (utilisables) : {nb_kept}")
print(f"  Soit {nb_kept} = {total} - {nb_exclues}")

labels = {"A4": meta.variable_value_labels.get("A4"),
          "interview__status": meta.variable_value_labels.get("interview__status")}
pyreadstat.write_dta(kept, "Questionnaire_COSO_UTILISABLES.dta",
                     variable_value_labels=labels)
print("\n  -> Questionnaire_COSO_UTILISABLES.dta cree")

# ----------------------------------------------------------- 5. Verification
s = kept["interview__status"].value_counts().to_dict()
print("\nRepartition par statut dans la base utilisable :")
for k in sorted(s, key=lambda x: -x):
    print(f"  - Statut {int(k)} : {s[k]}")