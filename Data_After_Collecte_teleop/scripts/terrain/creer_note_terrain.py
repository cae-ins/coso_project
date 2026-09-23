# -*- coding: utf-8 -*-
"""Note d'une page : comment l'on passe de 1 032 fiches à 962 candidats."""

import sys, os, pyreadstat, pandas as pd
sys.path.insert(0, os.path.expanduser("~/.claude/skills/note-docx-sobre/scripts"))
from docx_sobre import Note

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(os.path.dirname(ICI))     # racine du projet
OUT  = os.path.join(RACINE, "MIGONE", "resultats_croisement", "Note_CANDIDAT_ENQUETE_TERRAIN.docx")

avec, _ = pyreadstat.read_dta(os.path.join(RACINE, "resultats", "Questionnaire_COSO_VF_avec_completude.dta"))
final, _ = pyreadstat.read_dta(os.path.join(RACINE, "resultats", "QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta"))
terr = pd.read_excel(os.path.join(RACINE, "MIGONE", "outputs", "CANDIDAT_ENQUETE_TERRAIN.xlsx"), sheet_name="Enquete terrain")

g = avec.groupby("cover_id").size().value_counts().sort_index()

comp = int((final['classe_completude'] == '1-COMPLET').sum())
quasi = int((final['classe_completude'] == '2-QUASI_COMPLET').sum())
incomp = int((final['classe_completude'] == '4-INCOMPLET').sum())
vide = int((final['classe_completude'] == '5-VIDE').sum())
moyen = int((final['classe_completude'] == '3-MOYEN').sum())
cq = comp + quasi

nbp = int((g.index * g).sum())
lignes = [[f"{int(k)} fiche" if int(k) == 1 else f"{int(k)} fiches", int(v), int(k * v)]
          for k, v in g.items()]

n = Note(entete="COSO. Enquête terrain", pied="Analyse de complétude. Usage interne")
n.bandeau("République de Côte d'Ivoire", "COSO, enquête de complétude")
n.titre_note("NOTE",
             "Constitution de la base de 962 candidats à partir du questionnaire")
n.bloc_identification([
    ("Objet", "Expliquer le passage de 1 032 fiches brutes à 962 candidats uniques, "
              "puis à la liste des candidats à enquêter sur le terrain"),
    ("Sources", "Questionnaire COSO via Survey Solutions, croisements téléphoniques et projet COSO"),
])

n.titre("Pourquoi 962 candidats ?", 1)
n.p([("Le questionnaire comporte ", False), ("1 032 fiches", True),
     (" pour ", False), ("962 candidats distincts", True),
     (" : un même candidat peut avoir été interviewé plusieurs fois. Le doublon se définit "
      "par le candidat (identifiant cover_id) et non par le couple nom-téléphone, car un "
      "candidat peut être rappelé sur plusieurs numéros qui diffèrent d'une fiche à l'autre. "
      "La répartition des fiches par candidat est la suivante.", False)])
n.tableau(["Nombre de fiches par candidat", "Candidats", "Fiches"],
          lignes + [["Total", int(final['cover_id'].nunique()), nbp]],
          widths=[5.1, 2.8, 2.2], fs=9.5,
          legende="Répartition des 1 032 fiches entre les 962 candidats.")
n.p([("Pour chaque candidat, ", False), ("une seule fiche est conservée", True),
     (", la plus complète : taux de complétude le plus élevé, puis nombre de questions "
      "renseignées, puis classe de qualité (COMPLET avant QUASI COMPLET, MOYEN, INCOMPLET, "
      "VIDE). On passe ainsi de ", False), ("1 032 fiches (962 candidats) à 962 fiches (962 "
      "candidats)", True), (", soit ", False), ("70 fiches de doublons écartées", True),
     (" ; chaque candidat est désormais représenté une et une seule fois.", False)])
n.p([("La qualité des 962 fiches retenues se répartit ainsi : ", False),
     (f"{comp} COMPLET", True), (f", {quasi} QUASI COMPLET, {incomp} INCOMPLET, {moyen} MOYEN et "
      f"{vide} VIDES.", False),
     (" Les ", False), (f"{cq} candidats COMPLET et QUASI COMPLET", True),
     (" sont déjà pourvus d'une bonne fiche : ils sont retirés de la liste des contacts, qui "
      "passe ainsi de 1 688 à ", False), (f"{len(terr)} candidats", True),
     (". Cette liste finale, celle des candidats à enquêter sur le terrain, compte 266 "
      "candidats identifiés comme devant être refaits ; le détail des motifs figure dans le "
      "fichier associé.", False)])
n.p([("Les traitements sont reproductibles : le dédoublonnage est scripté dans "
      "06_pipeline_doublons.py et le croisement des listes dans croisement_migone.py.", False)],
     size=9.5)

n.save(OUT)
from docx import Document
d = Document(OUT)
print("OK ->", OUT)
print("car.", sum(len(p.text) for p in d.paragraphs))