# Pipeline COSO

Le [rapport méthodologique](rapport_methodologique.md) explique les définitions, les
dénominateurs, les exclusions, les codages et les limites des 21 indicateurs.

## Chaîne d'exécution

| Étape | Code | Entrée | Sortie |
| --- | --- | --- | --- |
| **01** Complétude logique | `01_completude_logique.py` | `02_bases/` | `04_resultats/traitement/Questionnaire_COSO_VF_avec_completude.dta` |
| **02** Note de complétude | `02_generer_notes.py` | résultat 01 | `06_notes/Note_Methodologique_Completude.docx/.pdf` |
| **03** Contrôle des bases | `03_lire_verifier_bases.py` | `02_bases/` (lecture seule) | rapport console `[OK]` / `[ERREUR]` |
| **04** Note des manquants | `04_generer_note_manques.py` | résultat 01 | `06_notes/Note_Pourquoi_Incompletes.docx/.pdf` |
| **05** Rattrapage terrain | `05_generer_rattrapage.py` | résultat 01 | `04_resultats/traitement/rattrapage_terrain.xlsx` + note |
| **06** Dédoublonnage | `06_pipeline_doublons.py` | résultat 01 | `04_resultats/traitement/QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta` (962) |
| **07** Apurement | `07_apurement_indicateurs.py` | DTA dédoublonné | `base_apuree.csv` (664) + `meta_apurement.json` |
| **08** Calcul | `08_calcul_indicateurs.py` | base apurée | `04_resultats/indicateurs/indicateurs.json` |
| **09** Excel | `09_excel_indicateurs.py` | indicateurs.json | `Indicateurs_COSO.xlsx` (7 feuilles) |
| **10** Rapport Word | `10_rapport_indicateurs.py` | indicateurs.json | `Rapport_indicateurs_COSO.docx` |
| **11** Contrôle | `11_verifier_indicateurs.py` | base + livrables | 68 contrôles console, sans fichier modifié |
| **12** Variables programme | `12_variables_programme.py` | base apurée + DTA | `04_resultats/analyse_programme/base_programme.csv` |
| **13** Indicateurs programme | `13_indicateurs_programme.py` | base programme + `01_sources/maf_sonet_ci.csv` | `indicateurs_programme.json` |
| **14** Excel programme | `14_excel_programme.py` | indicateurs_programme.json | `Analyse_Programme_COSO.xlsx` (12 feuilles) |
| **15** Note programme | `15_note_programme.py` | indicateurs_programme.json | `Note_Analyse_Programme_COSO.docx` |
| **16** Contrôle programme | `16_verifier_programme.py` | base + livrables programme | contrôles console, sans fichier modifié |

Pour tout relancer depuis la racine du dossier :

```bash
bash 03_pipeline/executer.sh                 # étapes 01 → 16
COSO_PYTHON=/opt/anaconda3/bin/python3 bash 03_pipeline/executer.sh
```

Chaque étape est relançable isolément (`python3 03_pipeline/08_calcul_indicateurs.py`) ;
elles sont indépendantes et s'arrêtent au premier échec dans `executer.sh`.

## Volet « analyse programme » (étapes 12 → 16)

Les étapes 12 à 16 reproduisent, sur **notre population inchangée** (664 candidats de
`base_apuree.csv`), les analyses de conception de programme présentes dans les do-files
d'Arthur et absentes du pipeline officiel : filières A/B/C (P2), concentration et
saturation sectorielles, adéquation formation ↔ aspiration, signes de vulnérabilité du
ménage, codage des métiers et gap technique, écart offre/demande MAF (SONET-CI),
planification géographique, revenus/heures avec quartiles, et croisements à deux
dimensions.

Ce volet est **séparé** du rapport officiel des 21 indicateurs : il contient des scores
composites (`vuln_score`, `gap_score`/`gap_level`) et une donnée externe (matrice MAF
SONET-CI), étiquetés « exploratoire ». Il ne doit pas être présenté comme un résultat de
suivi-évaluation validé. Détails et réserves dans `Note_Analyse_Programme_COSO.docx`.

- `lib_programme.py` : codage des secteurs (`O4`, `P4X`) et des métiers (`P1`), signes de
  vulnérabilité, pénalités du gap, revenus mensualisés, indicateurs géographiques.
- `01_sources/maf_sonet_ci.csv` : matrice de référence SONET-CI (sept. 2026), transcrite
  du do-file d'Arthur (14 métiers × 10 régions = 140 cellules). Attention : la matrice
  totalise 461 MAF, alors que le rapport SONET-CI annonce 477 au total (écart de 16 non
  ventilable par région dans la source). La matrice est aussi embarquée dans
  `lib_programme.py` (les `.csv` sont exclus du dépôt par `.gitignore`).
- `--sector-match corrige|litteral` (étape 12) : le do-file d'Arthur applique au
  `sector_match` un décalage (+1) par rapport au codage officiel F2 ; `corrige` (défaut)
  rétablit son intention, `litteral` reproduit le code tel quel.

## Fichiers d'appui

- `libelles_coso.py` : dictionnaire `LIBELLES` (94 variables et leurs modalités),
  régénérable depuis le codebook `05_docs/codebook_*.xlsx` ;
- `rapport_methodologique.md` : définitions, dénominateurs, audit et limites ;
- `heritage/analyse_pipeline/` : version antérieure du pipeline (01–04), conservée
  pour référence ; `heritage/` contient aussi les scripts de travail terrain récupérés ;
- `terrain/` : création des bases terrain, affectation et croisements MIGONE.

## Prérequis

Python avec `pandas`, `numpy`, `openpyxl` et `python-docx`
(interpréteur par défaut : `/opt/anaconda3/bin/python3` s'il existe, sinon
`python3` ; modifiable par `COSO_PYTHON`). Fermer le classeur Excel avant de relancer l'étape 09.
Les étapes 01 à 06 sont idempotentes : elles régénèrent leurs sorties à l'identique,
hors horodatages internes des fichiers et date du jour des notes.
