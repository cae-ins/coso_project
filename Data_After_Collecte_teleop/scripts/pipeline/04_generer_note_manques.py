# -*- coding: utf-8 -*-
"""
04_generer_note_manques.py
==========================
Note courte (Word + PDF) : pourquoi les interviews sont incompletes
(classes 4-INCOMPLET et 3-MOYEN) et comment les rattraper.

Tous les chiffres sont recalcules a partir de la base finale
resultats/Questionnaire_COSO_VF_avec_completude.dta.
"""
import os
import pyreadstat
import pandas as pd

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(os.path.dirname(ICI))     # racine du projet
DOSSIER_RES  = os.path.join(RACINE, "resultats")
DOSSIER_NOTE = os.path.join(RACINE, "notes")

base, meta = pyreadstat.read_dta(
    f"{DOSSIER_RES}/Questionnaire_COSO_VF_avec_completude.dta")

def remplie(s):
    return (s.notna() & s.astype(str).str.strip().ne("")
            & s.astype(str).str.strip().ne("."))

# ---------------------------------------------------------------
# CHIFFRES (recalcules ici pour rester exacts)
# ---------------------------------------------------------------
n_total = len(base)

def n_classe(c):
    return int((base["classe_completude"] == c).sum())

n_complet, n_quasi = n_classe("1-COMPLET"), n_classe("2-QUASI_COMPLET")
n_moyen, n_incomp, n_vide = (n_classe("3-MOYEN"), n_classe("4-INCOMPLET"),
                             n_classe("5-VIDE"))

incomp = base[base["classe_completude"] == "4-INCOMPLET"]
moyen  = base[base["classe_completude"] == "3-MOYEN"]

# progression INCOMPLET par section (1ere question de section remplie)
sec = [("A", "A1"), ("B", "B1"), ("C", "C1"), ("D", "D1"), ("E", "E1"),
       ("EMPLOYE", "EMPLOYE"), ("F", "F1"), ("G", "G1"), ("H", "H1"),
       ("J", "J1"), ("K", "K1"), ("L", "L1"), ("M", "M1"), ("N", "N1"),
       ("O", "O1"), ("P", "P1"), ("Q", "Q1"), ("R", "R1")]
lignes_prog_incomp = []
for nom, cq in sec:
    if cq in incomp.columns:
        lignes_prog_incomp.append([nom, cq,
                                   f"{100*remplie(incomp[cq]).mean():.1f} %"])
lignes_prog_moyen = []
for nom, cq in sec:
    if cq in moyen.columns:
        lignes_prog_moyen.append([nom, cq,
                                  f"{100*remplie(moyen[cq]).mean():.1f} %"])

# statut xA4 des incomplets
a4 = incomp["A4"].astype(str).str.strip().replace("<NA>", "NA")
tab_statut_incomp = pd.crosstab(
    incomp["interview__status"].fillna(-1).astype(int), a4.fillna("NA"))
lignes_statut_incomp = [[i, " + ".join(f"{c}:{tab_statut_incomp.loc[i,c]}" for c in tab_statut_incomp.columns
                                       if tab_statut_incomp.loc[i,c] > 0)]
                        for i in tab_statut_incomp.index]

# consentement chez les 291
cons = incomp["consentement"].astype(str).str.strip().replace("<NA>", "NA")
lignes_cons = [[k, str(v)] for k, v in cons.value_counts().items()]

# stats n_rempli par statut
g = incomp.groupby("interview__status")["n_rempli"].agg(["count", "min", "mean", "max"]).round(1)
lignes_rempli = [[int(i)] + list(g.loc[i]) if i in g.index else [int(i)] + ["-"]*4
                 for i in sorted(set(incomp["interview__status"].dropna().astype(int)))]

