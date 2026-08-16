# Validation du template d'apurement COSO

**Date :** 16 aout 2026
**Source testee :** `Questionnaire_COSO_V5_1_STATA_All_20260815T1946Z.zip`
**SHA-256 :** `6F41BE295E312C22AF626A97B0C63FEBC4C5DA9C52764FE468D8F518E5377699`

## Resultat

Le template `Analyse/apurement_coso/` a ete construit a partir des conventions
du depot `ENE_APUREMENT` et adapte a la structure COSO : une base principale
`1:1` par `interview__key`, sans roster metier dans l'export courant.

- 19 sections du questionnaire identifiees ;
- 195 objets/questions documentes ;
- 218 variables presentes dans le fichier Stata ;
- 499 lignes dans la matrice complete ;
- 477 controles questionnaire generes et executables ;
- domaine et coherence parent-enfant de 4 listes en cascade traces `A_VALIDER` ;
- 6 controles metier proposes, executables mais a valider ;
- 3 variables calculees documentees sans recalcul automatique ;
- 9 objets questionnaire exclus des exports automatiques pour confidentialite
  ou identifiants restreints (`cover_id`, `nom`, `telephone`, `B7`, `R1A`,
  `R2A`, `R3B`, `R4`, `R6`) ;
- aucune correction automatique generee.

## Controles techniques passes

- construction complete depuis l'archive : **OK** ;
- extraction R du dictionnaire : **OK** ;
- extraction Python du questionnaire et des conditions heritees : **OK** ;
- correspondance questionnaire-donnees : **OK** ;
- traduction des univers et validations simples en Stata : **OK** ;
- garde `count if` / `if r(N)>0` pour les exports Excel filtres : **OK** ;
- absence de methodes Survey Solutions non traduites dans le code executable :
  **OK** ;
- unicite des identifiants de regles et presence source/statut/action : **OK** ;
- reproductibilite bit-a-bit des fichiers generes : **OK** ;
- echantillons de valeurs des identifiants et variables personnelles expurges
  du dictionnaire tracable : **OK**.

## Faits verifies dans les donnees

La validation dynamique R, sans correction des donnees, retrouve :

- 862 fiches brutes ;
- 481 fiches au statut `100` ;
- 441 fiches sous le perimetre provisoire `statut 100 + consentement positif +
  cle unique` ;
- aucun doublon de `interview__key` ;
- 110 lignes brutes et 43 lignes du perimetre metier concernees par un
  `cover_id` repete ;
- 111 ages hors cible PAD provisoire 15-35 ans, mais aucun age hors plage
  plausible 15-99 ;
- 19 codes `G3=998` et 98 codes `H5=999999` dans le perimetre metier ;
- 17 totaux hebdomadaires superieurs a 84 heures ;
- 3 valeurs `H4A` superieures a 100 ;
- aucune valeur `H5` superieure a 5 millions hors code special ;
- 19 valeurs `Q2` vides et 48 valeurs non vides non numeriques.

## Distinctions de decision

### Faits documentes par le questionnaire

- `G3=998` est un code special autorise « Ne sait pas » ;
- `H5=999999` est un code special autorise « Ne veut pas dire » ;
- `Q2` est programmee comme variable texte ;
- les conditions de section doivent etre heritees par les questions qu'elles
  contiennent.

Le template exporte donc `998` et `999999` dans des rapports de codes speciaux
pour preparer leur traitement analytique. Il ne les classe pas comme valeurs
illegales et ne les recode pas sans validation.

### Hypotheses de travail a valider

- perimetre questionnaire : `interview__status == 100` ;
- perimetre metier : `statut 100 + consentement positif + cle unique` ;
- cible d'age 15-35 ans ;
- seuil de plausibilite de 84 heures ;
- seuil de 100 travailleurs remuneres pour `H4A` ;
- seuil de 5 millions FCFA pour `H5` ;
- attente d'une valeur numerique ou codifiable pour `Q2`.

### Decisions appliquees dans le template

- aucune ligne brute supprimee ;
- aucun recodage, aucune imputation et aucune deduplication ;
- aucune valeur personnelle dans les rapports questionnaire generes ;
- le rapport `cover_id` du controle systeme est explicitement interne et
  restreint ;
- la sortie porte le statut `diagnostic_only` tant qu'aucune correction metier
  n'est validee.

## Limite de validation

Les do-files n'ont pas ete executes par Stata dans cette session : le dossier
`C:\Program Files\Stata18` ne contient que `STATA.LIC`, sans executable Stata.
La validation couvre donc la generation, les controles statiques et la
contre-verification dynamique R. Un run natif de `program/00_master.do` reste
necessaire sur un poste Stata 15+ avant utilisation operationnelle.
