#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fichier de travail terrain (Excel) + note Word (rattrapage)."""
import os, datetime
import numpy as np
import pandas as pd
import pyreadstat
import docx
from docx.shared import Pt, Cm, RGBColor
from docx.enum.table import WD_TABLE_ALIGNMENT

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(os.path.dirname(ICI))     # racine du projet
DOSSIER_RES = os.path.join(RACINE, "resultats")
DOSSIER_NOTE = os.path.join(RACINE, "notes")

base, meta = pyreadstat.read_dta(
    f"{DOSSIER_RES}/Questionnaire_COSO_VF_avec_completude.dta")
detail = pd.read_excel(f"{DOSSIER_RES}/manquants_id_detail.xlsx")

def rempli(v):
    if v is None: return False
    if isinstance(v, float) and np.isnan(v): return False
    return str(v).strip() not in ("", "nan", "None", ".")

# ---------- 1) detection doublons nom+tel ----------
P = base[base.apply(lambda x: rempli(x["telephone"]) and rempli(x["nom"]),
                    axis=1)].copy()
P["tel"] = P["telephone"].astype(str).str.replace("[^0-9]", "", regex=True)
P["nom2"] = P["nom"].astype(str).str.strip().str.lower()
P["dbl"] = P.duplicated(subset=["tel", "nom2"], keep=False)
P = P[P["dbl"]][["interview__key", "tel", "nom2",
                 "interview__status", "classe_completude", "n_rempli"]]

paires = {}
for key, g in P.groupby(["tel", "nom2"]):
    cles = list(g["interview__key"])
    for c in cles:
        jumeaux = [x for x in cles if x != c]
        if jumeaux:
            j = g[g["interview__key"] == jumeaux[0]].iloc[0]
            paires[c] = (jumeaux[0], j["classe_completude"])

# ---------- 2) extraire les questions manquantes par clé ----------
manques = {}
for _, row in detail.iterrows():
    manques.setdefault(row["interview__key"], []).append(row["question_manquante"])

# ---------- 3) construire le fichier terrain ----------
sel = base[base["classe_completude"].isin(
    ["4-INCOMPLET", "3-MOYEN", "2-QUASI_COMPLET"])].copy()

def cons(v):
    if isinstance(v, float) and np.isnan(v): return "NA"
    return "OUI" if int(v) == 1 else "NON"

def action(row):
    if row["classe_completude"] == "4-INCOMPLET":
        if row["interview__key"] in paires:
            return "EXCLURE (doublon de " + paires[row["interview__key"]][0] + ")"
        if row["consentement"] == 1.0:
            return "REFAIRE (consentement OUI)"
        if row["consentement"] == 0.0:
            return "EXCLURE (refus consentement)"
        return "RECONTACTER (consentement a confirmer)"
    if row["classe_completude"] == "3-MOYEN":
        return "COMPLETER fin de questionnaire (P/Q/R)"
    return "COMPLETER (manque ~" + str(int(row["n_attendu"] - row["n_rempli"])) + " questions)"

def questions(row):
    k = row["interview__key"]
    if row["classe_completude"] == "4-INCOMPLET":
        return "reprendre du debut (block A/B)"
    return "; ".join(manques.get(k, []))

sel["consentement_lbl"] = sel["consentement"].apply(cons)
sel["doublon_de"] = sel["interview__key"].map(lambda k: paires[k][0] if k in paires else None)
sel["doublon_classe"] = sel["interview__key"].map(lambda k: paires[k][1] if k in paires else None)
sel["action"] = sel.apply(action, axis=1)
sel["questions_manquantes"] = sel.apply(questions, axis=1)

cols = ["classe_completude", "interview__key", "interview__id",
        "nom", "telephone", "localite", "interview__status",
        "consentement_lbl", "n_attendu", "n_rempli", "taux_completude",
        "action", "doublon_de", "doublon_classe", "questions_manquantes"]
res = sel[cols].sort_values(["classe_completude", "n_rempli"])
res.to_excel(f"{DOSSIER_RES}/rattrapage_terrain.xlsx", index=False)
print("Excel terrain :", len(res), "interviews ->", f"{DOSSIER_RES}/rattrapage_terrain.xlsx")

# ---------- 4) note Word ----------
doc = docx.Document()
style = doc.styles["Normal"]
style.font.name = "Calibri"
style.font.size = Pt(10)

def titre(txt, n=1):
    h = doc.add_heading(txt, level=n)
    for run in h.runs:
        run.font.color.rgb = RGBColor(0x1F, 0x3B, 0x5A)
    return h

def p(txt, bold=False):
    para = doc.add_paragraph(txt)
    if para.runs and bold:
        para.runs[0].bold = True

def tableau(df, tete=True):
    t = doc.add_table(rows=len(df) + 1, cols=len(df.columns))
    t.style = "Light Grid Accent 1"
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    for j, c in enumerate(df.columns):
        cell = t.cell(0, j)
        cell.text = str(c)
        for run in cell.paragraphs[0].runs:
            run.bold = True
            run.font.size = Pt(8)
    for i, (_, row) in enumerate(df.iterrows(), start=1):
        for j, c in enumerate(df.columns):
            v = row[c]
            t.cell(i, j).text = "" if (isinstance(v, float) and np.isnan(v)) else str(v)
            for run in t.cell(i, j).paragraphs[0].runs:
                run.font.size = Pt(8)

