"""15 — Produire la note Word « analyse programme » (variante Arthur).

Entrées : 04_resultats/analyse_programme/indicateurs_programme.json
         04_resultats/analyse_programme/meta_programme.json
Sortie  : 04_resultats/analyse_programme/Note_Analyse_Programme_COSO.docx

La note explique, bloc par bloc, ce que produit l'analyse, et se termine par une
section dédiée à la question MAF (ce que faisait Arthur, et en quoi c'était utile).
"""

from __future__ import annotations

import argparse
import json
from datetime import date
from pathlib import Path

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Pt, RGBColor

ICI = Path(__file__).resolve().parent
RACINE = ICI.parent
DOSSIER = RACINE / "04_resultats" / "analyse_programme"
ENTREE = DOSSIER / "indicateurs_programme.json"
META = DOSSIER / "meta_programme.json"
SORTIE = DOSSIER / "Note_Analyse_Programme_COSO.docx"

BLEU = RGBColor(0x17, 0x32, 0x4D)
GRIS = RGBColor(0x59, 0x59, 0x59)

INTRO_BLOC = {
    "P1": "Répartition des candidats entre les trois filières déduites de P2. "
          "C'est la photographie qui commande l'organisation des cohortes.",
    "P2": "Où se concentrent les aspirations sectorielles, région par région. "
          "Une région où plus de 30 % des candidats visent le même secteur est "
          "signalée comme zone de saturation.",
    "P3": "Ce que les candidats ont suivi comme formation (O4 codé) et si ce "
          "domaine correspond au secteur visé (train_match).",
    "P4": "Cinq signes de fragilité du ménage. Volontairement présentés séparément "
          "(pas de score imposé) ; le score 0-5 est fourni à titre exploratoire.",
    "P5": "Le métier visé (codage par mots-clés de P1), sa couverture par un MAF, "
          "et l'écart de compétences (gap) en trois pénalités.",
    "P6": "Écart entre la demande (candidats aspirant à un métier) et l'offre de "
          "formateurs MAF recensée par SONET-CI. Donnée externe, appariement "
          "approximatif — lire avec les notes.",
    "P7": "Où livrer la formation : densité et dispersion des candidats par "
          "cluster (région × milieu).",
    "P8": "Revenus (mensualisés), heures travaillées et revenu souhaité, avec "
          "quartiles — des mesures que notre pipeline officiel ne produit pas.",
    "P9": "Croisements à deux dimensions (autonomie perçue, formation, "
          "compétences) que le moteur officiel mono-axe ne permettait pas.",
    "P10": "Diagnostic de l'entonnoir de participation par sexe, sur l'ensemble "
           "des tentatives (hors population d'analyse).",
}


def _police(p, taille=10, gras=False, italique=False, couleur=None):
    for run in p.runs:
        run.font.size = Pt(taille)
        run.font.bold = gras or run.font.bold
        run.font.italic = italique
        if couleur is not None:
            run.font.color.rgb = couleur


def _para(doc, texte, taille=10, italique=False, couleur=None, gras=False):
    p = doc.add_paragraph(texte)
    _police(p, taille, gras=gras, italique=italique, couleur=couleur)
    return p


def _tableau(doc, entetes, lignes):
    t = doc.add_table(rows=1, cols=len(entetes))
    t.style = "Light Grid Accent 1"
    for j, e in enumerate(entetes):
        c = t.rows[0].cells[j]
        c.text = ""
        run = c.paragraphs[0].add_run(str(e))
        run.bold = True
        run.font.size = Pt(8)
    for rang in lignes:
        cells = t.add_row().cells
        for j, v in enumerate(rang):
            cells[j].text = "" if v is None else str(v)
            for p in cells[j].paragraphs:
                for run in p.runs:
                    run.font.size = Pt(8)
    return t


