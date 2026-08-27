/*================================
  HIGH FREQUENCY CHECK : SECTION B - IDENTIFICATION ET CONSENTEMENT
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
cap erase "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*


*------------------------*----------------------*------------------*
replace section = "B. Identification et Consentement"

* B1. District
preserve
	keep if missing(B1) & !missing(HHB_debut)
	replace commentaire = "Vous n'avez pas renseigné le district"
	replace variable = "B1"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B2. Région
preserve
	keep if missing(B2) & !missing(HHB_debut)
	replace commentaire = "Vous n'avez pas renseigné la région"
	replace variable = "B2"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B3. Département
preserve
	keep if missing(B3) & !missing(HHB_debut)
	replace commentaire = "Vous n'avez pas renseigné le département"
	replace variable = "B3"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B4. Sous-préfecture/Commune
preserve
	keep if missing(B4) & !missing(HHB_debut)
	replace commentaire = "Vous n'avez pas renseigné la sous-préfecture ou la commune"
	replace variable = "B4"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B5. Milieu de résidence
preserve
	keep if missing(B5) & !missing(HHB_debut)
	replace commentaire = "Vous n'avez pas renseigné le milieu de résidence"
	replace variable = "B5"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B6. Confirmation identité du répondant

preserve
	keep if !missing(B6) & !inlist(B6, 1, 2) & !missing(HHB_debut)
	replace commentaire = "Vous n'avez pas renseigné la confirmation de l'identité du répondant (B6)"
	replace variable = "B6"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B6A. Posez si B6=2 : Puis-je parler à la personne ?
preserve
	keep if missing(B6A) & B6 == 2 & !missing(HHB_debut)
	replace commentaire = "Vous n'avez pas renseigné B6A (demande à parler à la personne) alors que B6=2"
	replace variable = "B6A"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B6A. Ne doit pas être renseigné si B6=1
preserve
	keep if !missing(B6A) & B6 == 1 & !missing(HHB_debut)
	replace commentaire = "B6A a été renseigné alors que B6=1 (non requis)"
	replace variable = "B6A"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B6B. Posez si B6A=2 : Rappel à un moment convenable ?
preserve
	keep if missing(B6B) & B6A == 2 & !missing(HHB_debut)
	replace commentaire = "Vous n'avez pas renseigné B6B (proposition de rappel) alors que B6A=2"
	replace variable = "B6B"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B6B. Ne doit pas être renseigné si B6A=1
preserve
	keep if !missing(B6B) & B6A == 1 & !missing(HHB_debut)
	replace commentaire = "B6B a été renseigné alors que B6A=1 (non requis)"
	replace variable = "B6B"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B6C. Posez si B6B=1 : Date et heure souhaitées pour le rappel
preserve
	keep if missing(B6C) & B6B == 1 & !missing(HHB_debut)
	replace commentaire = "Vous n'avez pas renseigné la date et l'heure souhaitées pour le rappel (B6C) alors que B6B=1"
	replace variable = "B6C"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B6C. Ne doit pas être renseigné si B6B=2
preserve
	keep if !missing(B6C) & B6B == 2 & !missing(HHB_debut)
	replace commentaire = "B6C a été renseigné alors que B6B=2 (fin d'entretien attendue, non requis)"
	replace variable = "B6C"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B6D. Posez si B6=1 ou B6A=1 : Consentement à participer
preserve
	keep if missing(B6D) & inlist(1, B6, B6A) & !missing(HHB_debut)
	replace commentaire = "Vous n'avez pas renseigné le consentement du répondant (B6D) alors que B6=1 ou B6A=1"
	replace variable = "B6D"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B6D. Vérification modalité valide (1 ou 2)
preserve
	keep if !missing(B6D) & !inlist(B6D, 1, 2) & !missing(HHB_debut)
	replace commentaire = "La valeur renseignée pour B6D est invalide (valeur attendue : 1 ou 2)"
	replace variable = "B6D"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B6E. Posez si B6D=2 : Proposition de rappel
preserve
	keep if missing(B6E) & B6D == 2 & !missing(HHB_debut)
	replace commentaire = "Vous n'avez pas renseigné B6E (proposition de rappel) alors que B6D=2"
	replace variable = "B6E"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B6E. Ne doit pas être renseigné si B6D=1
preserve
	keep if !missing(B6E) & B6D == 1 & !missing(HHB_debut)
	replace commentaire = "B6E a été renseigné alors que B6D=1 (non requis)"
	replace variable = "B6E"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B6F. Posez si B6E=1 : Date et heure souhaitées pour le rappel
preserve
	keep if missing(B6F) & B6E == 1 & !missing(HHB_debut)
	replace commentaire = "Vous n'avez pas renseigné la date et l'heure souhaitées pour le rappel (B6F) alors que B6E=1"
	replace variable = "B6F"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B6F. Ne doit pas être renseigné si B6E=2
preserve
	keep if !missing(B6F) & B6E == 2 & !missing(HHB_debut)
	replace commentaire = "B6F a été renseigné alors que B6E=2 (fin d'entretien attendue, non requis)"
	replace variable = "B6F"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore

* B7. Nom complet du répondant 
preserve
	keep if missing(B7) & B6D == 1 & !missing(HHB_debut)
	replace commentaire = "Vous n'avez pas renseigné le nom complet du répondant (B7) alors que le consentement a été obtenu (B6D=1)"
	replace variable = "B7"
	append using "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", replace
restore