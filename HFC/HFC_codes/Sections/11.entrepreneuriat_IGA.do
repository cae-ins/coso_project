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
cap erase "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

*----------------------------------------------------------------*
replace section = "K.Entrepreneuriat_IGA"

* K1. A déjà créé sa propre activité génératrice de revenus/entreprise
preserve
	keep if missing(K1) & !missing(HHK_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) a déjà créé sa propre activité génératrice de revenus"
	replace variable = "K1"
	save "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta", replace
restore

* K2. Souhaiterait créer sa propre activité à l'avenir (si K1=2)
preserve
	keep if missing(K2) & K1 == 2 & !missing(HHK_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) souhaiterait créer sa propre activité à l'avenir"
	replace variable = "K2"
	append using "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta", replace
restore

* K3. Principale source d'argent pour démarrer l'activité (si K1=1)
preserve
	keep if missing(K3) & K1 == 1 & !missing(HHK_debut)
	replace commentaire = "Vous n'avez pas renseigné la principale source d'argent utilisée pour démarrer cette activité"
	replace variable = "K3"
	append using "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta", replace
restore

* K4. Principale source de financement envisagée (si K1=2 et K2=1)
preserve
	keep if missing(K4) & K1 == 2 & K2 == 1 & !missing(HHK_debut)
	replace commentaire = "Vous n'avez pas renseigné la principale source de financement envisagée si l'enquêté devrait créer cette activité"
	replace variable = "K4"
	append using "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta", replace
restore

* K5. Principales raisons de non-création de l'activité (si K1=2 et K2=1) - choix multiples
preserve
	keep if missing(K5__1) & missing(K5__2) & missing(K5__3) & missing(K5__4) & missing(K5__5) & missing(K5__6) & missing(K5__7) & K1 == 2 & K2 == 1 & !missing(HHK_debut)
	replace commentaire = "Vous n'avez pas renseigné les principales raisons pour lesquelles l'enquêté n'a pas encore créé cette activité"
	replace variable = "K5"
	append using "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta", replace
restore

* K6. Formation spécifique en entrepreneuriat/gestion d'entreprise
preserve
	keep if missing(K6) & !missing(HHK_debut)
	replace commentaire = "Vous n'avez pas renseigné si l'enquêté(e) a déjà reçu une formation en entrepreneuriat ou en gestion d'entreprise"
	replace variable = "IGA6"
	append using "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta", replace
restore

* K7. Auto-évaluation des compétences pour gérer une IGA
preserve
	keep if missing(K7) & !missing(HHK_debut)
	replace commentaire = "Vous n'avez pas renseigné votre évaluation de vos propres compétences pour gérer une activité génératrice de revenus"
	replace variable = "IGA7"
	append using "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta", replace
restore
