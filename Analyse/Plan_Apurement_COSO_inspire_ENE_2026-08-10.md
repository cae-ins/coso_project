# Plan d'apurement COSO inspiré du dispositif ENE

Date : 10 août 2026  
Source de référence examinée : `C:\Users\f.migone\Desktop\ENE_APUREMENT`  
Périmètre COSO observé : export Survey Solutions V5.1 du 10/08/2026, entretiens complétés.

## Conclusion

Oui, le code d'apurement ENE permet d'inférer une architecture d'apurement pour COSO. Il ne faut toutefois pas copier les règles ENE telles quelles : ENE est une enquête ménage/individus avec rosters, sections standardisées et règles BIT, tandis que COSO est un suivi individuel orienté insertion.

La transposition fiable porte surtout sur la méthode :

1. conserver l'export brut et produire une base de travail séparée ;
2. valider la clé technique `interview__key` avant toute analyse ;
3. filtrer explicitement `interview_status == 100` (`Completed`) et le consentement positif ;
4. tester, variable par variable, les manquants dans l'univers, les réponses hors univers, les domaines et les cohérences ;
5. exporter chaque anomalie avec l'identifiant de l'entretien et les variables de contexte ;
6. séparer le diagnostic, la proposition de correction et la correction validée ;
7. ne jamais imputer ou supprimer une observation sans décision métier traçable.

## Ce qui est directement réutilisable

| Dispositif ENE | Adaptation COSO proposée | Statut |
|---|---|---|
| `parentfile.do` et orchestration par étapes | Un script maître COSO appelant préparation, contrôles système, contrôles par module et synthèse | À créer |
| `00-suppression_doublons.do` | Contrôle des doublons `interview__key` ; contrôle séparé de `cover_id` | Déjà partiellement présent |
| `00-protections_sauvegarde_brute.do` | Interdire l'écrasement de la base brute et vérifier les variables sentinelles | À formaliser |
| Tests en quatre étapes : manquant, saut, domaine, cohérence | Fonctions de contrôle par règle, avec export CSV/XLSX des cas | À créer |
| `export excel ... if anomalie` | Rapports COSO par règle et par module, avec statut `à_revoir` | Déjà amorcé en CSV |
| Standardisation par section | Modules COSO A à R, sans inventer de rosters ENE | À structurer |
| Validation des fichiers de codification | Contrôle spécifique des réponses texte `Autre`, notamment `Q2`, `R4`, `R6` | À créer |
| Logs et validation des sorties | Journal de contrôle avec nombre testé, nombre en anomalie et action proposée | À créer |

## Codes d'apurement COSO que l'on peut inférer maintenant

Les règles ci-dessous sont des propositions techniques fondées sur le questionnaire, les variables observées et le code indicateur existant. Elles ne constituent pas encore des décisions métier.

