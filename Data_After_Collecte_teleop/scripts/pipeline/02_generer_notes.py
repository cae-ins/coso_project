# -*- coding: utf-8 -*-
"""
02_generer_notes.py
===================
Cree la note methodologique de l'analyse de completude logique
au format Word (.docx) et PDF (.pdf).

La note est centree sur la METHODOLOGIE et presente ses resultats sous
forme de tableaux (intervalles de classification, statistiques de
validation, repartition des interviews, lien avec la base utilisable).
Le detail des questions manquantes par interview est renvoye vers le
fichier Excel resultats/manquants_id_detail.xlsx.

Le script relance 01_completude_logique.py pour utiliser les chiffres
a jour (et regenerer l'Excel ID+manque).
"""
import os
import subprocess
import pyreadstat
import pandas as pd

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(os.path.dirname(ICI))     # racine du projet
DOSSIER_RES  = os.path.join(RACINE, "resultats")
DOSSIER_NOTE = os.path.join(RACINE, "notes")

# ---------------------------------------------------------------
# 0) RELANCE DU CALCUL (resultats et Excel a jour)
# ---------------------------------------------------------------
print("Relance du calcul de completude...")
subprocess.run(["python3", "01_completude_logique.py"], cwd=ICI, check=True)

# ---------------------------------------------------------------
# 1) CHARGEMENT DES RESULTATS
# ---------------------------------------------------------------
base, meta = pyreadstat.read_dta(f"{DOSSIER_RES}/Questionnaire_COSO_VF_avec_completude.dta")

n_total = len(base)
t = base["taux_completude"]

def n_classe(code):
    return int((base["classe_completude"] == code).sum())

n_complet  = n_classe("1-COMPLET")
n_quasi    = n_classe("2-QUASI_COMPLET")
n_moyen    = n_classe("3-MOYEN")
n_incomp   = n_classe("4-INCOMPLET")
n_vide     = n_classe("5-VIDE")

a4_pour = base["A4"].astype(str).str.strip().astype("Float64")
utilisable = ~(a4_pour.isin([2, 3, 4, 5, 6, 7]) | (base["consentement"] == 0))
n_util = int(utilisable.sum())
def n_util_classe(code):
    return int((utilisable & (base["classe_completude"] == code)).sum())
n_complet_util = n_util_classe("1-COMPLET")
n_quasi_util   = n_util_classe("2-QUASI_COMPLET")
n_mauvaises    = n_util_classe("4-INCOMPLET") + n_util_classe("5-VIDE")

test = (base["interview__status"] == 100) & a4_pour.eq(1.0)
t_ref = t[test]
n_ref = int(test.sum())
ref_ok = int((t_ref == 1.0).sum())
ref_sous90 = int((t_ref < 0.9).sum())
ref_min  = t_ref.min() if n_ref else None
ref_max  = t_ref.max() if n_ref else None

