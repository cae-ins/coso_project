# Analyse COSO : complétude, dédoublonnage et indicateurs

Ce dossier retrace toute la chaîne de traitement des données de l'enquête
téléphonique COSO, de la base de départ jusqu'aux indicateurs calculés :

```
01_sources/ + 02_bases/                base de départ
        │
        ▼  03_pipeline/01 … 06         complétude logique, notes, rattrapage, dédoublonnage
        │
04_resultats/traitement/
   QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta   base dédoublonnée (962 entretiens)
        │
        ▼  03_pipeline/07 … 11         apurement, calcul des indicateurs, Excel, Word, contrôle
        │
04_resultats/indicateurs/              Excel des indicateurs + rapport Word explicatif
```

## Arborescence

```
Data_After_Collecte_teleop/
├── README.md                     <- ce fichier (chaîne complète)
├── 01_sources/                   <- BASE DE DÉPART : fichiers projet, contacts, affectation
├── 02_bases/                     <- bases .dta intermédiaires puis finale
│   ├── Questionnaire_COSO_V5.dta             (1032 x 218, protocole final)
│   ├── Questionnaire_COSO_VF.dta             (1032 x 218, fusion V4+V5)
│   ├── Questionnaire_COSO_VF_avec_completude.dta  (BASE FINALE + taux/classe)
│   └── QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta  (copie de travail dédoublonnée)
├── 03_pipeline/                   <- CODE DE TRAITEMENT, dans l'ordre d'exécution
│   ├── 01_completude_logique.py     completude logique (skip logic) → resultats/traitement
│   ├── 02_generer_notes.py          note Word/PDF de completude
│   ├── 03_lire_verifier_bases.py    contrôle des 8 bases (lecture seule)
│   ├── 04_generer_note_manques.py   note « Pourquoi incomplètes »
│   ├── 05_generer_rattrapage.py     fichier de rattrapage terrain
│   ├── 06_pipeline_doublons.py      dédoublonnage → QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta
│   ├── 07_apurement_indicateurs.py  filtre population → base_apuree.csv + meta
│   ├── 08_calcul_indicateurs.py     calcul de tous les indicateurs → indicateurs.json
│   ├── 09_excel_indicateurs.py      classeur Excel multi-feuilles
│   ├── 10_rapport_indicateurs.py    rapport Word explicatif
│   ├── 11_verifier_indicateurs.py   contrôles de cohérence des livrables
│   ├── executer.sh                  lance 01 → 11 d'un coup
│   ├── README.md                    table des étapes 01 → 11
│   ├── rapport_methodologique.md    définitions, formules, limites
│   ├── heritage/                    anciens scripts (archives, non relancés)
│   └── terrain/                     scripts terrain (MIGONE)
├── 04_resultats/
│   ├── traitement/                  sorties des étapes 01 → 06
│   │   ├── QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta   BASE DÉDOUBLONNÉE (962)
│   │   ├── Questionnaire_COSO_VF_avec_completude.dta
│   │   ├── manquants_*.csv / recap_classes.csv / fichiers xlsx de décision
│   │   └── (étape 07) base_apuree.csv + meta_apurement.json
│   ├── indicateurs/                 sorties des étapes 07 → 11
│   │   ├── Indicateurs_COSO.xlsx            tous les indicateurs calculés
│   │   └── Rapport_indicateurs_COSO.docx    rapport explicatif
│   └── migone/                     affectations terrain + croisements MIGONE
├── 05_docs/                        documents d'analyse
│   ├── Indicteurs_COSO (1).xlsx    liste officielle des 21 indicateurs
│   ├── Liste_indicateurs_COSO.docx liste détaillée des indicateurs + formules
│   ├── codebook_QUESTIONNAIRE_VF_SANS_DOUBLON_VF.xlsx  (feuilles Variables/Codebook/Valeurs)
│   └── Original Questionnaire_COSO_V5.html  libellés des questions et sauts
└── 06_notes/                       notes méthodologiques (completude, rattrapage…)
```

## Les bases du dossier `02_bases/`

