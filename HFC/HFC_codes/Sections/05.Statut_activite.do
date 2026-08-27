/*================================
  HIGH FREQUENCY CHECK : SECTION E - STATUT D'ACTIVITE
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
cap erase "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*


*------------------------*----------------------*------------------*
replace section = "E. Statut d'Activité"

* E1. Travail rémunéré au cours des 7 derniers jours
preserve
	keep if missing(E1) & !missing(HHE_debut)
	replace commentaire = "Vous n'avez pas renseigné si le répondant a travaillé en échange d'une rémunération au cours des 7 derniers jours (E1)"
	replace variable = "E1"
	save "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta", replace
restore

* E2. Emploi ou entreprise avec absence temporaire (posé si E1=2)
preserve
	keep if missing(E2) & E1 == 2 & !missing(HHE_debut)
	replace commentaire = "Vous n'avez pas renseigné si le répondant dispose d'un emploi dont il est temporairement absent (E2) alors que E1=2"
	replace variable = "E2"
	append using "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta", replace
restore

* E2. Ne doit pas être renseigné si E1=1
preserve
	keep if !missing(E2) & E1 == 1 & !missing(HHE_debut)
	replace commentaire = "E2 a été renseigné alors que E1=1 (répondant déjà classé EMPLOYÉ, E2 non requis)"
	replace variable = "E2"
	append using "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta", replace
restore

* E3. Aide sans rémunération dans entreprise/exploitation familiale (posé si E1=2 et E2=2)
preserve
	keep if missing(E3) & E1 == 2 & E2 == 2 & !missing(HHE_debut)
	replace commentaire = "Vous n'avez pas renseigné si le répondant a aidé sans rémunération dans une entreprise ou exploitation familiale (E3) alors que E1=2 et E2=2"
	replace variable = "E3"
	append using "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta", replace
restore

* E3. Ne doit pas être renseigné si E1=1 ou E2=1
preserve
	keep if !missing(E3) & (E1 == 1 | E2 == 1) & !missing(HHE_debut)
	replace commentaire = "E3 a été renseigné alors que le répondant est déjà classé EMPLOYÉ (E1=1 ou E2=1, E3 non requis)"
	replace variable = "E3"
	append using "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta", replace
restore

* E3A. Destination des produits/services (posé si E3=1)
preserve
	keep if missing(E3A) & E3 == 1 & !missing(HHE_debut)
	replace commentaire = "Vous n'avez pas renseigné si les produits ou services de l'activité sont destinés à la vente ou à l'usage du ménage (E3A) alors que E3=1"
	replace variable = "E3A"
	append using "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta", replace
restore

* E3A. Ne doit pas être renseigné si E3=2
preserve
	keep if !missing(E3A) & E3 == 2 & !missing(HHE_debut)
	replace commentaire = "E3A a été renseigné alors que E3=2 (activité non exercée, E3A non requis)"
	replace variable = "E3A"
	append using "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta", replace
restore

* Vérification cohérence : EMPLOYE ne peut pas être manquant si E1 est renseigné
preserve
	keep if missing(EMPLOYE) & !missing(E1) & !missing(HHE_debut)
	replace commentaire = "Le statut EMPLOYÉ n'a pas pu être déterminé malgré les réponses renseignées aux questions E1 à E3A"
	replace variable = "EMPLOYE"
	append using "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta", replace
restore