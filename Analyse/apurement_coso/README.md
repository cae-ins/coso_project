# Apurement COSO en R

Ce dossier transpose le workflow de `ENE_APUREMENT` au questionnaire COSO V5.1.
Le moteur operationnel est en R ; les do-files Stata restent une reference
d'audit. L'archive Survey Solutions originale n'est jamais modifiee et aucune
correction metier non validee n'est appliquee.

## Statut des regles

Le pipeline distingue explicitement :

- `questionnaire` : filtre, domaine ou validation lu dans le questionnaire ;
- `donnee_observee` : anomalie constatee dans l'export ;
- `metier_propose` : controle plausible encore a valider ;
- `metier_valide` : correction explicitement approuvee ;
- `terrain` : cas a retourner aux agents ou superviseurs.

Les anomalies sont exportees pour revue. Les corrections deterministes validees
devront etre inscrites dans `R/60_corrections_validees.R`, avec leur identifiant,
leur source, leur date et leurs tests avant/apres. Ce registre est actuellement
vide et la sortie porte le statut `diagnostic_only`.

## Architecture

```text
datain/staging       archive Survey Solutions immuable
datain/brute         copie extraite et recreee a chaque construction
datain/standard      base standardisee, non filtree
dataout/standard     19 vues diagnostiques par section
dataout/final        base diagnostique finale
document             rapports Excel conditionnels et synthese du run
generated            dictionnaire, matrice, comptages et manifestes non nominatifs
logs                 journaux d'execution R/Stata
R                    moteur R, modules et scripts generes par section
program              miroir Stata conserve comme reference d'audit
tools                staging, extraction, generation et validations
```

Les donnees brutes, bases derivees, rapports Excel et logs sont ignores par Git.
Les scripts, matrices et manifestes agreges sans identifiants restent tracables.

## Sources et priorite

1. questionnaire HTML Survey Solutions embarque dans l'archive ;
2. donnees `Questionnaire_COSO_V5.dta` et leur dictionnaire ;
3. rapports d'anomalies et retours de codification, lorsqu'ils existent ;
4. regles institutionnelles ou metier, marquees `metier_propose` avant validation.

Le perimetre questionnaire `interview__status == 100` et le perimetre metier
`statut 100 + consentement positif + cle technique unique` sont des hypotheses
d'apurement. Ils ne suppriment aucune fiche.

## Construction et execution complete

Depuis la racine du depot :

```powershell
.\Analyse\apurement_coso\tools\00_build_template.ps1 `
  -SourceZip ".\Data\Suivi_Collecte\Questionnaire_COSO_V5_1_STATA_All_YYYYMMDDThhmmZ.zip"
```

La construction :

1. copie l'archive dans la couche `staging` et recree la couche `brute` ;
2. extrait le dictionnaire `.dta` et les regles du questionnaire ;
3. genere un script R par section et le miroir Stata ;
4. evalue 477 controles questionnaire et 6 controles metier proposes ;
5. produit les rapports seulement lorsqu'au moins un cas existe ;
6. ecrit les vues de section et la base finale diagnostique ;
7. compare les indicateurs du moteur aux controles dynamiques independants ;
8. verifie le contrat de sortie et la confidentialite des rapports.

Pour relancer uniquement le moteur apres une construction :

```powershell
& "C:\Program Files\R\R-4.5.3\bin\Rscript.exe" `
  ".\Analyse\apurement_coso\R\00_master.R" `
  ".\Analyse\apurement_coso"
```

Les sorties de controle tracables sont :

- `generated/r_engine_manifest.csv` : contrat et volumetrie du moteur ;
- `generated/r_run_summary.csv` : indicateurs agreges du run ;
- `generated/r_rule_counts.csv` : comptage par regle, sans identifiant individuel ;
- `document/synthese_apurement_r.xlsx` : synthese locale pour revue ;
- `dataout/final/coso_apurement_diagnostic.dta` : base locale non publiee.

## Confidentialite

Les rapports questionnaire n'exportent pas `cover_id`, `nom`, `telephone`,
`nom_agent`, `nom_sup`, `B7`, `R1A`, `R2A`, `R3B`, `R4` ou `R6`. Les deux
variables de personnel restent controlees, mais leurs valeurs et labels sont
retires des rapports non restreints. Le rapport de doublons `cover_id`
est place dans `document/00_systeme_restreint` et marque `interne_restreint`.
Les validateurs relisent les en-tetes de tous les rapports non restreints et
bloquent le run si une colonne sensible est detectee.

## Limites et decisions encore ouvertes

- `G3=998` et `H5=999999` sont des codes speciaux autorises, pas des valeurs
  automatiquement illegales ; leur recodage analytique reste a valider.
- La cible 15-35 ans, le seuil de 84 heures, `H4A>100`, `H5>5 000 000` et
  l'attente d'une valeur numerique/codifiable pour `Q2` restent
  `metier_propose`.
- Les 481 entretiens au statut 100 sont controles par section ; les 441 fiches
  du perimetre metier provisoire servent uniquement aux controles proposes.
- Le miroir Stata protege les comparaisons par des gardes `!missing(...)`, mais
  n'a pas ete execute sur ce poste faute d'executable Stata ; R reste le seul
  moteur operationnel valide.
- Pour les quatre listes en cascade, le domaine et la coherence parent-enfant
  restent explicitement `A_VALIDER` : les options du HTML Preview sont
  tronquees et ne doivent pas servir seules a produire des anomalies.
- Les champs « Autre a preciser » ont leurs controles de manquants et de sauts,
  mais le lot dedie de codification manuelle et l'integration des fichiers de
  retour restent a construire. Aucun code n'est invente dans cette version.

## Orientation MinIO

Une etape ulterieure organisera d'abord localement les etats de donnees dans
MinIO, selon la separation ENE : source/staging immuable, brute de travail,
standard, sorties d'apurement et livrables finaux. Cette orientation est
confirmee, mais les buckets, conventions de nommage, droits d'acces, manifestes
et regles de promotion entre couches ne sont pas encore implementes.