| Fichier | Lignes x Colonnes | Rôle |
|---|---|---|
| `Questionnaire_COSO_V4.dta` | 284 x 214 | protocole de départ (version 4) |
| `Questionnaire_COSO_V5.dta` | 1032 x 218 | protocole final (version 5) |
| `Questionnaire_COSO_VF.dta` | 1032 x 218 | base finale fusionnée V4+V5 |
| `Questionnaire_COSO_VF_avec_statut.dta` | 1032 x 220 | VF + colonnes de statut |
| `Questionnaire_COSO_TERMINES.dta` | 1032 x 220 | VF + statut terminé / catégorie |
| `Questionnaire_COSO_UTILISABLES.dta` | 841 x 218 | VF filtrée = interviews utilisables |
| `Questionnaire_COSO_VF_avec_completude_logique.dta` | 1032 x 222 | VF + version intermédiaire |
| `Questionnaire_COSO_VF_avec_completude.dta` | 1032 x 222 | **BASE FINALE** (taux + classe) |
| `QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta` | 962 x 218 | copie de travail = sortie du 06 |

Contrôle après toute manipulation :

```bash
python3 03_pipeline/03_lire_verifier_bases.py    # affiche [OK] ou [ERREUR] par base
```

## Étape clé : la base dédoublonnée

`04_resultats/traitement/QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta` (962 entretiens)
est la base de départ de l'analyse des indicateurs. Les colonnes `taux_completude`
et `classe_completude` permettent de filtrer :

| classe | effectif | % |
|---|---:|---:|
| 1-COMPLET (100 %) | 613 | 63,7 % |
| 2-QUASI_COMPLET (90–100 %) | 51 | 5,3 % |
| 3-MOYEN (50–90 %) | 9 | 0,9 % |
| 4-INCOMPLET (< 50 %) | 255 | 26,5 % |
| 5-VIDE (0 %) | 34 | 3,5 % |

Population analysée des indicateurs (étape 07) :

```
classe_completude ∈ {1-COMPLET, 2-QUASI_COMPLET}  ET  consentement = 1
→ 664 entretiens retenus au filtre de complétude, moins 1 sans consentement
→ 663 candidats (613 complets + 50 quasi complets consentants)
```

## Relancer la chaîne complète

Depuis la racine du dossier :

```bash
bash 03_pipeline/executer.sh        # étapes 01 → 11

# ou étape par étape :
python3 03_pipeline/01_completude_logique.py
python3 03_pipeline/06_pipeline_doublons.py    # → QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta
python3 03_pipeline/07_apurement_indicateurs.py
python3 03_pipeline/08_calcul_indicateurs.py
python3 03_pipeline/09_excel_indicateurs.py
python3 03_pipeline/10_rapport_indicateurs.py
python3 03_pipeline/11_verifier_indicateurs.py
```

Prérequis : Python (`pandas`, `numpy`, `openpyxl`, `python-docx`) —
interpréteur par défaut `/opt/anaconda3/bin/python3` s'il existe, sinon `python3`;
modifiable via `COSO_PYTHON`.
Fermer le classeur Excel avant de relancer.

## Sorties indicateurs

| Fichier | Contenu |
|---|---|
| `04_resultats/indicateurs/Indicateurs_COSO.xlsx` | 7 feuilles : Methode · Synthese_globale · Modalites · Sous_groupes · Couverture_21 · Non_calculables · Meta |
| `04_resultats/indicateurs/Rapport_indicateurs_COSO.docx` | Rapport Word : sources, règles de calcul, résultats par bloc, limites, reproductibilité |

Les définitions, formules, populations et limites sont détaillées dans
`03_pipeline/rapport_methodologique.md`.

## Affectation terrain (MIGONE)

```bash
python3 03_pipeline/terrain/creer_base_terrain.py    # CANDIDAT_ENQUETE_TERRAIN.xlsx
python3 03_pipeline/terrain/affectation_terrain.py   # AFFECTATION_COSO_TERRAIN_VF.xlsx
python3 03_pipeline/terrain/croisement_migone.py     # croisements dans 04_resultats/migone/
```

- Enquêteurs : liste définitive `COMPTE_AGENT_COSO_VF.xlsx` (58 agents) ;
  chaque région traite ses propres candidats. Max 3 entretiens/enqueteur/jour.
- 1024 candidats affectés en 13 jours ouvrés.
- BOUNKANI (110) est affecté à ses propres enquêteurs (6 jours).

## Robustesse de la méthodologie (complétude)

Les règles de saut (skip logic) ont été validées sur les 425 interviews de
référence (statut 100 et A4 = 1) : médiane du taux = 1,000 ; 406 des 425
(95,5 %) à exactement 100 % ; seulement 2 sous 90 %. La logique implémentée
reproduit bien le questionnement réellement appliqué.

Le détail des manques (interview × question) reste disponible dans
`04_resultats/traitement/manquants_id_detail.xlsx`.
