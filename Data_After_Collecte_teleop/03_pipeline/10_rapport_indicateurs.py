"""10 — Produire le rapport Word explicatif des indicateurs.

Entrées : 04_resultats/indicateurs/indicateurs.json
          03_pipeline/09_excel_indicateurs.py (règles de calcul)
          03_pipeline/08_calcul_indicateurs.py (barèmes de codage)
Sortie  : 04_resultats/indicateurs/Rapport_indicateurs_COSO.docx
"""

from __future__ import annotations

import argparse
import importlib.util
import json
from datetime import date
from pathlib import Path

from docx import Document
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Mm, Pt, RGBColor

ICI = Path(__file__).resolve().parent
RACINE = ICI.parent
INDICATEURS = RACINE / "04_resultats" / "indicateurs" / "indicateurs.json"
SORTIE = RACINE / "04_resultats" / "indicateurs" / "Rapport_indicateurs_COSO.docx"

BLEU = RGBColor(0x17, 0x32, 0x4D)
GRIS = RGBColor(0x59, 0x59, 0x59)
VERT, ORANGE, ROUGE, GRIS_ETAT = "C6EFCE", "FFE5B4", "FFC7CE", "E7E6E6"


def _charger(nom: str, chemin: Path):
    spec = importlib.util.spec_from_file_location(nom, chemin)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


mod08 = _charger("calcul08", ICI / "08_calcul_indicateurs.py")
mod09 = _charger("excel09", ICI / "09_excel_indicateurs.py")

CHAINE = [
    ("01", "Complétude logique (skip logic) sur chaque base", "resultats/traitement/*.dta"),
    ("02", "Note Word/PDF de complétude", "06_notes/…completude.docx"),
    ("03", "Lecture et contrôle des 8 bases (lecture seule)", "rapport console [OK]/[ERREUR]"),
    ("04", "Note « Pourquoi incomplètes »", "06_notes/…manques.docx"),
    ("05", "Fichier de rattrapage terrain + note", "05_docs/ + 06_notes/"),
    ("06", "Pipeline de dédoublonnage", "QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta (962)"),
    ("07", "Apurement : population analysée, dérivés, audit", "base_apuree.csv (663) + meta_apurement.json"),
    ("08", "Calcul des indicateurs et sous-groupes", "indicateurs.json"),
    ("09", "Classeur Excel multi-feuilles", "Indicateurs_COSO.xlsx"),
    ("10", "Rapport Word explicatif (ce document)", "Rapport_indicateurs_COSO.docx"),
    ("11", "Contrôles de cohérence des livrables", "rapport console assertions"),
]


def _ombrage(cellule, couleur: str) -> None:
    tc_pr = cellule._tc.get_or_add_tcPr()
    ombrage = OxmlElement("w:shd")
    ombrage.set(qn("w:val"), "clear")
    ombrage.set(qn("w:fill"), couleur)
    tc_pr.append(ombrage)


def _police(paragraphe, taille: float, gras: bool = False, italique: bool = False,
            couleur: RGBColor | None = None) -> None:
    for run in paragraphe.runs:
        run.font.size = Pt(taille)
        run.font.name = "Calibri"
        run.bold = gras
        run.italic = italique
        if couleur is not None:
            run.font.color.rgb = couleur


def _tableau(doc: Document, colonnes: list[str], lignes: list[list[str]],
             largeurs: list[float] | None = None, corps: float = 8.5):
    table = doc.add_table(rows=1, cols=len(colonnes))
    table.style = "Table Grid"
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    for i, texte in enumerate(colonnes):
        cellule = table.rows[0].cells[i]
        cellule.text = texte
        _ombrage(cellule, "17324D")
        for paragraphe in cellule.paragraphs:
            _police(paragraphe, corps, gras=True, couleur=RGBColor(0xFF, 0xFF, 0xFF))
    for ligne in lignes:
        cellules = table.add_row().cells
        for i, texte in enumerate(ligne):
            cellules[i].text = str(texte)
            for paragraphe in cellules[i].paragraphs:
                _police(paragraphe, corps)
                paragraphe.paragraph_format.space_after = Pt(1)
                paragraphe.paragraph_format.space_before = Pt(1)
    if largeurs:
        for rangée in table.rows:
            for i, largeur in enumerate(largeurs):
                rangée.cells[i].width = Mm(largeur)
    return table


