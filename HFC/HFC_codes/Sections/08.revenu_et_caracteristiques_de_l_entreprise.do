/*================================
  HIGH FREQUENCY CHECK : SECTION H - REVENU ET CARACTERISTIQUES DE L'ENTREPRISE (Posez si EMPLOYÉ)
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
cap erase "$base_erreurs_stata/08.Revenu_et_caracteristiques_de_l_entreprise/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*


*----------------------------------------------------------------*
replace section = "H.Revenu_et_Caracteristiques_de_l_Entreprise"

* H1. Mode de paiement (si F1=Salarié)
preserve
	keep if missing(H1) & F1 == 1 & !missing(HHH_debut)
	replace commentaire = "Vous n'avez pas renseigné comment l'enquêté est payé(e) pour cet emploi"
	replace variable = "H1"
	save "$base_erreurs_stata/08.Revenu_et_caracteristiques_de_l_entreprise/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta", replace
restore

* H2. Fréquence de paiement (si F1=Salarié)
preserve
	keep if missing(H2) & F1 == 1 & !missing(HHH_debut)
	replace commentaire = "Vous n'avez pas renseigné à quelle fréquence l'enquêté est payé(e)"
	replace variable = "H2"
	append using "$base_erreurs_stata/08.Revenu_et_caracteristiques_de_l_entreprise/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/08.Revenu_et_caracteristiques_de_l_entreprise/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta", replace
restore

* H3. Salaire net dernière période de paie (si F1=Salarié)
preserve
	keep if missing(H3) & F1 == 1 & !missing(HHH_debut)
	replace commentaire = "Vous n'avez pas renseigné le salaire net de l'enquêté pour sa dernière période de paie"
	replace variable = "H3"
	append using "$base_erreurs_stata/08.Revenu_et_caracteristiques_de_l_entreprise/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/08.Revenu_et_caracteristiques_de_l_entreprise/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta", replace
restore

* H4. Activité/entreprise enregistrée (si F1=Employeur, Travailleur indépendant, ou Membre de coopérative)
preserve
	keep if missing(H4) & inlist(F1, 2, 3, 4) & !missing(HHH_debut)
	replace commentaire = "Vous n'avez pas renseigné si cette activité ou entreprise est enregistrée"
	replace variable = "H4"
	append using "$base_erreurs_stata/08.Revenu_et_caracteristiques_de_l_entreprise/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/08.Revenu_et_caracteristiques_de_l_entreprise/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta", replace
restore

* H4A. Nombre de travailleurs rémunérés (si F1=Employeur ou Travailleur indépendant)
preserve
	keep if missing(H4A) & inlist(F1, 2, 3) & !missing(HHH_debut)
	replace commentaire = "Vous n'avez pas renseigné combien de travailleurs rémunérés l'enquêté a actuellement, sans vous compter vous-même"
	replace variable = "H4A"
	append using "$base_erreurs_stata/08.Revenu_et_caracteristiques_de_l_entreprise/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/08.Revenu_et_caracteristiques_de_l_entreprise/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta", replace
restore

* H5. Revenu personnel du mois dernier (si F1=Employeur, Travailleur indépendant, ou Membre de coopérative)
preserve
	keep if missing(H5) & inlist(F1, 2, 3, 4) & !missing(HHH_debut)
	replace commentaire = "Vous n'avez pas renseigné combien l'enquêté a personnellement gagné ou retiré de cette activité le mois dernier"
	replace variable = "H5"
	append using "$base_erreurs_stata/08.Revenu_et_caracteristiques_de_l_entreprise/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta"
	save "$base_erreurs_stata/08.Revenu_et_caracteristiques_de_l_entreprise/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta", replace
restore