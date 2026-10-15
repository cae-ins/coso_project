"""16 — Contrôles de cohérence du volet « analyse programme » (variante Arthur).

Contrôle, sans modifier aucun fichier :
  · base_programme.csv (population inchangée, domaine des variables dérivées) ;
  · indicateurs_programme.json (structure des tableaux, matrice MAF) ;
  · le classeur Analyse_Programme_COSO.xlsx (feuilles, intégrité) ;
  · la note Note_Analyse_Programme_COSO.docx (sections, pas de données nominatives).

Sortie console : une ligne [OK] ou [ERREUR] par contrôle, code retour 1 si échec.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd
from docx import Document
from openpyxl import load_workbook

ICI = Path(__file__).resolve().parent
RACINE = ICI.parent
DOSSIER = RACINE / "04_resultats" / "analyse_programme"
BASE = DOSSIER / "base_programme.csv"
META = DOSSIER / "meta_programme.json"
JSON_PRG = DOSSIER / "indicateurs_programme.json"
XLSX = DOSSIER / "Analyse_Programme_COSO.xlsx"
DOCX = DOSSIER / "Note_Analyse_Programme_COSO.docx"

PII_TEXTE = re.compile(r"\b0[1-9]\d{8}\b|[\w.+-]+@[\w-]+\.[\w.]+")
FEUILLES = ["Methode", "P1_Filieres", "P2_Saturation", "P3_Formation",
            "P4_Vulnerabilite", "P5_Metiers_Gap", "P6_Ecart_MAF", "P7_Geographie",
            "P8_Revenus", "P9_Croisements", "P10_Entonnoir", "MAF_cellules"]
SECTIONS = ["1. Objet et périmètre", "2. Population et codage",
            "Ce que faisait Arthur avec la MAF, et en quoi c'était utile",
            "Limites générales"]
N_POPULATION = 664
N_MAF_CELLULES = 140

echecs: list[str] = []
controles = 0


def controler(nom: str, condition: bool, detail: str = "") -> bool:
    global controles
    controles += 1
    if condition:
        print(f"[OK] {nom}")
    else:
        message = f"{nom}" + (f" — {detail}" if detail else "")
        print(f"[ERREUR] {message}")
        echecs.append(message)
    return bool(condition)


def controler_base() -> pd.DataFrame:
    d = pd.read_csv(BASE, low_memory=False)
    controler(f"base_programme : {N_POPULATION} lignes (population inchangée)",
              len(d) == N_POPULATION, str(len(d)))
    controler("base_programme : identifiants uniques", d.interview__key.is_unique)
    controler("base_programme : filières A/B/C couvrent la population",
              int(d.track.isin([1, 2, 3, 4]).sum()) == N_POPULATION
              and int(d.track.isin([1, 2, 3]).sum()) + int(d.track.eq(4).sum())
              == N_POPULATION)
    controler("track : domain {1,2,3,4}",
              set(d.track.dropna().unique()) <= {1, 2, 3, 4},
              str(sorted(d.track.dropna().unique())))
    controler("trade_code : domain 1–25",
              d.trade_code.between(1, 25).all(), str(sorted(d.trade_code.unique())))
    controler("gap_level : domain 0–4",
              d.gap_level.dropna().isin([0, 1, 2, 3, 4]).all(),
              str(sorted(d.gap_level.dropna().unique())))
    controler("gap_score : domain 0–3",
              d.gap_score.dropna().isin([0, 1, 2, 3]).all())
    controler("vuln_score : domain 0–5",
              d.vuln_score.dropna().isin([0, 1, 2, 3, 4, 5]).all(),
              str(sorted(d.vuln_score.dropna().unique())))
    controler("vuln_score : même dénominateur que les 5 signes",
              int(d.vuln_score.notna().sum())
              == int(d[["vuln_1", "vuln_2", "vuln_3", "vuln_4", "vuln_5"]]
                     .notna().all(axis=1).sum()))
    controler("maf_match : cohérent avec trade_code",
              (d.maf_match.eq(1) == d.trade_code.isin(
                  [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 21])).all())
    controler("track_libelle : aucun libellé vide",
              d.track_libelle.notna().all())
    controler("base_programme : aucune donnée nominative dans les colonnes",
              not any(PII_TEXTE.search(str(c)) for c in d.columns))
    return d


def controler_json(d: pd.DataFrame) -> dict:
    payload = json.loads(JSON_PRG.read_text(encoding="utf-8"))
    tables = payload["tableaux"]
    controler("JSON : au moins 40 tableaux", len(tables) >= 40, str(len(tables)))
    larg = [len(t["entetes"]) for t in tables]
    coherents = all(len(r) == len(t["entetes"])
                    for t in tables for r in t["lignes"])
    controler("JSON : chaque ligne a la largeur de ses en-têtes", coherents)
    controler("JSON : en-têtes renseignés (hors colonne de libellés)",
              all(all(str(e) != "" for e in t["entetes"][1:]) for t in tables)
              and all(e is not None for t in tables for e in t["entetes"]))
    controler("JSON : blocs attendus P1–P10",
              {t["bloc"] for t in tables} >= {f"P{i}" for i in range(1, 10)})
    controler("JSON : aucune donnée nominative dans les tableaux",
              not any(PII_TEXTE.search(str(c))
                      for t in tables for r in t["lignes"] for c in r))
    controler("JSON : libellés de filières présents (A/B/C)",
              any(("A — Création" in str(c)) or ("Filière A" in str(c))
                  for t in tables for r in t["lignes"] for c in r))

    maf = payload["maf"]["cellules"]
    controler(f"JSON MAF : {N_MAF_CELLULES} cellules", len(maf) == N_MAF_CELLULES,
              str(len(maf)))
    demandes = pd.Series([c["demande"] for c in maf])
    offres = pd.Series([c["supply"] for c in maf])
    attendu_demande = int(d[d.maf_match.eq(1)].shape[0])
    controler("JSON MAF : la demande par cellule somme à la population MAF-matchable",
              int(demandes.sum()) == attendu_demande,
              f"{int(demandes.sum())} vs {attendu_demande}")

    def drapeau(dem, sup):
        if pd.isna(sup):
            return "ND"
        if sup == 0:
            return "Rouge" if dem > 0 else ""
        r = dem / sup
        return "Vert" if r <= 1 else ("Orange" if r <= 3 else "Rouge")

    incoherents = [c for c in maf
                   if drapeau(c["demande"], c["supply"]) != (c["flag"] or "")]
    controler("JSON MAF : feux tricolores cohérents avec demande/offre",
              not incoherents, str(incoherents[:3]))
    controler("JSON MAF : référence SONET-CI présente",
              "SONET" in payload["maf"]["source"]["reference"])
    total_offre = int(offres.sum())
    controler("JSON MAF : offre totale = 461 (matrice ; le catalogue annonce 477)",
              total_offre == 461, str(total_offre))
    return payload


def controler_excel(payload: dict) -> None:
    if not controler("Excel : fichier présent", XLSX.exists()):
        return
    wb = load_workbook(XLSX, read_only=True)
    controler("Excel : 12 feuilles attendues", wb.sheetnames == FEUILLES,
              str(wb.sheetnames))
    controler("Excel : feuille Methode renseignée",
              wb["Methode"].max_row > 5)
    controler("Excel : MAF_cellules = 4 + n lignes",
              wb["MAF_cellules"].max_row == 4 + len(payload["maf"]["cellules"]),
              str(wb["MAF_cellules"].max_row))
    for feuille in FEUILLES[1:-1]:
        nb = sum(1 for t in payload["tableaux"]
                 if t["bloc"] == feuille.split("_")[0])
        controler(f"Excel : {feuille} contient {nb} tableau(x)",
                  wb[feuille].max_row > 1 and nb >= 1)
    wb.close()


def controler_word() -> None:
    if not controler("Word : fichier présent", DOCX.exists()):
        return
    with zipfile.ZipFile(DOCX) as paquet:
        controler("Word : paquet DOCX intègre", paquet.testzip() is None)
        controler("Word : parties XML principales présentes",
                  {"[Content_Types].xml", "word/document.xml", "word/styles.xml"}
                  <= set(paquet.namelist()))
    doc = Document(DOCX)
    textes = [p.text.strip() for p in doc.paragraphs]
    for section in SECTIONS:
        controler(f"Word : section « {section} »", section in textes)
    controler("Word : au moins 25 tableaux", len(doc.tables) >= 25,
              str(len(doc.tables)))
    corps = "\n".join(textes)
    corps += "\n".join(c.text for t in doc.tables for r in t.rows for c in r.cells)
    controler(f"Word : population annoncée = {N_POPULATION}",
              str(N_POPULATION) in corps)
    controler("Word : la MAF est expliquée (offre, demande, feu tricolore)",
              all(mot in corps for mot in ("MAF", "SONET-CI", "Vert"))
              and "candidats par MAF" in corps)
    controler("Word : aucune donnée nominative", not PII_TEXTE.search(corps))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.parse_args()

    if not controler("Livrables programme présents",
                     BASE.exists() and JSON_PRG.exists() and META.exists()):
        print(f"\n{controles} contrôles, {len(echecs)} échec(s).")
        sys.exit(1)
    base = controler_base()
    charge = controler_json(base)
    controler_excel(charge)
    controler_word()

    print(f"\n{controles} contrôles, {len(echecs)} échec(s).")
    if echecs:
        for message in echecs:
            print(f"  ✗ {message}")
        sys.exit(1)
