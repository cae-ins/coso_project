# Cadre opérationnel des indicateurs d'effets — COSO Nord

**Version :** révision du 2 juillet 2026 (v2) — remplace la proposition du 27 juin 2026
**Questionnaire de référence :** Draft 7 (version du 01/07/2026) + Addendum chômage/sous-emploi
(`Outils_de_Collecte/Addendum_Draft7_Chomage_SousEmploi.md`)
**Compagnons :** `Matrice_Indicateurs_Eval_Impact_COSO.xlsx` (matrice complète TOC × éval) ·
`Cadre_Estimands_Impact_COSO.md` (machinerie ITT/LATE/CATE)
**Statut :** définitions et formules conceptuelles ; le code R/Stata est dérivé de ce cadre.

> **Changements v1 → v2** : (1) ré-ancrage de tous les codes sur le **V7 réel + addendum** (la v1
> référençait le Draft 8 non retenu : `PR*`, `FIES*`, `COH*`, `PSY*`, `G8`, `J4`, `O9`, `END7`) ;
> (2) décisions tranchées depuis le 27/06 intégrées (seuil 40 h ENE, définitions LU1–LU4 vérifiées
> contre le code ENE, hiérarchie des primaires) ; (3) ajout des emplois créés (`H4A`) ; (4) réserve
> de désirabilité sur le module M ; (5) items Draft 8 conservés mais marqués **[conditionnel]** —
> activés seulement si la Note de revue est adoptée.

## Principes *(inchangés — ils étaient bons)*

- Les règles du questionnaire sont distinguées des propositions à valider.
- Les données d'assignation, formation, kit et suivi viennent prioritairement du SIG.
- Une non-réponse réelle reste manquante.
- Un **zéro structurel** n'est créé que lorsque l'absence de l'activité est **observée**
  (ex. : `NON_EMPLOYE` observé ⇒ `profit = 0` ; `H5` manquant chez un indépendant ⇒ manquant).
- Pour l'effet causal principal, privilégier un outcome défini pour **toute la population
  randomisée** (non conditionnel).
- Les analyses conditionnelles aux employés ou aux entreprises actives sont secondaires et
  descriptives, car l'emploi et l'ouverture d'une activité sont eux-mêmes affectés par le traitement
  (biais de sélection post-traitement).

## Population et estimand

Randomisation confirmée (décision du 27/06/2026). Estimateur principal :

```text
Y_endline = α + β·ASSIGNATION + γ·Y_baseline + δ'STRATES + ε        (ANCOVA, ITT)
```

β est l'effet ITT. Estimateur secondaire : LATE par IV/2SLS, instrument = assignation, traitement
effectif = **formation achevée ET kit remis** (SIG). Détails : `Cadre_Estimands_Impact_COSO.md`.

**Hiérarchie des outcomes (harmonisée avec la matrice) :**

- **2 primaires** (testés sans correction) : **profit d'un mois ordinaire** (économie) et **indice
  de cohésion sociale** (bailleur).
- **Indices-résumés de famille** (un par famille C.1–C.5 et D) testés avec correction Romano-Wolf
  entre familles.
- Les composantes individuelles des familles sont exploratoires/descriptives.

## Cadre des effets

Colonne « Disponibilité » : **V7** = calculable avec le questionnaire actuel · **V7+A** = requiert
l'addendum · **[COND]** = requiert un ajout de la Note de revue · **SIG** = système d'information.

