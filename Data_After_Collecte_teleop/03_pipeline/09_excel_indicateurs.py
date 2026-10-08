"""09 — Produire le classeur Excel des indicateurs.

Entrée : 04_resultats/indicateurs/indicateurs.json
Sortie : 04_resultats/indicateurs/Indicateurs_COSO.xlsx

Sept feuilles : Methode, Synthese_globale, Modalites, Sous_groupes,
Couverture_21, Non_calculables, Meta. Fermer le classeur avant de relancer.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from openpyxl import Workbook
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter
from openpyxl.worksheet.table import Table, TableStyleInfo

ICI = Path(__file__).resolve().parent
RACINE = ICI.parent
INDICATEURS = RACINE / "04_resultats" / "indicateurs" / "indicateurs.json"
SORTIE = RACINE / "04_resultats" / "indicateurs" / "Indicateurs_COSO.xlsx"

BLEU = "17324D"
ENTETE = PatternFill("solid", fgColor=BLEU)
TITRE = Font(bold=True, color=BLEU, size=11)
GRAS = Font(bold=True)
BLANC = Font(color="FFFFFF", bold=True)
FIN = Side(style="thin", color="BFBFBF")
CADRE = Border(left=FIN, right=FIN, top=FIN, bottom=FIN)
CENTRE = Alignment(horizontal="center", vertical="center")
GAUCHE = Alignment(horizontal="left", vertical="top", wrap_text=True)

COLONNES_MODALITES = ["niveau", "district", "region", "sexe", "age_groupe", "milieu",
                      "n_groupe", "bloc", "code", "mesure", "modalite", "valeur", "unite",
                      "effectif", "denominateur", "sans_reponse", "variables", "precision"]
COLONNES_SYNTH = ["bloc", "code", "mesure", "valeur", "unite", "effectif",
                  "denominateur", "sans_reponse", "precision"]

METHODE = [
    ("Objet", "Tous les indicateurs calculés à partir de l'enquête téléphonique COSO "
              "(candidats du Programme Jeunesse), blocs D1 à D11, pour l'ensemble et six "
              "désagrégations. Une mesure « en attente » ou « indisponible » n'est jamais "
              "publiée comme zéro."),
    ("Source", "02_bases/QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta — 962 entretiens, copie de "
               "travail issue du pipeline de dédoublonnage (étape 06)."),
    ("Population analysée", "classe_completude ∈ {1-COMPLET, 2-QUASI_COMPLET} ET "
                            "consentement = 1 → 664 entretiens au filtre de complétude, "
                            "moins 1 sans consentement = 663 candidats (étape 07)."),
    ("Proportion", "Part (%) = 100 × (réponses dans la modalité) / (réponses valides de la "
                   "population concernée). Le dénominateur propre à chaque question figure "
                   "dans la colonne « denominateur »."),
    ("Médiane", "Calculée sur les valeurs valides ; sans numérateur. La colonne "
                "« denominateur » donne le nombre de valeurs utilisées, "
                "« sans_reponse » le reste de la population."),
    ("Codes spéciaux", "Comparaison par égalité exacte : 998 (G3, ne sait pas), 99999 (H3), "
                       "999999 (H5), 99998 (L8), 9 (Q4–Q10, ne sait pas). Jamais de "
                       "comparaison < ou > sur ces codes."),
    ("Skip logic", "Une question non posée (saut du questionnaire) reste absente : elle "
                   "n'est jamais comptée comme « non ». Les réponses hors parcours sont "
                   "signalements dans l'audit de l'étape 07, pas des exclusions."),
    ("Vraisemblance", "Âge retenu de 15 à 120 ans ; heures de 0 à 168 ; âge au premier "
                      "emploi de 5 à 80 ans ; revenu souhaité (P3) de 1 à 5 000 000 FCFA ; "
                      "durée d'entretien de 1 à 600 minutes. Les valeurs hors plage sont "
                      "laissées vides, jamais corrigées."),
    ("Petits effectifs", "Tout dénominateur inférieur à 30 porte la mention "
                         "« Effectif faible : dénominateur < 30. » dans « precision »."),
    ("Sous-groupes", "Ensemble, districts (4), régions (10), sexe, groupes d'âge, milieu. "
                     "Les dénominateurs propres à chaque sous-groupe servent à chaque "
                     "calcul ; le classeur distingue chaque ligne par « niveau » et ses clés."),
    ("Codages", "Quatre questions ouvertes sont codées par mots-clés (barèmes dans le "
                "rapport Word, section « Codages ») : P1 métier visé, O4 domaine de "
                "formation, P5 obstacle principal, G5A nature de l'autre activité. "
                "Codage descriptif, non officiel ; les réponses vides restent hors "
                "dénominateur."),
    ("1.1 à 1.3", "Écartés de ce calcul en attente de décision : le registre d'enrôlement, "
                  "les statuts de sélection et la convention de dénominateur font foi. "
                  "Voir « Non_calculables »."),
    ("Désagrégations", "Aucune inférence statistique : les écarts entre groupes sont "
                       "descriptifs. Aucun plan de sondage représentatif n'est fourni."),
]


def _largeurs(ws, max_par_col: dict[int, int]) -> None:
    for i, largeur in max_par_col.items():
        ws.column_dimensions[get_column_letter(i)].width = largeur


def _entete(ws, colonnes: list[str]) -> None:
    ws.append(colonnes)
    for cellule in ws[1]:
        cellule.fill = ENTETE
        cellule.font = BLANC
        cellule.alignment = CENTRE
    ws.freeze_panes = "A2"


def _table(ws, nom: str) -> None:
    if ws.max_row >= 2:
        plage = f"A1:{get_column_letter(ws.max_column)}{ws.max_row}"
        tab = Table(displayName=nom, ref=plage)
        tab.tableStyleInfo = TableStyleInfo(name="TableStyleMedium2", showRowStripes=True)
        ws.add_table(tab)


def _formater_valeur(cellule, unite: str | None) -> None:
    if unite == "%":
        cellule.number_format = "0.0"
    elif unite and "FCFA" in unite:
        cellule.number_format = "#,##0"
    else:
        cellule.number_format = "0.00"


def produire(payload: dict, sortie: Path = SORTIE) -> None:
    lignes = payload["resultats"]
    meta = payload["metadata"]
    wb = Workbook()

    ws = wb.active
    ws.title = "Methode"
    ws.append(["Rubrique", "Contenu"])
    for cellule in ws[1]:
        cellule.fill = ENTETE
        cellule.font = BLANC
        cellule.alignment = CENTRE
    for rubrique, contenu in METHODE:
        ws.append([rubrique, contenu])
    for ligne in ws.iter_rows(min_row=2):
        ligne[0].font = GRAS
        ligne[0].alignment = GAUCHE
        ligne[1].alignment = GAUCHE
    ws.freeze_panes = "A2"
    _largeurs(ws, {1: 24, 2: 110})

    synthese = [l for l in lignes if l["niveau"] == "Ensemble" and not l["modalite"]]
    ws = wb.create_sheet("Synthese_globale")
    _entete(ws, COLONNES_SYNTH)
    for l in synthese:
        ws.append([l[c] for c in COLONNES_SYNTH])
        _formater_valeur(ws.cell(ws.max_row, 4), l["unite"])
    for ligne in ws.iter_rows(min_row=2):
        for cellule in ligne:
            cellule.alignment = GAUCHE
    _table(ws, "TableSynthese")
    _largeurs(ws, {1: 34, 2: 9, 3: 62, 4: 12, 5: 12, 6: 10, 7: 13, 8: 13, 9: 60})

    ws = wb.create_sheet("Modalites")
    _entete(ws, COLONNES_MODALITES)
    for l in lignes:
        ws.append([l[c] for c in COLONNES_MODALITES])
        _formater_valeur(ws.cell(ws.max_row, 12), l["unite"])
    _table(ws, "TableModalites")
    _largeurs(ws, {1: 10, 2: 13, 3: 13, 4: 8, 5: 13, 6: 9, 7: 9, 8: 32, 9: 9,
                   10: 58, 11: 34, 12: 11, 13: 10, 14: 9, 15: 13, 16: 13, 17: 26, 18: 70})

    vus: dict[tuple, int] = {}
    for l in lignes:
        cle = (l["niveau"], l["district"], l["region"], l["sexe"],
               l["age_groupe"], l["milieu"])
        vus[cle] = l["n_groupe"]
    n_total = meta.get("n_apures") or max(vus.values())
    ws = wb.create_sheet("Sous_groupes")
    _entete(ws, ["niveau", "district", "region", "sexe", "age_groupe", "milieu",
                 "n_groupe", "part_ensemble_%"])
    for cle in sorted(vus):
        n = vus[cle]
        ws.append(list(cle) + [n, round(100 * n / n_total, 1)])
        ws.cell(ws.max_row, 8).number_format = "0.0"
    _table(ws, "TableGroupes")
    _largeurs(ws, {1: 11, 2: 14, 3: 14, 4: 9, 5: 14, 6: 10, 7: 10, 8: 16})

    ws = wb.create_sheet("Couverture_21")
    _entete(ws, ["code", "indicateur", "statut", "mesures_calculees",
                 "limite_ou_registre_requis"])
    for e in payload["couverture"]:
        ws.append([e["code"], e["indicateur"], e["statut"], ", ".join(e["mesures"]),
                   e["limite"]])
    for ligne in ws.iter_rows(min_row=2):
        for cellule in ligne:
            cellule.alignment = GAUCHE
        statut = ligne[2]
        statut.font = (Font(bold=True, color="1F7A1F") if statut.value == "calculé"
                       else Font(bold=True, color="B36B00") if statut.value == "partiel"
                       else Font(bold=True, color="9C0006"))
    _table(ws, "TableCouverture")
    _largeurs(ws, {1: 8, 2: 42, 3: 14, 4: 40, 5: 95})

    ws = wb.create_sheet("Non_calculables")
    _entete(ws, ["code", "indicateur", "statut", "raison"])
    for e in payload["non_calculables"]:
        ws.append([e["code"], e["indicateur"], e["statut"], e["raison"]])
    for ligne in ws.iter_rows(min_row=2):
        for cellule in ligne:
            cellule.alignment = GAUCHE
    _table(ws, "TableNonCalc")
    _largeurs(ws, {1: 8, 2: 42, 3: 14, 4: 110})

    ws = wb.create_sheet("Meta")
    ws.append(["cle", "valeur"])
    for cellule in ws[1]:
        cellule.fill = ENTETE
        cellule.font = BLANC
    def aplatir(pre: str, objet) -> None:
        if isinstance(objet, dict):
            for cle, valeur in objet.items():
                aplatir(f"{pre}.{cle}" if pre else str(cle), valeur)
        else:
            ws.append([pre, objet])
    for cle, valeur in meta.items():
        aplatir(cle, valeur)
    for ligne in ws.iter_rows(min_row=2):
        ligne[0].font = GRAS
    _largeurs(ws, {1: 34, 2: 70})

    for feuille in wb.worksheets:
        feuille.sheet_view.showGridLines = False
    sortie.parent.mkdir(parents=True, exist_ok=True)
    wb.save(sortie)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--indicateurs", type=Path, default=INDICATEURS)
    parser.add_argument("--sortie", type=Path, default=SORTIE)
    args = parser.parse_args()
    charge = json.loads(args.indicateurs.read_text(encoding="utf-8"))
    produire(charge, args.sortie)
    print(f"{args.sortie.name} : {len(charge['resultats'])} lignes, "
          f"{len(charge['couverture'])} indicateurs")