def produire(entree: Path = ENTREE, meta_path: Path = META,
             sortie: Path = SORTIE) -> dict:
    payload = json.loads(entree.read_text(encoding="utf-8"))
    meta = json.loads(meta_path.read_text(encoding="utf-8"))
    pm = payload["metadata"]
    doc = Document()

    doc.add_heading("Analyse programme COSO — note d'accompagnement", level=0)
    sous = doc.add_paragraph()
    r = sous.add_run("Volet exploratoire (variante Arthur), séparé du rapport officiel "
                     "des 21 indicateurs.")
    r.italic = True
    r.font.color.rgb = GRIS
    sous.alignment = WD_ALIGN_PARAGRAPH.LEFT

    doc.add_heading("1. Objet et périmètre", level=1)
    _para(doc, f"Cette note accompagne le classeur « Analyse_Programme_COSO.xlsx ». "
               f"Elle décrit les analyses de conception de programme que produisait le "
               f"do-file d'Arthur et qui n'étaient pas encore intégrées à notre pipeline, "
               f"en les recalculant sur NOTRE population ({pm['population']} candidats, "
               f"étape 07). Elle est volontairement séparée du rapport officiel des 21 "
               f"indicateurs : elle contient des scores composites et une donnée externe "
               f"(SONET-CI), non validés comme résultats de suivi-évaluation.")
    _para(doc, pm["avertissement"], italique=True, couleur=GRIS)

    doc.add_heading("2. Population et codage", level=1)
    _para(doc, f"Population : {pm['population']} candidats (classe de complétude "
               f"COMPLET ou QUASI_COMPLET, étape 07 — population inchangée).")
    _para(doc, f"Mode de calcul de sector_match : {pm['mode_sector_match']}. "
               f"Le do-file d'Arthur comporte un décalage (+1) entre son mapping et le "
               f"codage officiel F2 ; nous utilisons la version corrigée, conforme à son "
               f"intention, tout en gardant l'option littérale disponible.")
    rt = meta.get("repartition_track", {})
    _para(doc, "Répartition des filières : " +
          " ; ".join(f"{k} = {v}" for k, v in rt.items()) + ".")
    _para(doc, f"Métiers couverts par un MAF : {meta.get('n_maf_matchables')} candidats. "
               f"Score de vulnérabilité moyen : {meta.get('vuln_score_moyen')} "
               f"(sur {meta.get('n_vuln_calculable')} calculables).")

    for bloc, lib in pm["blocs"].items():
        tables = [t for t in payload["tableaux"] if t["bloc"] == bloc]
        if not tables:
            continue
        doc.add_heading(f"{lib}", level=1)
        if bloc in INTRO_BLOC:
            _para(doc, INTRO_BLOC[bloc])
        for tab in tables:
            _para(doc, f"{tab['cle']} — {tab['titre']}", taille=10, gras=True,
                  couleur=BLEU)
            if tab.get("note"):
                _para(doc, tab["note"], taille=8, italique=True, couleur=GRIS)
            _tableau(doc, tab["entetes"], tab["lignes"])

    # — Section MAF demandée explicitement —
    doc.add_heading("Ce que faisait Arthur avec la MAF, et en quoi c'était utile", level=1)
    _para(doc, "La question MAF est le cœur de l'analyse de conception d'Arthur "
               "(son « Analyse 10 »). Rappel de sa logique :")
    for puce in [
        "Côté OFFRE : Arthur recense les Maîtres Artisans Formateurs (MAF) disponibles "
        "métier par métier et région par région, à partir du rapport de mission "
        "SONET-CI de septembre 2026 (14 métiers, 10 régions). Cette donnée "
        "n'existe pas dans le questionnaire : il la code en dur dans son do-file.",
        "Côté DEMANDE : il compte, dans l'enquête, combien de candidats aspirent à "
        "chacun de ces métiers, dans chaque région (croisement trade_code × région).",
        "Écart : il calcule le ratio « candidats par MAF » et le traduit en feu "
        "tricolore — Vert ≤ 1 (offre suffisante), Orange 1–3 (tension modérée), "
        "Rouge > 3 ou offre nulle avec demande (tension forte).",
    ]:
        doc.add_paragraph(puce, style="List Bullet")
    _para(doc, "En quoi c'était utile :")
    for puce in [
        "Décider OÙ former : repérer les régions où un métier attire beaucoup de "
        "candidats mais dispose de peu de formateurs, pour y affecter les MAF.",
        "Décider QUOI financer : orienter l'appui vers les métiers en tension, ou au "
        "contraire rassurer sur les métiers déjà bien couverts.",
        "Offrir un critère OBJECTIF de priorisation aux décideurs (un feu lisible "
        "plutôt qu'une liste de chiffres).",
        "Relier la demande exprimée par les jeunes à l'offre réelle de formation : "
        "c'est ce qui distingue une analyse de conception d'un reporting.",
    ]:
        doc.add_paragraph(puce, style="List Bullet")
    _para(doc, "Réserves assumées : la matrice SONET-CI est une donnée externe datée ; "
               "sa somme (461 MAF) diffère du total annoncé dans le rapport (477), "
               "l'écart de 16 n'étant pas ventilable par région dans la source ; "
               "l'appariement métier ↔ catégorie SONET est approximatif (peinture "
               "partagée avec maçonnerie/carrelage, pneus absorbés dans mécanique, "
               "froid/climatisation partiel), le ratio compte des têtes et non une "
               "capacité d'accueil, et la demande dépend de notre propre codage de P1. "
               "Ces réserves sont rappelées sur la feuille P6 et dans la feuille "
               "MAF_cellules.", italique=True, couleur=GRIS)

    doc.add_heading("Limites générales", level=1)
    for puce in [
        "Scores composites (vulnérabilité, gap) : recette d'Arthur, seuils non validés. "
        "À traiter comme pistes de conception, pas comme indicateurs de résultat.",
        "Codage par mots-clés (secteurs, métiers) : sensible à la formulation libre des "
        "réponses ; 25 = non codable, 97 = secteur non classé.",
        "Petits effectifs : plusieurs régions comptent moins de 20 candidats ; lire les "
        "parts avec les effectifs.",
    ]:
        doc.add_paragraph(puce, style="List Bullet")

    p = doc.add_paragraph()
    r = p.add_run(f"Note générée le {date.today().isoformat()}.")
    r.italic = True
    r.font.size = Pt(8)
    r.font.color.rgb = GRIS

    sortie.parent.mkdir(parents=True, exist_ok=True)
    doc.save(sortie)
    return {"sortie": str(sortie), "tableaux": len(payload["tableaux"])}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--entree", type=Path, default=ENTREE)
    parser.add_argument("--meta", type=Path, default=META)
    parser.add_argument("--sortie", type=Path, default=SORTIE)
    args = parser.parse_args()
    print(json.dumps(produire(args.entree, args.meta, args.sortie),
                     ensure_ascii=False, indent=2))