def _format_valeur(unite: str | None, valeur) -> str:
    if valeur is None:
        return "—"
    if unite == "%":
        return f"{valeur:.1f} %".replace(".", ",")
    if unite and "FCFA" in unite:
        entier = int(round(valeur))
        return f"{entier:,}".replace(",", " ") + " " + unite
    if abs(valeur - round(valeur)) < 1e-9:
        nombre = str(int(round(valeur)))
    else:
        nombre = f"{valeur:.2f}".rstrip("0").rstrip(".").replace(".", ",")
    return f"{nombre} {unite}" if unite else nombre


def _effet(effectif, denominateur) -> str:
    if denominateur is None:
        return str(effectif) if effectif is not None else "—"
    if effectif is None:
        return f"{denominateur} valeurs"
    return f"{effectif} / {denominateur}"


def _titre(doc: Document, niveau: int, texte: str) -> None:
    entete = doc.add_heading(texte, level=niveau)
    for run in entete.runs:
        run.font.color.rgb = BLEU
        run.font.name = "Calibri"


def _paragraphe(doc: Document, texte: str, taille: float = 10,
                italique: bool = False, couleur: RGBColor | None = None) -> None:
    p = doc.add_paragraph(texte)
    p.paragraph_format.space_after = Pt(6)
    _police(p, taille, italique=italique, couleur=couleur)


def _puce(doc: Document, texte: str) -> None:
    p = doc.add_paragraph(texte, style="List Bullet")
    p.paragraph_format.space_after = Pt(3)
    _police(p, 10)


