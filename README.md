# COSO — insertion professionnelle des jeunes

Ce dépôt contient les codes, cadres méthodologiques et documents de travail
reproductibles du volet d'insertion professionnelle des jeunes du projet COSO.

## Contenu

- `Analyse/R/` : préparation des exports, construction des indicateurs et analyses d'impact ;
- `Analyse/stata/` : scripts Stata correspondants ;
- `Analyse/estimands/` : simulations et vérifications des estimands ;
- `Analyse/scripts/` : calculs de puissance et outils auxiliaires ;
- `Suivi_Evaluation/` : cadre d'indicateurs, estimands et documentation de mesure ;
- `Outils_de_Collecte/` : notes et spécifications questionnaire conservées sous forme texte lorsque possible.

## Données

Les données individuelles, exports Survey Solutions, bases `.dta`, fichiers Excel,
documents institutionnels et sorties provisoires ne sont pas versionnés dans ce
dépôt public. Ils doivent être fournis séparément dans l'environnement de travail
autorisé, conformément aux règles de confidentialité du projet.

La base brute reste la source de vérité. Les scripts d'analyse doivent être
exécutés sur une copie de travail préparée et documentée ; aucune correction ne
doit être appliquée silencieusement.

## Chaîne analytique

```text
export Survey Solutions
  -> préparation des statuts et des clés
  -> contrôles d'apurement
  -> base analytique par vague
  -> jonction assignation / SIG
  -> indicateurs baseline-endline
  -> analyses ITT, LATE et diagnostics
```

Les règles documentées, les propositions métier et les décisions validées doivent
rester distinguées. Le statut `interview_status` doit être interprété selon la
documentation Survey Solutions et non selon une convention implicite.

## Reproduction locale

Les chemins d'entrée sont paramétrés par les scripts ou doivent être adaptés à
l'environnement local. La préparation de l'export V5.1 est lancée avec :

```powershell
Rscript Analyse/R/00_preparer_export_v51.R <export.zip> <sortie.dta> <dossier_rapports>
```

Les scripts d'indicateurs et d'estimation ne doivent être exécutés qu'après
harmonisation des vagues et jonction de l'assignation officielle.

## Dashboard de qualité

Le dashboard agrégé de suivi de la collecte est publié sur
[GitHub Pages](https://cae-ins.github.io/coso_project/). Son déploiement est
déclenché uniquement par les pushes sur le dossier `/docs` de la branche
`dashboard`. Les bases, les
cas individuels et le rapport PDF restent hors du dépôt public.

Le processus local est documenté dans
`Analyse/Processus_Suivi_Qualite_Donnees_COSO.md`.

## Statut

Le dépôt est une base de travail publique initialisée à partir de la version
locale du projet. Les résultats fondés sur les données provisoires restent dans
l'espace de travail restreint et ne constituent pas des résultats officiels.
