# Analyse de la completude logique des interviews COSO + affectation terrain (MIGONE)

Ce dossier retrace l'analyse realisee sur la base `Questionnaire_COSO_VF.dta`
(1032 interviews) visant a repondre a la question :

> **Combien d'interviews sont reellement totalement remplies, en tenant
> compte de la logique conditionnelle du questionnaire ?**

et la preparation de l'affectation terrain des candidats aux enqueteurs.

## Arborescence

```
Data_After_Collecte_teleop/
├── README.md
├── scripts/
│   ├── pipeline/                        <- pipeline d'analyse de completude
│   │   ├── 01_completude_logique.py     <- le calcul complet (simple, commente)
│   │   ├── 02_generer_notes.py          <- cree la note Word + PDF (relance le calcul)
│   │   ├── 03_lire_verifier_bases.py    <- lit et verifie toutes les bases (controle)
│   │   ├── 04_generer_note_manques.py   <- note "Pourquoi incompletes"
│   │   ├── 05_generer_rattrapage.py     <- fichier de rattrapage terrain
│   │   ├── 06_pipeline_doublons.py      <- dedoublonnage + fichiers de travail
│   │   └── heritage/                    <- anciens scripts (archives, non relances)
│   └── terrain/                         <- scripts MIGONE (terrain)
│       ├── affectation_terrain.py       <- affectation candidats/enqueteurs (V1 + V2)
│       ├── creer_base_terrain.py        <- base CANDIDAT_ENQUETE_TERRAIN
│       ├── creer_note_terrain.py        <- note CANDIDAT_ENQUETE_TERRAIN
│       ├── croisement_migone.py         <- croisement des listes MIGONE/COSO
│       └── croisement_migone_jaures.py  <- variante Jaures
├── bases/                     <- toutes les bases .dta utilisees (copies)
├── inputs/                    <- fichiers sources (affectation, contacts, projet...)
├── resultats/                 <- sorties du pipeline (dta, csv, xlsx)
│   ├── QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta   <- base dedoublonnee (962 interviews)
│   ├── Questionnaire_COSO_VF_avec_completude.dta
│   ├── manquants_par_classe.csv / recap_classes.csv
│   ├── manquants_id_detail.xlsx
│   └── fichiers xlsx de decision (318, 329, rattrapage...)
├── notes/                     <- notes Word/PDF/LaTeX de l'analyse
└── MIGONE/
    ├── outputs/               <- affectations terrain + base candidate enquete
    │   ├── AFFECTATION_COSO_TERRAIN_PLANIFIEE.xlsx  (V1 : BOUNKANI reporte)
    │   ├── AFFECTATION_COSO_TERRAIN_BOUNKANI_TCHOLOGO.xlsx  (V2 : BOUNKANI->TCHOLOGO)
    │   ├── CANDIDAT_ENQUETE_TERRAIN.xlsx
    │   └── QUESTIONNAIRE_VF_SANS_DOUBLON_VF.xlsx
    └── resultats_croisement/ <- croisements MIGONE (csv 01-06, xlsx 07-11, note)
```

## Les bases du dossier `bases/`

| Fichier | Lignes x Colonnes | Role |
|---|---|---|
| `Questionnaire_COSO_V4.dta` | 284 x 214 | protocole de depart (version 4) |
| `Questionnaire_COSO_V5.dta` | 1032 x 218 | protocole final (version 5) |
| `Questionnaire_COSO_VF.dta` | 1032 x 218 | base finale fusionnee V4+V5 |
| `Questionnaire_COSO_TERMINES.dta` | 1032 x 220 | VF + statut termine / categorie |
| `Questionnaire_COSO_VF_avec_statut.dta` | 1032 x 220 | VF + colonnes de statut |
| `Questionnaire_COSO_UTILISABLES.dta` | 841 x 218 | VF filtree = interviews utilisables |
| `Questionnaire_COSO_VF_avec_completude_logique.dta` | 1032 x 222 | VF + version intermediaire de completude |
| `Questionnaire_COSO_VF_avec_completude.dta` | 1032 x 222 | **BASE FINALE** (taux + classe completude) |

Toutes les cles (`interview__key`) de V5 sont identiques a VF ; TERMINES,
STATUT et la base finale contiennent exactement les memes interviews que
VF ; UTILISABLES est un sous-ensemble (841). La base V4 est un protocole
separe (les identifiants finals proviennent de V5).

