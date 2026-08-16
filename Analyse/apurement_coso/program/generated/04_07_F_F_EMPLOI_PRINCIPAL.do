/*===========================================================================
  Section F. EMPLOI PRINCIPAL
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

cap mkdir "$document\07_F"

*---------------------------------------------------------------------------
* HHF_debut - HHF_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHF_debut) | trim(HHF_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHF_debut manquant dans son univers" if ((missing(HHF_debut) | trim(HHF_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHF_debut) | trim(HHF_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHF_debut) | trim(HHF_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHF_debut commentaire source_regle action_proposee ///
        using "$document\07_F\HHF_debut_manquant.xlsx", ///
        if ((missing(HHF_debut) | trim(HHF_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHF_debut) & trim(HHF_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHF_debut renseigne hors univers" if ((!missing(HHF_debut) & trim(HHF_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHF_debut) & trim(HHF_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHF_debut) & trim(HHF_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHF_debut commentaire source_regle action_proposee ///
        using "$document\07_F\HHF_debut_hors_univers.xlsx", ///
        if ((!missing(HHF_debut) & trim(HHF_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* F1 - F1. Quel est votre statut votre emploi ?
* Type questionnaire : single-select
count if (missing(F1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F1 manquant dans son univers" if (missing(F1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(F1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(F1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district F1 commentaire source_regle action_proposee ///
        using "$document\07_F\F1_manquant.xlsx", ///
        if (missing(F1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(F1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F1 renseigne hors univers" if (!missing(F1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(F1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(F1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district F1 commentaire source_regle action_proposee ///
        using "$document\07_F\F1_hors_univers.xlsx", ///
        if (!missing(F1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(F1, 1, 2, 3, 4, 5, 7, 9))) & (!missing(F1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F1 hors domaine questionnaire" if !((inlist(F1, 1, 2, 3, 4, 5, 7, 9))) & (!missing(F1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(F1, 1, 2, 3, 4, 5, 7, 9))) & (!missing(F1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(F1, 1, 2, 3, 4, 5, 7, 9))) & (!missing(F1)) & ($audit_scope)
    export excel interview__key cover_district F1 commentaire source_regle action_proposee ///
        using "$document\07_F\F1_hors_domaine.xlsx", ///
        if !((inlist(F1, 1, 2, 3, 4, 5, 7, 9))) & (!missing(F1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* F1X - F1X. Autre a preciser
* Type questionnaire : text
count if ((missing(F1X) | trim(F1X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F1X manquant dans son univers" if ((missing(F1X) | trim(F1X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(F1X) | trim(F1X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 9)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(F1X) | trim(F1X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 9)))) & ($audit_scope)
    export excel interview__key cover_district F1X commentaire source_regle action_proposee ///
        using "$document\07_F\F1X_manquant.xlsx", ///
        if ((missing(F1X) | trim(F1X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(F1X) & trim(F1X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F1X renseigne hors univers" if ((!missing(F1X) & trim(F1X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(F1X) & trim(F1X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 9)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(F1X) & trim(F1X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 9)))) & ($audit_scope)
    export excel interview__key cover_district F1X commentaire source_regle action_proposee ///
        using "$document\07_F\F1X_hors_univers.xlsx", ///
        if ((!missing(F1X) & trim(F1X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* F2 - F2. Quel est le secteur de votre activite principale ?
* Type questionnaire : single-select
count if (missing(F2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F2 manquant dans son univers" if (missing(F2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(F2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(F2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district F2 commentaire source_regle action_proposee ///
        using "$document\07_F\F2_manquant.xlsx", ///
        if (missing(F2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(F2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F2 renseigne hors univers" if (!missing(F2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(F2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(F2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district F2 commentaire source_regle action_proposee ///
        using "$document\07_F\F2_hors_univers.xlsx", ///
        if (!missing(F2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(F2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) | inlist(F2, 11, 12, 13, 14, 99))) & (!missing(F2)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F2 hors domaine questionnaire" if !((inlist(F2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) | inlist(F2, 11, 12, 13, 14, 99))) & (!missing(F2)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(F2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) | inlist(F2, 11, 12, 13, 14, 99))) & (!missing(F2)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(F2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) | inlist(F2, 11, 12, 13, 14, 99))) & (!missing(F2)) & ($audit_scope)
    export excel interview__key cover_district F2 commentaire source_regle action_proposee ///
        using "$document\07_F\F2_hors_domaine.xlsx", ///
        if !((inlist(F2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) | inlist(F2, 11, 12, 13, 14, 99))) & (!missing(F2)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* F2X - F2X. Preciser l'autre secteur
* Type questionnaire : text
count if ((missing(F2X) | trim(F2X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F2) & (F2 == 99)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F2X manquant dans son univers" if ((missing(F2X) | trim(F2X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F2) & (F2 == 99)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(F2X) | trim(F2X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F2) & (F2 == 99)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(F2X) | trim(F2X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F2) & (F2 == 99)))) & ($audit_scope)
    export excel interview__key cover_district F2X commentaire source_regle action_proposee ///
        using "$document\07_F\F2X_manquant.xlsx", ///
        if ((missing(F2X) | trim(F2X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F2) & (F2 == 99)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(F2X) & trim(F2X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F2) & (F2 == 99)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F2X renseigne hors univers" if ((!missing(F2X) & trim(F2X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F2) & (F2 == 99)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(F2X) & trim(F2X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F2) & (F2 == 99)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(F2X) & trim(F2X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F2) & (F2 == 99)))) & ($audit_scope)
    export excel interview__key cover_district F2X commentaire source_regle action_proposee ///
        using "$document\07_F\F2X_hors_univers.xlsx", ///
        if ((!missing(F2X) & trim(F2X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F2) & (F2 == 99)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* F3 - F3. Ou exercez-vous principalement ce travail ?
* Type questionnaire : single-select
count if (missing(F3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F3 manquant dans son univers" if (missing(F3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(F3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(F3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district F3 commentaire source_regle action_proposee ///
        using "$document\07_F\F3_manquant.xlsx", ///
        if (missing(F3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(F3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F3 renseigne hors univers" if (!missing(F3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(F3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(F3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district F3 commentaire source_regle action_proposee ///
        using "$document\07_F\F3_hors_univers.xlsx", ///
        if (!missing(F3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(F3, 1, 2, 3, 4, 5, 6, 7, 8, 9))) & (!missing(F3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F3 hors domaine questionnaire" if !((inlist(F3, 1, 2, 3, 4, 5, 6, 7, 8, 9))) & (!missing(F3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(F3, 1, 2, 3, 4, 5, 6, 7, 8, 9))) & (!missing(F3)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(F3, 1, 2, 3, 4, 5, 6, 7, 8, 9))) & (!missing(F3)) & ($audit_scope)
    export excel interview__key cover_district F3 commentaire source_regle action_proposee ///
        using "$document\07_F\F3_hors_domaine.xlsx", ///
        if !((inlist(F3, 1, 2, 3, 4, 5, 6, 7, 8, 9))) & (!missing(F3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* F3X - F3X. Preciser l'autre lieu d'exercice
* Type questionnaire : text
count if ((missing(F3X) | trim(F3X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F3) & (F3 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F3X manquant dans son univers" if ((missing(F3X) | trim(F3X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F3) & (F3 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(F3X) | trim(F3X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F3) & (F3 == 9)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(F3X) | trim(F3X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F3) & (F3 == 9)))) & ($audit_scope)
    export excel interview__key cover_district F3X commentaire source_regle action_proposee ///
        using "$document\07_F\F3X_manquant.xlsx", ///
        if ((missing(F3X) | trim(F3X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F3) & (F3 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(F3X) & trim(F3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F3) & (F3 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F3X renseigne hors univers" if ((!missing(F3X) & trim(F3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F3) & (F3 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(F3X) & trim(F3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F3) & (F3 == 9)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(F3X) & trim(F3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F3) & (F3 == 9)))) & ($audit_scope)
    export excel interview__key cover_district F3X commentaire source_regle action_proposee ///
        using "$document\07_F\F3X_hors_univers.xlsx", ///
        if ((!missing(F3X) & trim(F3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F3) & (F3 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* F4 - F4. Depuis combien de temps travaillez-vous dans cet emploi/cette activite, sans interruption ?
* Type questionnaire : single-select
count if (missing(F4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F4 manquant dans son univers" if (missing(F4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(F4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(F4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district F4 commentaire source_regle action_proposee ///
        using "$document\07_F\F4_manquant.xlsx", ///
        if (missing(F4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(F4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F4 renseigne hors univers" if (!missing(F4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(F4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(F4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district F4 commentaire source_regle action_proposee ///
        using "$document\07_F\F4_hors_univers.xlsx", ///
        if (!missing(F4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(F4, 1, 2, 3, 4, 5))) & (!missing(F4)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "F4 hors domaine questionnaire" if !((inlist(F4, 1, 2, 3, 4, 5))) & (!missing(F4)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(F4, 1, 2, 3, 4, 5))) & (!missing(F4)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(F4, 1, 2, 3, 4, 5))) & (!missing(F4)) & ($audit_scope)
    export excel interview__key cover_district F4 commentaire source_regle action_proposee ///
        using "$document\07_F\F4_hors_domaine.xlsx", ///
        if !((inlist(F4, 1, 2, 3, 4, 5))) & (!missing(F4)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHF_fin - HHF_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHF_fin) | trim(HHF_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHF_fin manquant dans son univers" if ((missing(HHF_fin) | trim(HHF_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHF_fin) | trim(HHF_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHF_fin) | trim(HHF_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHF_fin commentaire source_regle action_proposee ///
        using "$document\07_F\HHF_fin_manquant.xlsx", ///
        if ((missing(HHF_fin) | trim(HHF_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHF_fin) & trim(HHF_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHF_fin renseigne hors univers" if ((!missing(HHF_fin) & trim(HHF_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHF_fin) & trim(HHF_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHF_fin) & trim(HHF_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHF_fin commentaire source_regle action_proposee ///
        using "$document\07_F\HHF_fin_hors_univers.xlsx", ///
        if ((!missing(HHF_fin) & trim(HHF_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHF_debut F1 F1X F2 F2X F3 F3X F4 HHF_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue F."
        exit 459
    }
    save "$section_output\07_F.dta", replace
restore

display as result "Controles section F termines."
