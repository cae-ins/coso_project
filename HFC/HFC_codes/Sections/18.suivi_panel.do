/*================================
  HIGH FREQUENCY CHECK : SECTION R - SUIVI PANEL
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
cap erase "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

*----------------------------------------------------------------*
replace section = "R.Suivi_panel"

* R1. Meilleur moyen de contact
preserve
	keep if missing(R1) & !missing(HHR_debut)
	replace commentaire = "Vous n'avez pas renseigné si le numéro utilisé est le meilleur moyen pour contacter l'enquêté"
	replace variable = "R1"
	save "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta", replace
restore

* R1A. Meilleur numéro à l'avenir (si R1=2)
preserve
	keep if missing(R1A) & R1 == 2 & !missing(HHR_debut)
	replace commentaire = "Vous n'avez pas renseigné le meilleur numéro pour contacter l'enquêté à l'avenir"
	replace variable = "R1A"
	append using "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta", replace
restore

* R2. Autre numéro disponible
preserve
	keep if missing(R2) & !missing(HHR_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté a un autre numéro"
	replace variable = "R2"
	append using "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta", replace
restore

* R2A. Quel est cet autre numéro (si R2=1)
preserve
	keep if missing(R2A) & R2 == 1 & !missing(HHR_debut)
	replace commentaire = "Vous n'avez pas renseigné l'autre numéro de contact"
	replace variable = "R2A"
	append using "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta", replace
restore

* R3. Utilisation de WhatsApp
preserve
	keep if missing(R3) & !missing(HHR_debut)
	replace commentaire = "Vous n'avez pas renseigné si vous utilisez WhatsApp"
	replace variable = "R3"
	append using "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta", replace
restore

* R3A. Compte WhatsApp lié au même numéro (si R3=1)
preserve
	keep if missing(R3A) & R3 == 1 & !missing(HHR_debut)
	replace commentaire = "Vous n'avez pas renseigné si le compte WhatsApp est lié au même numéro"
	replace variable = "R3A"
	append using "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta", replace
restore

* R3B. Numéro lié au compte WhatsApp (si R3A=2)
preserve
	keep if missing(R3B) & R3A == 2 & !missing(HHR_debut)
	replace commentaire = "Vous n'avez pas renseigné le numéro lié au compte WhatsApp"
	replace variable = "R3B"
	append using "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta", replace
restore

* R4. Contact d'une personne de recours
preserve
	keep if missing(R4) & !missing(HHR_debut)
	replace commentaire = "Vous n'avez pas renseigné le contact d'une personne de recours"
	replace variable = "R4"
	append using "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta", replace
restore

* R5. Accepte d'être recontacté(e)
preserve
	keep if missing(R5) & !missing(HHR_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) accepte d'être recontacté(e)"
	replace variable = "R5"
	append using "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta", replace
restore