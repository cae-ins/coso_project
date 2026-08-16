/*===========================================================================
  Section J. CHOMAGE DUREE ET RECHERCHE DEMPLOI
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

cap mkdir "$document\11_J"

*---------------------------------------------------------------------------
* HHJ_debut - HHJ_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHJ_debut) | trim(HHJ_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHJ_debut manquant dans son univers" if ((missing(HHJ_debut) | trim(HHJ_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHJ_debut) | trim(HHJ_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHJ_debut) | trim(HHJ_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    export excel interview__key cover_district HHJ_debut commentaire source_regle action_proposee ///
        using "$document\11_J\HHJ_debut_manquant.xlsx", ///
        if ((missing(HHJ_debut) | trim(HHJ_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHJ_debut) & trim(HHJ_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHJ_debut renseigne hors univers" if ((!missing(HHJ_debut) & trim(HHJ_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHJ_debut) & trim(HHJ_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHJ_debut) & trim(HHJ_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    export excel interview__key cover_district HHJ_debut commentaire source_regle action_proposee ///
        using "$document\11_J\HHJ_debut_hors_univers.xlsx", ///
        if ((!missing(HHJ_debut) & trim(HHJ_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* J0 - J0. Au cours des 30 derniers jours, avez-vous cherche un emploi salarie ou independant, ou essaye de demarrer une activite generatrice de revenus (petit commerce, atelier, exploita
* Type questionnaire : single-select
count if (missing(J0)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J0 manquant dans son univers" if (missing(J0)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(J0)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(J0)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    export excel interview__key cover_district J0 commentaire source_regle action_proposee ///
        using "$document\11_J\J0_manquant.xlsx", ///
        if (missing(J0)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(J0)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J0 renseigne hors univers" if (!missing(J0)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(J0)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(J0)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    export excel interview__key cover_district J0 commentaire source_regle action_proposee ///
        using "$document\11_J\J0_hors_univers.xlsx", ///
        if (!missing(J0)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(J0, 1, 2))) & (!missing(J0)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J0 hors domaine questionnaire" if !((inlist(J0, 1, 2))) & (!missing(J0)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(J0, 1, 2))) & (!missing(J0)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(J0, 1, 2))) & (!missing(J0)) & ($audit_scope)
    export excel interview__key cover_district J0 commentaire source_regle action_proposee ///
        using "$document\11_J\J0_hors_domaine.xlsx", ///
        if !((inlist(J0, 1, 2))) & (!missing(J0)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* J0A - J0A. Quelle est la principale raison pour laquelle vous n'avez pas cherche d'emploi ni essaye de demarrer une activite au cours des 30 derniers jours ?
* Type questionnaire : single-select
count if (missing(J0A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J0A manquant dans son univers" if (missing(J0A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(J0A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(J0A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    export excel interview__key cover_district J0A commentaire source_regle action_proposee ///
        using "$document\11_J\J0A_manquant.xlsx", ///
        if (missing(J0A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(J0A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J0A renseigne hors univers" if (!missing(J0A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(J0A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(J0A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    export excel interview__key cover_district J0A commentaire source_regle action_proposee ///
        using "$document\11_J\J0A_hors_univers.xlsx", ///
        if (!missing(J0A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(J0A, 1, 2, 3, 4, 5, 6, 7, 8, 9))) & (!missing(J0A)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J0A hors domaine questionnaire" if !((inlist(J0A, 1, 2, 3, 4, 5, 6, 7, 8, 9))) & (!missing(J0A)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(J0A, 1, 2, 3, 4, 5, 6, 7, 8, 9))) & (!missing(J0A)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(J0A, 1, 2, 3, 4, 5, 6, 7, 8, 9))) & (!missing(J0A)) & ($audit_scope)
    export excel interview__key cover_district J0A commentaire source_regle action_proposee ///
        using "$document\11_J\J0A_hors_domaine.xlsx", ///
        if !((inlist(J0A, 1, 2, 3, 4, 5, 6, 7, 8, 9))) & (!missing(J0A)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* J0B - J0B. A l'heure actuelle, souhaiteriez-vous travailler ?
* Type questionnaire : single-select
count if (missing(J0B)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J0B manquant dans son univers" if (missing(J0B)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(J0B)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(J0B)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    export excel interview__key cover_district J0B commentaire source_regle action_proposee ///
        using "$document\11_J\J0B_manquant.xlsx", ///
        if (missing(J0B)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(J0B)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J0B renseigne hors univers" if (!missing(J0B)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(J0B)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(J0B)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    export excel interview__key cover_district J0B commentaire source_regle action_proposee ///
        using "$document\11_J\J0B_hors_univers.xlsx", ///
        if (!missing(J0B)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(J0B, 1, 2))) & (!missing(J0B)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J0B hors domaine questionnaire" if !((inlist(J0B, 1, 2))) & (!missing(J0B)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(J0B, 1, 2))) & (!missing(J0B)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(J0B, 1, 2))) & (!missing(J0B)) & ($audit_scope)
    export excel interview__key cover_district J0B commentaire source_regle action_proposee ///
        using "$document\11_J\J0B_hors_domaine.xlsx", ///
        if !((inlist(J0B, 1, 2))) & (!missing(J0B)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* J1 - J1. Quavez-vous fait principalement au cours des 30 derniers jours pour trouver un emploi ou demarrer une entreprise ?
* Type questionnaire : single-select
count if (missing(J1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J1 manquant dans son univers" if (missing(J1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(J1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(J1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
    export excel interview__key cover_district J1 commentaire source_regle action_proposee ///
        using "$document\11_J\J1_manquant.xlsx", ///
        if (missing(J1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(J1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J1 renseigne hors univers" if (!missing(J1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(J1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(J1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
    export excel interview__key cover_district J1 commentaire source_regle action_proposee ///
        using "$document\11_J\J1_hors_univers.xlsx", ///
        if (!missing(J1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(J1, 1, 2, 3, 4, 5, 6, 9))) & (!missing(J1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J1 hors domaine questionnaire" if !((inlist(J1, 1, 2, 3, 4, 5, 6, 9))) & (!missing(J1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(J1, 1, 2, 3, 4, 5, 6, 9))) & (!missing(J1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(J1, 1, 2, 3, 4, 5, 6, 9))) & (!missing(J1)) & ($audit_scope)
    export excel interview__key cover_district J1 commentaire source_regle action_proposee ///
        using "$document\11_J\J1_hors_domaine.xlsx", ///
        if !((inlist(J1, 1, 2, 3, 4, 5, 6, 9))) & (!missing(J1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* J1X - J1X. Preciser l'autre action
* Type questionnaire : text
count if ((missing(J1X) | trim(J1X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J1) & (J1 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J1X manquant dans son univers" if ((missing(J1X) | trim(J1X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J1) & (J1 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(J1X) | trim(J1X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J1) & (J1 == 9)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(J1X) | trim(J1X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J1) & (J1 == 9)))) & ($audit_scope)
    export excel interview__key cover_district J1X commentaire source_regle action_proposee ///
        using "$document\11_J\J1X_manquant.xlsx", ///
        if ((missing(J1X) | trim(J1X) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J1) & (J1 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(J1X) & trim(J1X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J1) & (J1 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J1X renseigne hors univers" if ((!missing(J1X) & trim(J1X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J1) & (J1 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(J1X) & trim(J1X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J1) & (J1 == 9)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(J1X) & trim(J1X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J1) & (J1 == 9)))) & ($audit_scope)
    export excel interview__key cover_district J1X commentaire source_regle action_proposee ///
        using "$document\11_J\J1X_hors_univers.xlsx", ///
        if ((!missing(J1X) & trim(J1X) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J1) & (J1 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* J2 - J2. Depuis combien de temps etes-vous sans emploi et en recherche ?
* Type questionnaire : single-select
count if (missing(J2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J2 manquant dans son univers" if (missing(J2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(J2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(J2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
    export excel interview__key cover_district J2 commentaire source_regle action_proposee ///
        using "$document\11_J\J2_manquant.xlsx", ///
        if (missing(J2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(J2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J2 renseigne hors univers" if (!missing(J2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(J2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(J2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope)
    export excel interview__key cover_district J2 commentaire source_regle action_proposee ///
        using "$document\11_J\J2_hors_univers.xlsx", ///
        if (!missing(J2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(J2, 1, 2, 3, 4, 5, 6))) & (!missing(J2)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J2 hors domaine questionnaire" if !((inlist(J2, 1, 2, 3, 4, 5, 6))) & (!missing(J2)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(J2, 1, 2, 3, 4, 5, 6))) & (!missing(J2)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(J2, 1, 2, 3, 4, 5, 6))) & (!missing(J2)) & ($audit_scope)
    export excel interview__key cover_district J2 commentaire source_regle action_proposee ///
        using "$document\11_J\J2_hors_domaine.xlsx", ///
        if !((inlist(J2, 1, 2, 3, 4, 5, 6))) & (!missing(J2)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* J3 - J3. Si vous aviez trouve un emploi la semaine derniere, auriez-vous pu commencer dans les deux semaines suivantes ?
* Type questionnaire : single-select
count if (missing(J3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J3 manquant dans son univers" if (missing(J3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(J3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(J3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    export excel interview__key cover_district J3 commentaire source_regle action_proposee ///
        using "$document\11_J\J3_manquant.xlsx", ///
        if (missing(J3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(J3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J3 renseigne hors univers" if (!missing(J3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(J3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(J3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope)
    export excel interview__key cover_district J3 commentaire source_regle action_proposee ///
        using "$document\11_J\J3_hors_univers.xlsx", ///
        if (!missing(J3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0))) & ((!missing(J0) & (J0 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(J3, 1, 2))) & (!missing(J3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "J3 hors domaine questionnaire" if !((inlist(J3, 1, 2))) & (!missing(J3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(J3, 1, 2))) & (!missing(J3)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(J3, 1, 2))) & (!missing(J3)) & ($audit_scope)
    export excel interview__key cover_district J3 commentaire source_regle action_proposee ///
        using "$document\11_J\J3_hors_domaine.xlsx", ///
        if !((inlist(J3, 1, 2))) & (!missing(J3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHJ_fin - HHJ_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHJ_fin) | trim(HHJ_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHJ_fin manquant dans son univers" if ((missing(HHJ_fin) | trim(HHJ_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHJ_fin) | trim(HHJ_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHJ_fin) | trim(HHJ_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    export excel interview__key cover_district HHJ_fin commentaire source_regle action_proposee ///
        using "$document\11_J\HHJ_fin_manquant.xlsx", ///
        if ((missing(HHJ_fin) | trim(HHJ_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHJ_fin) & trim(HHJ_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHJ_fin renseigne hors univers" if ((!missing(HHJ_fin) & trim(HHJ_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHJ_fin) & trim(HHJ_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHJ_fin) & trim(HHJ_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope)
    export excel interview__key cover_district HHJ_fin commentaire source_regle action_proposee ///
        using "$document\11_J\HHJ_fin_hors_univers.xlsx", ///
        if ((!missing(HHJ_fin) & trim(HHJ_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 0)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHJ_debut J0 J0A J0B J1 J1X J2 J3 HHJ_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue J."
        exit 459
    }
    save "$section_output\11_J.dta", replace
restore

display as result "Controles section J termines."
