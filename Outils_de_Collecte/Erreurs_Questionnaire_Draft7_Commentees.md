# Erreurs du questionnaire COSO — Draft 7 (fiche commentée)

**Date de la fiche :** 30 juin 2026
**Audit source :** `Analyse/Analyse_Matrice_Effets_Questionnaire_Draft7.md` (27 juin 2026)
**Questionnaire concerné :** `Outils_de_Collecte/Questionnaire_COSO_Draft_7.docx`
**Statut :** ces erreurs ont motivé la production du **Draft 8** (`Questionnaire_COSO_Draft_8_Proposition`).
La présente fiche les reliste de façon commentée pour la relecture et le suivi de correction.

> **Lecture :** chaque entrée indique l'erreur, *pourquoi* c'est un problème, et *la correction
> attendue*. Aucune erreur nouvelle n'est ajoutée : le contenu est repris fidèlement de l'audit.

---

## Partie A — Erreurs de logique / codification

À corriger **avant** toute programmation du questionnaire (filtres, variables dérivées, sauts).

| # | Code / localisation | Erreur | Commentaire (problème → correction) |
|---|---|---|---|
| A1 | Variable dérivée `EMPLOYÉ` | Formule construite sur `D1/D2/D3` au lieu de `E1/E2/E3A` | **Problème :** la variable d'emploi pointe vers les mauvaises sections → statut d'activité faux pour tout le monde. **Correction :** `EMPLOYÉ = E1==1 \|\| E2==1 \|\| (E3==1 && E3A==1)`. |
| A2 | Variable `NON EMPLOYÉ` | Utilisée sans être définie | **Problème :** variable invoquée mais jamais construite → indicateurs de chômage/inactivité incalculables. **Correction :** définir explicitement `NON_EMPLOYÉ = 1 - EMPLOYÉ`. |
| A3 | Section B — `B6A`/`B6B` | Doublon `B6B`, `B6A` apparemment absent | **Problème :** numérotation incohérente → risque de collision de variables à l'export. **Correction :** rétablir `B6A`, supprimer le doublon. |
| A4 | Filtre `C2` | Renvoie vers `B2A` au lieu de `C2A` | **Problème :** saut mal dirigé → le répondant saute la mauvaise question. **Correction :** rediriger le filtre `C2` vers `C2A`. |
| A5 | Saut `N1 = Non` | Renvoie vers `L6A` au lieu de `N6A` | **Problème :** sortie du module chocs vers un mauvais point → données manquantes structurelles indues. **Correction :** `N1=Non → N6A`. |
| A6 | Bloc `Code O2` | Bloc orphelin placé après `O6` | **Problème :** bloc mal positionné dans le flux → ambiguïté de saisie/exploitation. **Correction :** nettoyer / repositionner le bloc `O2`. |
| A7 | Filtres `R1A–R3B` | Renvoient vers `P1–P3A` au lieu de `R1–R3A` | **Problème :** sauts du module R dirigés vers le module P → parcours incohérent. **Correction :** rediriger vers `R1–R3A`. |
| A8 | Module `N` | Modalités non numérotées sur une partie du module | **Problème :** modalités sans code → recodage et exploitation impossibles de façon déterministe. **Correction :** numéroter toutes les modalités. |
| A9 | Question `Q10` | Typo « Ne sait pa » | **Problème :** libellé de modalité erroné → incohérence de label, risque de mauvaise reconnaissance. **Correction :** corriger en « Ne sait pas ». |

---

## Partie B — Problèmes de mesure par indicateur d'effet

Gravité : **Critique** = indicateur non calculable robustement ; **Partiel** = calculable mais incomplet.

### 3.1 — Statut d'activité — **Critique**
- **Questions :** `E1–E3A`, `F1`, `J1–J3`.
- **Erreur :** chômage et inactivité ne sont pas séparables ; toute personne non employée est
  implicitement traitée comme « en recherche ».
- **Commentaire :** sans distinction recherche active / inactivité / découragement, l'indicateur
  d'emploi est biaisé. **Correction :** corriger `EMPLOYÉ` (cf. A1), définir `NON_EMPLOYÉ` (cf. A2),
  ajouter une question binaire de **recherche active** avant `J1`, poser `J1–J2` aux seuls chercheurs,
  ajouter le **motif de non-recherche**, conserver `J3` pour la disponibilité.