def produire(payload: dict, sortie: Path = SORTIE) -> None:
    lignes = payload["resultats"]
    couverture = payload["couverture"]
    non_calc = payload["non_calculables"]
    meta = payload["metadata"]
    ensemble = [l for l in lignes if l["niveau"] == "Ensemble"]
    n = meta.get("n_apures", 663)

    doc = Document()
    section = doc.sections[0]
    section.page_width, section.page_height = Mm(210), Mm(297)
    section.left_margin = section.right_margin = Mm(18)
    section.top_margin = section.bottom_margin = Mm(16)
    style = doc.styles["Normal"]
    style.font.name = "Calibri"
    style.font.size = Pt(10)

    titre = doc.add_heading("Rapport explicatif des indicateurs COSO", level=0)
    for run in titre.runs:
        run.font.color.rgb = BLEU
        run.font.name = "Calibri"
    sous = doc.add_paragraph("Enquête téléphonique COSO — Programme Jeunesse · "
                             "résultats calculés à partir du questionnaire dédoublonné")
    _police(sous, 11, italique=True, couleur=GRIS)

    _tableau(doc, ["Élément", "Valeur"], [
        ["Population analysée", f"{n} candidats (complétude 1 ou 2, consentement = 1)"],
        ["Source", "02_bases/QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta"],
        ["Empreinte SHA-256 de la source",
         str(meta.get("sha256_source", ""))[:32] + "…"],
        ["Classeur associé", "04_resultats/indicateurs/Indicateurs_COSO.xlsx"],
        ["Date de génération", date.today().strftime("%d/%m/%Y")],
        ["Étapes de calcul", "07 apurement · 08 calcul · 09 Excel · 10 rapport · 11 contrôle"],
    ], largeurs=[55, 120])
    doc.add_paragraph()

    # 1 ------------------------------------------------------------------
    _titre(doc, 1, "1. Objet et sources")
    _paragraphe(doc,
                "Ce rapport présente l'ensemble des indicateurs calculés à partir de "
                "l'enquête téléphonique COSO, menée auprès des jeunes candidats du Programme "
                "Jeunesse. Il commente les résultats pour les 21 indicateurs du cadre "
                "officiel, blocs D1 à D11, pour l'ensemble de la population et six "
                "désagrégations (district, région, sexe, groupe d'âge, milieu).")
    _paragraphe(doc,
                "La source est le questionnaire dédoublonné "
                "QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta (962 entretiens), issu du pipeline de "
                "dédoublonnage. Le filtre de population — classe de complétude "
                "1-COMPLET ou 2-QUASI_COMPLET et consentement = 1 — retient 664 entretiens, "
                "dont 663 après exclusion d'un entretien sans consentement. Toutes les "
                "décompositions de ce rapport portent sur ces 663 candidats, sauf mention "
                "explicite d'un dénominateur propre.")
    _paragraphe(doc,
                "Aucune donnée nominative (nom, téléphone, noms propres de répondants) "
                "ne figure dans les livrables : le classeur et ce rapport s'appuient sur la "
                "copie apurée dont les colonnes identifiantes ont été retirées "
                "à l'étape 07.")

    # 2 ------------------------------------------------------------------
    _titre(doc, 1, "2. Chaîne de traitement")
    _paragraphe(doc,
                "Les étapes 01 à 06 construisent et contrôlent la base ; les étapes 07 à 11 "
                "produisent les indicateurs. Chaque étape est un script indépendant, "
                "relançable, écrit dans un dossier de sortie dédié.")
    _tableau(doc, ["Étape", "Rôle", "Sortie principale"],
             [[e, r, s] for e, r, s in CHAINE], largeurs=[14, 96, 65])
    doc.add_paragraph()

    # 3 ------------------------------------------------------------------
    _titre(doc, 1, "3. Règles de calcul")
    _paragraphe(doc,
                "Les règles ci-dessous sont appliquées uniformément à tous les indicateurs "
                "et à tous les sous-groupes. Elles sont reprises, à l'identique, dans la "
                "feuille « Methode » du classeur Excel.")
    _tableau(doc, ["Rubrique", "Contenu"],
             [[rubrique, contenu] for rubrique, contenu in mod09.METHODE],
             largeurs=[36, 139])
    doc.add_paragraph()

    # 4 ------------------------------------------------------------------
    _titre(doc, 1, "4. Couverture des 21 indicateurs")
    _paragraphe(doc,
                "Sur les 21 indicateurs du cadre officiel, 8 sont calculés, 3 sont partiels "
                "(composantes partiellement couvertes par le questionnaire) et 10 sont "
                "indisponables faute de source dans l'enquête téléphonique. Trois "
                "indicateurs — 1.1, 1.2 et 1.3 — sont explicitement réservés "
                "« en attente » : leur calcul suppose le registre d'enrôlement et les "
                "statuts de sélection, hors périmètre de cette enquête.")
    _tableau(doc,
             ["Code", "Indicateur", "Statut", "Mesures calculées", "Limite / registre requis"],
             [[e["code"], e["indicateur"], e["statut"], ", ".join(e["mesures"]), e["limite"]]
              for e in couverture], largeurs=[12, 42, 20, 45, 56], corps=8)
    table = doc.tables[-1]
    for i, e in enumerate(couverture, start=1):
        couleur = (VERT if e["statut"] == "calculé" else ORANGE if e["statut"] == "partiel"
                   else GRIS_ETAT if e["statut"] == "en attente" else ROUGE)
        _ombrage(table.rows[i].cells[2], couleur)
    doc.add_paragraph()

    _titre(doc, 2, "4.1 Indicateurs non calculables")
    _tableau(doc, ["Code", "Indicateur", "Statut", "Raison"],
             [[e["code"], e["indicateur"], e["statut"], e["raison"]] for e in non_calc],
             largeurs=[12, 42, 20, 101], corps=8)
    doc.add_paragraph()

    # 5 ------------------------------------------------------------------
    _titre(doc, 1, "5. Résultats par bloc")
    _paragraphe(doc,
                f"Chaque tableau donne, pour l'ensemble des {n} candidats, la mesure "
                "principale de chaque indicateur du bloc et, le cas échéant, la répartition "
                "par modalité. « Eff. / Dénom. » rappelle le numérateur et le dénominateur "
                "propres à la mesure : les questions posées sous condition de saut ou "
                "restreintes à une sous-population ont un dénominateur inférieur à 663. "
                "Les lignes sans numérateur (médianes) affichent dans la dernière colonne "
                "le nombre de valeurs utilisées.")
    ordre = sorted({l["bloc"] for l in ensemble})
    ordre.sort(key=lambda b: (int("".join(c for c in b.split(" ")[0] if c.isdigit())), b))
    for bloc in ordre:
        if not bloc.startswith("D"):
            continue
        _titre(doc, 2, bloc)
        lignes_bloc = [l for l in ensemble if l["bloc"] == bloc]
        tableau = _tableau(doc, ["Code", "Mesure", "Modalité", "Valeur", "Eff. / Dénom."],
                           [[l["code"], l["mesure"],
                             l["modalite"] or "—",
                             _format_valeur(l["unite"], l["valeur"]),
                             _effet(l["effectif"], l["denominateur"])]
                            for l in lignes_bloc],
                           largeurs=[13, 74, 40, 24, 24], corps=8)
        for i, l in enumerate(lignes_bloc, start=1):
            cellule = tableau.rows[i].cells[3]
            cellule.paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.RIGHT
        notes = [l for l in lignes_bloc if l["precision"]]
        if notes:
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(3)
            p.paragraph_format.space_after = Pt(10)
            run = p.add_run("Notes — " + " · ".join(
                f"{l['code']} : {l['precision']}" for l in notes))
            run.font.size = Pt(8)
            run.italic = True
            run.font.color.rgb = GRIS

    # 6 ------------------------------------------------------------------
    _titre(doc, 1, "6. Codages des questions ouvertes")
    _paragraphe(doc,
                "Quatre questions du questionnaire sont ouvertes (saisie libre). Elles sont "
                "codées ici par mots-clés, à des fins descriptives uniquement : le codage "
                "n'est pas un codage officiel, il classe chaque réponse dans la famille de "
                "mots-clés la plus proche. Les réponses restées vides ne comptent pas dans "
                "les dénominateurs ; les réponses non reconnues sont regroupées en "
                "« Autre ou non précisé ».")
    familles = ", ".join(nom for nom, _ in mod08.FAMILLES_METIER)
    _paragraphe(doc, f"Familles de métiers et d'activités retenues : {familles}.")
    obstacle = ", ".join(nom for nom, _ in mod08.FAMILLES_OBSTACLE)
    _paragraphe(doc, f"Familles d'obstacles retenues : {obstacle}.")

    codages = [
        ("D8.11", "Métier ou activité visé à 5 ans (P1)"),
        ("D8.12", "Domaine de formation visé (O4)"),
        ("D8.3", "Obstacle principal à la réalisation du projet (P5)"),
        ("D3.11", "Nature de l'autre activité (G5A)"),
    ]
    for code, intitule in codages:
        rows = [l for l in ensemble if l["code"] == code and l["modalite"]]
        if not rows:
            continue
        _titre(doc, 2, f"6.{[c for c, _ in codages].index(code) + 1} {intitule}")
        _tableau(doc, ["Modalité codée", "Part", "Eff. / Dénom."],
                 [[l["modalite"], _format_valeur(l["unite"], l["valeur"]),
                   _effet(l["effectif"], l["denominateur"])] for l in rows],
                 largeurs=[90, 30, 55], corps=8.5)
        doc.add_paragraph()

    # 7 ------------------------------------------------------------------
    _titre(doc, 1, "7. Sous-groupes")
    vus: dict[tuple, int] = {}
    for l in lignes:
        cle = (l["niveau"], l["district"], l["region"], l["sexe"],
               l["age_groupe"], l["milieu"])
        vus[cle] = l["n_groupe"]
    _paragraphe(doc,
                "Le classeur Excel décline tous les indicateurs selon six niveaux "
                "d'agrégation — Ensemble, district, région, sexe, groupe d'âge, milieu — "
                "soit 23 groupes au total. Chaque ligne du classeur porte le nom du groupe "
                "et sa taille : c'est cette taille, et non 663, qui sert de dénominateur.")
    _tableau(doc, ["Niveau", "Clé", "Effectif", "Part de l'ensemble"],
             [[cle[0], " · ".join(str(x) for x in cle[1:] if x) or "Ensemble",
               str(n_groupe), f"{100 * n_groupe / n:.1f} %".replace(".", ",")]
              for cle, n_groupe in sorted(vus.items())],
             largeurs=[30, 95, 22, 28], corps=8.5)
    doc.add_paragraph()

    _titre(doc, 2, "7.1 Lecture par district")
    _paragraphe(doc,
                "Quatre indicateurs, en écart entre districts, illustrent la lecture "
                "des désagrégations. Les écarts sont descriptifs : aucun test "
                "d'hypothèse n'est réalisé et aucun plan de sondage représentatif "
                "n'est fourni.")
    cibles = [
        ("D3.1", "Statut d'activité observé", "En emploi", "Part des personnes en emploi"),
        ("D8.1", "Formation ou apprentissage durant les 12 derniers mois", "",
         "Part ayant suivi une formation"),
        ("D7.1", "Possède un compte Mobile Money", "",
         "Part détenant un compte Mobile Money"),
        ("D10.1", "Ménage ayant subi un choc ou problème important", "",
         "Part ayant subi un choc"),
    ]
    lignes_districts = []
    for code, mesure, modalite, libelle in cibles:
        rows = [l for l in lignes if l["niveau"] == "District"
                and l["code"] == code and l["mesure"] == mesure
                and l["modalite"] == modalite and l["denominateur"]]
        rows.sort(key=lambda l: l["valeur"])
        if len(rows) >= 2:
            bas, haut = rows[0], rows[-1]
            lignes_districts.append([
                libelle,
                f"{bas['district']} ({_format_valeur('%', bas['valeur'])}, "
                f"{bas['effectif']}/{bas['denominateur']})",
                f"{haut['district']} ({_format_valeur('%', haut['valeur'])}, "
                f"{haut['effectif']}/{haut['denominateur']})",
                f"{haut['valeur'] - bas['valeur']:.1f} pts".replace(".", ","),
            ])
    _tableau(doc, ["Indicateur", "District le plus bas", "District le plus haut",
                   "Écart"], lignes_districts, largeurs=[56, 52, 52, 15], corps=8.5)
    doc.add_paragraph()

    # 8 ------------------------------------------------------------------
    _titre(doc, 1, "8. Limites")
    for texte in [
        "Enquête téléphonique et déclaratif : les revenus, heures et patrimoines "
        "sont déclarés, sans vérification terrain ni pièce justificative.",
        "Cadre non probabiliste : l'enquête couvre les candidats joignables du "
        "programme ; aucun résultat n'est extrapolable à l'ensemble des jeunes du pays.",
        "Statuts descriptifs : les écarts entre districts, sexes ou âges sont "
        "descriptifs, sans inférence statistique.",
        "Sauts de questionnaire : certaines questions ne sont posées qu'à des "
        "sous-populations (demandeurs d'emploi, salariés, porteurs de dette). Leur "
        "dénominateur propre est toujours affiché ; une question non posée n'est jamais "
        "comptée comme « non ».",
        "Codages ouverts : les quatre familles de mots-clés (section 6) sont "
        "descriptives et non officielles ; elles restent à relire par l'équipe projet.",
        "1.1, 1.2 et 1.3 restent en attente : leur valeur définitive dépend du registre "
        "d'enrôlement, des statuts de sélection et de la convention de dénominateur "
        "arrêtée par le projet.",
        "Qualité de collecte : 71 signalements d'incohérence sur 663 entretiens "
        "ont été audités à l'étape 07 (âge, dates hors parcours, heures, montants "
        "non quantifiés) ; les entretiens sont conservés, les valeurs non "
        "vraisemblables sont laissées vides, jamais corrigées.",
        "Petits effectifs : plusieurs sous-groupes ont un dénominateur inférieur "
        "à 30 ; ces mesures portent la mention « Effectif faible » dans le classeur.",
    ]:
        _puce(doc, texte)

    # 9 ------------------------------------------------------------------
    _titre(doc, 1, "9. Reproductibilité")
    _paragraphe(doc,
                "Tout le calcul est rejouable de bout en bout depuis le dossier du projet :")
    for commande in [
        "bash 03_pipeline/executer.sh          # étapes 01 → 11",
        "python3 03_pipeline/07_apurement_indicateurs.py",
        "python3 03_pipeline/08_calcul_indicateurs.py",
        "python3 03_pipeline/09_excel_indicateurs.py",
        "python3 03_pipeline/10_rapport_indicateurs.py",
        "python3 03_pipeline/11_verifier_indicateurs.py",
    ]:
        p = doc.add_paragraph()
        run = p.add_run(commande)
        run.font.name = "Courier New"
        run.font.size = Pt(9)
        p.paragraph_format.space_after = Pt(2)
    _paragraphe(doc,
                "L'étape 11 contrôle l'intégrité des livrables (effectifs de population, "
                "unicité des clés, absence de données nominatives, additivité des "
                "sous-groupes, repères de valeurs, feuilles du classeur, structure du "
                "présent document). Les sorties intermédiaires (base_apuree.csv, "
                "meta_apurement.json) portent l'empreinte SHA-256 de la source, "
                "ce qui permet de vérifier que les livrables correspondent bien au "
                "fichier de données utilisé.")
    _paragraphe(doc,
                "Fichiers produits dans 04_resultats/indicateurs/ : indicateurs.json "
                "(données machine), Indicateurs_COSO.xlsx (7 feuilles : Methode, "
                "Synthese_globale, Modalites, Sous_groupes, Couverture_21, "
                "Non_calculables, Meta), Rapport_indicateurs_COSO.docx (ce document).",
                italique=True, couleur=GRIS)

    zoom = doc.settings.element.find(qn("w:zoom"))
    if zoom is not None and zoom.get(qn("w:percent")) is None:
        zoom.set(qn("w:percent"), "100")

    sortie.parent.mkdir(parents=True, exist_ok=True)
    doc.save(sortie)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--indicateurs", type=Path, default=INDICATEURS)
    parser.add_argument("--sortie", type=Path, default=SORTIE)
    args = parser.parse_args()
    charge = json.loads(args.indicateurs.read_text(encoding="utf-8"))
    produire(charge, args.sortie)
    print(f"{args.sortie.name} : {len(charge['resultats'])} lignes de résultats, "
          f"{len(charge['couverture'])} indicateurs")
