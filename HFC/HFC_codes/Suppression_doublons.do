/*========================================================================
  HIGH FREQUENCY CHECK : Suppression des doublons dans las bases rejets
  Auteur : Equipe projet - COSO 
  Date   : juillet 2026
=========================================================================*/

clear all

cls
set more off

*Chargemet des chemiins d'accès
do "/Users/macbookair/Desktop/CAE/COSO/HFC/HFC_codes/Chemins_acces.do"



///---------------SUPPPRESSION DES DOUBLONS DANS LES BASES D'ERREURS----------------------///

*============================ 01.Gestion des tentatives d'appels ============================*
use "$base_erreurs_stata/01.Gestion_des_tentatives_appel/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta", replace

*============================ 02.identification et consentement ============================*
use "$base_erreurs_stata/02.Identification_et_consentement/02.identification_et_consentement_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/02.identification_et_consentement_du_`c(current_date)'.dta", replace

*============================ 03.Profil_sociodemographique ============================*
use "$base_erreurs_stata/03.Profil_sociodemographique/03.Profil_sociodemographique_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/03.Profil_sociodemographique_du_`c(current_date)'.dta", replace

*============================== 04.Menage ==============================*
use "$base_erreurs_stata/04.Menage/04.Menage_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/04.Menage_du_`c(current_date)'.dta", replace

*============================ 05.Statut_activite ============================*
use "$base_erreurs_stata/05.Statut_activite/05.Statut_activite_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/05.Statut_activite_du_`c(current_date)'.dta", replace

*============================ 06.Emploi_principal ============================*
use "$base_erreurs_stata/06.Emploi_principal/06.Emploi_principal_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/06.Emploi_principal_du_`c(current_date)'.dta", replace

*============================ 07.Qualite_emploiemploi ============================*
use "$base_erreurs_stata/07.Qualite_emploi/07.Qualite_emploiemploi_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/07.Qualite_emploiemploi_du_`c(current_date)'.dta", replace

*======================= 08.revenu_et_caracteristiques_de_l_entreprise_du_ =======================*
use "$base_erreurs_stata/08.Revenu_et_caracteristiques_de_l_entreprise/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta", replace

*============================ 09.recherche_d_un_autre_emploi_en_emploi ============================*
use "$base_erreurs_stata/09.Recherche_d_un_autre_emploi_en_emploi/09.recherche_d_un_autre_emploi_en_emploi_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/09.recherche_d_un_autre_emploi_en_emploi_du_`c(current_date)'.dta", replace

*============================= 10.chomage_duree_et_recherche_emploi===========================*
use "$base_erreurs_stata/10.Chomage_duree_et_recherche_emploi/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta", replace

*============================ 11.entrepreneuriat_iga ============================*
use "$base_erreurs_stata/11.Entrepreneuriat_IGA/11.entrepreneuriat_iga_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/11.entrepreneuriat_iga_du_`c(current_date)'.dta", replace

*============================ 12.inclusion_financiere_et_epargne ============================*
use "$base_erreurs_stata/12.Inclusion_financiere_et_epargne/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta", replace

*============================= 13.changement_de_statut ===========================*
use "$base_erreurs_stata/13.Changement_de_statut/13.changement_de_statut_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/13.changement_de_statut_du_`c(current_date)'.dta", replace

*============================ 14.resilience_face_aux_chocs ============================*
use "$base_erreurs_stata/14.Resilience_face_aux_chocs/14.resilience_face_aux_chocs_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/14.resilience_face_aux_chocs_du_`c(current_date)'.dta", replace

*======================= 15.experience_professionnelle_et_formations =========================*
use "$base_erreurs_stata/15.Experience_professionnelle_et_formations/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta", replace

*============================= 16.aspirations_professionnelles ===========================*
use "$base_erreurs_stata/16.Aspirations_professionnelles/16.aspirations_professionnelles_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/16.aspirations_professionnelles_du_`c(current_date)'.dta", replace

*============================ 17.cohesion_sociale_et_engagement ============================*
use "$base_erreurs_stata/17.Cohesion_sociale_et_engagement/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta", replace

*======================= 18.suivi_panel =========================*
use "$base_erreurs_stata/18.Suivi_panel/18.suivi_panel_du_`c(current_date)'.dta", clear
cap duplicates drop interview__key interview__id variable commentaire, force
keep interview__key interview__id nom_sup nom_agent variable commentaire
save "$base_erreurs_stata_unique/18.suivi_panel_du_`c(current_date)'.dta", replace




///---------------FUSIONS DES BASES D'ERREURS----------------------///

use "$base_erreurs_stata_unique/01.Gestion_des_tentatives_appel_du_`c(current_date)'.dta", clear
append using "$base_erreurs_stata_unique/02.identification_et_consentement_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/03.Profil_sociodemographique_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/04.Menage_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/05.Statut_activite_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/06.Emploi_principal_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/07.Qualite_emploiemploi_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/08.revenu_et_caracteristiques_de_l_entreprise_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/09.recherche_d_un_autre_emploi_en_emploi_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/10.chomage_duree_et_recherche_emploi_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/11.entrepreneuriat_iga_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/12.inclusion_financiere_et_epargne_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/13.changement_de_statut_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/14.resilience_face_aux_chocs_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/15.experience_professionnelle_et_formations_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/16.aspirations_professionnelles_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/17.cohesion_sociale_et_engagement_du_`c(current_date)'.dta", force
append using "$base_erreurs_stata_unique/18.suivi_panel_du_`c(current_date)'.dta", force


///---------------EXPORTATION DES BASES D'ERREURS----------------------///

*Exportation de la base des erreurs au format stata
save "$base_erreurs_stata_unique/base_erreur_globale_du_`c(current_date)'.dta", replace

*Exportation de la base des erreurs au format stata
sort interview__key nom_sup nom_agent
export excel using "$base_erreurs_excel/Base_erreur_globale_du_`c(current_date)'.xlsx", firstrow(variables) replace
