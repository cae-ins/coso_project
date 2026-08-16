/*===========================================================================
  Section K. ENTREPRENEURIAT
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

cap mkdir "$document\12_K"

*---------------------------------------------------------------------------
* HHK_debut - HHK_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHK_debut) | trim(HHK_debut) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHK_debut manquant dans son univers" if ((missing(HHK_debut) | trim(HHK_debut) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHK_debut) | trim(HHK_debut) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHK_debut) | trim(HHK_debut) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHK_debut commentaire source_regle action_proposee ///
        using "$document\12_K\HHK_debut_manquant.xlsx", ///
        if ((missing(HHK_debut) | trim(HHK_debut) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHK_debut) & trim(HHK_debut) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHK_debut renseigne hors univers" if ((!missing(HHK_debut) & trim(HHK_debut) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHK_debut) & trim(HHK_debut) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHK_debut) & trim(HHK_debut) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHK_debut commentaire source_regle action_proposee ///
        using "$document\12_K\HHK_debut_hors_univers.xlsx", ///
        if ((!missing(HHK_debut) & trim(HHK_debut) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* K1 - K1. Avez-vous personnellement deja cree votre propre activite generatrice de revenus, entreprise ou affaire quelle soit toujours active, quelle ait ferme depuis, ou quil sagisse de
* Type questionnaire : single-select
count if (missing(K1)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K1 manquant dans son univers" if (missing(K1)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(K1)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(K1)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district K1 commentaire source_regle action_proposee ///
        using "$document\12_K\K1_manquant.xlsx", ///
        if (missing(K1)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(K1)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K1 renseigne hors univers" if (!missing(K1)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(K1)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(K1)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district K1 commentaire source_regle action_proposee ///
        using "$document\12_K\K1_hors_univers.xlsx", ///
        if (!missing(K1)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(K1, 1, 2))) & (!missing(K1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K1 hors domaine questionnaire" if !((inlist(K1, 1, 2))) & (!missing(K1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(K1, 1, 2))) & (!missing(K1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(K1, 1, 2))) & (!missing(K1)) & ($audit_scope)
    export excel interview__key cover_district K1 commentaire source_regle action_proposee ///
        using "$document\12_K\K1_hors_domaine.xlsx", ///
        if !((inlist(K1, 1, 2))) & (!missing(K1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* K2 - K2. Souhaiteriez-vous creer votre propre activite generatrice de revenus ou entreprise a lavenir ?
* Type questionnaire : single-select
count if (missing(K2)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K2 manquant dans son univers" if (missing(K2)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(K2)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(K2)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)))) & ($audit_scope)
    export excel interview__key cover_district K2 commentaire source_regle action_proposee ///
        using "$document\12_K\K2_manquant.xlsx", ///
        if (missing(K2)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(K2)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K2 renseigne hors univers" if (!missing(K2)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(K2)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(K2)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)))) & ($audit_scope)
    export excel interview__key cover_district K2 commentaire source_regle action_proposee ///
        using "$document\12_K\K2_hors_univers.xlsx", ///
        if (!missing(K2)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(K2, 1, 2))) & (!missing(K2)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K2 hors domaine questionnaire" if !((inlist(K2, 1, 2))) & (!missing(K2)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(K2, 1, 2))) & (!missing(K2)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(K2, 1, 2))) & (!missing(K2)) & ($audit_scope)
    export excel interview__key cover_district K2 commentaire source_regle action_proposee ///
        using "$document\12_K\K2_hors_domaine.xlsx", ///
        if !((inlist(K2, 1, 2))) & (!missing(K2)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* K3 - K3. Quelle a ete la principale source dargent utilisee pour demarrer cette activite ?
* Type questionnaire : single-select
count if (missing(K3)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K3 manquant dans son univers" if (missing(K3)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(K3)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(K3)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district K3 commentaire source_regle action_proposee ///
        using "$document\12_K\K3_manquant.xlsx", ///
        if (missing(K3)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(K3)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K3 renseigne hors univers" if (!missing(K3)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(K3)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(K3)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district K3 commentaire source_regle action_proposee ///
        using "$document\12_K\K3_hors_univers.xlsx", ///
        if (!missing(K3)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(K3, 1, 2, 3, 4, 5, 6, 9))) & (!missing(K3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K3 hors domaine questionnaire" if !((inlist(K3, 1, 2, 3, 4, 5, 6, 9))) & (!missing(K3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(K3, 1, 2, 3, 4, 5, 6, 9))) & (!missing(K3)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(K3, 1, 2, 3, 4, 5, 6, 9))) & (!missing(K3)) & ($audit_scope)
    export excel interview__key cover_district K3 commentaire source_regle action_proposee ///
        using "$document\12_K\K3_hors_domaine.xlsx", ///
        if !((inlist(K3, 1, 2, 3, 4, 5, 6, 9))) & (!missing(K3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* K3X - K3X. Preciser l'autre source
* Type questionnaire : text
count if ((missing(K3X) | trim(K3X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K3) & (K3 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K3X manquant dans son univers" if ((missing(K3X) | trim(K3X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K3) & (K3 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(K3X) | trim(K3X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K3) & (K3 == 9)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(K3X) | trim(K3X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K3) & (K3 == 9)))) & ($audit_scope)
    export excel interview__key cover_district K3X commentaire source_regle action_proposee ///
        using "$document\12_K\K3X_manquant.xlsx", ///
        if ((missing(K3X) | trim(K3X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K3) & (K3 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(K3X) & trim(K3X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K3) & (K3 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K3X renseigne hors univers" if ((!missing(K3X) & trim(K3X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K3) & (K3 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(K3X) & trim(K3X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K3) & (K3 == 9)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(K3X) & trim(K3X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K3) & (K3 == 9)))) & ($audit_scope)
    export excel interview__key cover_district K3X commentaire source_regle action_proposee ///
        using "$document\12_K\K3X_hors_univers.xlsx", ///
        if ((!missing(K3X) & trim(K3X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K3) & (K3 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* K4 - K4. Quelle serait selon vous votre principale source de financement si vous deviez creer cette activite ?
* Type questionnaire : single-select
count if (missing(K4)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K4 manquant dans son univers" if (missing(K4)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(K4)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(K4)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
    export excel interview__key cover_district K4 commentaire source_regle action_proposee ///
        using "$document\12_K\K4_manquant.xlsx", ///
        if (missing(K4)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(K4)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K4 renseigne hors univers" if (!missing(K4)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(K4)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(K4)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
    export excel interview__key cover_district K4 commentaire source_regle action_proposee ///
        using "$document\12_K\K4_hors_univers.xlsx", ///
        if (!missing(K4)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(K4, 1, 2, 3, 4, 5, 6, 7, 9))) & (!missing(K4)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K4 hors domaine questionnaire" if !((inlist(K4, 1, 2, 3, 4, 5, 6, 7, 9))) & (!missing(K4)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(K4, 1, 2, 3, 4, 5, 6, 7, 9))) & (!missing(K4)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(K4, 1, 2, 3, 4, 5, 6, 7, 9))) & (!missing(K4)) & ($audit_scope)
    export excel interview__key cover_district K4 commentaire source_regle action_proposee ///
        using "$document\12_K\K4_hors_domaine.xlsx", ///
        if !((inlist(K4, 1, 2, 3, 4, 5, 6, 7, 9))) & (!missing(K4)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* K4X - K4X. Preciser l'autre source
* Type questionnaire : text
count if ((missing(K4X) | trim(K4X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K4) & (K4 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K4X manquant dans son univers" if ((missing(K4X) | trim(K4X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K4) & (K4 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(K4X) | trim(K4X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K4) & (K4 == 9)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(K4X) | trim(K4X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K4) & (K4 == 9)))) & ($audit_scope)
    export excel interview__key cover_district K4X commentaire source_regle action_proposee ///
        using "$document\12_K\K4X_manquant.xlsx", ///
        if ((missing(K4X) | trim(K4X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K4) & (K4 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(K4X) & trim(K4X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K4) & (K4 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K4X renseigne hors univers" if ((!missing(K4X) & trim(K4X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K4) & (K4 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(K4X) & trim(K4X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K4) & (K4 == 9)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(K4X) & trim(K4X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K4) & (K4 == 9)))) & ($audit_scope)
    export excel interview__key cover_district K4X commentaire source_regle action_proposee ///
        using "$document\12_K\K4X_hors_univers.xlsx", ///
        if ((!missing(K4X) & trim(K4X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K4) & (K4 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* K5 - K5. Quelles sont les principales raisons pour lesquelles vous navez pas encore cree cette activite ? (Plusieurs reponses possibles)
* Type questionnaire : multi-select
count if (missing(K5__1) & missing(K5__2) & missing(K5__3) & missing(K5__4) & missing(K5__5) & missing(K5__6) & missing(K5__7) & missing(K5__9)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K5 multi-select manquant dans son univers" if (missing(K5__1) & missing(K5__2) & missing(K5__3) & missing(K5__4) & missing(K5__5) & missing(K5__6) & missing(K5__7) & missing(K5__9)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(K5__1) & missing(K5__2) & missing(K5__3) & missing(K5__4) & missing(K5__5) & missing(K5__6) & missing(K5__7) & missing(K5__9)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(K5__1) & missing(K5__2) & missing(K5__3) & missing(K5__4) & missing(K5__5) & missing(K5__6) & missing(K5__7) & missing(K5__9)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
    export excel interview__key cover_district K5__1 K5__2 K5__3 K5__4 K5__5 K5__6 K5__7 K5__9 commentaire source_regle action_proposee ///
        using "$document\12_K\K5_manquant.xlsx", ///
        if (missing(K5__1) & missing(K5__2) & missing(K5__3) & missing(K5__4) & missing(K5__5) & missing(K5__6) & missing(K5__7) & missing(K5__9)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(K5__1) | !missing(K5__2) | !missing(K5__3) | !missing(K5__4) | !missing(K5__5) | !missing(K5__6) | !missing(K5__7) | !missing(K5__9)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K5 multi-select renseigne hors univers" if (!missing(K5__1) | !missing(K5__2) | !missing(K5__3) | !missing(K5__4) | !missing(K5__5) | !missing(K5__6) | !missing(K5__7) | !missing(K5__9)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(K5__1) | !missing(K5__2) | !missing(K5__3) | !missing(K5__4) | !missing(K5__5) | !missing(K5__6) | !missing(K5__7) | !missing(K5__9)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(K5__1) | !missing(K5__2) | !missing(K5__3) | !missing(K5__4) | !missing(K5__5) | !missing(K5__6) | !missing(K5__7) | !missing(K5__9)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope)
    export excel interview__key cover_district K5__1 K5__2 K5__3 K5__4 K5__5 K5__6 K5__7 K5__9 commentaire source_regle action_proposee ///
        using "$document\12_K\K5_hors_univers.xlsx", ///
        if (!missing(K5__1) | !missing(K5__2) | !missing(K5__3) | !missing(K5__4) | !missing(K5__5) | !missing(K5__6) | !missing(K5__7) | !missing(K5__9)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & ((!missing(K1) & (K1 == 2)) & (!missing(K2) & (K2 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(K5__1, 0, 1) & !missing(K5__1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K5__1 hors domaine 0/1" if !inlist(K5__1, 0, 1) & !missing(K5__1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(K5__1, 0, 1) & !missing(K5__1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(K5__1, 0, 1) & !missing(K5__1) & ($audit_scope)
    export excel interview__key cover_district K5__1 commentaire source_regle action_proposee ///
        using "$document\12_K\K5__1_hors_domaine.xlsx", ///
        if !inlist(K5__1, 0, 1) & !missing(K5__1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(K5__2, 0, 1) & !missing(K5__2) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K5__2 hors domaine 0/1" if !inlist(K5__2, 0, 1) & !missing(K5__2) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(K5__2, 0, 1) & !missing(K5__2) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(K5__2, 0, 1) & !missing(K5__2) & ($audit_scope)
    export excel interview__key cover_district K5__2 commentaire source_regle action_proposee ///
        using "$document\12_K\K5__2_hors_domaine.xlsx", ///
        if !inlist(K5__2, 0, 1) & !missing(K5__2) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(K5__3, 0, 1) & !missing(K5__3) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K5__3 hors domaine 0/1" if !inlist(K5__3, 0, 1) & !missing(K5__3) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(K5__3, 0, 1) & !missing(K5__3) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(K5__3, 0, 1) & !missing(K5__3) & ($audit_scope)
    export excel interview__key cover_district K5__3 commentaire source_regle action_proposee ///
        using "$document\12_K\K5__3_hors_domaine.xlsx", ///
        if !inlist(K5__3, 0, 1) & !missing(K5__3) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(K5__4, 0, 1) & !missing(K5__4) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K5__4 hors domaine 0/1" if !inlist(K5__4, 0, 1) & !missing(K5__4) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(K5__4, 0, 1) & !missing(K5__4) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(K5__4, 0, 1) & !missing(K5__4) & ($audit_scope)
    export excel interview__key cover_district K5__4 commentaire source_regle action_proposee ///
        using "$document\12_K\K5__4_hors_domaine.xlsx", ///
        if !inlist(K5__4, 0, 1) & !missing(K5__4) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(K5__5, 0, 1) & !missing(K5__5) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K5__5 hors domaine 0/1" if !inlist(K5__5, 0, 1) & !missing(K5__5) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(K5__5, 0, 1) & !missing(K5__5) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(K5__5, 0, 1) & !missing(K5__5) & ($audit_scope)
    export excel interview__key cover_district K5__5 commentaire source_regle action_proposee ///
        using "$document\12_K\K5__5_hors_domaine.xlsx", ///
        if !inlist(K5__5, 0, 1) & !missing(K5__5) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(K5__6, 0, 1) & !missing(K5__6) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K5__6 hors domaine 0/1" if !inlist(K5__6, 0, 1) & !missing(K5__6) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(K5__6, 0, 1) & !missing(K5__6) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(K5__6, 0, 1) & !missing(K5__6) & ($audit_scope)
    export excel interview__key cover_district K5__6 commentaire source_regle action_proposee ///
        using "$document\12_K\K5__6_hors_domaine.xlsx", ///
        if !inlist(K5__6, 0, 1) & !missing(K5__6) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(K5__7, 0, 1) & !missing(K5__7) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K5__7 hors domaine 0/1" if !inlist(K5__7, 0, 1) & !missing(K5__7) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(K5__7, 0, 1) & !missing(K5__7) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(K5__7, 0, 1) & !missing(K5__7) & ($audit_scope)
    export excel interview__key cover_district K5__7 commentaire source_regle action_proposee ///
        using "$document\12_K\K5__7_hors_domaine.xlsx", ///
        if !inlist(K5__7, 0, 1) & !missing(K5__7) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(K5__9, 0, 1) & !missing(K5__9) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K5__9 hors domaine 0/1" if !inlist(K5__9, 0, 1) & !missing(K5__9) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(K5__9, 0, 1) & !missing(K5__9) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(K5__9, 0, 1) & !missing(K5__9) & ($audit_scope)
    export excel interview__key cover_district K5__9 commentaire source_regle action_proposee ///
        using "$document\12_K\K5__9_hors_domaine.xlsx", ///
        if !inlist(K5__9, 0, 1) & !missing(K5__9) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* K5X - K5X. Preciser l'autre raison
* Type questionnaire : text
count if ((missing(K5X) | trim(K5X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & (((!missing(K5__9) & (K5__9 == 1))))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K5X manquant dans son univers" if ((missing(K5X) | trim(K5X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & (((!missing(K5__9) & (K5__9 == 1))))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(K5X) | trim(K5X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & (((!missing(K5__9) & (K5__9 == 1))))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(K5X) | trim(K5X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & (((!missing(K5__9) & (K5__9 == 1))))) & ($audit_scope)
    export excel interview__key cover_district K5X commentaire source_regle action_proposee ///
        using "$document\12_K\K5X_manquant.xlsx", ///
        if ((missing(K5X) | trim(K5X) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & (((!missing(K5__9) & (K5__9 == 1))))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(K5X) & trim(K5X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & (((!missing(K5__9) & (K5__9 == 1))))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K5X renseigne hors univers" if ((!missing(K5X) & trim(K5X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & (((!missing(K5__9) & (K5__9 == 1))))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(K5X) & trim(K5X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & (((!missing(K5__9) & (K5__9 == 1))))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(K5X) & trim(K5X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & (((!missing(K5__9) & (K5__9 == 1))))) & ($audit_scope)
    export excel interview__key cover_district K5X commentaire source_regle action_proposee ///
        using "$document\12_K\K5X_hors_univers.xlsx", ///
        if ((!missing(K5X) & trim(K5X) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1))) & (((!missing(K5__9) & (K5__9 == 1))))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* K6 - K6. Avez-vous deja recu une formation specifiquement en entrepreneuriat ou en gestion dentreprise (distincte dune formation technique/professionnelle) ?
* Type questionnaire : single-select
count if (missing(K6)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K6 manquant dans son univers" if (missing(K6)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(K6)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(K6)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district K6 commentaire source_regle action_proposee ///
        using "$document\12_K\K6_manquant.xlsx", ///
        if (missing(K6)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(K6)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K6 renseigne hors univers" if (!missing(K6)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(K6)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(K6)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district K6 commentaire source_regle action_proposee ///
        using "$document\12_K\K6_hors_univers.xlsx", ///
        if (!missing(K6)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(K6, 1, 2))) & (!missing(K6)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K6 hors domaine questionnaire" if !((inlist(K6, 1, 2))) & (!missing(K6)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(K6, 1, 2))) & (!missing(K6)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(K6, 1, 2))) & (!missing(K6)) & ($audit_scope)
    export excel interview__key cover_district K6 commentaire source_regle action_proposee ///
        using "$document\12_K\K6_hors_domaine.xlsx", ///
        if !((inlist(K6, 1, 2))) & (!missing(K6)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* K7 - K7. Comment evaluez-vous vos propres competences pour gerer une activite generatrice de revenus (par exemple : tenue de comptes de base, fixation des prix, gestion de la clientele)
* Type questionnaire : single-select
count if (missing(K7)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K7 manquant dans son univers" if (missing(K7)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(K7)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(K7)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district K7 commentaire source_regle action_proposee ///
        using "$document\12_K\K7_manquant.xlsx", ///
        if (missing(K7)) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(K7)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K7 renseigne hors univers" if (!missing(K7)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(K7)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(K7)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district K7 commentaire source_regle action_proposee ///
        using "$document\12_K\K7_hors_univers.xlsx", ///
        if (!missing(K7)) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(K7, 1, 2, 3, 4, 5))) & (!missing(K7)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "K7 hors domaine questionnaire" if !((inlist(K7, 1, 2, 3, 4, 5))) & (!missing(K7)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(K7, 1, 2, 3, 4, 5))) & (!missing(K7)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(K7, 1, 2, 3, 4, 5))) & (!missing(K7)) & ($audit_scope)
    export excel interview__key cover_district K7 commentaire source_regle action_proposee ///
        using "$document\12_K\K7_hors_domaine.xlsx", ///
        if !((inlist(K7, 1, 2, 3, 4, 5))) & (!missing(K7)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHK_fin - HHK_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHK_fin) | trim(HHK_fin) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHK_fin manquant dans son univers" if ((missing(HHK_fin) | trim(HHK_fin) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHK_fin) | trim(HHK_fin) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHK_fin) | trim(HHK_fin) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHK_fin commentaire source_regle action_proposee ///
        using "$document\12_K\HHK_fin_manquant.xlsx", ///
        if ((missing(HHK_fin) | trim(HHK_fin) == "")) & (((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHK_fin) & trim(HHK_fin) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHK_fin renseigne hors univers" if ((!missing(HHK_fin) & trim(HHK_fin) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHK_fin) & trim(HHK_fin) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHK_fin) & trim(HHK_fin) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHK_fin commentaire source_regle action_proposee ///
        using "$document\12_K\HHK_fin_hors_univers.xlsx", ///
        if ((!missing(HHK_fin) & trim(HHK_fin) != "")) & !(((!missing(HHI_fin) | !missing(HHJ_fin)) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHK_debut K1 K2 K3 K3X K4 K4X K5__1 K5__2 K5__3 K5__4 K5__5 K5__6 K5__7 K5__9 K5X K6 K7 HHK_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue K."
        exit 459
    }
    save "$section_output\12_K.dta", replace
restore

display as result "Controles section K termines."
