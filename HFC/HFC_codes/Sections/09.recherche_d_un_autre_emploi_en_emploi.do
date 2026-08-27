/*================================
  HIGH FREQUENCY CHECK : SECTION I - RECHERCHE D'UN AUTRE EMPLOI – EN EMPLOI (Posez si EMPLOYÉ)
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
cap erase "$base_erreurs_stata/09.Recherche_d_un_autre_emploi_en_emploi/09.recherche_d_un_autre_emploi_en_emploi_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*


*----------------------------------------------------------------*
replace section = "I.Recherche_d_un_Autre_Emploi_en_Emploi"

* I1. Recherche activement un autre emploi/activité
preserve
	keep if missing(I1) & EMPLOYE == 1 & !missing(HHI_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) recherche activement un autre emploi ou une autre activité"
	replace variable = "I1"
	save "$base_erreurs_stata/09.Recherche_d_un_autre_emploi_en_emploi/09.recherche_d_un_autre_emploi_en_emploi_du_`c(current_date)'.dta", replace
restore

* I2. Principale raison de la recherche (si I1=1)
preserve
	keep if missing(I2) & I1 == 1 & !missing(HHI_debut)
	replace commentaire = "Vous n'avez pas renseigné la principale raison pour laquelle l'enquêté(e) recherche un autre emploi"
	replace variable = "I2"
	append using "$base_erreurs_stata/09.Recherche_d_un_Autre_Emploi_en_Emploi/09.recherche_d_un_autre_emploi_en_emploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/09.Recherche_d_un_autre_emploi_en_emploi/09.recherche_d_un_autre_emploi_en_emploi_du_`c(current_date)'.dta", replace
restore

* I3. Principale démarche pour chercher cet autre emploi (si I1=1)
preserve
	keep if missing(I3) & I1 == 1 & !missing(HHI_debut)
	replace commentaire = "Vous n'avez pas renseigné ce que l'enquêté(e) a fait principalement pour chercher cet autre emploi"
	replace variable = "I3"
	append using "$base_erreurs_stata/09.Recherche_d_un_autre_emploi_en_emploi/09.recherche_d_un_autre_emploi_en_emploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/09.Recherche_d_un_autre_emploi_en_emploi/09.recherche_d_un_autre_emploi_en_emploi_du_`c(current_date)'.dta", replace
restore