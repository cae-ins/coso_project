# -*- coding: utf-8 -*-
"""Génère la note d'analyse en Word (.docx)"""
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

doc = Document()

# Styles de base
style = doc.styles["Normal"]
style.font.name = "Calibri"
style.font.size = Pt(11)

BLEU = RGBColor(0x1F, 0x4E, 0x79)

# ---------------------------------------------------------------- Titre
t = doc.add_heading("Note d'analyse - Base COSO (collecte téléphonique)", level=0)
t.alignment = WD_ALIGN_PARAGRAPH.CENTER
doc.add_paragraph(
    "Traitement des bases de données du questionnaire COSO "
    "| Statut des 65 et 60 considérés comme enquêtes terminées"
).alignment = WD_ALIGN_PARAGRAPH.CENTER

# ---------------------------------------------------------------- 1. Contexte
doc.add_heading("1. Contexte et sources des données", level=1)
doc.add_paragraph(
    "Deux bases de collecte téléphonique du questionnaire COSO ont été "
    "fusionnées et nettoyées :"
)
tab = doc.add_table(rows=4, cols=4)
tab.style = "Light Grid Accent 1"
hdr = tab.rows[0].cells
for i, h in enumerate(["Base", "Lignes", "Colonnes", "Remarque"]):
    hdr[i].text = h
for i, r in enumerate([
    ["V4", "284", "214", "Plus ancienne, sans cover_id, D5__11, R6, R7"],
    ["V5", "1032", "218", "Base de référence (pas de doublons)"],
    ["Finale (VF)", "1032", "218", "V5 enrichie par V4"],
]):
    for j, v in enumerate(r):
        tab.rows[i + 1].cells[j].text = v

doc.add_paragraph("")
doc.add_paragraph(
    "Les 282 ménages distincts de la base V4 sont tous retrouvés dans V5 "
    "(0 nouveau ménage) : un simple concaténation aurait créé des doublons. "
    "La base V5 sert donc de référence et V4 ne sert qu'à remplir les cases "
    "vides. Au total, 2921 cellules manquantes ont été imputées depuis V4 et "
    "les zones géographiques B1 (district) et B2 (région) ont été complétées "
    "depuis le fichier cover (239 et 240 valeurs manquantes ramenées à 0)."
)

# ---------------------------------------------------------------- 2. Hypothèse
doc.add_heading("2. Hypothèse de travail", level=1)
doc.add_paragraph(
    "Les statuts issus du serveur de collecte (SuSo) sont les suivants :"
)
tab = doc.add_table(rows=4, cols=3)
tab.style = "Light Grid Accent 1"
for i, h in enumerate(["Statut", "Signification", "Effectif"]):
    tab.rows[0].cells[i].text = h
for i, r in enumerate([
    ["100", "Completed - enquête validée et terminée", "524"],
    ["65", "Rejected - enquête terminée mais à corriger", "362"],
    ["60", "Assigned - interview assignée à un enquêteur", "146"],
]):
    for j, v in enumerate(r):
        tab.rows[i + 1].cells[j].text = v

p = doc.add_paragraph(
    "\nHypothèse retenue : les statuts 65 et 60 sont considérés comme des "
    "enquêtes TERMINÉES (le questionnaire a été administré). "
)
p.add_run("Ainsi, sur les 1032 interviews de la base finale, 1032 (100 %) "
          "sont considérées comme terminées.").bold = True
doc.add_paragraph(
    "Deux catégories sont distinguées pour le suivi : "
    "'Enquête terminée' (statut 100, n=524) et 'Non terminée "
    "(assignée/rejetée)' (statuts 60 et 65, n=508)."
)

# ---------------------------------------------------------------- 3. Appels
doc.add_heading("3. Résultat des appels (question A4)", level=1)
doc.add_paragraph(
    "La question A4 enregistre l'issue de chaque appel téléphonique. "
    "Cette information permet de qualifier les interviews et de mesurer "
    "le taux de réalisation de la collecte. Répartition des 1032 interviews :"
)
tab = doc.add_table(rows=9, cols=3)
tab.style = "Light Grid Accent 1"
for i, h in enumerate(["Code", "Intitulé", "Effectif"]):
    tab.rows[0].cells[i].text = h
