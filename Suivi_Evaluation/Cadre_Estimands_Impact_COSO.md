# Cadre des estimands de l'évaluation d'impact COSO

**Version :** 27 juin 2026  
**Objet :** préciser ce que le design à deux bras permet d'estimer sur l'insertion des jeunes  
**Statut :** cadre méthodologique à valider avant le plan de pré-analyse

## 1. Décision de design

Le projet retient un design simple à deux bras en raison de la taille disponible :

- **traitement** : jeunes sélectionnés pour recevoir le package COSO ;
- **contrôle** : candidats éligibles non sélectionnés, constituant la comparaison.

Le package comprend plusieurs composantes :

1. formation technique et/ou entrepreneuriale ;
2. kit, équipement, financement ou fonds de roulement ;
3. accompagnement et suivi post-installation.

Ce design permet d'estimer causalement l'effet du **programme complet offert**. Il ne permet pas d'identifier séparément l'effet causal propre de chaque composante, car elles ne sont pas randomisées indépendamment.

Les chiffres actuellement utilisés — environ 600 sélectionnés et 1 088 candidats non sélectionnés — restent des paramètres de travail jusqu'à confirmation du protocole et du fichier d'assignation.

## 2. Notation

Pour chaque jeune `i` :

| Symbole | Définition COSO |
|---|---|
| `Zᵢ` | assignation aléatoire : 1=sélectionné pour COSO, 0=non sélectionné |
| `Dᵢ` | participation effective au programme, selon une définition fixée avant l'analyse |
| `Yᵢ` | outcome : emploi, activité active, profit, heures, FIES, confiance, etc. |
| `Xᵢ` | caractéristique observée avant traitement : sexe, instruction, région, secteur initial, handicap, etc. |
| `Yᵢ(1)` | résultat potentiel si le jeune est assigné au programme |
| `Yᵢ(0)` | résultat potentiel si le jeune est assigné au contrôle |

L'assignation `Z` et la participation effective `D` ne sont pas équivalentes :

- un jeune peut être sélectionné mais ne pas commencer ou achever le programme ;
- un témoin peut recevoir un autre appui similaire ;
- un crossover dans COSO doit être distingué d'une exposition à un programme externe.

## 3. Estimand principal : ITT

### 3.1 Définition

L'effet en intention de traiter mesure l'effet causal d'être **assigné/offert** au programme :

```text
ITT = E(Y | Z=1) - E(Y | Z=0)
```

L'analyse conserve chaque jeune dans son bras initial :

- un sélectionné reste dans le traitement même s'il abandonne ;
- un non-sélectionné reste dans le contrôle même s'il trouve un autre appui.

### 3.2 Pourquoi l'ITT est principal

L'ITT :

- préserve la comparabilité produite par la randomisation ;
- mesure l'effet de la politique telle qu'elle est réellement déployée ;
- intègre les refus, abandons et défauts de mise en œuvre ;
- évite le biais d'une comparaison naïve entre participants et non-participants.

Pour COSO, l'ITT répond à la question :

> Quel est l'effet d'être sélectionné pour recevoir le package COSO sur l'insertion économique et sociale des jeunes éligibles ?

### 3.3 Spécification principale

Pour un outcome observé à la baseline et à l'endline :

```text
Yᵢ,endline = α + β Zᵢ + γ Yᵢ,baseline
             + effets fixes des strates + εᵢ
```

`β` est l'effet ITT.

Règles proposées :

- ANCOVA lorsque la valeur baseline de l'outcome existe ;
- effets fixes des strates de randomisation ;
- erreurs-types cohérentes avec l'unité d'assignation ;
- modèle linéaire pour les outcomes binaires, avec effets en points de pourcentage ;
- résultat en niveau pour les montants, avec transformations éventuelles en robustesse.

Cette spécification ne dépend plus que de l'unité et des strates : la **randomisation est confirmée (décision responsable, 27/06/2026)** ; reste à formaliser par écrit l'unité, les strates et le moment du tirage.

## 4. ATE, SATE et PATE

### 4.1 ITT comme effet moyen de l'assignation

Dans l'échantillon randomisé, l'ITT est un effet moyen de l'**assignation**. Il peut être décrit comme un SATE de l'offre du programme :

```text
SATE_assignation = moyenne[Yᵢ(1)-Yᵢ(0)] dans l'échantillon
```

### 4.2 Effet moyen du traitement reçu

L'effet moyen de recevoir effectivement le programme n'est pas automatiquement identifié lorsque la compliance est imparfaite.

Si :

- tous les sélectionnés reçoivent le programme ;
- aucun témoin ne le reçoit ;
- il n'y a ni spillover ni contamination ;

