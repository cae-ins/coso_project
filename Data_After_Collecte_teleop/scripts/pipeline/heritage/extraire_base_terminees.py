# -*- coding: utf-8 -*-
"""
EXTRAIRE LA BASE DES ENQUETES TERMINEES
========================================
Ce script lit la base finale 'Questionnaire_COSO_VF.dta' et en extrait la base
des enquetes TERMINEES, selon l'hypothese de travail retenue :

    HYPOTHESE :
    -----------
    Les interviews dont le statut est 100 (Completed), 65 (Rejected by
    supervisor) et 60 (Interviewer assigned) sont TOUTES considerees comme
    des enquetes TERMINEES (le questionnaire a ete administre).

    Deux categories sont distinguees dans la base :
      - "Enquete terminee"                 : statut 100
      - "Non terminee (assignee/rejetee)"  : statut 60 ou 65

Fichier de sortie : Questionnaire_COSO_TERMINES.dta
"""
import pyreadstat

# ---------------------------------------------------------------- 1. Lecture
fichier = "Questionnaire_COSO_VF.dta"
v5, meta = pyreadstat.read_dta(fichier)
print(f"Base source : {fichier}")
print(f"  -> {v5.shape[0]} interviews x {v5.shape[1]} colonnes\n")

# ------------------------------------------- 2. Definitions des statuts 60/65/100
#  100 = Completed            : enquete validee et terminee
#   65 = RejectedBySupervisor : terminee mais a corriger
#   60 = InterviewerAssigned  : assignee (debut/terminaison en teleop)
STATUTS_TERMINES = [100, 65, 60]

# ---------------------------------------------------------- 3. Categorie de statut
# On cree une colonne lisible qui distingue les deux groupes dont on parlait.
def categorie_de_statut(s):
    if s == 100:
        return "Enquete terminee"
    if s in (65, 60):
        return "Non terminee (assignee/rejetee)"
    return "Autre"

v5["categorie_statut"] = v5["interview__status"].map(categorie_de_statut)

# -- Colonne binaire : enquete consideree terminee au titre de l'hypothese
v5["est_terminee"] = v5["interview__status"].isin(STATUTS_TERMINES).astype(int)

# ---------------------------------------------------------------------- 4. Recap
print("=== Repartition des statuts ===")
print(v5["interview__status"].value_counts().sort_index().to_string())
print()
print("=== Categories (hypothese 60 et 65 = terminees) ===")
recap = v5.groupby("categorie_statut").agg(
    nb_interviews=("interview__key", "count"),
    dont_terminees=("est_terminee", "sum"),
)
print(recap.to_string())
print()
total = len(v5)
terminees = int(v5["est_terminee"].sum())
print(f"TOTAL : {terminees} / {total} interviews considerees comme TERMINEES")
print(f"      ({terminees / total * 100:.1f} %)")

# ---------------------------------------------------------------------- 5. Sortie
# On garde la base entiere (toutes les interviews) et on ajoute la colonne
# 'categorie_statut'. Ce sont celles avec est_terminee == 1 qui forment la
# base des enquetes terminees.
from pandas.api.types import is_datetime64_any_dtype

seuil = v5["est_terminee"] == 1
print(f"\nExtraction de la base des TERMINEES : {seuil.sum()} interviews...")

# Sauvegarde 1 : la base entiere avec les categories (pour suivi)
labels = {"A4": meta.variable_value_labels.get("A4"),
          "interview__status": meta.variable_value_labels.get("interview__status")}
pyreadstat.write_dta(v5, "Questionnaire_COSO_VF_avec_statut.dta",
                     variable_value_labels=labels)
print("  -> Questionnaire_COSO_VF_avec_statut.dta  (base complete + colonnes de statut)")

# Sauvegarde 2 : les SEULES enquetes terminees -> base d'analyse
filtrees = v5[seuil].copy()
pyreadstat.write_dta(filtrees, "Questionnaire_COSO_TERMINES.dta",
                     variable_value_labels=labels)
print(f"  -> Questionnaire_COSO_TERMINES.dta         ({len(filtrees)} interviews)")

print("\nTermine.")