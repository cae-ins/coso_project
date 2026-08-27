Comment l'installer :

Installer d'abord dans spyder ou Vscode ceci :

pip install openpyxl python-docx

Ensuite pour le lancer il faut :
📋 ÉTAPE 1 — Vérifier si Python est déjà installé

1. Appuyez sur les touches Windows + R de votre clavier

2. Tapez cmd puis appuyez sur Entrée

3. Une fenêtre noire s'ouvre (c'est le "terminal")

4. Tapez le nom du disque ou vous avez deposé le programme .py. Par exemple si le programme est le disque D, tapez D:    puis appuyez sur Entrée

5. Tapez cd  (avec un espace) puis faites glisser votre dossier dans la fenêtre noire — le chemin se remplit tout seul

6. Appuyez sur Entrée

7. Puis tapez : python export_pdf_par_region.py

🖥️ ÉTAPE 6 — Utiliser l'interface

Ce que fait l'interface (UserForm) :

Parcourir → sélectionner votre fichier .xlsx ou .xlsm
Feuille → liste déroulante peuplée automatiquement
Colonne de regroupement → choisir REGION, DISTRICT ou n'importe quelle colonne
Colonnes à exclure → cases à cocher pour chaque colonne détectée
⚠️ Alerte automatique si un nom de colonne dépasse 30 caractères — le message indique exactement quelle colonne renommer
Lancer l'export → génère un PDF par valeur unique, avec journal de progression en temps réel

La conversion PDF fonctionne via LibreOffice ou MS Word — le script essaie les de