| Code | Indicateur | Définition descriptive | Variables | Disponibilité | Rôle |
|---|---|---|---|---|---|
| 3.1a | Taux d'emploi | `EMPLOYE` / population randomisée | `E1–E3A` | V7 | Famille C.1 |
| 3.1b | Activité indépendante active | `EMPLOYE & F1∈{2,3}` | `E1–E3A`, `F1` | V7 | Famille C.1 |
| 3.1c | Composition de l'emploi | parts par statut parmi les employés | `F1` | V7 | Descriptif |
| 3.1d | **Statut d'employeur** | `EMPLOYE & F1==2` | `F1` | V7 | Famille C.3 |
| 3.1e | **Emplois rémunérés créés** | `H4A` si `F1∈{2,3}` ; 0 sinon (non conditionnel) | `H4A`, `F1` | V7 | Famille C.3 |
| 3.2a | Secteur actuel | part par secteur parmi les employés | `F2` | V7 | Descriptif |
| 3.2b | Adéquation métier–appui | activité actuelle conforme au métier appuyé | libellé `F2` + SIG | V7+SIG (fragile : libellé libre) ; propre avec métier codé **[COND]** | Mécanisme |
| 3.3a | Heures hebdomadaires | `G3 + G6·(G5==1)` parmi les employés | `G3`, `G5`, `G6` | V7 | Descriptif |
| 3.3b | Heures non conditionnelles | heures ; **0 si `NON_EMPLOYE` observé** | statut + heures | V7 | Famille C.1 |
| 3.3c | Ancienneté dans l'activité | durée continue dans l'emploi principal | `F4` | V7 (tranches) | Famille C.1 (pérennité : `F4∈{3,4,5}`) |
| 3.4a | Revenu mensuel du travail | salaire mensualisé ou profit ; **0 si sans emploi observé** | `H2`, `H3`, profit | V7 partiel — propre avec MMW **[COND]** | Famille C.2 |
| 3.4b | Profit du dernier mois | profit net après dépenses, avant retrait personnel | `H5A` **[COND]** (le `H5` actuel amalgame) | **[COND]** | Robustesse |
| 3.4c | **Profit d'un mois ordinaire** | `H5A` si `H5B`=ordinaire, sinon `H5C` | `H5A–H5C` **[COND]** | **[COND]** | **PRIMAIRE économique** |
| 3.4d | Capital productif | valeur de revente équipement + stock | — | Absent du V7 **[COND]** | Famille C.2 |
| 3.5a | Recherche active d'emploi | a recherché sur 30 jours (non-employés) | `J0` | **V7+A** | Famille C.1 |
| 3.5b | Contrainte principale déclarée | distribution des obstacles | `I2`, `K5`, `P5`, `J0A` | V7 (+A pour `J0A`) | Descriptif |
| 3.6a | Formation récente | formés sur 12 mois / population | `O3` | V7 | 1er stade (enquête) |
| 3.6b | Formation gouvernementale | `O3==1 & O5==3` | `O3`, `O5` | V7 (proxy) — exposition COSO propre via SIG | 1er stade |
| 3.6c | Appui concurrent (contamination) | témoins ayant reçu formation/kit d'un programme | `O3`, `O5` + SIG | V7 (grossier) — propre **[COND]** | Qualité T2 |
| 3.7a | Taux de chômage (LU1) | `CHOMEUR / (EMPLOYE + CHOMEUR)` ; future starters inclus | `J0`, `J0A`, `J3` | **V7+A** | Famille C.1 |
| 3.7b | Sous-emploi horaire | `EMPLOYE & heures<40 & G7==1 & G7A==1` | `G3/G5/G6`, `G7`, `G7A` | **V7+A** | Famille C.1 |
| 3.7c | Sous-utilisation LU4 | `(CHOMEUR + sous_emp + MOP) / (main-d'œuvre élargie)` | + `J0B` | **V7+A** | Famille C.1 |
| 3.8a | Capacité de résilience (indice) | indice préspécifié : capacité d'urgence + capacité subjective + épargne + actifs + diversification | `N6A`, `N7`, `L3/L4`, `D5`, `G5` | V7 | Indice-résumé C.5 |
| 3.8b | Stratégie négative face au choc | vente d'actifs / réduction de consommation parmi les exposés | `N1`, `N4` | V7 ⚠ conditionnel au choc → descriptif | Descriptif |
| 3.8c | Récupération après choc | délai de retour au niveau antérieur parmi les exposés | `N5` | V7 ⚠ idem | Descriptif |
| 3.8d | Insécurité alimentaire (FIES) | score 0–8 | — | Absent du V7 **[COND]** | Famille C.5 si ajouté |
| 3.9a | Statut productif perçu | indice `M1`, `M3`, `M4` | `M1–M4` | V7 ⚠ **désirabilité** (libellés calqués sur la TOC → biais différentiel probable) | Famille C.4, à reporter avec 3.9b |
| 3.9b | **Indépendance vis-à-vis de l'aide** | `M2==3` (aucune aide externe 12 mois) — **factuel** | `M2` | V7 | **Ancre de la famille C.4** |
| 4.1a | Espoir / auto-efficacité | indice PSY | — | Absent du V7 **[COND]** | Famille C.5/psy si ajouté |
| 4.2a | Confiance généralisée | `Q3==1` | `Q3` | V7 (binaire, pas 0–10) | Famille D |
| 4.2b | Confiance intergroupe | `z(Q4)` | `Q4` | V7 (item unique, pas 3 items) | Famille D |
| 4.2c | Confiance institutionnelle | moyenne `z(Q5)…z(Q10)` | `Q5–Q10` | V7 (6 items) | Famille D |
| 4.2d | Appartenance / paix / sécurité | sous-indices séparés | — | Absent du V7 **[COND]** (Note de revue §4) | Famille D si ajouté |
| 4.2e | Voix communautaire | participation aux décisions | — | Absent du V7 **[COND]** — indicateur PAD | Famille D si ajouté |
| 4.2f | Participation associative & volontariat | `Q1==1` ; `Q2` (comptage 30 j) | `Q1`, `Q2` | V7 | Famille D |

