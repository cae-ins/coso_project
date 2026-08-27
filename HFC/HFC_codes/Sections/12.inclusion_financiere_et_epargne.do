/*================================
  HIGH FREQUENCY CHECK : SECTION L - INCLUSION FINANCIERE & EPARGNE
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
cap erase "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

*----------------------------------------------------------------*
replace section = "L.Inclusion_Financiere_et_Epargne"

* L1. Compte Mobile Money
preserve
	keep if missing(L1) & !missing(HHL_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) possède un compte Mobile Money"
	replace variable = "L1"
	save "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta", replace
restore

* L2. Compte bancaire
preserve
	keep if missing(L2) & !missing(HHL_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) possède un compte bancaire"
	replace variable = "L2"
	append using "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta", replace
restore

* L3. Épargne régulière
preserve
	keep if missing(L3) & !missing(HHL_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) met régulièrement de l'argent de côté"
	replace variable = "L3"
	append using "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta", replace
restore

* L4. Montant épargné dans un mois typique (si L3=1 ou 2)
preserve
	keep if missing(L4) & (L3 == 1 | L3 == 2) & !missing(HHL_debut)
	replace commentaire = "Vous n'avez pas renseigné le montant que l'enquêté met de côté dans un mois typique"
	replace variable = "L4"
	append using "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta", replace
restore

* L5. Lieu principal de conservation de l'épargne (si L3=1 ou 2)
preserve
	keep if missing(L5) & (L3 == 1 | L3 == 2) & !missing(HHL_debut)
	replace commentaire = "Vous n'avez pas renseigné où l'enquêté conserve principalement son épargne"
	replace variable = "L5"
	append using "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta", replace
restore

* L6. Prêt ou dette en cours
preserve
	keep if missing(L6) & !missing(HHL_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) a actuellement un prêt ou une dette en cours"
	replace variable = "L6"
	append using "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta", replace
restore

* L7. Principale source du prêt/dette (si L6=1)
preserve
	keep if missing(L7) & L6 == 1 & !missing(HHL_debut)
	replace commentaire = "Vous n'avez pas renseigné la principale source de ce prêt ou de cette dette"
	replace variable = "L7"
	append using "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta", replace
restore

* L8. Montant total dû actuellement (si L6=1)
preserve
	keep if missing(L8) & L6 == 1 & !missing(HHL_debut)
	replace commentaire = "Vous n'avez pas renseigné le montant total que l'enquêté doit actuellement"
	replace variable = "L8"
	append using "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta", replace
restore

* L9. Principal motif du prêt (si L6=1)
preserve
	keep if missing(L9) & L6 == 1 & !missing(HHL_debut)
	replace commentaire = "Vous n'avez pas renseigné le principal motif de ce prêt"
	replace variable = "L9"
	append using "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta", replace
restore