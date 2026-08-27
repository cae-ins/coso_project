/*================================
  HIGH FREQUENCY CHECK : SECTION Q - COHESION SOCIAL ET ENGAGEMENT
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
cap erase "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.Cohesion_sociale_et_engagement_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

*----------------------------------------------------------------*
replace section = "Q.Cohesion_sociale_et_engagement"

* Q1. Membre d'une association/coopérative/club/groupe communautaire
preserve
	keep if missing(Q1) & !missing(HHQ_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) est membre d'une association"
	replace variable = "Q1"
	save "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta", replace
restore

* Q2. Fréquence bénévolat 30 derniers jours
preserve
	keep if missing(Q2) & !missing(HHQ_debut)
	replace commentaire = "Vous n'avez pas renseigné le nombre de fois où l'enquêté(e) a donné de son temps libre"
	replace variable = "Q2"
	append using "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta", replace
restore

* Q3. Confiance générale envers les autres
preserve
	keep if missing(Q3) & !missing(HHQ_debut)
	replace commentaire = "Vous n'avez pas renseigné le niveau de confiance générale envers les autres"
	replace variable = "Q3"
	append using "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta", replace
restore

* Q4. Confiance envers les jeunes d'origine différente
preserve
	keep if missing(Q4) & !missing(HHQ_debut)
	replace commentaire = "Vous n'avez pas renseigné le niveau de confiance envers les jeunes d'origine différente"
	replace variable = "Q4"
	append using "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta", replace
restore

* Q5. Confiance envers la police
preserve
	keep if missing(Q5) & !missing(HHQ_debut)
	replace commentaire = "Vous n'avez pas renseigné le niveau de confiance envers la police"
	replace variable = "Q5"
	append using "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta", replace
restore

* Q6. Confiance envers les forces armées
preserve
	keep if missing(Q6) & !missing(HHQ_debut)
	replace commentaire = "Vous n'avez pas renseigné le niveau de confiance envers les forces armées"
	replace variable = "Q6"
	append using "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta", replace
restore

* Q7. Confiance envers les chefs traditionnels
preserve
	keep if missing(Q7) & !missing(HHQ_debut)
	replace commentaire = "Vous n'avez pas renseigné le niveau de confiance envers les chefs traditionnels"
	replace variable = "Q7"
	append using "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta", replace
restore

* Q8. Confiance envers les chefs religieux
preserve
	keep if missing(Q8) & !missing(HHQ_debut)
	replace commentaire = "Vous n'avez pas renseigné le niveau de confiance envers les chefs religieux"
	replace variable = "Q8"
	append using "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta", replace
restore

* Q9. Confiance envers les autorités gouvernementales locales
preserve
	keep if missing(Q9) & !missing(HHQ_debut)
	replace commentaire = "Vous n'avez pas renseigné le niveau de confiance envers les autorités gouvernementales locales"
	replace variable = "Q9"
	append using "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta", replace
restore

* Q10. Confiance envers les autorités gouvernementales centrales
preserve
	keep if missing(Q10) & !missing(HHQ_debut)
	replace commentaire = "Vous n'avez pas renseigné le niveau de confiance envers les autorités gouvernementales centrales"
	replace variable = "Q10"
	append using "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta", replace
restore