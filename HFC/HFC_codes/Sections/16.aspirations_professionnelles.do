/*================================
  HIGH FREQUENCY CHECK : SECTION P - ASPIRATIONS PROFESSIONNELLES
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
cap erase "$base_erreurs_stata/16.Aspirations_professionnelles/16.aspirations_professionnelles_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

*----------------------------------------------------------------*
replace section = "P.Aspirations_Professionnelles"

* P1. Métier ou activité souhaitée dans les 5 prochaines années
preserve
	keep if missing(P1) & !missing(HHP_debut)
	replace commentaire = "Vous n'avez pas renseigné le métier ou l'activité souhaité(e) dans les cinq prochaines années"
	replace variable = "P1"
	save "$base_erreurs_stata/16.Aspirations_professionnelles/16.aspirations_professionnelles_du_`c(current_date)'.dta", replace
restore

* P2. Type d'objectif principal (emploi salarié/entreprise/développer activité)
preserve
	keep if missing(P2) & !missing(HHP_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) souhaite trouver un emploi salarié, créer ou développer une entreprise"
	replace variable = "P2"
	append using "$base_erreurs_stata/16.Aspirations_professionnelles/16.aspirations_professionnelles_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/16.Aspirations_professionnelles/16.aspirations_professionnelles_du_`c(current_date)'.dta", replace
restore

* P3. Revenu mensuel souhaité (FCFA)
preserve
	keep if missing(P3) & !missing(HHP_debut)
	replace commentaire = "Vous n'avez pas renseigné le revenu mensuel souhaité"
	replace variable = "P3"
	append using "$base_erreurs_stata/16.Aspirations_professionnelles/16.aspirations_professionnelles_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/16.Aspirations_professionnelles/16.aspirations_professionnelles_du_`c(current_date)'.dta", replace
restore

* P4. Secteur d'activité qui intéresse le plus
preserve
	keep if missing(P4) & !missing(HHP_debut)
	replace commentaire = "Vous n'avez pas renseigné le secteur d'activité qui intéresse le plus l'enquêté(e)"
	replace variable = "P4"
	append using "$base_erreurs_stata/16.Aspirations_professionnelles/16.aspirations_professionnelles_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/16.Aspirations_professionnelles/16.aspirations_professionnelles_du_`c(current_date)'.dta", replace
restore

* P5. Principal obstacle à la réalisation des objectifs professionnels
preserve
	keep if missing(P5) & !missing(HHP_debut)
	replace commentaire = "Vous n'avez pas renseigné le principal obstacle à la réalisation de vos objectifs professionnels"
	replace variable = "P5"
	append using "$base_erreurs_stata/16.Aspirations_professionnelles/16.aspirations_professionnelles_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/16.Aspirations_professionnelles/16.aspirations_professionnelles_du_`c(current_date)'.dta", replace
restore
