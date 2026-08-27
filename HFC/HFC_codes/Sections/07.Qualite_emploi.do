/*================================
  HIGH FREQUENCY CHECK : SECTION G.	QUALITE DE L'EMPLOI 
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
cap erase "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*


*------------------------*----------------------*------------------*
replace section = "G. Qualité de l'Emploi"

* G1. Contrat de travail
preserve
	keep if missing(G1) & EMPLOYE == 1 & !missing(HHG_debut)
	replace commentaire = "Vous n'avez pas renseigné le type de contrat de travail (G1) alors que le répondant est classé EMPLOYÉ"
	replace variable = "G1"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore

* G2. Couverture sociale
preserve
	keep if missing(G2) & EMPLOYE == 1 & !missing(HHG_debut)
	replace commentaire = "Vous n'avez pas renseigné si le répondant bénéficie d'une couverture sociale (G2) alors que le répondant est classé EMPLOYÉ"
	replace variable = "G2"
	append using "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore

* G3. Heures travaillées la semaine dernière
preserve
	keep if missing(G3) & EMPLOYE == 1 & !missing(HHG_debut)
	replace commentaire = "Vous n'avez pas renseigné le nombre d'heures travaillées dans l'emploi principal la semaine dernière (G3)"
	replace variable = "G3"
	append using "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore

* G4. Heures habituelles vs heures effectuées
preserve
	keep if missing(G4) & !missing(G3) & !missing(HHG_debut)
	replace commentaire = "Vous n'avez pas renseigné si le nombre d'heures travaillées correspond aux heures habituelles (G4)"
	replace variable = "G4"
	append using "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore

* G4A. Heures effectivement travaillées (posé si G4=2)
preserve
	keep if missing(G4A) & G4 == 2 & !missing(HHG_debut)
	replace commentaire = "Vous n'avez pas renseigné le nombre d'heures effectivement travaillées (G4A) alors que G4=2"
	replace variable = "G4A"
	append using "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore

* G4A. Ne doit pas être renseigné si G4=1
preserve
	keep if !missing(G4A) & G4 == 1 & !missing(HHG_debut)
	replace commentaire = "G4A a été renseigné alors que G4=1 (heures habituelles confirmées, G4A non requis)"
	replace variable = "G4A"
	append using "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore

* G5. Autre emploi ou activité génératrice de revenus
preserve
	keep if missing(G5) & EMPLOYE == 1 & !missing(HHG_debut)
	replace commentaire = "Vous n'avez pas renseigné si le répondant a un autre emploi ou activité génératrice de revenus (G5)"
	replace variable = "G5"
	append using "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore

* G5A. Précision de l'autre activité (posé si G5=1)
preserve
	keep if missing(G5A) & G5 == 1 & !missing(HHG_debut)
	replace commentaire = "Vous n'avez pas précisé la nature de l'autre activité (G5A) alors que G5=1"
	replace variable = "G5A"
	append using "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore

* G5A. Ne doit pas être renseigné si G5=2
preserve
	keep if !missing(G5A) & G5 == 2 & !missing(HHG_debut)
	replace commentaire = "G5A a été renseigné alors que G5=2 (aucun autre emploi déclaré, G5A non requis)"
	replace variable = "G5A"
	append using "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore

* G6. Heures consacrées aux autres emplois/activités (posé si G5=1)
preserve
	keep if missing(G6) & G5 == 1 & !missing(HHG_debut)
	replace commentaire = "Vous n'avez pas renseigné le nombre d'heures consacrées aux autres emplois/activités (G6) alors que G5=1"
	replace variable = "G6"
	append using "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore

* G6. Ne doit pas être renseigné si G5=2
preserve
	keep if !missing(G6) & G5 == 2 & !missing(HHG_debut)
	replace commentaire = "G6 a été renseigné alors que G5=2 (aucun autre emploi déclaré, G6 non requis)"
	replace variable = "G6"
	append using "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore

* G7. Souhait de travailler plus d'heures
preserve
	keep if missing(G7) & EMPLOYE == 1 & !missing(HHG_debut)
	replace commentaire = "Vous n'avez pas renseigné si le répondant aurait voulu travailler plus d'heures au cours des 30 derniers jours (G7)"
	replace variable = "G7"
	append using "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore

* G7A. Disponibilité pour travailler plus (posé si G7=1)
preserve
	keep if missing(G7A) & G7 == 1 & !missing(HHG_debut)
	replace commentaire = "Vous n'avez pas renseigné si le répondant aurait pu commencer à travailler plus d'heures dans les deux prochaines semaines (G7A) alors que G7=1"
	replace variable = "G7A"
	append using "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore

* G7A. Ne doit pas être renseigné si G7=2
preserve
	keep if !missing(G7A) & G7 == 2 & !missing(HHG_debut)
	replace commentaire = "G7A a été renseigné alors que G7=2 (répondant ne souhaitait pas travailler plus, G7A non requis)"
	replace variable = "G7A"
	append using "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace
restore
