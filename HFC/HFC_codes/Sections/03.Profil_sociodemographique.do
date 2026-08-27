/*================================
  HIGH FREQUENCY CHECK : SECTION C - PROFIL SOCIODEMOGRAPHIQUE
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
cap erase "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*


*------------------------*----------------------*------------------*
replace section = "C. Profil Sociodémographique"

* C1. Sexe
preserve
	keep if missing(C1) & !missing(HHC_debut)
	replace commentaire = "Vous n'avez pas renseigné le sexe du répondant"
	replace variable = "C1"
	save "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta", replace
restore

/* C2A. Date de naissance
preserve
	keep if missing(C2A_annee) & !missing(HHC_debut)
	replace commentaire = "Vous n'avez pas renseigné la date de naissance du répondant (C2A)"
	replace variable = "C2A"
	append using "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta", replace
restore
*/
* C2. Âge révolu (posé si C2A=9999)
preserve
	keep if missing(C2) & C2A_annee == 9999 & !missing(HHC_debut)
	replace commentaire = "Vous n'avez pas renseigné l'âge révolu (C2) alors que la date de naissance est inconnue (C2A=9999)"
	replace variable = "C2"
	append using "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta", replace
restore

* C2. Ne doit pas être renseigné si C2A != 9999
preserve
	keep if !missing(C2) & C2A_annee != 9999 & !missing(C2A_annee) & !missing(HHC_debut)
	replace commentaire = "L'âge révolu (C2) a été renseigné alors que la date de naissance est connue (C2A != 9999)"
	replace variable = "C2"
	append using "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta", replace
restore

* C3. Statut matrimonial
preserve
	keep if missing(C3) & !missing(HHC_debut)
	replace commentaire = "Vous n'avez pas renseigné le statut matrimonial du répondant (C3)"
	replace variable = "C3"
	append using "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta", replace
restore

* C4. Niveau d'études
preserve
	keep if missing(C4) & !missing(HHC_debut)
	replace commentaire = "Vous n'avez pas renseigné le niveau d'études du répondant (C4)"
	replace variable = "C4"
	append using "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta", replace
restore

* C6. Alphabétisation (posé si C4=0)
preserve
	keep if missing(C6) & C4 == 0 & !missing(HHC_debut)
	replace commentaire = "Vous n'avez pas renseigné si le répondant sait lire et écrire (C6) alors que son niveau d'études est nul (C4=0)"
	replace variable = "C6"
	append using "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta", replace
restore

* C6. Ne doit pas être renseigné si C4 != 0
preserve
	keep if !missing(C6) & C4 != 0 & !missing(C4) & !missing(HHC_debut)
	replace commentaire = "La question sur l'alphabétisation (C6) a été renseignée alors que le répondant a un niveau d'études (C4 != 0)"
	replace variable = "C6"
	append using "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta", replace
restore

* C7. Déplacement au cours des 12 derniers mois
preserve
	keep if missing(C7) & !missing(HHC_debut)
	replace commentaire = "Vous n'avez pas renseigné si le répondant a effectué un déplacement au cours des 12 derniers mois (C7)"
	replace variable = "C7"
	append using "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta", replace
restore

* C8. Localité/pays de départ (posé si C7=1)
preserve
	keep if missing(C8) & C7 == 1 & !missing(HHC_debut)
	replace commentaire = "Vous n'avez pas renseigné la localité/pays de départ (C8) alors que le répondant a effectué un déplacement (C7=1)"
	replace variable = "C8"
	append using "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta", replace
restore

* C9. Localité/pays d'installation (posé si C7=1)
preserve
	keep if missing(C9) & C7 == 1 & !missing(HHC_debut)
	replace commentaire = "Vous n'avez pas renseigné la localité/pays d'installation (C9) alors que le répondant a effectué un déplacement (C7=1)"
	replace variable = "C9"
	append using "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta", replace
restore
