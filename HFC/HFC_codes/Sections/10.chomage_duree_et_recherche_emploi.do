/*================================
  HIGH FREQUENCY CHECK : SECTION J - CHOMAGE – DUREE ET RECHERCHE D'EMPLOI (Posez si NON EMPLOYÉ)
  Auteur : Equipe projet - COSO 
  Date   : juillet 2026
==================================*/


clear all //Cette commande supprime toutes les données, variables, macros, matrices et programmes en mémoire. Elle "nettoie" l'espace de travail pour permettre de commencer une nouvelle session sans interférences.

cls //Cette commande efface l'interface utilisateur de Stata

set more off //Par défaut, Stata interrompt l'affichage des sorties longues pour demander à l'utilisateur d'appuyer sur une touche pour continuer. Cette commande désactive ce comportement, permettant à Stata de faire défiler automatiquement toutes les sorties sans interruption.



*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
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
cap erase "$base_erreurs_stata/10.Chomage_duree_et_recherche_emploi/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

*----------------------------------------------------------------*
replace section = "J.Chomage_Duree_et_Recherche_Emploi"

* J0. A cherché un emploi/activité au cours des 30 derniers jours (si NON EMPLOYÉ)
preserve
	keep if missing(J0) & EMPLOYE == 0 & !missing(HHJ_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) a cherché un emploi ou essayé de démarrer une activité au cours des 30 derniers jours"
	replace variable = "J0"
	save "$base_erreurs_stata/10.Chomage_duree_et_recherche_emploi/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta", replace
restore

* J0A. Principale raison de non-recherche d'emploi (si J0=2)
preserve
	keep if missing(J0A) & J0 == 2 & !missing(HHJ_debut)
	replace commentaire = "Vous n'avez pas renseigné la principale raison pour laquelle l'enquêté n'avait pas cherché d'emploi ni essayé de démarrer une activité"
	replace variable = "J0A"
	append using "$base_erreurs_stata/10.Chomage_duree_et_recherche_emploi/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/10.Chomage_duree_et_recherche_emploi/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta", replace
restore

* J0B. Souhaiterait travailler à l'heure actuelle (si J0=2)
preserve
	keep if missing(J0B) & J0 == 2 & !missing(HHJ_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) souhaiterait travailler à l'heure actuelle"
	replace variable = "J0B"
	append using "$base_erreurs_stata/10.Chomage_duree_et_recherche_emploi/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/10.Chomage_duree_et_recherche_emploi/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta", replace
restore

* J1. Principale démarche pour trouver un emploi/créer une entreprise (si J0=1)
preserve
	keep if missing(J1) & J0 == 1 & !missing(HHJ_debut)
	replace commentaire = "Vous n'avez pas renseigné ce que l'enquêté a fait principalement pour trouver un emploi ou démarrer une entreprise"
	replace variable = "J1"
	append using "$base_erreurs_stata/10.Chomage_duree_et_recherche_emploi/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/10.Chomage_duree_et_recherche_emploi/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta", replace
restore

* J2. Durée depuis laquelle sans emploi et en recherche (si J0=1)
preserve
	keep if missing(J2) & J0 == 1 & !missing(HHJ_debut)
	replace commentaire = "Vous n'avez pas renseigné depuis combien de temps l'enquêté est sans emploi et en recherche"
	replace variable = "J2"
	append using "$base_erreurs_stata/10.Chomage_duree_et_recherche_emploi/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/10.Chomage_duree_et_recherche_emploi/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta", replace
restore

* J3. Disponibilité pour commencer un emploi dans les 2 semaines (si NON EMPLOYÉ, y compris J0=2)
preserve
	keep if missing(J3) & EMPLOYE == 0 & !missing(HHJ_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté a pu commencer un emploi dans les deux semaines suivantes"
	replace variable = "J3"
	append using "$base_erreurs_stata/10.Chomage_duree_et_recherche_emploi/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/10.Chomage_duree_et_recherche_emploi/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta", replace
restore