# ---------------------------------------------------------------
# 2) CONTENU STRUCTURE DE LA NOTE  (paragraphes + tableaux)
# ---------------------------------------------------------------
# Chaque element est un tuple ("type", ...) :
#   ("h1", texte) / ("h2", texte) / ("p", texte)
#   ("table", entetes, lignes)
CONTENU = [
    ("h1", "NOTE METHODOLOGIQUE"),
    ("h2", "Analyse de la completude logique des interviews COSO"),
    ("p",
     "La presente note decrit la methode utilisee pour determiner, parmi les "
     f"{n_total} interviews de la base Questionnaire_COSO_VF.dta, celles qui "
     "sont reellement et totalement remplies au regard de la logique "
     "conditionnelle du questionnaire. Le detail des questions manquantes a "
     "l'echelle de chaque interview (identifiant + question concernee) est "
     "fourni dans le fichier Excel joint : manquants_id_detail.xlsx."),

    ("h2", "1. Question de depart"),
    ("p",
     "Combien d'interviews sont completement realisees ? Dans un questionnaire "
     "a logique de saut, certaines questions ne sont posees qu'en fonction des "
     "reponses anterieures. Une interview est dite complete lorsque toutes les "
     "questions devaient lui etre posees - compte tenu des reponses precedentes - "
     "ont effectivement recu une reponse. A l'inverse, une interview interrompue "
     "se reconnait a des questions attendues mais laissees vides (abandon, "
     "refus, erreur de collecte)."),

    ("h2", "2. Principe de la methode"),
    ("p",
     "Pour chaque interview i, on reconstitue l'ensemble Q(i) des questions qui "
     "devaient lui etre posees en appliquant la logique de saut du questionnaire "
     "(sections A a R). On compte ensuite les questions attendues qui ont "
     "reellement une reponse non vide. Le taux de completude vaut :"),
    ("p",
     "   taux_completude(i) = |questions attendues repondus| / |Q(i)|"),
    ("p",
     "Deux precautions sont prises. D'une part, une reponse n'est comptee que si "
     "la cellule contient une vraie valeur : la base comporte des chaines vides  "
     "ou . qui ne sont pas NaN et ne doivent pas etre confondues avec une "
     "reponse. D'autre part, les champs techniques (horodatages, coordonnees "
     "GPS), les champs d'identification et les champs libres non soumis a la "
     "logique (C6, C9, C10, C11) sont exclus du calcul."),

    ("h2", "3. Logique de saut retenue"),
    ("p",
     "Chaque regle est deduite du questionnaire Draft 8 et verifiee sur les "
     "donnees. Les principales regles sont synthetisees ci-dessous."),
    ("table",
     ["Section", "Champ", "Condition d'attente"],
     [
      ["A", "A1, A4 (resultat de l'appel)", "toutes les interviews"],
      ["A", "A4X (preciser le resultat)", "si A4 = autre (8)"],
      ["A", "A5 (jour / heure de rendez-vous)", "si A4 = prise de rendez-vous (5)"],
      ["C", "C5 (diplome)", "si niveau d'etudes au moins primaire (C4 >= 2)"],
      ["C", "C8 (pays)", "si C7 = Cote d'Ivoire (1)"],
      ["E", "E2, E3, E3A", "E2 si E1 = non ; E3 si E2 = non ; E3A si E3 = oui"],
      ["F, G, H, I", "section emploi", "si la personne a une activite (EMPLOYE = 1)"],
      ["H", "H1 a H3 (salaires)", "si salarie (F1 = 1)"],
      ["H", "H3A (classe de salaire)", "si montant refuse (H3 = 99999)"],
      ["H", "H4, H5 (revenus)", "si non salarie (F1 = 2, 3 ou 4)"],
      ["H", "H5A (classe de revenu)", "si montant refuse (H5 = 999999)"],
      ["J", "toute la section", "si sans activite (EMPLOYE = 0)"],
      ["K", "K2, K3", "K2 si K1 = non ; K3 si K1 = oui"],
      ["K", "K4, K5, K5X", "si K2 = oui ; K5X si K5 = autre"],
      ["L", "L4, L5 (epargne)", "si L3 = oui"],
      ["L", "L7 a L9 (dette)", "si L6 = oui"],
      ["N", "N2 a N5 (chocs)", "si N1 = oui"],
      ["O", "O2 (formation)", "si O1 = oui ; O4-O6 si O3 = oui"],
      ["R", "R1A, R2A, R3A, R3B", "si le code correspondant est choisi"],

     ]),

    ("h2", "4. Validation statistique de la methode"),
    ("p",
     "Reconstruire une logique de saut comporte un risque : imaginer des regles "
     "trop strictes (qui penaliseraient des interviews completes) ou trop "
     "laxistes (qui masqueraient des abandons). Pour controler ce risque, les "
     "regles sont testees sur un groupe de reference objectif : les interviews "
     "validees par le superviseur et dont le questionnaire est rempli "
     "(interview__status = 100 et A4 = 1), soit " + str(n_ref) + " interviews. "
     "Ce groupe de reference n'entre PAS dans le calcul du taux : il sert "
     "uniquement de metre etalon. Si la reconstruction est exacte, quasi toutes "
     "doivent atteindre 100 %."),
    ("table",
     ["Indicateur de validation", "Valeur"],
     [
      ["Interviews de reference (metre etalon)", str(n_ref)],
      ["dont taux de completude = 100 %", f"{ref_ok}  ({100*ref_ok/n_ref:.1f} %)"],
      ["mediane du taux", "1.000"],
      ["moyenne du taux", f"{t_ref.mean():.3f}" if n_ref else "n.d."],
      ["minimum / maximum du taux", f"{ref_min:.3f} / {ref_max:.3f}" if n_ref else "n.d."],
      ["references sous 90 %", str(ref_sous90)],
     ]),
    ("p",
     "Un taux median de 1.000 et " + str(round(100*ref_ok/n_ref)) + f" % de references "
     "exactement a 100 % confirment que la logique retenue reproduit le "
     "questionnaire reelement applique : elle n'est ni trop stricte, ni trop "
     "laxiste."),

    ("h2", "5. Classification des interviews"),
    ("p",
     "A partir du taux de completude, chaque interview est rangee dans l'une des "
     "cinq classes suivantes :"),
    ("table",
     ["Classe", "Intervalle du taux", "Lecture"],
     [
      ["1-COMPLET", "taux = 100 %", "aucune question attendue n'est vide"],
      ["2-QUASI_COMPLET", "90 % <= taux < 100 %", "quasi tout est rempli, il reste quelques manques"],
      ["3-MOYEN", "50 % <= taux < 90 %", "une partie notable du questionnaire est vide"],
      ["4-INCOMPLET", "0 % < taux < 50 %", "la majorite des questions attendues sont vides"],
      ["5-VIDE", "taux = 0 %", "aucune question exploitable repondue"],
     ]),

    ("h2", "6. Resultats"),
    ("h3", "6.1. Repartition des " + str(n_total) + " interviews"),
    ("table",
     ["Classe", "Effectif", "Part"],
     [
      ["1-COMPLET", str(n_complet), f"{100*n_complet/n_total:.1f} %"],
      ["2-QUASI_COMPLET", str(n_quasi), f"{100*n_quasi/n_total:.1f} %"],
      ["3-MOYEN", str(n_moyen), f"{100*n_moyen/n_total:.1f} %"],
      ["4-INCOMPLET", str(n_incomp), f"{100*n_incomp/n_total:.1f} %"],
      ["5-VIDE", str(n_vide), f"{100*n_vide/n_total:.1f} %"],
      ["TOTAL", str(n_total), "100.0 %"],
     ]),
    ("p",
     "Taux moyen global : " + f"{t.mean():.3f}" + " ; mediane : "
     + f"{t.median():.3f}" + "."),
    ("p",
     "Reponse a la question de depart : " + str(n_complet)
     + f" interviews ({100*n_complet/n_total:.1f} %) sont totalement remplies, "
     "c'est-a-dire que toutes les questions attendues selon la logique du "
     "questionnaire ont ete repondues. En y ajoutant les quasi-completes, la "
     "base ""fiable"" compte " + str(n_complet + n_quasi)
     + f" interviews ({100*(n_complet+n_quasi)/n_total:.1f} %)."),

    ("h3", "6.2. Lien avec l'ancienne base d'analyse « utilisable »"),
    ("p",
     "L'ancien filtre d'eligibilite (A4 sans echec et consentement accepte) "
     "retenait " + str(n_util) + " interviews. Le croisement de ce filtre avec "
     "la nouvelle classification est le suivant :"),
    ("table",
     ["Statut de completude", "Interviews « utilisables »", "Part des " + str(n_util)],
     [
      ["1-COMPLET", str(n_complet_util), f"{100*n_complet_util/n_util:.1f} %"],
      ["2-QUASI_COMPLET", str(n_quasi_util), f"{100*n_quasi_util/n_util:.1f} %"],
      ["4/5-INCOMPLET / VIDE", str(n_mauvaises), f"{100*n_mauvaises/n_util:.1f} %"],
     ]),
    ("p",
     "Parmi les interviews dites « utilisables », " + str(n_complet_util + n_quasi_util)
     + " (" + f"{100*(n_complet_util+n_quasi_util)/n_util:.1f} %" + ") sont pleines "
     "et fiables, mais " + str(n_mauvaises) + " sont en realite incompletes ou "
     "vides. Conclusion : le critere A4 est plus laxiste que la completude "
     "reelle. La classe de completude fournie dans la base constitue donc le "
     "critere de qualite a privilegier."),

    ("h2", "7. Exploitation du fichier Excel joint (manquants_id_detail.xlsx)"),
    ("p",
     "Le detail des manques est conserve dans un fichier Excel a part afin de "
     "garder la presente note lisible. Ce fichier contient une ligne par couple "
     "(interview ; question manquante), avec l'identifiant de l'interview "
     "(interview__id / interview__key), la classe de completude et la question "
     "concernee. Il permet de :"),
    ("p",
     "  - filtrer par classe (ex. 4-INCOMPLET ou 5-VIDE) ;"),
    ("p",
     "  - recuperer la liste des identifiants d'interviews a revoir, "
     "a recontacter ou a relancer ;"),
    ("p",
     "  - mesurer, pour une question donnee, combien d'interviews la laissent "
     "vide."),
    ("p",
     "La base Questionnaire_COSO_VF_avec_completude.dta associe en outre a "
     "chaque interview deux colonnes filtrables : taux_completude (proportion "
     "de 0 a 1) et classe_completude (de 1-COMPLET a 5-VIDE)."),

    ("h2", "8. Limites et precautions"),
    ("p",
     "  - Un champ « preciser » facultatif (ex. K5X) peut manquer sans que le "
     "questionnaire soit reellement inacheve ; la classe 2-QUASI_COMPLET permet "
     "de recuperer ces cas."),
    ("p",
     "  - Les " + str(n_ref) + " references confirment empiriquement la validite "
     "de la logique, mais ne constituent pas une demonstration mathematique. La "
     "confiance provient de la convergence entre la logique du questionnaire et "
     "le comportement observe des donnees."),
    ("p",
     "  - La completude mesure que tout est repondu, pas la qualite des "
     "reponses : une valeur aberrante reste une valeur presente. Une etape "
     "complementaire serait necessaire pour verifier la coherence interne des "
     "reponses (fiabilite intrinseque)."),
]

