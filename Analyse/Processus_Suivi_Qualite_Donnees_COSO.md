# Processus quotidien de suivi de la qualité des données COSO

## Livrables quotidiens

Chaque nouvel export produit un dossier horodaté avec deux livrables principaux :

1. `rapport_qualite_quotidien.pdf` : synthèse actionnable, variables à renforcer, agents à accompagner ou recadrer, cas à revoir et décisions attendues ;
2. `dashboard_qualite.html` : consultation des valeurs manquantes, taux de remplissage, cas signalés par variable, module et agent.

Les fichiers CSV détaillés accompagnent le dashboard pour permettre le suivi dans Excel ou une reprise ultérieure.

## Exécution du soir

Déposer le nouvel export `.zip` dans `Data/Suivi_Collecte`, puis lancer :

```powershell
.\Analyse\Run_Suivi_Qualite_COSO.ps1
```

Le script prend automatiquement le fichier `.zip` ou `.dta` le plus récent. Pour imposer un fichier :

```powershell
.\Analyse\Run_Suivi_Qualite_COSO.ps1 -InputFile "Data\Suivi_Collecte\dernier_export.zip"
```

## Ce que contient le rapport PDF

- nombre de fiches reçues, complétées et éligibles ;
- nombre de règles exécutées et de cas signalés ;
- variables avec le plus de valeurs manquantes ;
- modules incomplets ;
- agents dépassant les seuils de retour ciblé ou de recadrage prioritaire ;
- actions recommandées et fichiers détaillés à consulter.

Les seuils sont transparents et provisoires :

- recadrage prioritaire : au moins 20 % de variables cœur manquantes en moyenne ou 25 % des fiches de l'agent signalées ;
- retour ciblé et contrôle renforcé : à partir de 10 %.

Ces seuils doivent être recalibrés après quelques jours de collecte et ne constituent pas, seuls, une preuve de mauvaise performance.

## Ce que contient le dashboard

- `dashboard_variables.csv` : testés, observés, manquants, taux de manquants, valeurs distinctes et cas signalés ;
- `dashboard_modules.csv` : synthèse par module ;
- `dashboard_agents.csv` : fiches complétées, valeurs cœur manquantes, fiches signalées, taux et action proposée ;
- `audit/quality_cases_for_review.csv` : cas individuels, sans téléphone ni nom ;
- `dashboard_qualite.html` : vue interne avec les priorités par agent ;
- `dashboard_public.html` : vue agrégée sans agents, clés ni cas individuels, destinée à GitHub Pages.

## Protocoles d'action

Le rapport ne « sanctionne » pas automatiquement un agent. Une alerte doit déclencher :

1. vérification des cas individuels ;
2. discussion avec l'agent ou le superviseur ;
3. distinction entre problème de questionnaire, problème de programmation, difficulté répondant et erreur agent ;
4. décision documentée : conserver, corriger la source, recoder, mettre en manquant, exclure ou laisser non résolu ;
5. vérification de la vague suivante.

Les contrôles d'agent doivent être interprétés avec le volume d'entretiens, la zone, le mode d'interview et la difficulté des cas. Une comparaison brute entre agents peut être trompeuse.

## Publication du dashboard sur GitHub Pages

Le dashboard public est servi directement depuis le dossier `/docs` de la branche dédiée `dashboard`. GitHub Pages republie le site à chaque push sur cette branche ; aucun push sur `main` n'est nécessaire.

Après un run quotidien, depuis la branche `dashboard` :

```powershell
.\Analyse\Publier_Dashboard_GitHub.ps1 -OutputRoot "Analyse\suivi_qualite"
```

Le script sélectionne le run le plus récent, refuse les tables contenant des colonnes individuelles sensibles, copie uniquement `dashboard_public.html` vers `docs/index.html`, puis réalise un commit et un push sur `origin/dashboard`. Le PDF, le dashboard interne par agent et les fichiers de cas individuels ne sont pas publiés.

Activation initiale, une seule fois : dans **Settings → Pages**, choisir **Deploy from a branch**, puis la branche `dashboard` et le dossier `/docs`.

## Alignement DIME

Le processus suit les principes DIME de contrôles de haute fréquence : complétude, cohérence, qualité des réponses et suivi des enquêteurs. DIME recommande d'exécuter ces contrôles à chaque réception de données, de partager un journal quotidien des erreurs et d'utiliser les résultats pour le retour terrain et la formation. [DIME — High Frequency Checks](https://dimewiki.worldbank.org/High_Frequency_Checks)

Il reprend aussi le principe de documentation reproductible : chaque run conserve la source, la date, le code exécuté, les sorties et la décision prise. [DIME — Reproducible Research](https://dimewiki.worldbank.org/Reproducible_Research)

## Limites actuelles

La première version utilise les variables et règles déjà identifiées dans l'export V5.1. Elle devra être enrichie avec :

- les diagnostics Survey Solutions et les commentaires reliés à chaque entretien ;
- la durée d'entretien calculée de façon harmonisée ;
- les tentatives de contact et les statuts de suivi ;
- un historique inter-exports pour détecter les dérives ;
- des back-checks et accompagnements documentés ;
- la matrice complète des règles du questionnaire et du manuel enquêteur.
