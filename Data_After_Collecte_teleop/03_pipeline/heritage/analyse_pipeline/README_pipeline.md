# Pipeline COSO

Le [rapport méthodologique](rapport_methodologique.md) explique les définitions, les dénominateurs, les exclusions et les limites des 21 indicateurs.

| Étape | Code | Entrée | Sortie |
| --- | --- | --- | --- |
| **01** Apurement | `01_apurement.py` | DTA original | `résultats/base_apuree.csv` |
| **02** Calcul | `02_indicateurs.py` | Base apurée | Résultats temporaires communs à Excel et PDF |
| **03** Excel | `03_excel.mjs` | Résultats temporaires | `résultats/indicateurs_COSO.xlsx` |
| **04** Synthèse | `04_rapport.py` puis Tectonic | Mêmes résultats temporaires | `résultats/synthese_COSO.pdf` |
| **05** Contrôle | `05_verifier.py` | Base et livrables | Validation, sans autre fichier |

Pour tout relancer depuis le dossier `analyse` :

```bash
./pipeline/executer.sh
```

Prérequis : Python avec `pandas`, `numpy` et `openpyxl` (interpréteur par défaut : `/opt/anaconda3/bin/python3`, modifiable par `COSO_PYTHON`), Node avec `@oai/artifact-tool` (dépendances du runtime, chemin modifiable par `COSO_NODE_MODULES`) et Tectonic. Le script prépare ses dépendances Node et ses fichiers intermédiaires dans un dossier temporaire. Fermer le classeur Excel avant de relancer le pipeline. Le dossier `résultats` contient uniquement les trois livrables indiqués ci-dessus.

Dans un environnement restreint où Tectonic ne peut pas être appelé par un script, exécuter successivement les étapes `01` à `04` avec un répertoire temporaire, puis lancer directement `tectonic --only-cached` et l'étape `05`. Le PDF fourni a été compilé et vérifié de cette manière.