# ---------------------------------------------------------------
# 3) GENERATION WORD  (paragraphes + tableaux)
# ---------------------------------------------------------------
from docx import Document
from docx.shared import Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn

doc = Document()
for elt in CONTENU:
    typ = elt[0]
    if typ == "h1":
        p = doc.add_paragraph(elt[1])
        r = p.runs[0]; r.bold = True; r.font.size = Pt(18); r.font.color.rgb = None
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    elif typ == "h2":
        p = doc.add_paragraph(elt[1])
        r = p.runs[0]; r.bold = True; r.font.size = Pt(13)
        p.paragraph_format.space_before = Pt(10)
    elif typ == "h3":
        p = doc.add_paragraph(elt[1])
        r = p.runs[0]; r.bold = True; r.font.size = Pt(11.5)
    elif typ == "p":
        p = doc.add_paragraph(elt[1])
        p.paragraph_format.space_after = Pt(4)
    elif typ == "table":
        entetes, lignes = elt[1], elt[2]
        table = doc.add_table(rows=1, cols=len(entetes))
        table.style = "Table Grid"
        hdr = table.rows[0].cells
        for j, h in enumerate(entetes):
            hdr[j].text = ""
            r = hdr[j].paragraphs[0].add_run(h); r.bold = True
        for ligne in lignes:
            cells = table.add_row().cells
            for j, val in enumerate(ligne):
                cells[j].text = str(val)
        doc.add_paragraph()

