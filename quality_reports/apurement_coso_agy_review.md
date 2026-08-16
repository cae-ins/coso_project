# Revue independante agy — apurement COSO en R

**Date :** 16 aout 2026
**Perimetre :** moteur R `diagnostic_only`, generateurs, matrices, rapports,
confidentialite et contrat de sortie.

## Verdict

**PASS** — aucun constat bloquant ou majeur ne subsiste apres corrections.

## Corrections issues de la revue

- alignement de `missing()` sur Stata pour `NA`, chaines vides et espaces ;
- expurgation des noms d'agents/superviseurs dans le dictionnaire, les labels,
  les options du questionnaire et les rapports non restreints ;
- chemins de source rendus relatifs dans les artefacts tracables ;
- validateur rendu independant des volumes et du hash du seul export du 15 aout ;
- comparaison stricte des 218 colonnes brutes avec la sortie lorsque zero
  correction est declare ;
- quatre listes en cascade maintenues `A_VALIDER`, car les options du HTML
  Preview sont tronquees et produiraient de faux domaines ;
- comparaisons nullable du miroir Stata protegees par `!missing(...)`.

## Controles confirmes

- 499 lignes dans la matrice ;
- 477 regles questionnaire et 6 regles metier proposees executees ;
- 4 controles de cascade `A_VALIDER` ;
- aucune erreur d'evaluation et aucune correction automatique ;
- 59 rapports Excel dont le nombre de lignes correspond au manifeste ;
- 862 lignes conservees ;
- 218 colonnes brutes identiques, plus 5 colonnes techniques documentees ;
- aucune donnee sensible dans les artefacts committables ;
- aucun nom de personnel ou chemin utilisateur dans les artefacts tracables ;
- separation explicite des faits, hypotheses et decisions.

## Reserves mineures

- le workflow complet « Autre a preciser » (export exhaustif, codification,
  validation et integration des retours) reste a construire ;
- l'environnement R/Python n'est pas encore verrouille par `renv.lock` et un
  fichier de dependances Python ;
- les sorties regenerables sont nettoyees avant la fin du run : une erreur
  intermediaire peut laisser une couche de sortie partielle, sans toucher au
  snapshot brut ;
- la parite native Stata reste non testee faute d'executable local.

Ces reserves sont compatibles avec le statut `diagnostic_only`; elles devront
etre traitees avant de qualifier la base de completement apuree.
