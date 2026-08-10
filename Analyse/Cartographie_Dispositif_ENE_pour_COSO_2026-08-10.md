# Cartographie approfondie du dispositif ENE utile à COSO

Date : 10 août 2026  
Dossiers examinés : `ENE_INDICATORS_TABULATIONS`, `ENE_SURVEY_WEIGHTS`, `ENE_MEDALLION_ORCHESTRATION`, `ENE_APUREMENT`, `ENE_SECRETS`, `ENE_METHOD_DOCS`, `ENE_INDICATORS_RESTRUCTURED`, `ENE_SUIVI_COLLECTE`.

## Synthèse

La lecture élargie montre que l'intérêt du dispositif ENE pour COSO ne se limite pas aux règles d'apurement. L'ENE fournit une architecture complète de production statistique :

```text
collecte / suivi
      ↓
export brut Survey Solutions
      ↓
apurement et rapports d'anomalies
      ↓
base standardisée
      ↓
pondération / calibration
      ↓
indicateurs pondérés et diagnostics
      ↓
publication / archivage
```

Pour COSO, cette architecture doit être adaptée à une évaluation d'impact : la branche « pondération d'enquête » n'est pas automatiquement nécessaire pour l'estimation ITT d'un échantillon randomisé, alors que la branche « assignation, attrition, traitement reçu et jonction SIG » devient centrale.

## Faits documentés par dépôt

### 1. `ENE_INDICATORS_TABULATIONS`

Le dépôt produit des indicateurs trimestriels et annuels à partir de bases déjà apurées et pondérées. Le point d'entrée maintenu est `scripts/stata/generate_quarterly.do`, qui appelle une préparation puis une tabulation.

Les éléments particulièrement utiles pour COSO sont :

- une configuration centralisée des chemins et de la période ;
- une séparation entre préparation de la base et production des tableaux ;
- un programme maître pour créer les variables dérivées ;
- des fonctions d'export vers un modèle Excel ;
- un mode de monitoring pendant la collecte et un mode final après apurement/pondération ;
- l'usage de la date réelle d'entretien (`date1`) plutôt que d'une variable de mois potentiellement erronée ;
- la comparaison temporelle avec la même période antérieure pour éviter la saisonnalité.

Le code d'indicateurs ENE comporte aussi des classifications fines de la situation dans l'emploi, de la formalité, de la vulnérabilité, du sous-emploi, de la main-d'œuvre potentielle et des NEET. Ces définitions sont des références conceptuelles, pas des règles à copier dans COSO.

### 2. `ENE_SURVEY_WEIGHTS`

RUWTHS organise les pondérations en étapes : poids de base, suivi/appairage, ajustement pour non-réponse, poids individuels, calibration sur totaux externes et contrôles qualité. La documentation distingue clairement les données brutes, nettoyées, traitées, pondérées, calibrées et les rapports.

La note méthodologique ENE documente aussi une chaîne reproductible de l'apurement à la diffusion, un schéma rotatif, les probabilités d'inclusion, la non-réponse, la calibration et la précision.

Pour COSO, la transposition utile est la séparation des couches et la traçabilité des poids. En revanche, les poids ENE ne doivent pas être appliqués aux 90 complétés COSO sans connaître le plan d'échantillonnage, les probabilités de sélection, les strates et les taux de réponse pertinents.

### 3. `ENE_MEDALLION_ORCHESTRATION`

Les scripts Python ne réalisent pas les calculs métier : ils assurent les transferts entre projets et stockage MinIO. Les buckets distinguent `staging`, `bronze`, `silver` et `gold`, avec des préfixes par période et entité.

Le principe transposable à COSO est un échange contrôlé par artefacts et manifestes :

- brut reçu et immuable ;
- base préparée ;
- rapports qualité ;
- base analytique ;
- sortie finale.

Pour COSO, un équivalent local peut être mis en place sans MinIO dans un premier temps, avec des dossiers versionnés et un manifeste de provenance. Une intégration distante ne doit être envisagée qu'après validation de la gouvernance des données et des accès.

### 4. `ENE_APUREMENT`

Le dépôt contient les scripts Stata d'orchestration, les sections standardisées, les contrôles par variable, les fichiers d'anomalies Excel et les validateurs Python. Il fournit le modèle le plus directement exploitable pour écrire l'audit COSO.

Les contrôles ENE sont organisés autour de quatre questions :

1. la valeur attendue est-elle manquante ?
2. une réponse existe-t-elle alors que l'univers ne l'autorise pas ?
3. la valeur appartient-elle au domaine attendu ?
4. la réponse est-elle cohérente avec les réponses précédentes et suivantes ?

Ce modèle sera appliqué aux modules COSO, mais en conservant les réponses brutes et en exportant les anomalies plutôt qu'en corrigeant immédiatement.

