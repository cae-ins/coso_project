============================================================================
AUTOMATISATION DU REJET DES ENTRETIENS EN ERREUR (HFC COSO)
============================================================================
AUTEUR   : Jaures MANOUAN
VERSION  : 1.0

BUT
---
Automatiser la boucle de rejet des entretiens en erreur :
    1. Stata (Main_COSO.do) produit la base d'erreurs (ordre de grandeur
       623 erreurs / 116 entretiens)  [FAIT AUTOMATIQUEMENT par Stata]
    2. Ce script génère AUTOMATIQUEMENT la base de rejet : regroupement des
       erreurs par entretien, construction du commentaire de rejet
       ("[code] message" par ligne), enrichissement via l'API
       Survey Solutions (id, statut, responsable).
    3. Le script rejette AUTOMATIQUEMENT les entretiens concernés avec le
       commentaire détaillé.

POURQUOI LA CIBLE DU REJET EST-ELLE CORRECTE SANS TABLE DE REFERENCE ?
----------------------------------------------------------------------
- nom_agent  (nom complet de l'enqueteur) vient de l'export Survey Solutions
- Numero_agent_terrain (ex. AgtTeleOp13) = LOGIN du responsable de l'entretien,
  recupere par l'API (Projet 1 existant).
- Or le responsable actuel d'un entretien termine (Completed) est PRECISEMENT
  l'enqueteur qui doit le corriger. En rejetant l'entretien, Survey Solutions
  le renvoie automatiquement a cet enqueteur : aucune re-affectation n'est
  necessaire.

STATUTS SURVEY SOLUTIONS ET ACTIONS
-----------------------------------
  COMPLETED / COMPLETEDBYSUPERVISOR -> REJET (hqreject) avec commentaire
  REJECTEDBYHEADQUARTERS/SUPERVISOR -> skip (deja rejete, en correction)
  *ASSIGNED                         -> skip (deja chez l'agent)
  autre / inconnu                   -> a revoir manuellement (Action=A_REVOIR)

INSTALLATION DES DEPENDANCES (une seule fois)
---------------------------------------------
    pip install pandas openpyxl ssaw

LANCEMENT
---------
  Analyse seule (AUCUNE action dans Survey Solutions) :
    python automatiser_rejet.py --dry-run

  Rejet automatique reel :
    python automatiser_rejet.py --execute

  Travailler sans connexion a l'API (base de rejet sans statut) :
    python automatiser_rejet.py --dry-run --sans-api

SORTIES
-------
  - Base_rejet_AUTO_du_<date>.xlsx : la base de rejet generautomatiquement
      (cles, statuts, responsables, commentaires d'ereur, action decidee).
  - log_rejet_auto.csv (mode --execute) : journal detaille du rejet.

REGLES DE GESTION DE L'API
--------------------------
  URL / worspace / comptes par defaut dans le fichier (modifiables en ligne
  de commande : --url --workspace --api-user --api-password --hq-user
  --hq-password).

REMARQUE SUR LE PIPELINE STATA
------------------------------
  Le script lit automatiquement le dernier fichier
  "Base_erreur_globale_du_*.xlsx" du dossier
  Bases/Base_erreurs/Base_erreurs_excel. Lancer d'abord Main_COSO.do (qui
  appelle Suppression_doublons.do) dans Stata, puis ce script.
============================================================================