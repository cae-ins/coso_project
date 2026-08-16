/*===========================================================================
  Section C. PROFIL SOCIODEMOGRAPHIQUE
  Genere depuis le questionnaire Survey Solutions et le dictionnaire .dta.
  Diagnostics uniquement : aucune correction automatique.
  Perimetre provisoire : $audit_scope.
===========================================================================*/

use "$working_base", clear

cap drop commentaire
gen str244 commentaire = ""
cap drop source_regle
gen str60 source_regle = ""
cap drop action_proposee
gen str60 action_proposee = ""

cap mkdir "$document\04_C"

*---------------------------------------------------------------------------
* HHC_debut - HHC_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHC_debut) | trim(HHC_debut) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHC_debut manquant dans son univers" if ((missing(HHC_debut) | trim(HHC_debut) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHC_debut) | trim(HHC_debut) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHC_debut) | trim(HHC_debut) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHC_debut commentaire source_regle action_proposee ///
        using "$document\04_C\HHC_debut_manquant.xlsx", ///
        if ((missing(HHC_debut) | trim(HHC_debut) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHC_debut) & trim(HHC_debut) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHC_debut renseigne hors univers" if ((!missing(HHC_debut) & trim(HHC_debut) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHC_debut) & trim(HHC_debut) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHC_debut) & trim(HHC_debut) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHC_debut commentaire source_regle action_proposee ///
        using "$document\04_C\HHC_debut_hors_univers.xlsx", ///
        if ((!missing(HHC_debut) & trim(HHC_debut) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C1 - C1. Quel est votre sexe?
* Type questionnaire : single-select
count if (missing(C1)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C1 manquant dans son univers" if (missing(C1)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(C1)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(C1)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C1 commentaire source_regle action_proposee ///
        using "$document\04_C\C1_manquant.xlsx", ///
        if (missing(C1)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C1)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C1 renseigne hors univers" if (!missing(C1)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C1)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(C1)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C1 commentaire source_regle action_proposee ///
        using "$document\04_C\C1_hors_univers.xlsx", ///
        if (!missing(C1)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(C1, 1, 2))) & (!missing(C1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C1 hors domaine questionnaire" if !((inlist(C1, 1, 2))) & (!missing(C1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(C1, 1, 2))) & (!missing(C1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(C1, 1, 2))) & (!missing(C1)) & ($audit_scope)
    export excel interview__key cover_district C1 commentaire source_regle action_proposee ///
        using "$document\04_C\C1_hors_domaine.xlsx", ///
        if !((inlist(C1, 1, 2))) & (!missing(C1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C2A_Jour - C2A_Jour. Quel est votre jour de naissance ?
* Type questionnaire : numeric: integer
count if (missing(C2A_Jour)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2A_Jour manquant dans son univers" if (missing(C2A_Jour)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(C2A_Jour)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(C2A_Jour)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C2A_Jour commentaire source_regle action_proposee ///
        using "$document\04_C\C2A_Jour_manquant.xlsx", ///
        if (missing(C2A_Jour)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C2A_Jour)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2A_Jour renseigne hors univers" if (!missing(C2A_Jour)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C2A_Jour)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(C2A_Jour)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C2A_Jour commentaire source_regle action_proposee ///
        using "$document\04_C\C2A_Jour_hors_univers.xlsx", ///
        if (!missing(C2A_Jour)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (inlist(C2A_Jour, 98)) & (!missing(C2A_Jour)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2A_Jour contient un code special autorise" if (inlist(C2A_Jour, 98)) & (!missing(C2A_Jour)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (inlist(C2A_Jour, 98)) & (!missing(C2A_Jour)) & ($audit_scope)
    replace action_proposee = "recodage_analyse_a_valider" if (inlist(C2A_Jour, 98)) & (!missing(C2A_Jour)) & ($audit_scope)
    export excel interview__key cover_district C2A_Jour commentaire source_regle action_proposee ///
        using "$document\04_C\C2A_Jour_code_special.xlsx", ///
        if (inlist(C2A_Jour, 98)) & (!missing(C2A_Jour)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C2A_Jour)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_Jour) & (C2A_Jour >= 1)) & (!missing(C2A_Jour) & (C2A_Jour <= 31))) | (!missing(C2A_Jour) & (C2A_Jour == 98))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2A_Jour viole la validation questionnaire 1" if (!missing(C2A_Jour)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_Jour) & (C2A_Jour >= 1)) & (!missing(C2A_Jour) & (C2A_Jour <= 31))) | (!missing(C2A_Jour) & (C2A_Jour == 98))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C2A_Jour)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_Jour) & (C2A_Jour >= 1)) & (!missing(C2A_Jour) & (C2A_Jour <= 31))) | (!missing(C2A_Jour) & (C2A_Jour == 98))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (!missing(C2A_Jour)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_Jour) & (C2A_Jour >= 1)) & (!missing(C2A_Jour) & (C2A_Jour <= 31))) | (!missing(C2A_Jour) & (C2A_Jour == 98))) & ($audit_scope)
    export excel interview__key cover_district C2A_Jour commentaire source_regle action_proposee ///
        using "$document\04_C\C2A_Jour_validation_1.xlsx", ///
        if (!missing(C2A_Jour)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_Jour) & (C2A_Jour >= 1)) & (!missing(C2A_Jour) & (C2A_Jour <= 31))) | (!missing(C2A_Jour) & (C2A_Jour == 98))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C2A_Mois - C2A_Mois. Quel est votre mois de naissance ?
* Type questionnaire : numeric: integer
count if (missing(C2A_Mois)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2A_Mois manquant dans son univers" if (missing(C2A_Mois)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(C2A_Mois)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(C2A_Mois)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C2A_Mois commentaire source_regle action_proposee ///
        using "$document\04_C\C2A_Mois_manquant.xlsx", ///
        if (missing(C2A_Mois)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C2A_Mois)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2A_Mois renseigne hors univers" if (!missing(C2A_Mois)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C2A_Mois)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(C2A_Mois)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C2A_Mois commentaire source_regle action_proposee ///
        using "$document\04_C\C2A_Mois_hors_univers.xlsx", ///
        if (!missing(C2A_Mois)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (inlist(C2A_Mois, 98)) & (!missing(C2A_Mois)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2A_Mois contient un code special autorise" if (inlist(C2A_Mois, 98)) & (!missing(C2A_Mois)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (inlist(C2A_Mois, 98)) & (!missing(C2A_Mois)) & ($audit_scope)
    replace action_proposee = "recodage_analyse_a_valider" if (inlist(C2A_Mois, 98)) & (!missing(C2A_Mois)) & ($audit_scope)
    export excel interview__key cover_district C2A_Mois commentaire source_regle action_proposee ///
        using "$document\04_C\C2A_Mois_code_special.xlsx", ///
        if (inlist(C2A_Mois, 98)) & (!missing(C2A_Mois)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C2A_Mois)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_Mois) & (C2A_Mois >= 1)) & (!missing(C2A_Mois) & (C2A_Mois <= 12))) | (!missing(C2A_Mois) & (C2A_Mois == 98))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2A_Mois viole la validation questionnaire 1" if (!missing(C2A_Mois)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_Mois) & (C2A_Mois >= 1)) & (!missing(C2A_Mois) & (C2A_Mois <= 12))) | (!missing(C2A_Mois) & (C2A_Mois == 98))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C2A_Mois)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_Mois) & (C2A_Mois >= 1)) & (!missing(C2A_Mois) & (C2A_Mois <= 12))) | (!missing(C2A_Mois) & (C2A_Mois == 98))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (!missing(C2A_Mois)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_Mois) & (C2A_Mois >= 1)) & (!missing(C2A_Mois) & (C2A_Mois <= 12))) | (!missing(C2A_Mois) & (C2A_Mois == 98))) & ($audit_scope)
    export excel interview__key cover_district C2A_Mois commentaire source_regle action_proposee ///
        using "$document\04_C\C2A_Mois_validation_1.xlsx", ///
        if (!missing(C2A_Mois)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_Mois) & (C2A_Mois >= 1)) & (!missing(C2A_Mois) & (C2A_Mois <= 12))) | (!missing(C2A_Mois) & (C2A_Mois == 98))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C2A_annee - C2A_annee. Quel est votre annee de naissance ?
* Type questionnaire : numeric: integer
count if (missing(C2A_annee)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2A_annee manquant dans son univers" if (missing(C2A_annee)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(C2A_annee)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(C2A_annee)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C2A_annee commentaire source_regle action_proposee ///
        using "$document\04_C\C2A_annee_manquant.xlsx", ///
        if (missing(C2A_annee)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C2A_annee)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2A_annee renseigne hors univers" if (!missing(C2A_annee)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C2A_annee)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(C2A_annee)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C2A_annee commentaire source_regle action_proposee ///
        using "$document\04_C\C2A_annee_hors_univers.xlsx", ///
        if (!missing(C2A_annee)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (inlist(C2A_annee, 9998)) & (!missing(C2A_annee)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2A_annee contient un code special autorise" if (inlist(C2A_annee, 9998)) & (!missing(C2A_annee)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (inlist(C2A_annee, 9998)) & (!missing(C2A_annee)) & ($audit_scope)
    replace action_proposee = "recodage_analyse_a_valider" if (inlist(C2A_annee, 9998)) & (!missing(C2A_annee)) & ($audit_scope)
    export excel interview__key cover_district C2A_annee commentaire source_regle action_proposee ///
        using "$document\04_C\C2A_annee_code_special.xlsx", ///
        if (inlist(C2A_annee, 9998)) & (!missing(C2A_annee)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C2A_annee)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_annee) & (C2A_annee >= 1950)) & (!missing(C2A_annee) & (C2A_annee <= 2026))) | (!missing(C2A_annee) & (C2A_annee == 9998))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2A_annee viole la validation questionnaire 1" if (!missing(C2A_annee)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_annee) & (C2A_annee >= 1950)) & (!missing(C2A_annee) & (C2A_annee <= 2026))) | (!missing(C2A_annee) & (C2A_annee == 9998))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C2A_annee)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_annee) & (C2A_annee >= 1950)) & (!missing(C2A_annee) & (C2A_annee <= 2026))) | (!missing(C2A_annee) & (C2A_annee == 9998))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (!missing(C2A_annee)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_annee) & (C2A_annee >= 1950)) & (!missing(C2A_annee) & (C2A_annee <= 2026))) | (!missing(C2A_annee) & (C2A_annee == 9998))) & ($audit_scope)
    export excel interview__key cover_district C2A_annee commentaire source_regle action_proposee ///
        using "$document\04_C\C2A_annee_validation_1.xlsx", ///
        if (!missing(C2A_annee)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & !(((!missing(C2A_annee) & (C2A_annee >= 1950)) & (!missing(C2A_annee) & (C2A_annee <= 2026))) | (!missing(C2A_annee) & (C2A_annee == 9998))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C2 - C2. Quel age avez avez-vous revolu ?
* Type questionnaire : numeric: integer
count if (missing(C2)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C2A_annee) & (C2A_annee == 9998)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2 manquant dans son univers" if (missing(C2)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C2A_annee) & (C2A_annee == 9998)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(C2)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C2A_annee) & (C2A_annee == 9998)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(C2)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C2A_annee) & (C2A_annee == 9998)))) & ($audit_scope)
    export excel interview__key cover_district C2 commentaire source_regle action_proposee ///
        using "$document\04_C\C2_manquant.xlsx", ///
        if (missing(C2)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C2A_annee) & (C2A_annee == 9998)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C2)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C2A_annee) & (C2A_annee == 9998)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C2 renseigne hors univers" if (!missing(C2)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C2A_annee) & (C2A_annee == 9998)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C2)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C2A_annee) & (C2A_annee == 9998)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(C2)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C2A_annee) & (C2A_annee == 9998)))) & ($audit_scope)
    export excel interview__key cover_district C2 commentaire source_regle action_proposee ///
        using "$document\04_C\C2_hors_univers.xlsx", ///
        if (!missing(C2)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C2A_annee) & (C2A_annee == 9998)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C3 - C3. Quel est votre statut matrimonial actuel ?
* Type questionnaire : single-select
count if (missing(C3)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C3 manquant dans son univers" if (missing(C3)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(C3)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(C3)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C3 commentaire source_regle action_proposee ///
        using "$document\04_C\C3_manquant.xlsx", ///
        if (missing(C3)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C3)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C3 renseigne hors univers" if (!missing(C3)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C3)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(C3)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C3 commentaire source_regle action_proposee ///
        using "$document\04_C\C3_hors_univers.xlsx", ///
        if (!missing(C3)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(C3, 1, 2, 3, 4, 5, 6))) & (!missing(C3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C3 hors domaine questionnaire" if !((inlist(C3, 1, 2, 3, 4, 5, 6))) & (!missing(C3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(C3, 1, 2, 3, 4, 5, 6))) & (!missing(C3)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(C3, 1, 2, 3, 4, 5, 6))) & (!missing(C3)) & ($audit_scope)
    export excel interview__key cover_district C3 commentaire source_regle action_proposee ///
        using "$document\04_C\C3_hors_domaine.xlsx", ///
        if !((inlist(C3, 1, 2, 3, 4, 5, 6))) & (!missing(C3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C4 - C4. Quel est le niveau d'etude le plus eleve que vous avez atteint?
* Type questionnaire : single-select
count if (missing(C4)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C4 manquant dans son univers" if (missing(C4)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(C4)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(C4)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C4 commentaire source_regle action_proposee ///
        using "$document\04_C\C4_manquant.xlsx", ///
        if (missing(C4)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C4)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C4 renseigne hors univers" if (!missing(C4)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C4)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(C4)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C4 commentaire source_regle action_proposee ///
        using "$document\04_C\C4_hors_univers.xlsx", ///
        if (!missing(C4)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(C4, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9) | inlist(C4, 10, 11, 12))) & (!missing(C4)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C4 hors domaine questionnaire" if !((inlist(C4, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9) | inlist(C4, 10, 11, 12))) & (!missing(C4)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(C4, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9) | inlist(C4, 10, 11, 12))) & (!missing(C4)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(C4, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9) | inlist(C4, 10, 11, 12))) & (!missing(C4)) & ($audit_scope)
    export excel interview__key cover_district C4 commentaire source_regle action_proposee ///
        using "$document\04_C\C4_hors_domaine.xlsx", ///
        if !((inlist(C4, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9) | inlist(C4, 10, 11, 12))) & (!missing(C4)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C5 - C5. Quel est le diplome le plus eleve obtenu ?
* Type questionnaire : single-select
count if (missing(C5)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 >= 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C5 manquant dans son univers" if (missing(C5)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 >= 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(C5)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 >= 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(C5)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 >= 2)))) & ($audit_scope)
    export excel interview__key cover_district C5 commentaire source_regle action_proposee ///
        using "$document\04_C\C5_manquant.xlsx", ///
        if (missing(C5)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 >= 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C5)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 >= 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C5 renseigne hors univers" if (!missing(C5)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 >= 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C5)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 >= 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(C5)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 >= 2)))) & ($audit_scope)
    export excel interview__key cover_district C5 commentaire source_regle action_proposee ///
        using "$document\04_C\C5_hors_univers.xlsx", ///
        if (!missing(C5)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 >= 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(C5, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(C5)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C5 hors domaine questionnaire" if !((inlist(C5, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(C5)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(C5, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(C5)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(C5, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(C5)) & ($audit_scope)
    export excel interview__key cover_district C5 commentaire source_regle action_proposee ///
        using "$document\04_C\C5_hors_domaine.xlsx", ///
        if !((inlist(C5, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(C5)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C6 - C6. Savez-vous lire et ecrire dans au moins une langue (francais ou autre) ?
* Type questionnaire : single-select
count if (missing(C6)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 <= 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C6 manquant dans son univers" if (missing(C6)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 <= 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(C6)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 <= 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(C6)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 <= 2)))) & ($audit_scope)
    export excel interview__key cover_district C6 commentaire source_regle action_proposee ///
        using "$document\04_C\C6_manquant.xlsx", ///
        if (missing(C6)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 <= 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C6)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 <= 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C6 renseigne hors univers" if (!missing(C6)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 <= 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C6)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 <= 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(C6)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 <= 2)))) & ($audit_scope)
    export excel interview__key cover_district C6 commentaire source_regle action_proposee ///
        using "$document\04_C\C6_hors_univers.xlsx", ///
        if (!missing(C6)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C4) & (C4 <= 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(C6, 1, 2))) & (!missing(C6)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C6 hors domaine questionnaire" if !((inlist(C6, 1, 2))) & (!missing(C6)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(C6, 1, 2))) & (!missing(C6)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(C6, 1, 2))) & (!missing(C6)) & ($audit_scope)
    export excel interview__key cover_district C6 commentaire source_regle action_proposee ///
        using "$document\04_C\C6_hors_domaine.xlsx", ///
        if !((inlist(C6, 1, 2))) & (!missing(C6)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C7 - C7. Au cours des douzes derniers mois avez-vous effectue un deplacement d'une localite a une autre localite/pays pour vous installer pendant au moins 6 mois ?
* Type questionnaire : single-select
count if (missing(C7)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C7 manquant dans son univers" if (missing(C7)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(C7)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(C7)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C7 commentaire source_regle action_proposee ///
        using "$document\04_C\C7_manquant.xlsx", ///
        if (missing(C7)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C7)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C7 renseigne hors univers" if (!missing(C7)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C7)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(C7)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district C7 commentaire source_regle action_proposee ///
        using "$document\04_C\C7_hors_univers.xlsx", ///
        if (!missing(C7)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(C7, 1, 2))) & (!missing(C7)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C7 hors domaine questionnaire" if !((inlist(C7, 1, 2))) & (!missing(C7)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(C7, 1, 2))) & (!missing(C7)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(C7, 1, 2))) & (!missing(C7)) & ($audit_scope)
    export excel interview__key cover_district C7 commentaire source_regle action_proposee ///
        using "$document\04_C\C7_hors_domaine.xlsx", ///
        if !((inlist(C7, 1, 2))) & (!missing(C7)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C8 - C8. Ou es ce que vous habitez avant de venir ou de vous installer dans cette localite ?
* Type questionnaire : single-select
count if (missing(C8)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C7) & (C7 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C8 manquant dans son univers" if (missing(C8)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C7) & (C7 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(C8)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C7) & (C7 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(C8)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C7) & (C7 == 1)))) & ($audit_scope)
    export excel interview__key cover_district C8 commentaire source_regle action_proposee ///
        using "$document\04_C\C8_manquant.xlsx", ///
        if (missing(C8)) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C7) & (C7 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(C8)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C7) & (C7 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C8 renseigne hors univers" if (!missing(C8)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C7) & (C7 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(C8)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C7) & (C7 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(C8)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C7) & (C7 == 1)))) & ($audit_scope)
    export excel interview__key cover_district C8 commentaire source_regle action_proposee ///
        using "$document\04_C\C8_hors_univers.xlsx", ///
        if (!missing(C8)) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C7) & (C7 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(C8, 1, 2))) & (!missing(C8)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C8 hors domaine questionnaire" if !((inlist(C8, 1, 2))) & (!missing(C8)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(C8, 1, 2))) & (!missing(C8)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(C8, 1, 2))) & (!missing(C8)) & ($audit_scope)
    export excel interview__key cover_district C8 commentaire source_regle action_proposee ///
        using "$document\04_C\C8_hors_domaine.xlsx", ///
        if !((inlist(C8, 1, 2))) & (!missing(C8)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C9 - C9. Indiquer la localite/pays ou vous etiez
* Type questionnaire : text
count if ((missing(C9) | trim(C9) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C9 manquant dans son univers" if ((missing(C9) | trim(C9) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(C9) | trim(C9) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(C9) | trim(C9) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
    export excel interview__key cover_district C9 commentaire source_regle action_proposee ///
        using "$document\04_C\C9_manquant.xlsx", ///
        if ((missing(C9) | trim(C9) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(C9) & trim(C9) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C9 renseigne hors univers" if ((!missing(C9) & trim(C9) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(C9) & trim(C9) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(C9) & trim(C9) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
    export excel interview__key cover_district C9 commentaire source_regle action_proposee ///
        using "$document\04_C\C9_hors_univers.xlsx", ///
        if ((!missing(C9) & trim(C9) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C10 - C10. Indiquez la localite ou vous vous etes installe ?
* Type questionnaire : text
count if ((missing(C10) | trim(C10) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C10 manquant dans son univers" if ((missing(C10) | trim(C10) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(C10) | trim(C10) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(C10) | trim(C10) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
    export excel interview__key cover_district C10 commentaire source_regle action_proposee ///
        using "$document\04_C\C10_manquant.xlsx", ///
        if ((missing(C10) | trim(C10) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(C10) & trim(C10) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C10 renseigne hors univers" if ((!missing(C10) & trim(C10) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(C10) & trim(C10) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(C10) & trim(C10) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope)
    export excel interview__key cover_district C10 commentaire source_regle action_proposee ///
        using "$document\04_C\C10_hors_univers.xlsx", ///
        if ((!missing(C10) & trim(C10) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* C11 - C11. Indiquez le pays d'ou vous venez
* Type questionnaire : text
count if ((missing(C11) | trim(C11) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C11 manquant dans son univers" if ((missing(C11) | trim(C11) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(C11) | trim(C11) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(C11) | trim(C11) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 2)))) & ($audit_scope)
    export excel interview__key cover_district C11 commentaire source_regle action_proposee ///
        using "$document\04_C\C11_manquant.xlsx", ///
        if ((missing(C11) | trim(C11) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(C11) & trim(C11) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "C11 renseigne hors univers" if ((!missing(C11) & trim(C11) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(C11) & trim(C11) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(C11) & trim(C11) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 2)))) & ($audit_scope)
    export excel interview__key cover_district C11 commentaire source_regle action_proposee ///
        using "$document\04_C\C11_hors_univers.xlsx", ///
        if ((!missing(C11) & trim(C11) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(C8) & (C8 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* age - Variable
* Type questionnaire : variable
* Variable calculee : documentee, sans controle automatique.

*---------------------------------------------------------------------------
* HHC_fin - HHC_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHC_fin) | trim(HHC_fin) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHC_fin manquant dans son univers" if ((missing(HHC_fin) | trim(HHC_fin) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHC_fin) | trim(HHC_fin) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHC_fin) | trim(HHC_fin) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHC_fin commentaire source_regle action_proposee ///
        using "$document\04_C\HHC_fin_manquant.xlsx", ///
        if ((missing(HHC_fin) | trim(HHC_fin) == "")) & ((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHC_fin) & trim(HHC_fin) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHC_fin renseigne hors univers" if ((!missing(HHC_fin) & trim(HHC_fin) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHC_fin) & trim(HHC_fin) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHC_fin) & trim(HHC_fin) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHC_fin commentaire source_regle action_proposee ///
        using "$document\04_C\HHC_fin_hors_univers.xlsx", ///
        if ((!missing(HHC_fin) & trim(HHC_fin) != "")) & !((!missing(HHB_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHC_debut C1 C2A_Jour C2A_Mois C2A_annee C2 C3 C4 C5 C6 C7 C8 C9 C10 C11 age HHC_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue C."
        exit 459
    }
    save "$section_output\04_C.dta", replace
restore

display as result "Controles section C termines."
