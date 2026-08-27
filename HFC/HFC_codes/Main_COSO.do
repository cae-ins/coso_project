/*=======================================
  HIGH FREQUENCY CHECK : HFC centrale
  Auteur : Equipe projet - COSO 
  Date   : juillet 2026
=======================================*/


*Chargement des chemins d'accès
do "/Users/macbookair/Desktop/CAE/COSO/HFC/HFC_codes/Chemins_acces.do"


*Exécution des dofiles
do "$dossier_de_travail/HFC_codes/Sections/01.Gestion_des_tentatives_appel.do"
do "$dossier_de_travail/HFC_codes/Sections/02.identification_et_consentement.do"
do "$dossier_de_travail/HFC_codes/Sections/03.Profil_sociodemographique.do"
do "$dossier_de_travail/HFC_codes/Sections/04.Menage.do"
do "$dossier_de_travail/HFC_codes/Sections/05.Statut_activite.do"
do "$dossier_de_travail/HFC_codes/Sections/06.Emploi_principal.do"
do "$dossier_de_travail/HFC_codes/Sections/07.Qualite_emploi.do"
do "$dossier_de_travail/HFC_codes/Sections/08.revenu_et_caracteristiques_de_l_entreprise.do"
do "$dossier_de_travail/HFC_codes/Sections/09.recherche_d_un_autre_emploi_en_emploi.do"
do "$dossier_de_travail/HFC_codes/Sections/10.chomage_duree_et_recherche_emploi.do"
do "$dossier_de_travail/HFC_codes/Sections/11.entrepreneuriat_iga.do"
do "$dossier_de_travail/HFC_codes/Sections/12.inclusion_financiere_et_epargne.do"
do "$dossier_de_travail/HFC_codes/Sections/13.changement_de_statut.do"
do "$dossier_de_travail/HFC_codes/Sections/14.resilience_face_aux_chocs.do"
do "$dossier_de_travail/HFC_codes/Sections/15.experience_professionnelle_et_formations.do"
do "$dossier_de_travail/HFC_codes/Sections/16.aspirations_professionnelles.do"
do "$dossier_de_travail/HFC_codes/Sections/17.cohesion_sociale_et_engagement.do"
do "$dossier_de_travail/HFC_codes/Sections/18.suivi_panel.do"

*Suppressions des doublons et exportations de la base d'erreurs
do "$dossier_de_travail/HFC_codes/Suppression_doublons.do"
