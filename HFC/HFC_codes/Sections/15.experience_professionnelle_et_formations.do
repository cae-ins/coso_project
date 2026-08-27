/*================================
  HIGH FREQUENCY CHECK : SECTION O - EXPERIENCE PROFESSIONNELLE ET FORMATIONS
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
cap erase "$base_erreurs_stata/15.Experience_professionnelle_et_formations/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

*----------------------------------------------------------------*
replace section = "O.Experience_Professionnelle_et_Formations"

* O1. Autre emploi ou activité génératrice de revenus auparavant
preserve
	keep if missing(O1) & !missing(HHO_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) a déjà eu un autre emploi ou une autre activité génératrice de revenus"
	replace variable = "O1"
	save "$base_erreurs_stata/15.Experience_professionnelle_et_formations/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta", replace
restore

* O2. Âge au premier emploi/activité (si O1=1)
preserve
	keep if missing(O2) & O1 == 1 & !missing(HHO_debut)
	replace commentaire = "Vous n'avez pas renseigné l'âge auquel l'enquêté(e) a commencé son tout premier emploi ou sa première activité génératrice de revenus"
	replace variable = "O2"
	append using "$base_erreurs_stata/15.Experience_professionnelle_et_formations/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/15.Experience_professionnelle_et_formations/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta", replace
restore

* O3. Formation professionnelle/technique ou apprentissage (12 derniers mois)
preserve
	keep if missing(O3) & !missing(HHO_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) a suivi une formation professionnelle ou un apprentissage au cours des 12 derniers mois"
	replace variable = "O3"
	append using "$base_erreurs_stata/15.Experience_professionnelle_et_formations/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/15.Experience_professionnelle_et_formations/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta", replace
restore

* O4. Métier ou domaine de la formation (si O3=1)
preserve
	keep if missing(O4) & O3 == 1 & !missing(HHO_debut)
	replace commentaire = "Vous n'avez pas renseigné le métier ou le domaine de la formation suivie"
	replace variable = "O4"
	append using "$base_erreurs_stata/15.Experience_professionnelle_et_formations/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/15.Experience_professionnelle_et_formations/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta", replace
restore

* O5. Structure ayant dispensé la formation (si O3=1)
preserve
	keep if missing(O5) & O3 == 1 & !missing(HHO_debut)
	replace commentaire = "Vous n'avez pas renseigné qui a principalement dispensé cette formation"
	replace variable = "O5"
	append using "$base_erreurs_stata/15.Experience_professionnelle_et_formations/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/15.Experience_professionnelle_et_formations/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta", replace
restore

* O6. Utilité de la formation pour trouver un emploi/améliorer les revenus (si O3=1)
preserve
	keep if missing(O6) & O3 == 1 & !missing(HHO_debut)
	replace commentaire = "Vous n'avez pas renseigné dans quelle mesure cette formation vous a été utile"
	replace variable = "O6"
	append using "$base_erreurs_stata/15.Experience_professionnelle_et_formations/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/15.Experience_professionnelle_et_formations/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta", replace
restore