### 5. `ENE_SUIVI_COLLECTE`

Le dépôt contient des outils de préparation de passage, de réinterrogation, de rejet d'entretiens, d'envoi, de contrôle à haute fréquence et de suivi Stata. La logique de suivi crée des clés de liaison entre passages, précharge certaines réponses antérieures et conserve des variables de traçabilité.

Pour COSO, cette partie est plus importante que la pondération si l'objectif est une évaluation d'impact. Il faudra notamment suivre :

- l'identifiant stable du jeune ;
- la vague baseline/endline ;
- l'entretien réalisé, refusé, introuvable ou interrompu ;
- l'assignation traitement/témoin ;
- le traitement effectivement reçu ;
- les tentatives de contact ;
- la jonction avec le SIG de formation, kit et visites.

### 6. `ENE_INDICATORS_RESTRUCTURED`

Ce dépôt est une restructuration volumineuse contenant des copies de worktrees, des dépendances R générées et des archives. Il confirme l'orientation vers des scripts organisés, des fonctions partagées et des points d'entrée stables, mais il ne faut pas traiter tous ses fichiers comme du code de production maintenu.

La source de vérité doit être limitée aux points d'entrée documentés et aux scripts non générés, après vérification des doublons entre le dépôt restructuré et `ENE_INDICATORS_TABULATIONS`.

### 7. `ENE_METHOD_DOCS`

Les documents méthodologiques confirment l'importance de distinguer plan d'échantillonnage, non-réponse, calibration et précision. Ils sont utiles pour la culture statistique et la documentation, mais ne déterminent pas le plan COSO.

### 8. `ENE_SECRETS`

Le dossier contient un fichier JSON d'identifiants. Son contenu n'a pas été ouvert ni copié. Il doit rester hors des rapports, du code et des fichiers transmissibles à COSO. Les fichiers `.env` repérés dans plusieurs dépôts doivent également être considérés comme sensibles.

## Transposition recommandée pour COSO

| Couche ENE | Équivalent COSO | Priorité |
|---|---|---:|
| Suivi de collecte | Statut `interview_status`, tentatives, qualité, attrition | Très haute |
| Brut / staging | ZIP Survey Solutions conservé tel quel | Très haute |
| Apurement | Audit des univers, sauts, domaines, cohérences | Très haute |
| Standardisation | Base analytique individuelle par vague | Haute |
| Pondération | À étudier seulement si le plan le justifie | Moyenne |
| Calibration | Non applicable par défaut à l'ITT randomisé | Faible / à justifier |
| Assignation | Table officielle traitement/témoin et strates | Très haute |
| SIG | Traitement reçu, dates, dose, conformité | Très haute |
| Indicateurs | Variables baseline/endline alignées sur la matrice d'effets | Très haute |
| Diagnostics | Attrition, contamination, équilibre, complétude | Très haute |
| Publication | Rapport PDF + fichiers analytiques dé-identifiés | Haute |

## Ce que l'on peut déjà décider techniquement

### Décisions de construction proposées

- utiliser `interview__key` comme clé technique de l'export, sans confondre cette clé avec l'identifiant longitudinal du jeune ;
- créer une table de suivi des statuts à chaque export ;
- conserver les observations exclues dans un fichier d'exclusion documenté ;
- produire les anomalies par règle, par module et par vague ;
- ajouter un manifeste de provenance indiquant fichier source, date, script, version et nombre de lignes ;
- séparer les données analytiques des variables personnelles et des coordonnées ;
- ne produire les indicateurs d'impact qu'après jonction avec l'assignation officielle et le SIG.

### Hypothèses qui restent à confirmer

- l'échantillon COSO est-il exhaustif parmi les jeunes ciblés ou issu d'un tirage probabiliste ?
- existe-t-il un poids de sélection ou un facteur de non-réponse à utiliser ?
- quel est l'identifiant stable prévu entre baseline, traitement et endline ?
- la randomisation est-elle individuelle ou par groupe/localité ?
- faut-il pondérer des statistiques descriptives de ciblage, indépendamment de l'ITT ?
- quelles règles institutionnelles régissent les exports vers l'équipe COSO ?

## Recommandation opérationnelle

Ne pas essayer de reproduire l'ensemble de l'ENE dans COSO. Construire une version légère en quatre blocs :

1. `00_ingestion_statuts.R` : export brut, statuts, consentement, clés et provenance ;
2. `05_audit_apurement_coso.R` : contrôles et rapports d'anomalies ;
3. `06_construire_panel_coso.R` : jointure identifiant jeune, vague, assignation et SIG ;
4. `07_indicateurs_evaluation_coso.R` : indicateurs, diagnostics d'attrition et estimands.

La pondération pourra être ajoutée comme bloc séparé si le plan de sélection le justifie. Elle ne doit pas être introduite simplement parce que l'ENE l'utilise.