## Formules conceptuelles

### Emploi

```text
EMPLOYE      = 1 si E1=1 ou E2=1 ou (E3=1 et E3A=1)
             = 0 si E1=2, E2=2 et [E3=2 ou (E3=1 et E3A=2)]
NON_EMPLOYE  = 1 − EMPLOYE
AUTO_EMPLOI  = EMPLOYE=1 et F1 ∈ {2 employeur, 3 indépendant}
EMPLOYEUR    = EMPLOYE=1 et F1 = 2
EMPLOIS_CREES = H4A si F1 ∈ {2,3} ; 0 sinon (zéro structurel observé) ; winsorisé p99
```

### Chômage, main-d'œuvre potentielle et inactivité *(définitions vérifiées contre le code ENE)*

```text
CHOMEUR   = NON_EMPLOYE et [ (J0=1 et J3=1)  ou  (J0A=8 et J3=1) ]     ← future starters inclus
MOP       = NON_EMPLOYE, non CHOMEUR, et [ (J0=1 et J3=2) ou (J0=2 et J0B=1 et J3=1) ]
DECOURAGE = J0=2 et J0A=1
INACTIF   = NON_EMPLOYE, non CHOMEUR, non MOP

LU1 = CHOMEUR / (EMPLOYE + CHOMEUR)
LU2 = (CHOMEUR + SOUS_EMPLOI) / (EMPLOYE + CHOMEUR)
LU3 = (CHOMEUR + MOP) / (EMPLOYE + CHOMEUR + MOP)
LU4 = (CHOMEUR + SOUS_EMPLOI + MOP) / (EMPLOYE + CHOMEUR + MOP)
```

### Heures et sous-emploi

```text
HEURES_TOTALES = G3 + G6·(G5=1)          (manquant si G3 manquant ; G6 manquant & G5=1 → manquant)
SOUS_EMPLOI    = EMPLOYE=1 et HEURES_TOTALES < 40 et G7=1 et G7A=1
```

**Seuil : 40 heures** (décision alignée sur les tabulations ENE ; en Stata, `heures<40` exclut
d'office les manquants).

### Salaire, profit et revenu

```text
SALAIRE_MENSUEL     = H3 × k(H2)   avec k = {26 ; 4,33 ; 2,17 ; 1} pour H2 = {1;2;3;4} ;
                      H2=5 (irrégulier) → conserver + drapeau qualité
PROFIT_DERNIER_MOIS = H5A                                   [COND — séquence MMW]
PROFIT_MOIS_NORMAL  = H5A si H5B=ordinaire, sinon H5C       [COND — séquence MMW]
PROFIT_NON_COND     = PROFIT_MOIS_NORMAL si AUTO_EMPLOI ;
                      0 si NON_EMPLOYE ou salarié observé ;
                      manquant si AUTO_EMPLOI et profit non renseigné
REVENU_TRAVAIL      = SALAIRE_MENSUEL si F1=1 ; PROFIT si F1∈{2,3,4} ; 0 si NON_EMPLOYE
```

Pertes déclarées = valeurs négatives (après validation du montant). Tant que la séquence MMW n'est
pas adoptée, `H5` ne doit **pas** être utilisé comme outcome primaire (amalgame profit /
prélèvements / dépenses — Note de revue §2.1) ; il ne sert qu'au test d'équilibre baseline.

**Transformation (décision proposée)** : winsorisation p1/p99 par vague et par bras de tous les
montants + IHS (asinh) pour l'estimation ; effets aussi rapportés en FCFA (niveaux winsorisés) pour
la lisibilité.

### Résilience

Ne pas mélanger exposition, capacité et conséquence. L'indice de capacité (3.8a) agrège uniquement
des **capacités** :

```text
IDX_RESILIENCE = anderson( N6A_recode (1 si facilement),
                           z(N7),
                           L3 ∈ {1,2},
                           z(score_actifs_D5),
                           G5=1 (diversification) )
```

Exposition (`N1`, `N2`) = covariable. Conséquences (`N3–N5`) = descriptif conditionnel, jamais
outcome causal.

### Statut productif perçu — ⚠ hiérarchie révisée

`M1` et `M4` reprennent le vocabulaire de la TOC (« producteur de valeur ») → risque fort de
désirabilité **différentielle** entre bras (surestime l'ITT). Règles :

1. **`M2` (factuel) est l'ancre** : `SANS_AIDE = (M2=3)`, reportée en tête de famille.
2. L'indice perçu reste calculé mais s'interprète à l'aune de `M2` :

```text
IDX_STATUT = anderson( SANS_AIDE, (M1=3), z(M3), (M4=1, NSP→manquant) )
```

3. Ne pas conclure sur l'indice s'il diverge de `M2`. À terme, remplacer `M1`/`M4` par des items
   factuels (part des dépenses de base autofinancée ; transferts envoyés vs reçus).

### Indices composites — règles communes

- **Indice d'Anderson** (pondération covariance inverse) pour les indices-résumés de famille ;
  z-scores **standardisés sur le bras témoin de la même vague** (convention Kling-Liebman-Katz).
- Item manquant : indice calculé sur les items observés si ≥ 50 % des items sont renseignés,
  manquant sinon (règle à figer dans le PAP).
- α de Cronbach documenté à la baseline pour chaque indice.

### Cohésion

Construire et rapporter séparément : participation (`Q1`), volontariat (`Q2`), confiance
généralisée (`Q3`), intergroupe (`Q4`), institutionnelle (`Q5–Q10`). L'indice global
`IDX_COHESION` (Anderson sur les 5 dimensions) est l'**outcome primaire bailleur** — préspécifié
dans le PAP. Si les dimensions manquantes (appartenance, sécurité, voix — **[COND]**) sont
ajoutées au questionnaire, les intégrer à l'indice **avant** l'endline, jamais après.

## Règles de qualité *(inchangées, complétées)*

Pour chaque variable : 1) manquants dans l'univers attendu ; 2) réponses hors univers ; 3) domaine
légal ; 4) plausibilité et cohérence croisée.