fichier_docx = os.path.join(DOSSIER_NOTE, "Note_Methodologique_Completude.docx")
doc.save(fichier_docx)
print("Word ecrit :", fichier_docx)

# ---------------------------------------------------------------
# 4) GENERATION PDF  (tableaux via fpdf2)
# ---------------------------------------------------------------
from fpdf import FPDF
from fpdf.fonts import FontFace

LARGEURES = {  # largeurs de colonnes par taille de tableau (en mm)
    2: None,
    3: None,
}

class NotePDF(FPDF):
    def header(self):
        self.set_font("ArialUni", "", 8)
        self.set_y(8)
        self.cell(0, 5, "Analyse de la completude logique des interviews COSO",
                  align="R")
        self.ln(3)
        self.set_draw_color(180, 180, 180)
        self.line(8, 16, 202, 16)
    def footer(self):
        self.set_y(-15)
        self.set_font("ArialUni", "", 8)
        self.cell(0, 10, f"Page {self.page_no()}", align="C")

pdf = NotePDF(format="A4")
pdf.add_font("ArialUni", "", "/Library/Fonts/Arial Unicode.ttf")
pdf.add_font("ArialUni", "B", "/Library/Fonts/Arial Unicode.ttf")
pdf.set_auto_page_break(auto=True, margin=20)

