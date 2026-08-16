/*===========================================================================
  Section I. RECHERCHE DUN AUTRE EMPLOI
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

cap mkdir "$document\10_I"

*---------------------------------------------------------------------------
* HHI_debut - HHI_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHI_debut) | trim(HHI_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHI_debut manquant dans son univers" if ((missing(HHI_debut) | trim(HHI_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHI_debut) | trim(HHI_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHI_debut) | trim(HHI_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHI_debut commentaire source_regle action_proposee ///
        using "$document\10_I\HHI_debut_manquant.xlsx", ///
        if ((missing(HHI_debut) | trim(HHI_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHI_debut) & trim(HHI_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHI_debut renseigne hors univers" if ((!missing(HHI_debut) & trim(HHI_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHI_debut) & trim(HHI_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHI_debut) & trim(HHI_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHI_debut commentaire source_regle action_proposee ///
        using "$document\10_I\HHI_debut_hors_univers.xlsx", ///
        if ((!missing(HHI_debut) & trim(HHI_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* I1 - I1. Bien que vous travailliez actuellement, recherchez-vous activement un autre emploi ou une autre activite ?
* Type questionnaire : single-select
count if (missing(I1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "I1 manquant dans son univers" if (missing(I1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(I1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(I1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district I1 commentaire source_regle action_proposee ///
        using "$document\10_I\I1_manquant.xlsx", ///
        if (missing(I1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(I1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "I1 renseigne hors univers" if (!missing(I1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(I1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(I1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district I1 commentaire source_regle action_proposee ///
        using "$document\10_I\I1_hors_univers.xlsx", ///
        if (!missing(I1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(I1, 1, 2))) & (!missing(I1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "I1 hors domaine questionnaire" if !((inlist(I1, 1, 2))) & (!missing(I1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(I1, 1, 2))) & (!missing(I1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(I1, 1, 2))) & (!missing(I1)) & ($audit_scope)
    export excel interview__key cover_district I1 commentaire source_regle action_proposee ///
        using "$document\10_I\I1_hors_domaine.xlsx", ///
        if !((inlist(I1, 1, 2))) & (!missing(I1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* I2 - I2. Quelle est la principale raison ?
* Type questionnaire : single-select
count if (missing(I2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "I2 manquant dans son univers" if (missing(I2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(I2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(I2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district I2 commentaire source_regle action_proposee ///
        using "$document\10_I\I2_manquant.xlsx", ///
        if (missing(I2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(I2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "I2 renseigne hors univers" if (!missing(I2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(I2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(I2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district I2 commentaire source_regle action_proposee ///
        using "$document\10_I\I2_hors_univers.xlsx", ///
        if (!missing(I2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(I2, 1, 2, 3, 4, 5))) & (!missing(I2)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "I2 hors domaine questionnaire" if !((inlist(I2, 1, 2, 3, 4, 5))) & (!missing(I2)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(I2, 1, 2, 3, 4, 5))) & (!missing(I2)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(I2, 1, 2, 3, 4, 5))) & (!missing(I2)) & ($audit_scope)
    export excel interview__key cover_district I2 commentaire source_regle action_proposee ///
        using "$document\10_I\I2_hors_domaine.xlsx", ///
        if !((inlist(I2, 1, 2, 3, 4, 5))) & (!missing(I2)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* I2X - I2X. Preciser l'autre raison
* Type questionnaire : text
count if ((missing(I2X) | trim(I2X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I2) & (I2 == 5)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "I2X manquant dans son univers" if ((missing(I2X) | trim(I2X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I2) & (I2 == 5)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(I2X) | trim(I2X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I2) & (I2 == 5)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(I2X) | trim(I2X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I2) & (I2 == 5)))) & ($audit_scope)
    export excel interview__key cover_district I2X commentaire source_regle action_proposee ///
        using "$document\10_I\I2X_manquant.xlsx", ///
        if ((missing(I2X) | trim(I2X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I2) & (I2 == 5)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(I2X) & trim(I2X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I2) & (I2 == 5)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "I2X renseigne hors univers" if ((!missing(I2X) & trim(I2X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I2) & (I2 == 5)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(I2X) & trim(I2X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I2) & (I2 == 5)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(I2X) & trim(I2X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I2) & (I2 == 5)))) & ($audit_scope)
    export excel interview__key cover_district I2X commentaire source_regle action_proposee ///
        using "$document\10_I\I2X_hors_univers.xlsx", ///
        if ((!missing(I2X) & trim(I2X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I2) & (I2 == 5)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* I3 - I3. Quavez-vous fait principalement pour chercher cet autre emploi ?
* Type questionnaire : single-select
count if (missing(I3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "I3 manquant dans son univers" if (missing(I3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(I3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(I3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district I3 commentaire source_regle action_proposee ///
        using "$document\10_I\I3_manquant.xlsx", ///
        if (missing(I3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(I3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "I3 renseigne hors univers" if (!missing(I3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(I3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(I3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district I3 commentaire source_regle action_proposee ///
        using "$document\10_I\I3_hors_univers.xlsx", ///
        if (!missing(I3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I1) & (I1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(I3, 1, 2, 3, 4, 5, 6, 9))) & (!missing(I3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "I3 hors domaine questionnaire" if !((inlist(I3, 1, 2, 3, 4, 5, 6, 9))) & (!missing(I3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(I3, 1, 2, 3, 4, 5, 6, 9))) & (!missing(I3)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(I3, 1, 2, 3, 4, 5, 6, 9))) & (!missing(I3)) & ($audit_scope)
    export excel interview__key cover_district I3 commentaire source_regle action_proposee ///
        using "$document\10_I\I3_hors_domaine.xlsx", ///
        if !((inlist(I3, 1, 2, 3, 4, 5, 6, 9))) & (!missing(I3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* I3X - I3X. Preciser l'autre action
* Type questionnaire : text
count if ((missing(I3X) | trim(I3X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I3) & (I3 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "I3X manquant dans son univers" if ((missing(I3X) | trim(I3X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I3) & (I3 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(I3X) | trim(I3X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I3) & (I3 == 9)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(I3X) | trim(I3X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I3) & (I3 == 9)))) & ($audit_scope)
    export excel interview__key cover_district I3X commentaire source_regle action_proposee ///
        using "$document\10_I\I3X_manquant.xlsx", ///
        if ((missing(I3X) | trim(I3X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I3) & (I3 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(I3X) & trim(I3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I3) & (I3 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "I3X renseigne hors univers" if ((!missing(I3X) & trim(I3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I3) & (I3 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(I3X) & trim(I3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I3) & (I3 == 9)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(I3X) & trim(I3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I3) & (I3 == 9)))) & ($audit_scope)
    export excel interview__key cover_district I3X commentaire source_regle action_proposee ///
        using "$document\10_I\I3X_hors_univers.xlsx", ///
        if ((!missing(I3X) & trim(I3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(I3) & (I3 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHI_fin - HHI_debut. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHI_fin) | trim(HHI_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHI_fin manquant dans son univers" if ((missing(HHI_fin) | trim(HHI_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHI_fin) | trim(HHI_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHI_fin) | trim(HHI_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHI_fin commentaire source_regle action_proposee ///
        using "$document\10_I\HHI_fin_manquant.xlsx", ///
        if ((missing(HHI_fin) | trim(HHI_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHI_fin) & trim(HHI_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHI_fin renseigne hors univers" if ((!missing(HHI_fin) & trim(HHI_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHI_fin) & trim(HHI_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHI_fin) & trim(HHI_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHI_fin commentaire source_regle action_proposee ///
        using "$document\10_I\HHI_fin_hors_univers.xlsx", ///
        if ((!missing(HHI_fin) & trim(HHI_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHI_debut I1 I2 I2X I3 I3X HHI_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue I."
        exit 459
    }
    save "$section_output\10_I.dta", replace
restore

display as result "Controles section I termines."