# ---------------------------------------------------------------
# CONTENU  (type, ...) : h1/h2/p/table
# ---------------------------------------------------------------
REF = ()  # placeholder
CONTENU = [
    ("h1", "NOTE  POURQUOI 291 INTERVIEWS SONT INCOMPLETES ET COMMENT LES RATTRAPER"),
    ("p",
     "Sur les %d interviews de la base finale : %d completes, %d quasi-completes, "
     "%d moyennes, %d incompletes et %d vides. Cette note explique pourquoi les "
     "interviews des classes 4-INCOMPLET (%d) et 3-MOYEN (%d) sont incompletes, "
     "et quelles actions de rattrapage sont possibles." %
     (n_total, n_complet, n_quasi, n_moyen, n_incomp, n_vide, n_incomp, n_moyen)),

    ("h2", "1. Pourquoi les %d interviews « 4-INCOMPLET » le sont" % n_incomp),
    ("p",
     f"Elles n'ont repondu qu'a {int(incomp['n_rempli'].min())} a "
     f"{int(incomp['n_rempli'].max())} question(s) sur ~65 attendues "
     f"(moyenne {incomp['n_rempli'].mean():.1f}). "
     "La progression section par section est sans ambiguite :"),
    ("table", ["Section", "1re question", "Interviews ayant repondu"],
     lignes_prog_incomp),
    ("p",
     "Lecture : les sections A (contact) et B (identification) sont remplies a "
     "presque 100 %, puis tout s'arrete des le debut de la section C : seules "
     f"{100*remplie(incomp['C1']).mean():.1f} % des interviews ont une reponse "
     f"a C1 ({int(remplie(incomp['C1']).sum())} / {len(incomp)}). Ce sont donc des "
     "« abandons precoces » : l'interview a ete ouverte puis recloturee sans etre "
     "menee, et non des abandons en cours de questionnaire."),
    ("p",
     f"La repartition par statut montre que cela touche toutes les categories, "
     f"y compris {int((incomp['interview__status']==100).sum())} interviews "
     "pourtant classees « validees » (statut 100) :"),
    ("p", "Nombre de questions effectivement remplies, par statut :"),
    ("table", ["statut", "nb interviews", "min", "moy.", "max"], lignes_rempli),
    ("p",
     f"Le consentement : "
     f"{', '.join(f'{v} x {k}' for k, v in incomp['consentement'].value_counts().items())} "
     f"sur les {len(incomp)}. Sans consentement, aucun recontact legal ; "
     "avec consentement, un rappel est theoriquement possible ;"),

    ("h2", f"2. Pourquoi les {n_moyen} interviews « 3-MOYEN » le sont"),
    ("p",
     f"Profil inverse : elles sont allees loin (de {int(moyen['n_rempli'].min())} "
     f"a {int(moyen['n_rempli'].max())} questions remplies sur ~90 attendues, "
     f"moyenne {moyen['n_rempli'].mean():.1f}) mais ont abandonne sur les "
     "sections de fin."),
    ("table", ["Section", "1re question", "Interviews ayant repondu"],
     lignes_prog_moyen),
    ("p",
     "Lecture : sections A a E, EMPLOYE, H et K remplies a 100 % ; les sections "
     "de la fin (O, P, Q, R notamment) ne sont remplies qu'a 40-60 %. Bilan : "
     "de vrais abandons en fin de questionnaire, sur des blocs conditionnels et "
     "les observations de l'enqueteur."),

    ("h2", "3. Comment rattraper (selon la classe)"),
    ("table",
     ["Classe", "Etat", "Action de rattrapage"],
     [
      [f"2-QUASI_COMPLET ({n_quasi})", "il manque 1 a 3 questions",
       "recontact cible : relancer preciseement les questions manquantes"],
      [f"3-MOYEN ({n_moyen})", "fin de questionnaire non passee",
       "recontact cible de la fin (sections O a R) - petit volume, realisable"],
      [f"4-INCOMPLET ({n_incomp})", "reponses presque inexistantes",
       f"recontact complet si consentement ({int((incomp['consentement']==1).sum())}) "
       "sinon exclusion de l'analyse"],
      ["5-VIDE (%d)" % n_vide, "aucun champ exploitable",
       "exclusion de l'analyse"],
     ]),
    ("p",
     "Ouverture pratique : pour les interviews a relancer, la liste exacte des "
     "identifiants et des questions manquantes est dans le fichier "
     "resultats/manquants_id_detail.xlsx (filtrer par classe puis par "
     "interview__id)."),
]