Pour controler que tout est correct apres une manipulation :

```bash
python3 scripts/pipeline/03_lire_verifier_bases.py   # affiche [OK] ou [ERREUR] par base
```

## La base finale produit ce que vous avez demande

`bases/Questionnaire_COSO_VF_avec_completude.dta` = la base complete (toutes
les interviews, toutes les colonnes d'origine) **plus deux nouvelles colonnes**
qui permettent de filtrer facilement :

| colonne | sens | exemple |
|---|---|---|
| `taux_completude` | proportion de questions attendues remplies (0..1) | 0.98 = 98 % |
| `classe_completude` | classe de completude | `1-COMPLET` |

Classes possibles :
`1-COMPLET` · `2-QUASI_COMPLET` · `3-MOYEN` · `4-INCOMPLET` · `5-VIDE`

Exemple de filtre voulu (dans Stata, R, ou Excel) :
- retenir uniquement les interviews totalement remplies :
  `classe_completude == "1-COMPLET"`  →  627 interviews
- retenir les interviews completes et quasi-completes (base "fiable") :
  `classe_completude in {"1-COMPLET", "2-QUASI_COMPLET"}`  →  689 interviews

## Bilan (1032 interviews)

| classe | effectif | % |
|---|---|---|
| 1-COMPLET (100 %) | 627 | 60.8 % |
| 2-QUASI_COMPLET (90-100 %) | 62 | 6.0 % |
| 3-MOYEN (50-90 %) | 10 | 1.0 % |
| 4-INCOMPLET (<50 %) | 291 | 28.2 % |
| 5-VIDE (0 %) | 42 | 4.1 % |

Cela signifie que **627 interviews (60,8 %) sont totalement remplies** :
toutes les questions qui devaient leur etre posees selon la logique du
questionnaire ont ete repondues.

## Robustesse de la methodologie

Les regles de saut (skip logic) ont ete validees sur les **425 interviews de
reference** (statut 100 et A4 = 1, donc validees par le superviseur et
reellement conduites) :
- mediane du taux = **1.000** (la moitie est exactement a 100 %) ;
- **406 des 425** (95,5 %) sont exactement a 100 % ;
- seulement **2** sont sous 90 %.

Cela confirme que la logique implantee reproduit bien le questionnement
reellement applique, et n'est pas trop stricte.

## Detailler les manques (identifiants + questions)

Le fichier `resultats/manquants_id_detail.xlsx` contient une ligne par couple
*(interview, question manquante)* : classe de completude, nom de la question,
`interview__id` et `interview__key`. Il permet de :
- filtrer par classe (ex. `4-INCOMPLET` ou `5-VIDE`) ;
- recuperer les identifiants des interviews a revoir / recontacter ;
- compter, pour une question donnee, combien d'interviews la laissent vide.

```python
import pandas as pd
d = pd.read_excel("resultats/manquants_id_detail.xlsx")
ids_incompletes = d[d.classe == "4-INCOMPLET"]["interview__id"].unique()
```

## Relancer le pipeline complet

Depuis la racine du dossier :

```bash
python3 scripts/pipeline/01_completude_logique.py   # recalcule et reecrit la base + CSV
python3 scripts/pipeline/02_generer_notes.py        # relance le calcul puis reecrit Word/PDF
python3 scripts/pipeline/06_pipeline_doublons.py    # dedoublonnage + fichiers de decision
```

## Affectation terrain (MIGONE)

```bash
python3 scripts/terrain/creer_base_terrain.py       # CANDIDAT_ENQUETE_TERRAIN.xlsx
python3 scripts/terrain/affectation_terrain.py      # V1 + V2 dans MIGONE/outputs/
python3 scripts/terrain/croisement_migone.py        # croisements dans MIGONE/resultats_croisement/
```

- 58 enqueteurs (48 facilitateurs + 10 superviseurs), max 3 entretiens/jour.
- V1 : 914 candidats affectes en 8 jours ouvres, BOUNKANI (110) reporte.
- V2 : 1024 candidats en 9 jours, BOUNKANI confie aux enqueteurs TCHOLOGO
  (jours 6-9) apres leur charge locale.