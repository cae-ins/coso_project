# Validation du moteur R d'apurement COSO

**Date :** 16 aout 2026
**Source :** `Questionnaire_COSO_V5_1_STATA_All_20260815T1946Z.zip`
**SHA-256 :** `6F41BE295E312C22AF626A97B0C63FEBC4C5DA9C52764FE468D8F518E5377699`

## Conclusion

Le moteur R execute l'integralite des controles actuellement qualifies
d'executables et produit une sortie diagnostique sans modifier les reponses.
Le miroir Stata est conserve comme reference, mais n'est plus requis pour le run
operationnel local.

La revue independante consignee dans `apurement_coso_agy_review.md` conclut a
**PASS** pour ce perimetre, sans constat bloquant ou majeur restant.

## Controles passes

- 30 fichiers R parses sans erreur, dont 19 scripts generes par section ;
- 477 controles questionnaire evalues ;
- domaine et coherence hierarchique de 4 listes en cascade traces `A_VALIDER`,
  sans faux controle automatique depuis le HTML Preview tronque ;
- 6 controles metier proposes evalues et maintenus au statut `a_valider` ;
- 19 vues de section produites, chacune avec 481 entretiens au statut 100 ;
- unicite de `interview__key` dans la sortie finale ;
- 862 lignes conservees dans la base finale ;
- zero correction, suppression, imputation, recodage ou deduplication ;
- egalite complete des 218 colonnes brutes (valeurs et attributs) entre la
  source et la sortie ; seules cinq colonnes techniques documentees sont ajoutees ;
- statut final uniforme `diagnostic_only` ;
- egalite exacte des 15 indicateurs agreges avec
  `generated/data_evidence_validation.csv` ;
- parite de la fonction `missing()` avec Stata pour `NA`, chaines vides et
  chaines composees d'espaces ;
- absence des onze colonnes sensibles, dont `nom_agent` et `nom_sup`, dans les
  rapports non restreints ;
- labels de valeurs expurges pour toutes les variables classees PII ;
- libelles des modalites `nom_agent` et `nom_sup` expurges dans les metadonnees
  du questionnaire, tout en conservant les codes necessaires au controle de
  domaine ;
- exemples de valeurs expurges pour toutes les variables textuelles du
  dictionnaire tracable ;
- reproductibilite bit a bit des trois manifestes CSV ;
- egalite logique complete de la base `.dta` entre deux executions successives.

Le conteneur `.dta` n'est pas bit-identique entre deux ecritures Haven, mais son
contenu, ses valeurs et ses attributs sont identiques. Les manifestes CSV qui
servent aux comparaisons de run sont, eux, bit-identiques.

## Resultats agreges confirmes

- 862 fiches brutes ;
- 481 fiches au statut 100 ;
- 441 fiches dans le perimetre metier provisoire ;
- 0 doublon de cle technique ;
- 110 lignes avec `cover_id` repete dans le brut et 43 dans le perimetre metier ;
- 111 ages hors cible PAD provisoire 15-35 ;
- 19 codes speciaux `G3=998` et 98 codes speciaux `H5=999999` ;
- 17 totaux d'heures superieurs a 84 ;
- 3 valeurs `H4A` superieures a 100 ;
- 19 valeurs `Q2` vides et 48 non vides non numeriques.

## Distinction des statuts

**Faits documentes :** les codes speciaux proviennent du questionnaire ; les
volumes ci-dessus sont observes dans l'export et reproduits par deux controles R
distincts.

**Hypotheses de travail :** les deux perimetres, la cible d'age, les seuils de
plausibilite et la codification attendue de `Q2` restent a valider.

**Decisions appliquees :** R est le moteur operationnel ; le pipeline conserve
toutes les lignes et n'applique aucune correction non validee ; les donnees et
rapports nominatifs restent locaux et ignores par Git.

## Limites residuelles

La parite native avec Stata n'a pas pu etre mesuree sur ce poste, qui ne dispose
pas de l'executable Stata. Les 2 410 couples fiche-regle du manifeste complet ne
sont pas directement comparables aux 334 couples issus du tableau de suivi
quotidien : le premier inventorie exhaustivement les domaines, sauts, manquants,
validations et codes speciaux du questionnaire, tandis que le second applique un
jeu plus restreint de 37 indicateurs de suivi.

Le generateur Stata protege desormais les comparaisons de variables nullable par
`!missing(...)`, avec un test de regression dedie. Cette correction rapproche le
miroir de la semantique Survey Solutions/R, sans remplacer le run natif Stata qui
reste indisponible sur ce poste.

Les champs « Autre a preciser » sont couverts par les controles de manquants et
de sauts, mais cette v1 ne produit pas encore le lot centralise de codification
manuelle et n'integre aucun fichier de retour. Cette limite est compatible avec
le statut `diagnostic_only`, pas avec une declaration d'apurement finalise.