### 3.2 — Type d'activité et secteur — **Partiel**
- **Questions :** `F1–F3`, `G5`, `P4`.
- **Erreur :** le **métier/occupation actuel** n'est pas capté ; `P4` mesure le secteur *aspiré*,
  pas l'actuel ; l'activité secondaire signalée en `G5` n'est pas qualifiée.
- **Correction :** ajouter un libellé ouvert + code métier pour l'activité principale, et qualifier
  le secteur/métier de l'activité secondaire.

### 3.3 — Durée du travail — **Partiel**
- **Questions :** `F4`, `G3–G7`.
- **Erreur :** la matrice mélange **ancienneté** (`F4`) et **volume horaire** (`G3`, `G6`) ; `G4`
  demande si les heures sont habituelles sans recueillir leur valeur quand elles diffèrent ; `G7`
  capte le souhait de travailler plus mais pas la **disponibilité**.
- **Correction :** séparer ancienneté et heures hebdomadaires, recueillir les heures habituelles,
  ajouter la disponibilité à travailler davantage.

### 3.4 — Revenus / profit — **Critique**
- **Questions :** `H1–H5`, `L4`.
- **Erreur :** pour les indépendants, `H5` mélange **profit, retrait personnel et dépenses de base**
  → mesure inexploitable comme **outcome économique primaire**.
- **Correction :** remplacer `H5` par un bloc profit : (1) profit net du dernier mois après toutes
  les dépenses de l'activité et avant retrait personnel ; (2) mois normal/bon/mauvais ; (3) profit
  d'un mois normal ; (4) dépenses de l'activité ; (5) chiffre d'affaires de contrôle ; (6) capital
  productif si la durée le permet. Prévoir zéro, NSP/refus et unités explicites.

### 3.5 — Recherche d'emploi et contraintes — **Partiel**
- **Questions :** `I1–I3`, `J1–J3`, `K5`, `P5`.
- **Erreur :** pas de vraie question **recherche active oui/non** ; motifs de non-recherche et
  d'indisponibilité absents ; `P5` non codifié de façon exploitable.
- **Correction :** ajouter la question recherche active, les motifs, et distinguer recherche d'emploi
  salarié vs démarches entrepreneuriales.

### 3.6 — Formations / AGR — **Partiel**
- **Questions :** `K1–K5`, `O3–O6`, sections `E/F`.
- **Erreur :** exposition **COSO** non identifiée ; dates, durée, achèvement/abandon absents ;
  kit / fonds de roulement / coaching et démarrage effectif de l'activité appuyée non mesurés.
- **Correction :** mesurer l'exposition réelle et les autres programmes reçus côté questionnaire ;
  rattacher les produits administratifs au **SIG**.

### 3.7 — Chômage / sous-emploi — **Critique**
- **Questions :** `E1–E3A`, `J1–J3`, `G3`, `G6`, `G7`.
- **Erreur :** définitions incomplètes ; la **disponibilité** manque pour caractériser le sous-emploi.
- **Correction :** scinder **3.7a Taux de chômage** = chômeurs / (employés + chômeurs) et
  **3.7b Sous-emploi lié au temps** = être employé + travailler sous un seuil préspécifié + vouloir
  et être disponible pour travailler davantage (ajouter la disponibilité).

### 3.8 — Résilience économique — **Partiel**
- **Questions :** `D5` (actifs), `G5` (diversification), `L1–L9` (épargne/finance),
  `N1–N7` (choc, impact, réponse, récupération, capacité).
- **Erreur :** `N2–N5` conditionnelles à l'exposition ; `N4` ne retient qu'une stratégie ;
  exposition, capacité et conséquence sont confondues ; seuil **250 000 FCFA** en `N6A` non justifié ;
  aucun **poids** défini.
- **Correction :** construire séparément (1) une capacité ex ante applicable à tous, (2) l'impact et
  les stratégies négatives parmi les exposés, (3) une incidence non conditionnelle « choc avec
  stratégie négative », (4) une mesure d'insécurité alimentaire si ajoutée ; justifier le seuil.