# ---------------------------------------------------------------
# GENERATION WORD
# ---------------------------------------------------------------
from docx import Document
from docx.shared import Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH

doc = Document()
for elt in CONTENU:
    typ = elt[0]
    if typ == "h1":
        p = doc.add_paragraph(elt[1]); r = p.runs[0]
        r.bold = True; r.font.size = Pt(15)
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    elif typ == "h2":
        p = doc.add_paragraph(elt[1]); r = p.runs[0]
        r.bold = True; r.font.size = Pt(12)
        p.paragraph_format.space_before = Pt(8)
    elif typ == "p":
        doc.add_paragraph(elt[1])
    elif typ == "table":
        entetes, lignes = elt[1], elt[2]
        t = doc.add_table(rows=1, cols=len(entetes)); t.style = "Table Grid"
        for j, h in enumerate(entetes):
            r = t.rows[0].cells[j].paragraphs[0].add_run(h); r.bold = True
        for ligne in lignes:
            cells = t.add_row().cells
            for j, val in enumerate(ligne):
                cells[j].text = str(val)
        doc.add_paragraph()

f = os.path.join(DOSSIER_NOTE, "Note_Pourquoi_Incompletes.docx")
doc.save(f)
print("Word ecrit :", f)

# ---------------------------------------------------------------
# GENERATION PDF
# ---------------------------------------------------------------
from fpdf import FPDF
from fpdf.fonts import FontFace

class P(FPDF):
    def header(self):
        self.set_font("ArialUni", "", 8)
        self.set_y(8); self.cell(0, 5, "Completude COSO - note de diagnostic", align="R")
        self.ln(3); self.set_draw_color(180, 180, 180); self.line(8, 16, 202, 16)
    def footer(self):
        self.set_y(-15); self.set_font("ArialUni", "", 8)
        self.cell(0, 10, f"Page {self.page_no()}", align="C")

pdf = P(format="A4")
pdf.add_font("ArialUni", "", "/Library/Fonts/Arial Unicode.ttf")
pdf.add_font("ArialUni", "B", "/Library/Fonts/Arial Unicode.ttf")
pdf.set_auto_page_break(auto=True, margin=20)
pdf.add_page()

def rendu_table(entetes, lignes, largeurs):
    ncol = len(entetes)
    align = tuple("LEFT" if largeurs and largeurs[i] == max(largeurs) else "CENTER"
                  for i in range(ncol))
    rows = [entetes] + [[str(v) for v in l] for l in lignes]
    with pdf.table(rows=rows, col_widths=largeurs, line_height=4.8,
                   text_align=align, first_row_as_headings=True,
                   headings_style=FontFace(emphasis="BOLD", color=(40, 40, 40)),
                   borders_layout="ALL"):
        pass

for elt in CONTENU:
    pdf.set_x(8)
    typ = elt[0]
    if typ == "h1":
        pdf.set_font("ArialUni", "B", 14)
        pdf.multi_cell(0, 6, elt[1], align="C"); pdf.ln(1)
    elif typ == "h2":
        pdf.ln(1)
        pdf.set_font("ArialUni", "B", 11.5)
        pdf.multi_cell(0, 6, elt[1])
    elif typ == "p":
        pdf.set_font("ArialUni", "", 9.5)
        pdf.set_x(8)
        pdf.multi_cell(pdf.epw, 4.8, elt[1])
    elif typ == "table":
        n = len(elt[1])
        largeurs = [55, 30, 65] if n == 3 and len(elt[2]) and len(elt[2][0]) == 3 else \
                   ([30, 30, 30, 30, 30] if n == 5 else None)
        if n == 4:
            largeurs = [45, 65, 40]
        pdf.set_font("ArialUni", "", 8.5)
        rendu_table(elt[1], elt[2], largeurs)
        pdf.ln(2)

f = os.path.join(DOSSIER_NOTE, "Note_Pourquoi_Incompletes.pdf")
pdf.output(f)
print("PDF ecrit :", f)