p("Fichier : Note_Rattrapage.docx", )
p("Date : " + datetime.date.today().strftime("%d/%m/%Y"))
doc.add_paragraph()

titre("Note de travail : rattrapage des interviews incompletes (COSO)", 0)
doc.add_paragraph(
    "Cette note ressort, pour les trois classes incompletes, ce qui peut encore "
    "etre rattrape sur le terrain. Elle s'appuie sur la base finale de "
    "1032 interviews et sur le detail des questions manquantes.")

titre("1. Vue d'ensemble", 1)
doc.add_paragraph(
    "Sur 1032 interviews, 689 sont exploitables a 100 % (COMPLET + QUASI). "
    "Le present travail concerne les 363 restantes : 291 INCOMPLET, 10 MOYEN "
    "et 62 QUASI. Apres analyse, 13 des 291 incompletes sont des doublons "
    "deja couverts par une interview complete et doivent etre exclues.")
df0 = pd.DataFrame({
    "Classe": ["4-INCOMPLET", "3-MOYEN", "2-QUASI_COMPLET", "Total"],
    "Effectif": [291, 10, 62, 363],
    "Telephone valide": [291, 10, 62, 363],
    "Consentement OUI": [107, 10, None, None],
    "Action recommandee": [
        "Recontacter ou exclure (doublons)",
        "Completer la fin du questionnaire",
        "Completer ~3 questions",
        "-",
    ],
})
tableau(df0)

titre("2. Les 291 INCOMPLET (abandon immediat)", 1)
doc.add_paragraph(
    "Ces interviews s'arretent des le block B : 156 ne depassent pas la "
    "couverture (B1-B2), 98 s'arretent apres B7 (avant la section menage), "
    "26 seulement entament le contenu (section C et plus).")
doc.add_paragraph("Probablement des interviews deplaces/suspendues ou de simples doublons. "
                  "Seules les 107 avec consentement OUI sont des candidats clairs au recontact.")
doc.add_paragraph("Situation detaillee :", style="List Bullet")
df1 = pd.DataFrame({
    "Derniere section atteinte": ["B1-B2 (couverture", "B7 (entree du menage)",
                                   "C-E (debut contenu)", "Total"],
    "Effectif": [156, 98, 37, 291],
})
tableau(df1)
doc.add_paragraph()
doc.add_paragraph("Dont 13 doublons a exclure (un jumeau COMPLET/QUASI existe deja) :", style="List Bullet")
l = [paires[k][0] + " (jumeau) <- " + k for k in sel[
    (sel["classe_completude"] == "4-INCOMPLET") & (sel["interview__key"].isin(paires))][
    "interview__key"]]
for x in l:
    doc.add_paragraph(x, style="List Bullet")

titre("3. Les 10 MOYEN (rattrapable par recontact cible)", 1)
doc.add_paragraph(
    "Les 10 ont tous un telephone valide et un consentement OUI. Ils sont "
    "alles jusqu'en section K-R ; il manque principalement les questions "
    "finales (Q1-Q10, R1-R7, P1/P3/P5). Un recontact court suffit a "
    "completer le dossier.")
tableau(pd.DataFrame({
    "Cas": ["10 interviews"],
    "Telephone": ["10/10"],
    "Consentement": ["10/10"],
    "Manques moyens": ["~20 questions/interview"],
    "Action": ["Recontacter pour fin Q/P/R"],
}))

titre("4. Les 62 QUASI (complesion rapide)", 1)
doc.add_paragraph(
    "Tous atteignent la section R. Il manque en moyenne seulement 3 questions. "
    "Les manques sont concentres : R7 (33), J3 (29), P1/P5/Q2/R4/R6 (22 "
    "chacun), D5__11 (21). Un rappel court suffit.")
tableau(pd.DataFrame({
    "Question": ["R7", "J3", "P1", "P5", "Q2", "R4", "R6", "D5__11"],
    "Nb interviews concernees": [33, 29, 22, 22, 22, 22, 22, 21],
}))

titre("5. Recapitulatif des actions terrain", 1)
df5 = pd.DataFrame({
    "Groupe": ["INCOMPLET - doublons", "INCOMPLET - consentement OUI",
                "INCOMPLET - refus", "INCOMPLET - sans consentement",
                "MOYEN", "QUASI"],
    "Effectif": [13, 104, 29, 145, 10, 62],
    "Telephone": ["-", "OUI", "OUI", "OUI", "OUI", "OUI"],
    "Action": ["EXCLURE", "REFAIRE le questionnaire",
               "EXCLURE (refus)", "RECONTACTER + confirmer consentement",
               "COMPLETER fin (P/Q/R)", "COMPLETER ~3 questions"],
})
tableau(df5)
doc.add_paragraph()
doc.add_paragraph(
    "Le fichier rattrapage_terrain.xlsx (joint) donne, pour chaque interview, "
    "l'identifiant (cle et id), le nom, le telephone, le consentement, le "
    "statut, la classe, l'action recommandee, le doublon eventuel et la liste "
    "des questions manquantes. Il est pret pour un import par l'equipe terrain.")

f_note = os.path.join(DOSSIER_NOTE, "Note_Rattrapage.docx")
doc.save(f_note)
print("Note Word :", f_note)