| Code proposé | Règle COSO | Sortie attendue | Décision requise |
|---|---|---|---|
| `SYS_STATUS_COMPLETED` | Retenir `interview_status == 100` pour l'analyse des complétés | Base d'analyse ; exclus documentés | Confirmer le périmètre analytique |
| `SYS_CONSENT` | Signaler consentement absent ou différent de 1 | Liste des cas à exclure/revoir | Validation juridique/métier |
| `SYS_KEY_UNIQUE` | `interview__key` doit être non manquante et unique | Doublons techniques | Règle technique, sans correction automatique |
| `SYS_COVER_ID_DUP` | Signaler les `cover_id` répétés, sans les supprimer | Rapport de rapprochement | Déterminer si `cover_id` est un identifiant d'unité ou de collecte |
| `SYS_DIAGNOSTICS` | Croiser erreurs Survey Solutions, commentaires et statut | Contrôle de qualité de collecte | Revoir les 4 commentaires présents |
| `DEM_AGE_DOMAIN` | Âge renseigné, domaine plausible ; isoler les âges élevés | Cas à revoir | Fixer les bornes attendues par le PAD/questionnaire |
| `EMP_UNIVERSE_F1` | `F1` seulement dans l'univers `EMPLOYE == 1` | Réponses hors saut / manquants dans l'univers | Confirmer le code de non-emploi |
| `EMP_HOURS_DOMAIN` | `G3` non négatif ; signaler `G3 > 84` et les codes spéciaux | Rapport heures atypiques | Valider le traitement des codes 998/999 |
| `EMP_HOURS_TOTAL` | Si activité secondaire, documenter le calcul des heures totales | Variable dérivée + flag | Confirmer la définition d'heures COSO |
| `EMP_ACTIVITY_12M` | Tester la cohérence de `F4` avec le statut d'activité | Rapport de cohérence | Valider la définition de pérennité |
| `EMP_REGISTRATION` | `H4/H4A` uniquement pour l'univers indépendant/employeur | Valeurs hors univers | Confirmer les catégories `F1` concernées |
| `EMP_JOBS_CREATED` | `H4A` non négatif et cohérent avec le statut indépendant/employeur | Cas atypiques | Décider du traitement des zéros et valeurs extrêmes |
| `INCOME_UNIT` | `H2` doit appartenir au domaine des unités de paiement | Domaine / conversion mensuelle | Valider les facteurs de conversion |
| `INCOME_VALUE` | `H3/H5` non négatif ; séparer refus, NSP et valeurs économiques | Rapport revenus | Confirmer les codes spéciaux et la winsorisation éventuelle |
| `INCOME_H5_PROXY` | Ne pas utiliser `H5` comme profit net sans séquence MMW | Exclusion de l'outcome profit | Décision déjà documentée dans le cadre indicateurs |
| `SEARCH_UNIVERSE` | `I1` seulement pour les personnes classées en emploi | Réponses hors univers | Confirmer l'univers exact de la question |
| `UNEMPLOYMENT_MODULE` | `J0/J0A/J0B/J1` insuffisant pour BIT complet si l'addendum est absent | Indicateur non calculé / manquants structurels | Adopter ou non l'addendum chômage |
| `SHOCK_UNIVERSE` | `N2:N5` seulement si exposition au choc | Réponses hors univers | Confirmer le code d'exposition `N1` |
| `COHESION_Q2_TEXT` | Harmoniser les réponses textuelles/non numériques de `Q2` avant comptage | Fichier de codification manuelle | Validation d'un dictionnaire de codage |
| `OTHER_TEXT_REVIEW` | Contrôler les champs `Autre` et les textes libres | Fichier de revue | Codification manuelle séparée |
| `PII_REVIEW` | Isoler téléphone et identifiants personnels `R4/R6` des sorties analytiques | Base dé-identifiée + rapport d'accès | Validation protection des données |

## Premiers cas déjà établis sur les complétés

Sur les 94 entretiens au statut `Completed`, 90 ont un consentement positif et constituent la base analytique provisoire utilisée dans les rapports précédents.

Les contrôles disponibles montrent :

- aucune erreur technique Survey Solutions dans les diagnostics examinés ;
- aucune incohérence observée entre `EMPLOYE` et la présence de `F1`, `G3` ou `H5/H4A` dans les contrôles de saut déjà réalisés ;
- `Q2` contient des valeurs textuelles ou non harmonisées, donc le comptage ne doit pas être utilisé sans codification ;
- `H5` contient des valeurs `999999` et ne peut pas être interprété comme un profit net ;
- le module chômage est trop incomplet pour calculer proprement le chômage BIT ;
- des informations personnelles sont présentes dans `R4/R6` et doivent être exclues des fichiers transmissibles.

## Architecture de fichiers recommandée pour COSO

```text
Analyse/
  R/
    00_preparer_export_v51.R
    01_construire_indicateurs_effets_draft7.R
    05_audit_apurement_coso.R
  apurement/
    regles_questionnaire.csv
    regles_metier_proposees.csv
    decisions_validees.csv
  outputs_provisoires/
    rapports_apurement/
      systeme/
      modules/
      codification/
      pii_restreint/
    base_brute_conservee/
    base_travail/
```

Le fichier `regles_questionnaire.csv` doit contenir les règles directement documentées par le questionnaire : univers, saut, domaine et validation. Le fichier `regles_metier_proposees.csv` doit contenir les contrôles de plausibilité ou les règles de calcul proposées. Les corrections ne doivent être activées qu'après transfert dans `decisions_validees.csv`.

## Ce qui ne doit pas être copié automatiquement depuis ENE

- la suppression en dur d'une liste d'identifiants ;
- les imputations par médiane ;
- les règles d'âge et de lien familial des rosters ENE ;
- les règles BIT et les seuils horaires ENE ;
- les procédures de codification CIAP/CITP ;
- la suppression des non-résidents ;
- la transformation d'un texte `Autre` en code numérique sans revue.

## Décision proposée pour la suite

La prochaine étape peut être l'écriture de `Analyse/R/05_audit_apurement_coso.R`, qui exécutera uniquement des contrôles et produira les fichiers d'anomalies sur les 90 entretiens analytiques, sans modifier les réponses. Les éventuelles corrections seront préparées ensuite dans un script séparé, après validation de la matrice des règles par l'équipe COSO.

