/*================================
  HIGH FREQUENCY CHECK : SECTION F - EMPLOI PRINCIPAL
  Auteur : Equipe projet - COSO 
  Date   : juin 2026
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
cap erase "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*


*------------------------*----------------------*------------------*
replace section = "F. Emploi Principal"

* F1. Statut dans l'emploi (posé si EMPLOYÉ)
preserve
	keep if missing(F1) & EMPLOYE == 1 & !missing(HHF_debut)
	replace commentaire = "Vous n'avez pas renseigné le statut dans l'emploi (F1) alors que le répondant est classé EMPLOYÉ"
	replace variable = "F1"
	save "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta", replace
restore

* F1. Ne doit pas être renseigné si NON_EMPLOYE
preserve
	keep if !missing(F1) & EMPLOYE == 0 & !missing(HHF_debut)
	replace commentaire = "F1 a été renseigné alors que le répondant est classé NON EMPLOYÉ"
	replace variable = "F1"
	append using "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta", replace
restore

* F2. Secteur d'activité principale
preserve
	keep if missing(F2) & EMPLOYE == 1 & !missing(HHF_debut)
	replace commentaire = "Vous n'avez pas renseigné le secteur d'activité principale (F2) alors que le répondant est classé EMPLOYÉ"
	replace variable = "F2"
	append using "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta", replace
restore

* F2. Ne doit pas être renseigné si NON_EMPLOYE
preserve
	keep if !missing(F2) & EMPLOYE == 0 & !missing(HHF_debut)
	replace commentaire = "F2 a été renseigné alors que le répondant est classé NON EMPLOYÉ"
	replace variable = "F2"
	append using "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta", replace
restore

* F3. Lieu d'exercice du travail
preserve
	keep if missing(F3) & EMPLOYE == 1 & !missing(HHF_debut)
	replace commentaire = "Vous n'avez pas renseigné le lieu d'exercice du travail (F3) alors que le répondant est classé EMPLOYÉ"
	replace variable = "F3"
	append using "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta", replace
restore

* F3. Ne doit pas être renseigné si NON_EMPLOYE
preserve
	keep if !missing(F3) & EMPLOYE == 0 & !missing(HHF_debut)
	replace commentaire = "F3 a été renseigné alors que le répondant est classé NON EMPLOYÉ"
	replace variable = "F3"
	append using "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta", replace
restore

* F4. Ancienneté dans l'emploi
preserve
	keep if missing(F4) & EMPLOYE == 1 & !missing(HHF_debut)
	replace commentaire = "Vous n'avez pas renseigné la durée dans l'emploi actuel (F4) alors que le répondant est classé EMPLOYÉ"
	replace variable = "F4"
	append using "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta", replace
restore

* F4. Ne doit pas être renseigné si NON_EMPLOYE
preserve
	keep if !missing(F4) & EMPLOYE == 0 & !missing(HHF_debut)
	replace commentaire = "F4 a été renseigné alors que le répondant est classé NON EMPLOYÉ"
	replace variable = "F4"
	append using "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta", replace
restore
