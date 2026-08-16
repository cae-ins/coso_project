/*===========================================================================
  Section N. RESILIENCE FACE AUX CHOCS
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

cap mkdir "$document\15_N"

*---------------------------------------------------------------------------
* HHN_debut - HHN_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHN_debut) | trim(HHN_debut) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHN_debut manquant dans son univers" if ((missing(HHN_debut) | trim(HHN_debut) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHN_debut) | trim(HHN_debut) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHN_debut) | trim(HHN_debut) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHN_debut commentaire source_regle action_proposee ///
        using "$document\15_N\HHN_debut_manquant.xlsx", ///
        if ((missing(HHN_debut) | trim(HHN_debut) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHN_debut) & trim(HHN_debut) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHN_debut renseigne hors univers" if ((!missing(HHN_debut) & trim(HHN_debut) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHN_debut) & trim(HHN_debut) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHN_debut) & trim(HHN_debut) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHN_debut commentaire source_regle action_proposee ///
        using "$document\15_N\HHN_debut_hors_univers.xlsx", ///
        if ((!missing(HHN_debut) & trim(HHN_debut) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* N1 - N1. Au cours des 12 derniers mois, votre menage a-t-il ete affecte par un choc economique/probleme ou autre (maladie, mauvaise recolte, perte d'emploi, catastrophe, etc.) ?
* Type questionnaire : single-select
count if (missing(N1)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N1 manquant dans son univers" if (missing(N1)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(N1)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(N1)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district N1 commentaire source_regle action_proposee ///
        using "$document\15_N\N1_manquant.xlsx", ///
        if (missing(N1)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(N1)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N1 renseigne hors univers" if (!missing(N1)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(N1)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(N1)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district N1 commentaire source_regle action_proposee ///
        using "$document\15_N\N1_hors_univers.xlsx", ///
        if (!missing(N1)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(N1, 1, 2))) & (!missing(N1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N1 hors domaine questionnaire" if !((inlist(N1, 1, 2))) & (!missing(N1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(N1, 1, 2))) & (!missing(N1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(N1, 1, 2))) & (!missing(N1)) & ($audit_scope)
    export excel interview__key cover_district N1 commentaire source_regle action_proposee ///
        using "$document\15_N\N1_hors_domaine.xlsx", ///
        if !((inlist(N1, 1, 2))) & (!missing(N1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* N2 - N2. Quel a ete le choc/probleme le plus important subi ?
* Type questionnaire : single-select
count if (missing(N2)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N2 manquant dans son univers" if (missing(N2)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(N2)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(N2)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district N2 commentaire source_regle action_proposee ///
        using "$document\15_N\N2_manquant.xlsx", ///
        if (missing(N2)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(N2)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N2 renseigne hors univers" if (!missing(N2)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(N2)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(N2)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district N2 commentaire source_regle action_proposee ///
        using "$document\15_N\N2_hors_univers.xlsx", ///
        if (!missing(N2)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(N2, 1, 2, 3, 4, 5, 9))) & (!missing(N2)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N2 hors domaine questionnaire" if !((inlist(N2, 1, 2, 3, 4, 5, 9))) & (!missing(N2)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(N2, 1, 2, 3, 4, 5, 9))) & (!missing(N2)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(N2, 1, 2, 3, 4, 5, 9))) & (!missing(N2)) & ($audit_scope)
    export excel interview__key cover_district N2 commentaire source_regle action_proposee ///
        using "$document\15_N\N2_hors_domaine.xlsx", ///
        if !((inlist(N2, 1, 2, 3, 4, 5, 9))) & (!missing(N2)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* N2X - N2X. Autre a preciser
* Type questionnaire : text
count if ((missing(N2X) | trim(N2X) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N2) & (N2 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N2X manquant dans son univers" if ((missing(N2X) | trim(N2X) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N2) & (N2 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(N2X) | trim(N2X) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N2) & (N2 == 9)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(N2X) | trim(N2X) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N2) & (N2 == 9)))) & ($audit_scope)
    export excel interview__key cover_district N2X commentaire source_regle action_proposee ///
        using "$document\15_N\N2X_manquant.xlsx", ///
        if ((missing(N2X) | trim(N2X) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N2) & (N2 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(N2X) & trim(N2X) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N2) & (N2 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N2X renseigne hors univers" if ((!missing(N2X) & trim(N2X) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N2) & (N2 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(N2X) & trim(N2X) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N2) & (N2 == 9)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(N2X) & trim(N2X) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N2) & (N2 == 9)))) & ($audit_scope)
    export excel interview__key cover_district N2X commentaire source_regle action_proposee ///
        using "$document\15_N\N2X_hors_univers.xlsx", ///
        if ((!missing(N2X) & trim(N2X) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N2) & (N2 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* N3 - N3. Quel a ete l'impact/la consequence de ce choc sur votre revenu ou votre activite ?
* Type questionnaire : single-select
count if (missing(N3)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N3 manquant dans son univers" if (missing(N3)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(N3)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(N3)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district N3 commentaire source_regle action_proposee ///
        using "$document\15_N\N3_manquant.xlsx", ///
        if (missing(N3)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(N3)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N3 renseigne hors univers" if (!missing(N3)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(N3)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(N3)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district N3 commentaire source_regle action_proposee ///
        using "$document\15_N\N3_hors_univers.xlsx", ///
        if (!missing(N3)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(N3, 1, 2, 3, 4))) & (!missing(N3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N3 hors domaine questionnaire" if !((inlist(N3, 1, 2, 3, 4))) & (!missing(N3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(N3, 1, 2, 3, 4))) & (!missing(N3)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(N3, 1, 2, 3, 4))) & (!missing(N3)) & ($audit_scope)
    export excel interview__key cover_district N3 commentaire source_regle action_proposee ///
        using "$document\15_N\N3_hors_domaine.xlsx", ///
        if !((inlist(N3, 1, 2, 3, 4))) & (!missing(N3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* N4 - N4. Comment avez-vous principalement fait face a ce choc/probleme ?
* Type questionnaire : single-select
count if (missing(N4)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N4 manquant dans son univers" if (missing(N4)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(N4)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(N4)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district N4 commentaire source_regle action_proposee ///
        using "$document\15_N\N4_manquant.xlsx", ///
        if (missing(N4)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(N4)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N4 renseigne hors univers" if (!missing(N4)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(N4)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(N4)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district N4 commentaire source_regle action_proposee ///
        using "$document\15_N\N4_hors_univers.xlsx", ///
        if (!missing(N4)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(N4, 1, 2, 3, 4, 5, 6, 9))) & (!missing(N4)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N4 hors domaine questionnaire" if !((inlist(N4, 1, 2, 3, 4, 5, 6, 9))) & (!missing(N4)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(N4, 1, 2, 3, 4, 5, 6, 9))) & (!missing(N4)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(N4, 1, 2, 3, 4, 5, 6, 9))) & (!missing(N4)) & ($audit_scope)
    export excel interview__key cover_district N4 commentaire source_regle action_proposee ///
        using "$document\15_N\N4_hors_domaine.xlsx", ///
        if !((inlist(N4, 1, 2, 3, 4, 5, 6, 9))) & (!missing(N4)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* N4X - N4X. Autre a preciser
* Type questionnaire : text
count if ((missing(N4X) | trim(N4X) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N4) & (N4 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N4X manquant dans son univers" if ((missing(N4X) | trim(N4X) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N4) & (N4 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(N4X) | trim(N4X) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N4) & (N4 == 9)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(N4X) | trim(N4X) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N4) & (N4 == 9)))) & ($audit_scope)
    export excel interview__key cover_district N4X commentaire source_regle action_proposee ///
        using "$document\15_N\N4X_manquant.xlsx", ///
        if ((missing(N4X) | trim(N4X) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N4) & (N4 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(N4X) & trim(N4X) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N4) & (N4 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N4X renseigne hors univers" if ((!missing(N4X) & trim(N4X) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N4) & (N4 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(N4X) & trim(N4X) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N4) & (N4 == 9)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(N4X) & trim(N4X) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N4) & (N4 == 9)))) & ($audit_scope)
    export excel interview__key cover_district N4X commentaire source_regle action_proposee ///
        using "$document\15_N\N4X_hors_univers.xlsx", ///
        if ((!missing(N4X) & trim(N4X) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N4) & (N4 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* N5 - N5. Combien de temps a-t-il fallu pour que votre activite ou votre revenu revienne a son niveau d'avant le choc ?
* Type questionnaire : single-select
count if (missing(N5)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N5 manquant dans son univers" if (missing(N5)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(N5)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(N5)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district N5 commentaire source_regle action_proposee ///
        using "$document\15_N\N5_manquant.xlsx", ///
        if (missing(N5)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(N5)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N5 renseigne hors univers" if (!missing(N5)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(N5)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(N5)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district N5 commentaire source_regle action_proposee ///
        using "$document\15_N\N5_hors_univers.xlsx", ///
        if (!missing(N5)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(N1) & (N1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(N5, 1, 2, 3, 4, 5))) & (!missing(N5)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N5 hors domaine questionnaire" if !((inlist(N5, 1, 2, 3, 4, 5))) & (!missing(N5)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(N5, 1, 2, 3, 4, 5))) & (!missing(N5)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(N5, 1, 2, 3, 4, 5))) & (!missing(N5)) & ($audit_scope)
    export excel interview__key cover_district N5 commentaire source_regle action_proposee ///
        using "$document\15_N\N5_hors_domaine.xlsx", ///
        if !((inlist(N5, 1, 2, 3, 4, 5))) & (!missing(N5)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* N6 - N6. Si vous deviez couvrir une depense imprevue de 250 000 FCFA , seriez-vous en mesure de reunir cette somme sans vous endetter lourdement ni vendre un bien essentiel ?
* Type questionnaire : single-select
count if (missing(N6)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N6 manquant dans son univers" if (missing(N6)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(N6)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(N6)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district N6 commentaire source_regle action_proposee ///
        using "$document\15_N\N6_manquant.xlsx", ///
        if (missing(N6)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(N6)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N6 renseigne hors univers" if (!missing(N6)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(N6)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(N6)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district N6 commentaire source_regle action_proposee ///
        using "$document\15_N\N6_hors_univers.xlsx", ///
        if (!missing(N6)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(N6, 1, 2, 3))) & (!missing(N6)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N6 hors domaine questionnaire" if !((inlist(N6, 1, 2, 3))) & (!missing(N6)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(N6, 1, 2, 3))) & (!missing(N6)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(N6, 1, 2, 3))) & (!missing(N6)) & ($audit_scope)
    export excel interview__key cover_district N6 commentaire source_regle action_proposee ///
        using "$document\15_N\N6_hors_domaine.xlsx", ///
        if !((inlist(N6, 1, 2, 3))) & (!missing(N6)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* N7 - N7. Globalement, sur une echelle de 1 a 10, comment evaluez-vous votre capacite actuelle a resister a un choc economique ?
* Type questionnaire : single-select
count if (missing(N7)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N7 manquant dans son univers" if (missing(N7)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(N7)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(N7)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district N7 commentaire source_regle action_proposee ///
        using "$document\15_N\N7_manquant.xlsx", ///
        if (missing(N7)) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(N7)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N7 renseigne hors univers" if (!missing(N7)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(N7)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(N7)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district N7 commentaire source_regle action_proposee ///
        using "$document\15_N\N7_hors_univers.xlsx", ///
        if (!missing(N7)) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(N7, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10))) & (!missing(N7)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "N7 hors domaine questionnaire" if !((inlist(N7, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10))) & (!missing(N7)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(N7, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10))) & (!missing(N7)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(N7, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10))) & (!missing(N7)) & ($audit_scope)
    export excel interview__key cover_district N7 commentaire source_regle action_proposee ///
        using "$document\15_N\N7_hors_domaine.xlsx", ///
        if !((inlist(N7, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10))) & (!missing(N7)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHN_fin - HHN_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHN_fin) | trim(HHN_fin) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHN_fin manquant dans son univers" if ((missing(HHN_fin) | trim(HHN_fin) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHN_fin) | trim(HHN_fin) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHN_fin) | trim(HHN_fin) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHN_fin commentaire source_regle action_proposee ///
        using "$document\15_N\HHN_fin_manquant.xlsx", ///
        if ((missing(HHN_fin) | trim(HHN_fin) == "")) & ((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHN_fin) & trim(HHN_fin) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHN_fin renseigne hors univers" if ((!missing(HHN_fin) & trim(HHN_fin) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHN_fin) & trim(HHN_fin) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHN_fin) & trim(HHN_fin) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHN_fin commentaire source_regle action_proposee ///
        using "$document\15_N\HHN_fin_hors_univers.xlsx", ///
        if ((!missing(HHN_fin) & trim(HHN_fin) != "")) & !((!missing(HHM_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHN_debut N1 N2 N2X N3 N4 N4X N5 N6 N7 HHN_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue N."
        exit 459
    }
    save "$section_output\15_N.dta", replace
restore

display as result "Controles section N termines."