distribution = [
    ("1",  "Entretien réalisé (questionnaire rempli)", "662"),
    ("2",  "Pas de réponse", "64"),
    ("3",  "Numéro invalide ou incorrect", "53"),
    ("4",  "Ligne occupée", "48"),
    ("5",  "Rendez-vous fixé pour un rappel", "3"),
    ("6",  "Refus de participer", "7"),
    ("7",  "Appel interrompu en cours d'entretien", "0"),
    ("8",  "Autre (à préciser)", "130"),
]
for i, r in enumerate(distribution, start=1):
    for j, v in enumerate(r):
        tab.rows[i].cells[j].text = v
doc.add_paragraph(
    "\nNB : 65 interviews n'ont pas de résultat d'appel renseigné. "
    "Une interview peut être considérée 'terminée' (statut 100/65/60) même "
    "si le résultat d'appel A4 indique un échec : la comptabilité dépend de "
    "la question posée à l'enquêteur."
)

# ---------------------------------------------------------------- 4. Remplissage
doc.add_heading("4. Taux de remplissage du questionnaire", level=1)
doc.add_paragraph(
    "Pour savoir si une interview peut alimenter les analyses, on mesure "
    "la proportion de cellules renseignées sur 170 colonnes de contenu "
    "du questionnaire (hors identifiants techniques et variables cover)."
)
tab = doc.add_table(rows=8, cols=3)
tab.style = "Light Grid Accent 1"
for i, h in enumerate(["Groupe", "Effectif", "Taux de remplissage"]):
    tab.rows[0].cells[i].text = h
remp = [
    ("Ensemble des 1032 interviews", "1032", "45,5 %"),
    ("Statut 100 - Completed", "524", "55,8 %"),
    ("Statut 65 - Rejetée", "362", "45,1 %"),
    ("Statut 60 - Assignée", "146", "9,8 %"),
    ("A4 = 1 (entretien réalisé)", "662", "62,6 %"),
    ("A4 = 2 (pas de réponse)", "64", "13,9 %"),
    ("A4 = 8 (autre)", "130", "19,5 %"),
]
for i, r in enumerate(remp, start=1):
    for j, v in enumerate(r):
        tab.rows[i].cells[j].text = v

doc.add_paragraph("")
p = doc.add_paragraph(
    "\nInterprétation : toutes les interviews sont considérées terminées, "
    "mais leur remplissage effectif varie fortement. "
)
p.add_run("Les interviews de statut 60 (assignées, n=146) ne sont remplies "
          "qu'à 9,8 % : elles comptent dans les 'terminées' mais contiennent "
          "peu de données exploitables.").bold = True
doc.add_paragraph(
    "En pratique, seules les interviews avec un taux de remplissage élevé "
    "("
    "statuts 100 et 65, ou A4 = 1) peuvent être utilisées pour des analyses "
    "statistiques de fond. Les autres lignes servent au calcul du taux de "
    "réalisation et à la cartographie des échecs de collecte."
)

# ---------------------------------------------------------------- 5. Conclusion
doc.add_heading("5. Conclusion et fichiers produits", level=1)
doc.add_paragraph(
    "Sous l'hypothèse retenue, la base exploitable contient 1032 interviews "
    "considérées comme terminées (100 % de la base finale), toutes "
    "exportées dans un fichier dédié à l'analyse. Les deux catégories de "
    "suivi ('Enquête terminée' et 'Non terminée - assignée/rejetée') sont "
    "conservées via la colonne categorie_statut."
)
tab = doc.add_table(rows=4, cols=2)
tab.style = "Light Grid Accent 1"
hdr = tab.rows[0].cells
hdr[0].text = "Fichier"
hdr[1].text = "Contenu"
for i, r in enumerate([
    ["Questionnaire_COSO_TERMINES.dta", "Base des interviews terminées (1032 lignes), prête pour l'analyse"],
    ["Questionnaire_COSO_VF_avec_statut.dta", "Base complète avec les colonnes categorie_statut et est_terminee"],
    ["RAPPORT_TRAITEMENT_BASE_COSO.txt", "Rapport détaillé du traitement (fusion V4/V5, imputations)"],
], start=1):
    for j, v in enumerate(r):
        tab.rows[i].cells[j].text = v

doc.save("Note_Analyse_COSO.docx")
print("Note Word générée : Note_Analyse_COSO.docx")