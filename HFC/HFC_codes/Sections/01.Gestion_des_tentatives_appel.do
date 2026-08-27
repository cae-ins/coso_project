/*================================
  HIGH FREQUENCY CHECK : SECTION A - GESTION DES TENTATIVES D'APPEL
  Auteur : Equipe projet - COSO 
  Date   : Juillet 2026
==================================*/


clear all //Cette commande supprime toutes les données, variables, macros, matrices et programmes en mémoire. Elle "nettoie" l'espace de travail pour permettre de commencer une nouvelle session sans interférences.

cls //Cette commande efface l'interface utilisateur de Stata

set more off //Par défaut, Stata interrompt l'affichage des sorties longues pour demander à l'utilisateur d'appuyer sur une touche pour continuer. Cette commande désactive ce comportement, permettant à Stata de faire défiler automatiquement toutes les sorties sans interruption.



*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

*Chargement des chemins d'accès
*do "D:/CAE/COSO/Collecte/Baseline/HFC/HFC_codes/Chemins_acces.do"

* Chargement de la base de données
use "$base_brute/Questionnaire_COSO_V4.dta", clear  

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*


*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

* Création des variables necessaire
capture drop section
generate section = ""

capture drop commentaire
generate commentaire = ""

capture drop variable
generate variable = ""


*Création ou écrasement de la base d'erreurs
cap erase "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*


*------------------------*----------------------*------------------*
replace section = "A. GESTION DES TENTATIVES D'APPEL"


* A1. Numéro de la tentative d'appel en cours
preserve
	keep if missing(A1) & !missing(HHA_debut)
	replace commentaire = "Vous n'avez pas renseigné le numéro de la tentative d'appel en cours"
	replace variable = "A1"
	save "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta", replace
restore

* A2. Date de l'appel
preserve
	keep if missing(A2_date) & !missing(HHA_debut)
	replace commentaire = "Vous n'avez pas renseigné la date de l'appel"
	replace variable = "A2_date"
	append using "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta", replace
restore

/* A3. Heure de l'appel
preserve
	keep if missing(A3) & !missing(HHA_debut)
	replace commentaire = "Vous n'avez pas renseigné l'heure de l'appel"
	replace variable = "A3"
	append using "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta", replace
restore
*/
* A4. Résultat de la tentative d'appel
preserve
	keep if missing(A4) & !missing(HHA_debut)
	replace commentaire = "Vous n'avez pas renseigné le résultat de la tentative d'appel"
	replace variable = "A4"
	append using "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta", replace
restore

* A4. Vérification modalité valide (1 à 8)
preserve
	keep if !missing(A4) & !inrange(A4, 1, 8) & !missing(HHA_debut)
	replace commentaire = "La valeur renseignée pour le résultat de la tentative d'appel est invalide (valeur attendue : 1 à 8)"
	replace variable = "A4"
	append using "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta", replace
restore

* A5. Date et heure de la prochaine tentative (posé si A4=5 ou A4=7)
preserve
	keep if missing(A5_date) & inlist(A4, 5, 7) & !missing(HHA_debut)
	replace commentaire = "Vous n'avez pas renseigné la date et l'heure prévues pour la prochaine tentative d'appel"
	replace variable = "A5_date"
	append using "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta", replace
restore

* A5. Cohérence : A5 ne doit pas être renseigné si A4 différent de 5 ou 7
preserve
	keep if !missing(A5_date) & !inlist(A4, 5, 7) & !missing(HHA_debut)
	replace commentaire = "La date de la prochaine tentative (A5) a été renseignée alors que le résultat de l'appel (A4) ne le requiert pas"
	replace variable = "A5_date"
	append using "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta", replace
restore