alors l'ITT coïncide avec l'effet moyen du traitement reçu dans l'échantillon.

Sinon, comparer directement `D=1` à `D=0` produit généralement un biais de sélection.

### 4.3 Effet dans la population

Un PATE pour l'ensemble de la population cible exige :

- soit un échantillon représentatif ;
- soit des poids ou une méthode de transport vers la population ;
- soit des hypothèses explicites de validité externe.

Le tirage aléatoire du traitement ne garantit pas à lui seul la représentativité des candidats.

## 5. Compliance dans COSO

### 5.1 Dimensions à suivre

La compliance n'est pas une variable unique. Le SIG doit distinguer :

| Dimension | Définition indicative | Source |
|---|---|---|
| Offre reçue | jeune informé de sa sélection et convoqué | fichier d'assignation/SIG |
| Take-up | jeune ayant commencé la formation | présence/SIG |
| Intensité | part des séances ou heures suivies | feuilles de présence |
| Complétion | formation achevée selon les règles validées | SIG/prestataire |
| Kit/financement | kit, équipement ou fonds effectivement remis | preuve de remise |
| Installation | activité appuyée effectivement démarrée | SIG/visite |
| Accompagnement | nombre et calendrier des visites reçues | fiches de suivi |
| Compliance complète | seuil combiné formation + kit + accompagnement | définition à valider |

### 5.2 Définition recommandée pour le LATE

Pour l'instrumentation, `D` doit être :

- binaire ;
- observable pour les deux bras ;
- défini avant l'analyse ;
- fortement affecté par l'assignation ;
- suffisamment large pour représenter la participation au package.

Une définition possible est :

> `D=1` si le jeune a effectivement commencé le programme COSO et atteint un seuil minimal préspécifié de participation.

Le seuil reste à valider.

### 5.3 Pourquoi ne pas définir D uniquement par la complétion

Une personne qui commence la formation mais ne l'achève pas peut déjà recevoir :

- des compétences ;
- des contacts ;
- une partie de l'accompagnement ;
- une modification de ses attentes ou comportements.

Si `D=1` signifie uniquement « formation achevée », l'assignation peut affecter l'outcome même chez des personnes classées `D=0`. L'hypothèse d'exclusion du modèle instrumental devient alors fragile.

La complétion et la compliance complète restent néanmoins des indicateurs essentiels de mise en œuvre.

## 6. Estimand secondaire : LATE/CACE

### 6.1 Définition

Le LATE, aussi appelé CACE, mesure l'effet du programme chez les **compliers** : les jeunes qui participent parce qu'ils ont été sélectionnés et qui n'auraient pas participé sans cette sélection.

Premier stade :

```text
Premier stade = E(D | Z=1) - E(D | Z=0)
```

Estimateur de Wald dans le cas simple :

```text
LATE = ITT sur Y / ITT sur D
     = [E(Y|Z=1)-E(Y|Z=0)]
       / [E(D|Z=1)-E(D|Z=0)]
```

En pratique, l'estimation peut être réalisée par doubles moindres carrés :

```text
Première étape : Dᵢ = π₀ + π₁ Zᵢ + strates + uᵢ
Deuxième étape : Yᵢ = α + τ D̂ᵢ + baseline + strates + εᵢ
```

`τ` estime le LATE.

### 6.2 Exemple

Supposons :

- ITT sur le taux d'emploi : `+9` points ;
- participation effective : `75 %` chez les sélectionnés ;
- participation COSO : `0 %` chez les témoins.

Alors :

```text
Premier stade = 0,75 - 0 = 0,75
LATE = 0,09 / 0,75 = 0,12
```

Le programme augmente l'emploi de 12 points chez les jeunes dont la participation est provoquée par la sélection.

### 6.3 Hypothèses du LATE

1. **Assignation exogène** : `Z` est effectivement randomisé.
2. **Pertinence** : `Z` modifie suffisamment la probabilité de participation `D`.
3. **Exclusion** : l'assignation affecte `Y` uniquement par la participation définie par `D`.
4. **Monotonie** : aucun jeune ne participe uniquement lorsqu'il n'est pas sélectionné tout en refusant lorsqu'il est sélectionné.
5. **Absence d'interférence** : l'assignation d'un jeune n'affecte pas directement le résultat d'un autre.
6. **Mesure fiable de D** : la participation est documentée dans le SIG.

### 6.4 Interprétation dans un package

Le LATE porte sur la **participation au programme COSO comme package**. Il ne fournit pas :

- l'effet propre de la formation ;
- l'effet propre du kit ou financement ;
- l'effet propre du coaching.