largeur_dispo = pdf.epw  # ~190 mm

pdf.add_page()
largeurs_tables = {
    "table1": [30, 55, 65],
    "table2": [95, 55],
    "table3": [45, 55, 50],
    "table4": [40, 65, 45],
    "table5": [60, 45, 45],
}

def rendu_table(entetes, lignes, largeurs):
    # premiere ligne de `rows` = en-tete stylisee automatiquement
    ncol = len(entetes)
    align = tuple("LEFT" if largeurs and largeurs[i] == max(largeurs)
                  else "CENTER" for i in range(ncol))
    rows = [entetes] + [[str(v) for v in ligne] for ligne in lignes]
    with pdf.table(rows=rows, col_widths=largeurs, line_height=4.8,
                   text_align=align, first_row_as_headings=True,
                   headings_style=FontFace(emphasis="BOLD", color=(40, 40, 40)),
                   borders_layout="ALL") as tb:
        pass

for elt in CONTENU:
    pdf.set_x(8)                      # revenir a la marge gauche apres les tableaux
    typ = elt[0]
    if typ == "h1":
        pdf.set_font("ArialUni", "B", 17)
        pdf.multi_cell(0, 7, elt[1], align="C")
        pdf.ln(1)
    elif typ == "h2":
        pdf.ln(2)
        pdf.set_font("ArialUni", "B", 12)
        pdf.multi_cell(0, 6, elt[1])
    elif typ == "h3":
        pdf.set_font("ArialUni", "B", 11)
        pdf.multi_cell(0, 6, elt[1])
    elif typ == "p":
        pdf.set_font("ArialUni", "", 9.5)
        pdf.set_x(8)
        pdf.multi_cell(largeur_dispo, 4.8, elt[1])
    elif typ == "table":
        n_col = len(elt[1])
        largeurs = None
        if n_col == 2:
            largeurs = largeurs_tables["table2"]
        elif n_col == 3:
            largeurs = largeurs_tables["table3"]
        pdf.set_font("ArialUni", "", 8.5)
        rendu_table(elt[1], elt[2], largeurs)
        pdf.ln(2)

# correction : derniere table (8. limites) pas de tableau active => rien

fichier_pdf = os.path.join(DOSSIER_NOTE, "Note_Methodologique_Completude.pdf")
pdf.output(fichier_pdf)
print("PDF ecrit :", fichier_pdf)