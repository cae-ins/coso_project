/*================================
  HIGH FREQUENCY CHECK : SECTION N - RESILIENCE FACE AUX CHOCS
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
cap erase "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

*----------------------------------------------------------------*
replace section = "N.Resilience_Face_aux_Chocs"

* N1. Ménage affecté par un choc au cours des 12 derniers mois
preserve
	keep if missing(N1) & !missing(HHN_debut)
	replace commentaire = "Vous n'avez pas renseigné si le ménage a été affecté par un choc au cours des 12 derniers mois"
	replace variable = "N1"
	save "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta", replace
restore

* N2. Choc/problème le plus important subi (si N1=1)
preserve
	keep if missing(N2) & N1 == 1 & !missing(HHN_debut)
	replace commentaire = "Vous n'avez pas renseigné le choc ou problème le plus important subi"
	replace variable = "N2"
	append using "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta", replace
restore

* N3. Impact/conséquence du choc sur le revenu ou l'activité (si N1=1)
preserve
	keep if missing(N3) & N1 == 1 & !missing(HHN_debut)
	replace commentaire = "Vous n'avez pas renseigné l'impact du choc sur le revenu ou l'activité de l'enquêté(e)"
	replace variable = "N3"
	append using "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta", replace
restore

* N4. Principale stratégie face au choc/problème (si N1=1)
preserve
	keep if missing(N4) & N1 == 1 & !missing(HHN_debut)
	replace commentaire = "Vous n'avez pas renseigné comment l'enquêté a principalement fait face à ce choc"
	replace variable = "N4"
	append using "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta", replace
restore

* N5. Temps nécessaire pour un retour au niveau d'avant le choc (si N1=1)
preserve
	keep if missing(N5) & N1 == 1 & !missing(HHN_debut)
	replace commentaire = "Vous n'avez pas renseigné le temps qu'il a fallu à l'enquêté pour que son activité ou revenu revienne à son niveau d'avant le choc"
	replace variable = "N5"
	append using "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta", replace
restore

* N6. Capacité à couvrir une dépense imprévue de 250 000 FCFA
preserve
	keep if missing(N6) & !missing(HHN_debut)
	replace commentaire = "Vous n'avez pas renseigné si le ménage serait en mesure de couvrir une dépense imprévue de 250 000 FCFA"
	replace variable = "N6"
	append using "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta", replace
restore

* N7. Auto-évaluation capacité à résister à un choc économique (1 à 10)
preserve
	keep if missing(N7) & !missing(HHN_debut)
	replace commentaire = "Vous n'avez pas renseigné l'évaluation de la capacité à résister de l'enquêté à un choc économique"
	replace variable = "N7"
	append using "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta", replace
restore