Définir successivement plusieurs variables `D` ne transforme pas le même instrument en identification séparée de chaque composante. L'assignation ouvre simultanément plusieurs canaux, ce qui fragilise l'exclusion pour une composante isolée.

## 7. Effets hétérogènes : CATE

### 7.1 Définition

Le CATE mesure l'effet moyen de l'assignation dans un sous-groupe défini par une caractéristique baseline `X` :

```text
CATE(x) = E[Y(1)-Y(0) | X=x]
```

Pour un sous-groupe binaire :

```text
Yᵢ,endline = α + β Zᵢ + δ Xᵢ + θ(Zᵢ×Xᵢ)
             + γYᵢ,baseline + strates + εᵢ
```

- effet dans le groupe de référence : `β` ;
- effet dans le groupe `X=1` : `β + θ` ;
- différence d'effet entre groupes : `θ`.

### 7.2 Sous-groupes COSO envisageables

Compte tenu de la taille, limiter les CATE à trois ou quatre dimensions préspécifiées :

1. sexe ;
2. absence/présence d'instruction formelle ;
3. situation économique initiale : activité existante ou non ;
4. secteur initial ou grande zone géographique, sous réserve d'effectifs.

Autres dimensions possibles mais à arbitrer :

- âge ;
- handicap ;
- niveau initial de vulnérabilité ;
- type de projet demandé : formation/apprentissage ou AGR.

### 7.3 Règles

- utiliser uniquement des caractéristiques mesurées avant assignation ;
- annoncer les sous-groupes avant l'analyse endline ;
- tester explicitement l'interaction, pas seulement comparer deux significativités ;
- rapporter les effectifs et intervalles de confiance ;
- contrôler la multiplicité ;
- interpréter prudemment les petites cellules.

Ne pas définir un CATE par :

- formation achevée ;
- kit reçu ;
- nombre de visites ;
- activité démarrée après sélection.

Ce sont des variables post-traitement.

### 7.4 LATE conditionnel

Un LATE peut être estimé par sous-groupe :

```text
LATE(x) = ITT_Y(x) / Premier_stade(x)
```

Il exige les hypothèses instrumentales dans chaque sous-groupe et une première étape suffisamment forte. La puissance sera inférieure à celle de l'ITT global.

## 8. Indicateurs d'impact concernés

### 8.1 Insertion économique

Outcomes centraux :

- emploi ;
- activité indépendante active ;
- profit net mensuel ;
- revenu mensuel du travail ;
- heures travaillées ;
- sous-emploi ;
- activité encore active à 6/12 mois ;
- capital productif ;
- formalisation.

Pour l'ITT, privilégier des outcomes définis pour toute la population :

- heures égales à zéro si non-emploi observé ;
- profit égal à zéro si absence certaine d'activité indépendante ;
- vraie non-réponse conservée comme manquante.

Les moyennes uniquement parmi les personnes employées ou les entreprises actives sont secondaires, car elles conditionnent sur un statut potentiellement affecté par le programme.

### 8.2 Résilience et inclusion financière

- épargne et montant épargné ;
- accès au crédit et dette ;
- diversification ;
- capacité à faire face à une dépense imprévue ;
- stratégies négatives ;
- récupération après choc ;
- FIES ;
- indice de résilience préspécifié.

### 8.3 Statut, autonomisation et psychosocial

- statut productif perçu ;
- auto-efficacité et espoir ;
- contrôle des revenus ;
- participation aux décisions ;
- mobilité ;
- normes de genre.

### 8.4 Cohésion sociale

- confiance généralisée ;
- confiance intra-communautaire ;
- confiance intergroupe ;
- confiance institutionnelle ;
- appartenance et réciprocité ;
- rejet de la violence ;
- sécurité ressentie ;
- engagement civique et voix communautaire.

Avec une randomisation individuelle, ces outcomes mesurent principalement des perceptions et comportements individuels. Ils ne suffisent pas à identifier un changement de cohésion au niveau collectif de la communauté.

## 9. Ce qui est causalement identifiable

| Question | Réponse avec le design à deux bras |
|---|---|
| Effet d'être sélectionné pour COSO | Oui : ITT |
| Effet de la participation au package chez les compliers | Potentiellement : LATE, sous hypothèses |
| Effet par sexe/instruction/statut initial | Oui : CATE de l'assignation, si préspécifié et suffisamment puissant |
| Effet moyen dans l'échantillon avec compliance parfaite | Oui : ITT coïncide avec l'effet du traitement |
| Effet dans toute la population du Nord | Pas automatiquement : besoin de transport/pondération |
| Effet propre de la formation | Non avec le design actuel |
| Effet propre du kit/financement | Non avec le design actuel |
| Effet propre de l'accompagnement | Non avec le design actuel |
| Comparaison causale « compléteurs vs non-compléteurs » | Non sans hypothèses supplémentaires |

