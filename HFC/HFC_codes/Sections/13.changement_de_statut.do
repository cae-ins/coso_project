/*================================
  HIGH FREQUENCY CHECK : SECTION M - CHANGEMENT DE STATUT
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
cap erase "$base_erreurs_stata/13.Changement_de_statut/13.changement_de_statut_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

*----------------------------------------------------------------*
replace section = "M.Changement_de_Statut"

* M1. Comment tu gagnes ta vie/subviens à tes besoins actuellement
preserve
	keep if missing(M1) & !missing(HHM_debut)
	replace commentaire = "Vous n'avez pas renseigné comment l'enquêté(e) gagne sa vie ou s'en sort financièrement en ce moment"
	replace variable = "M1"
	save "$base_erreurs_stata/13.Changement_de_statut/13.changement_de_statut_du_`c(current_date)'.dta", replace
restore

* M2. Aide financière ou matérielle externe (12 derniers mois)
preserve
	keep if missing(M2) & !missing(HHM_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) a reçu une aide financière ou matérielle externe au cours des 12 derniers mois"
	replace variable = "M2"
	append using "$base_erreurs_stata/13.Changement_de_statut/13.changement_de_statut_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/13.Changement_de_statut/13.changement_de_statut_du_`c(current_date)'.dta", replace
restore

* M3. Perception de l'entourage comme personne contribuant économiquement
preserve
	keep if missing(M3) & !missing(HHM_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'entourage perçoit l'enquêté(e) comme une personne qui contribue économiquement"
	replace variable = "M3"
	append using "$base_erreurs_stata/13.Changement_de_statut/13.changement_de_statut_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/13.Changement_de_statut/13.changement_de_statut_du_`c(current_date)'.dta", replace
restore

* M4. Projection à 12 mois (se prendre en charge vs dépendant d'une aide)
preserve
	keep if missing(M4) & !missing(HHM_debut)
	replace commentaire = "Vous n'avez pas renseigné comment l'enquêté(e) se projette dans 12 mois"
	replace variable = "M4"
	append using "$base_erreurs_stata/13.Changement_de_statut/13.changement_de_statut_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/13.Changement_de_statut/13.changement_de_statut_du_`c(current_date)'.dta", replace
restore