Contrôles prioritaires : employé sans section emploi ; non-employé avec réponses emploi ;
salaire/profit sans montant ; indépendant sans profit ; heures extrêmes (>84 h/sem) ;
**`H4A` > 0 avec `F1∉{2,3}`** ; **`J1` renseigné avec `J0=2`** ; **`G7A` renseigné avec `G7=2`** ;
stratégies de choc sans choc (`N4` avec `N1=2`) ; contacts panel (`R*`) hors base analytique.

## Désagrégations

sexe (`C1`) · âge (`C2A`/`C2`) · district (`B1`) · niveau d'instruction (`C4`) · secteur (`F2`) ·
assignation. **Handicap : impossible dans le V7** (pas de module Washington Group — **[COND]**,
exigence de désagrégation PAD à signaler). Hétérogénéités causales limitées et préspécifiées (PAP).

## Attrition

```text
OBSERVE_ENDLINE = 1 si l'outcome est renseigné, 0 sinon    (par outcome)
```

Comparer entre bras (global + par outcome), rapporter les motifs (`A4`), **bornes de Lee sur les
2 primaires si l'attrition différentielle est significative**. Pas de pondération automatique.

## Décisions — état au 2 juillet 2026

| # | Décision | État |
|---|---|---|
| 1 | Randomisation, unité, strates | **Décidée** (27/06) ; unité/strates/ratio/date à formaliser par écrit |
| 2 | Outcome économique primaire | **Proposé** : profit d'un mois ordinaire (3.4c) — dépend de l'adoption de la séquence MMW |
| 3 | Seuil du sous-emploi | **Tranché** : 40 h (alignement ENE) |
| 4 | Montant de dépense imprévue | **Dans le V7** : 250 000 FCFA (`N6A`) ; justifier le seuil dans le PAP |
| 5 | Pondération de l'indice de résilience | **Proposé** : indice d'Anderson (composantes ci-dessus) |
| 6 | Manquants dans les indices | **Proposé** : règle ≥ 50 % d'items observés |
| 7 | Familles & tests multiples | **Proposé** : 2 primaires sans correction ; Romano-Wolf par famille |
| 8 | Valeurs extrêmes | **Proposé** : winsorisation p1/p99 + IHS, niveaux en robustesse |
| 9 | Calendrier baseline/endline | Baseline avant tirage ; endline ≥ 12 mois post-installation |
| 10 | Désagrégations finales | Liste ci-dessus ; handicap conditionnel à l'ajout WG |
| 11 | **Adoption de l'addendum** (J0/J0A/J0B/G7A) | **À valider** — conditionne 3.5a, 3.7a–c |
| 12 | **Adoption de la séquence profit MMW** | **À valider** — conditionne le primaire économique |