## 10. Analyses de mécanismes

Les composantes peuvent être utilisées pour comprendre la mise en œuvre :

- taux de démarrage et de complétion ;
- assiduité ;
- réception et délai du kit ;
- démarrage de l'activité ;
- nombre de visites ;
- intégration AVEC.

Leurs associations avec les outcomes peuvent être présentées comme :

- descriptives ;
- exploratoires ;
- analyses de mécanismes.

Elles ne doivent pas être qualifiées d'effets causaux séparés.

## 11. Menaces à l'identification

### Attrition

La faible joignabilité observée rend nécessaire :

- un suivi des taux de réponse par bras ;
- un test d'attrition différentielle ;
- l'utilisation de contacts alternatifs ;
- des analyses de sensibilité si l'attrition est élevée.

### Contamination

Documenter :

- les témoins recevant COSO par erreur ;
- les deux bras recevant d'autres programmes ;
- la nature, le calendrier et l'intensité des appuis externes.

Un programme externe n'est pas nécessairement une compliance à COSO, mais peut réduire le contraste entre les bras.

### Spillovers

Des jeunes d'une même localité ou d'un même marché peuvent :

- partager les compétences ;
- se concurrencer ;
- partager du matériel ;
- modifier les opportunités des témoins.

Les spillovers compromettent l'interprétation standard ITT/LATE fondée sur l'absence d'interférence.

### Mise en œuvre variable

Les retards de formation, de kit ou de coaching réduisent l'ITT observé. Ils doivent être décrits comme une caractéristique du programme effectivement déployé, pas corrigés en retirant les non-compliants de l'ITT.

## 12. Ordre d'analyse et de restitution

1. diagramme des candidats, assignations, suivis et attritions ;
2. vérification du fichier de randomisation et des strates ;
3. balance baseline ;
4. taux de mise en œuvre et compliance ;
5. première étape `Z → D` ;
6. ITT sur les outcomes primaires ;
7. ITT sur les outcomes secondaires ;
8. LATE secondaire sur la participation au package ;
9. CATE préspécifiés ;
10. analyses d'attrition, contamination et spillovers ;
11. mécanismes descriptifs ;
12. correction des tests multiples par famille d'outcomes.

Le rapport doit toujours présenter l'ITT, même si le LATE est estimé.

## 13. Données minimales nécessaires

### Assignation

- identifiant unique ;
- éligibilité ;
- bras assigné ;
- date du tirage ;
- strate/bloc ;
- probabilité d'assignation si variable.

### Baseline/endline

- mêmes identifiants ;
- outcomes harmonisés ;
- date d'entretien ;
- statut de réponse et raison de non-réponse ;
- caractéristiques baseline des CATE.

### SIG de mise en œuvre

- convocation/information ;
- date de début de formation ;
- présences et intensité ;
- complétion ;
- date/type/valeur du kit ;
- date de démarrage de l'activité ;
- coaching prévu/réalisé ;
- arrêt et motif ;
- autres appuis connus.

## 14. Décisions à valider avant le plan de pré-analyse

1. ~~confirmation formelle de la randomisation individuelle~~ — **FAIT (décision responsable, 27/06/2026)** ; reste à documenter l'unité, les strates et le moment du tirage ;
2. définition des strates et de la variable d'assignation ;
3. définition binaire principale de `D` pour le LATE ;
4. seuil minimal de participation ;
5. liste et ordre des outcomes primaires ;
6. familles d'outcomes secondaires ;
7. trois ou quatre CATE prioritaires ;
8. règle de multiplicité ;
9. traitement des montants extrêmes et pertes ;
10. calendrier endline par rapport à l'installation ;
11. stratégie d'attrition ;
12. mesure de contamination et spillovers.

## 15. Synthèse à retenir

- **ITT principal** : effet causal d'être sélectionné pour le package COSO.
- **LATE secondaire** : effet de la participation au package chez les compliers, sous hypothèses instrumentales.
- **CATE secondaires** : effets de l'assignation dans quelques sous-groupes baseline préspécifiés.
- **ATE du traitement reçu** : coïncide avec l'ITT seulement en cas de compliance parfaite ou nécessite des hypothèses supplémentaires.
- **Effets séparés formation/kit/accompagnement** : non identifiables avec le design à deux bras.
- **Compliance détaillée** : indispensable pour la mise en œuvre et le premier stade, mais ne remplace pas l'ITT.