### 3.9 — Statut socio-économique perçu — **Partiel (avancé)**
- **Questions :** `M1–M4`.
- **Erreur :** `M1` et `M4` potentiellement redondants ; `M2` est un fait, pas nécessairement une
  dépendance ; échelles hétérogènes ; `M4` à inverser ; sensibilité à la désirabilité sociale.
- **Correction :** analyser d'abord les items **séparément** ; ne construire un indice que si la
  cohérence empirique et théorique est suffisante ; inverser `M4` ; harmoniser les échelles.

### Indicateurs adjacents

**Exclusion sociale / perte d'espoir.** Le Draft 7 ne couvre pas correctement ce construit.
*Correction :* séparer l'exclusion objective et l'espoir/auto-efficacité ; utiliser le bloc proposé
dans `Questions_a_ajouter_COSO.md`, sous réserve de validation.

**Cohésion sociale (`Q1–Q10`).** Couvre appartenance associative, volontariat, confiances
généralisée/intergroupe/institutionnelle. *Manquent :* confiance intra-communautaire et réciprocité ;
sentiment d'appartenance ; sécurité ressentie et rejet de la violence ; participation au règlement
d'un conflit ; **voix dans les décisions communautaires** ; à l'endline, perception que les
investissements ont accru la confiance. *Correction :* compléter ces dimensions — les deux dernières
sont **nécessaires à l'alignement au cadre de résultats du PAD**.

---

## Rupture de numérotation (matrice d'indicateurs)

La matrice `Analyse/Indicteurs_COSO_Analysés.xlsx` (feuille `Analyse`) utilise des **codes d'une
version antérieure** : elle n'est pas utilisable telle quelle avec le Draft 7 et doit être remappée
après stabilisation du questionnaire.

| Thème | Codes de la matrice | Codes réels Draft 7 |
|---|---|---|
| Statut d'activité | `D1–D11`, `EN_EMP`, `J1–J11` | `E1–E3A`, `EMPLOYÉ`, `F1`, `J1–J3` |
| Type / secteur | `E1–E6`, `F4–F6`, `N4` | `F1–F3`, `G5`, `P4` (secteur aspiré) |
| Temps de travail | `I1`, `I2`, `I8`, `F8` | `G3–G7` |
| Revenu | `G3A–G4`, `G8–G11` | `H1–H5` |
| Formation | `M1–M6` | `O3–O6` |
| Résilience | `L1–L9`, `H7`, `L6–L8` | `D5`, `G5`, `L1–L9`, `N1–N7` |
| Statut socio-économique | `K1–K8` | `M1–M4` |
| Cohésion sociale | `O1–O5F` | `Q1–Q10` |

---

## Ordre de correction (checklist commentée)

### Priorité 0 — bloquant
- [ ] Corriger codes, filtres et variables dérivées (A1–A9).
- [ ] Rendre calculables emploi, chômage et inactivité (3.1, 3.7).
- [ ] Remplacer `H5` par une vraie mesure du profit (3.4).
- [ ] Compléter les conditions du sous-emploi — ajouter la disponibilité (3.7).
- [ ] Nettoyer le bloc `O2` (A6).

### Priorité 1 — structuration
- [ ] Définir indicateurs, dénominateurs et sens de chaque item.
- [ ] Séparer chômage et sous-emploi (3.7a / 3.7b).
- [ ] Distinguer capacité, exposition et conséquence du choc (3.8).
- [ ] Définir le score `M1–M4` (3.9).
- [ ] Ajouter métier actuel (3.2) et heures habituelles (3.3).

### Priorité 2 — alignement bailleur
- [ ] Séparer exclusion et espoir.
- [ ] Compléter la cohésion (confiance intra-communautaire, appartenance, sécurité, conflit).
- [ ] Ajouter la **participation aux décisions** communautaires.
- [ ] Prévoir les indicateurs PAD à l'endline.
- [ ] Documenter le rattachement du volet d'insertion au cadre de résultats du PAD.

---

*Source de référence à ne pas modifier : `Analyse/Analyse_Matrice_Effets_Questionnaire_Draft7.md`.*
