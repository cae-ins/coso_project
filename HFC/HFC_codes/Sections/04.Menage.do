/*================================
  HIGH FREQUENCY CHECK : SECTION D - MENAGE
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
cap erase "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*


*------------------------*----------------------*------------------*
replace section = "D. Ménage"

* D1. Nombre de personnes dans le ménage
preserve
	keep if missing(D1) & !missing(HHD_debut)
	replace commentaire = "Vous n'avez pas renseigné le nombre de personnes vivant habituellement dans le ménage (D1)"
	replace variable = "D1"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D1. Vérification valeur plausible (au moins 1 personne)
preserve
	keep if !missing(D1) & D1 < 1 & !missing(HHD_debut)
	replace commentaire = "Le nombre de personnes dans le ménage (D1) est invalide (valeur attendue : au moins 1)"
	replace variable = "D1"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D1. Vérification valeur aberrante (plus de 30 personnes)
preserve
	keep if !missing(D1) & D1 > 30 & !missing(HHD_debut)
	replace commentaire = "Le nombre de personnes dans le ménage (D1) semble aberrant (valeur renseignée supérieure à 30)"
	replace variable = "D1"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D2. Nombre de personnes de moins de 15 ans
preserve
	keep if missing(D2) & !missing(HHD_debut)
	replace commentaire = "Vous n'avez pas renseigné le nombre de personnes de moins de 15 ans dans le ménage (D2)"
	replace variable = "D2"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D2. Cohérence : D2 ne peut pas être supérieur à D1
preserve
	keep if !missing(D2) & !missing(D1) & D2 > D1 & !missing(HHD_debut)
	replace commentaire = "Le nombre de personnes de moins de 15 ans (D2) est supérieur au nombre total de personnes dans le ménage (D1)"
	replace variable = "D2"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D3. Lien de parenté avec le chef de ménage
preserve
	keep if missing(D3) & !missing(HHD_debut)
	replace commentaire = "Vous n'avez pas renseigné le lien de parenté du répondant avec le chef de ménage (D3)"
	replace variable = "D3"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D4. Nombre de personnes exerçant une activité rémunérée
preserve
	keep if missing(D4) & !missing(HHD_debut)
	replace commentaire = "Vous n'avez pas renseigné le nombre de personnes du ménage exerçant une activité rémunérée (D4)"
	replace variable = "D4"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D4. Cohérence : D4 ne peut pas être supérieur à D1
preserve
	keep if !missing(D4) & !missing(D1) & D4 > D1 & !missing(HHD_debut)
	replace commentaire = "Le nombre de personnes ayant une activité rémunérée (D4) est supérieur au nombre total de personnes dans le ménage (D1)"
	replace variable = "D4"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D4. Cohérence : D4 ne peut pas être supérieur à D1-D2 (personnes de 15 ans et plus)
preserve
	keep if !missing(D4) & !missing(D1) & !missing(D2) & D4 > (D1 - D2) & !missing(HHD_debut)
	replace commentaire = "Le nombre de personnes ayant une activité rémunérée (D4) est supérieur au nombre de personnes de 15 ans et plus dans le ménage (D1-D2)"
	replace variable = "D4"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

/* D5a. Possession d'une télévision
preserve
	keep if missing(D5a) & !missing(HHD_debut)
	replace commentaire = "Vous n'avez pas renseigné si le ménage possède une télévision fonctionnelle (D5a)"
	replace variable = "D5a"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D5b. Possession d'un téléphone portable
preserve
	keep if missing(D5b) & !missing(HHD_debut)
	replace commentaire = "Vous n'avez pas renseigné si le ménage possède un téléphone portable fonctionnel (D5b)"
	replace variable = "D5b"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D5c. Possession d'une moto
preserve
	keep if missing(D5c) & !missing(HHD_debut)
	replace commentaire = "Vous n'avez pas renseigné si le ménage possède une moto fonctionnelle (D5c)"
	replace variable = "D5c"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D5d. Possession d'un vélo
preserve
	keep if missing(D5d) & !missing(HHD_debut)
	replace commentaire = "Vous n'avez pas renseigné si le ménage possède un vélo fonctionnel (D5d)"
	replace variable = "D5d"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D5e. Possession d'une brouette
preserve
	keep if missing(D5e) & !missing(HHD_debut)
	replace commentaire = "Vous n'avez pas renseigné si le ménage possède une brouette fonctionnelle (D5e)"
	replace variable = "D5e"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D5f. Possession d'un réfrigérateur/congélateur
preserve
	keep if missing(D5f) & !missing(HHD_debut)
	replace commentaire = "Vous n'avez pas renseigné si le ménage possède un réfrigérateur ou congélateur fonctionnel (D5f)"
	replace variable = "D5f"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D5g. Possession d'un ordinateur
preserve
	keep if missing(D5g) & !missing(HHD_debut)
	replace commentaire = "Vous n'avez pas renseigné si le ménage possède un ordinateur fonctionnel (D5g)"
	replace variable = "D5g"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D5h. Possession d'une radio
preserve
	keep if missing(D5h) & !missing(HHD_debut)
	replace commentaire = "Vous n'avez pas renseigné si le ménage possède une radio fonctionnelle (D5h)"
	replace variable = "D5h"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore

* D5i. Possession d'un ventilateur
preserve
	keep if missing(D5i) & !missing(HHD_debut)
	replace commentaire = "Vous n'avez pas renseigné si le ménage possède un ventilateur fonctionnel (D5i)"
	replace variable = "D5i"
	append using "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", replace
restore
