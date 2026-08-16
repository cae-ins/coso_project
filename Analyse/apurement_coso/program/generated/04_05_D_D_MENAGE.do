/*===========================================================================
  Section D. MENAGE
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

cap mkdir "$document\05_D"

*---------------------------------------------------------------------------
* HHD_debut - HHD_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHD_debut) | trim(HHD_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHD_debut manquant dans son univers" if ((missing(HHD_debut) | trim(HHD_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHD_debut) | trim(HHD_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHD_debut) | trim(HHD_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district HHD_debut commentaire source_regle action_proposee ///
        using "$document\05_D\HHD_debut_manquant.xlsx", ///
        if ((missing(HHD_debut) | trim(HHD_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHD_debut) & trim(HHD_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHD_debut renseigne hors univers" if ((!missing(HHD_debut) & trim(HHD_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHD_debut) & trim(HHD_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHD_debut) & trim(HHD_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district HHD_debut commentaire source_regle action_proposee ///
        using "$document\05_D\HHD_debut_hors_univers.xlsx", ///
        if ((!missing(HHD_debut) & trim(HHD_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* D1 - D1. Combien de personnes vivent habituellement dans votre menage ?
* Type questionnaire : numeric: integer
count if (missing(D1)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D1 manquant dans son univers" if (missing(D1)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(D1)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(D1)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district D1 commentaire source_regle action_proposee ///
        using "$document\05_D\D1_manquant.xlsx", ///
        if (missing(D1)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(D1)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D1 renseigne hors univers" if (!missing(D1)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(D1)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(D1)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district D1 commentaire source_regle action_proposee ///
        using "$document\05_D\D1_hors_univers.xlsx", ///
        if (!missing(D1)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* D2 - D2. Combien ont moins de 15 ans ?
* Type questionnaire : numeric: integer
count if (missing(D2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D2 manquant dans son univers" if (missing(D2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(D2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(D2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district D2 commentaire source_regle action_proposee ///
        using "$document\05_D\D2_manquant.xlsx", ///
        if (missing(D2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(D2)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D2 renseigne hors univers" if (!missing(D2)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(D2)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(D2)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district D2 commentaire source_regle action_proposee ///
        using "$document\05_D\D2_hors_univers.xlsx", ///
        if (!missing(D2)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(D2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & !((!missing(D2) & !missing(D1) & (D2 < D1))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D2 viole la validation questionnaire 1" if (!missing(D2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & !((!missing(D2) & !missing(D1) & (D2 < D1))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(D2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & !((!missing(D2) & !missing(D1) & (D2 < D1))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (!missing(D2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & !((!missing(D2) & !missing(D1) & (D2 < D1))) & ($audit_scope)
    export excel interview__key cover_district D2 commentaire source_regle action_proposee ///
        using "$document\05_D\D2_validation_1.xlsx", ///
        if (!missing(D2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & !((!missing(D2) & !missing(D1) & (D2 < D1))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* D3 - D3. Quel est votre lien avec le chef de menage ?
* Type questionnaire : single-select
count if (missing(D3)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D3 manquant dans son univers" if (missing(D3)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(D3)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(D3)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district D3 commentaire source_regle action_proposee ///
        using "$document\05_D\D3_manquant.xlsx", ///
        if (missing(D3)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(D3)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D3 renseigne hors univers" if (!missing(D3)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(D3)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(D3)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district D3 commentaire source_regle action_proposee ///
        using "$document\05_D\D3_hors_univers.xlsx", ///
        if (!missing(D3)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(D3, 1, 2, 3, 4, 5, 6, 7))) & (!missing(D3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D3 hors domaine questionnaire" if !((inlist(D3, 1, 2, 3, 4, 5, 6, 7))) & (!missing(D3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(D3, 1, 2, 3, 4, 5, 6, 7))) & (!missing(D3)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(D3, 1, 2, 3, 4, 5, 6, 7))) & (!missing(D3)) & ($audit_scope)
    export excel interview__key cover_district D3 commentaire source_regle action_proposee ///
        using "$document\05_D\D3_hors_domaine.xlsx", ///
        if !((inlist(D3, 1, 2, 3, 4, 5, 6, 7))) & (!missing(D3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* D3X - D3X. Preciser l'autre lien de parente avec le chef de menage ?
* Type questionnaire : text
count if ((missing(D3X) | trim(D3X) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin)) & ((!missing(D3) & (D3 == 7)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D3X manquant dans son univers" if ((missing(D3X) | trim(D3X) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin)) & ((!missing(D3) & (D3 == 7)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(D3X) | trim(D3X) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin)) & ((!missing(D3) & (D3 == 7)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(D3X) | trim(D3X) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin)) & ((!missing(D3) & (D3 == 7)))) & ($audit_scope)
    export excel interview__key cover_district D3X commentaire source_regle action_proposee ///
        using "$document\05_D\D3X_manquant.xlsx", ///
        if ((missing(D3X) | trim(D3X) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin)) & ((!missing(D3) & (D3 == 7)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(D3X) & trim(D3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin)) & ((!missing(D3) & (D3 == 7)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D3X renseigne hors univers" if ((!missing(D3X) & trim(D3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin)) & ((!missing(D3) & (D3 == 7)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(D3X) & trim(D3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin)) & ((!missing(D3) & (D3 == 7)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(D3X) & trim(D3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin)) & ((!missing(D3) & (D3 == 7)))) & ($audit_scope)
    export excel interview__key cover_district D3X commentaire source_regle action_proposee ///
        using "$document\05_D\D3X_hors_univers.xlsx", ///
        if ((!missing(D3X) & trim(D3X) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin)) & ((!missing(D3) & (D3 == 7)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* D4 - D4. Combien de personnes du menages exercent une activite renumeree
* Type questionnaire : numeric: integer
count if (missing(D4)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D4 manquant dans son univers" if (missing(D4)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(D4)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(D4)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district D4 commentaire source_regle action_proposee ///
        using "$document\05_D\D4_manquant.xlsx", ///
        if (missing(D4)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(D4)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D4 renseigne hors univers" if (!missing(D4)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(D4)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(D4)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district D4 commentaire source_regle action_proposee ///
        using "$document\05_D\D4_hors_univers.xlsx", ///
        if (!missing(D4)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* D5 - D5. Parmi les biens suivants,lesquels sont possedes par votre menage et sont fonctinnels?
* Type questionnaire : multi-select
count if (missing(D5__1) & missing(D5__2) & missing(D5__3) & missing(D5__4) & missing(D5__5) & missing(D5__6) & missing(D5__7) & missing(D5__8) & missing(D5__9) & missing(D5__10) & missing(D5__11)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5 multi-select manquant dans son univers" if (missing(D5__1) & missing(D5__2) & missing(D5__3) & missing(D5__4) & missing(D5__5) & missing(D5__6) & missing(D5__7) & missing(D5__8) & missing(D5__9) & missing(D5__10) & missing(D5__11)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(D5__1) & missing(D5__2) & missing(D5__3) & missing(D5__4) & missing(D5__5) & missing(D5__6) & missing(D5__7) & missing(D5__8) & missing(D5__9) & missing(D5__10) & missing(D5__11)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(D5__1) & missing(D5__2) & missing(D5__3) & missing(D5__4) & missing(D5__5) & missing(D5__6) & missing(D5__7) & missing(D5__8) & missing(D5__9) & missing(D5__10) & missing(D5__11)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district D5__1 D5__2 D5__3 D5__4 D5__5 D5__6 D5__7 D5__8 D5__9 D5__10 D5__11 commentaire source_regle action_proposee ///
        using "$document\05_D\D5_manquant.xlsx", ///
        if (missing(D5__1) & missing(D5__2) & missing(D5__3) & missing(D5__4) & missing(D5__5) & missing(D5__6) & missing(D5__7) & missing(D5__8) & missing(D5__9) & missing(D5__10) & missing(D5__11)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(D5__1) | !missing(D5__2) | !missing(D5__3) | !missing(D5__4) | !missing(D5__5) | !missing(D5__6) | !missing(D5__7) | !missing(D5__8) | !missing(D5__9) | !missing(D5__10) | !missing(D5__11)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5 multi-select renseigne hors univers" if (!missing(D5__1) | !missing(D5__2) | !missing(D5__3) | !missing(D5__4) | !missing(D5__5) | !missing(D5__6) | !missing(D5__7) | !missing(D5__8) | !missing(D5__9) | !missing(D5__10) | !missing(D5__11)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(D5__1) | !missing(D5__2) | !missing(D5__3) | !missing(D5__4) | !missing(D5__5) | !missing(D5__6) | !missing(D5__7) | !missing(D5__8) | !missing(D5__9) | !missing(D5__10) | !missing(D5__11)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(D5__1) | !missing(D5__2) | !missing(D5__3) | !missing(D5__4) | !missing(D5__5) | !missing(D5__6) | !missing(D5__7) | !missing(D5__8) | !missing(D5__9) | !missing(D5__10) | !missing(D5__11)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district D5__1 D5__2 D5__3 D5__4 D5__5 D5__6 D5__7 D5__8 D5__9 D5__10 D5__11 commentaire source_regle action_proposee ///
        using "$document\05_D\D5_hors_univers.xlsx", ///
        if (!missing(D5__1) | !missing(D5__2) | !missing(D5__3) | !missing(D5__4) | !missing(D5__5) | !missing(D5__6) | !missing(D5__7) | !missing(D5__8) | !missing(D5__9) | !missing(D5__10) | !missing(D5__11)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(D5__1, 0, 1) & !missing(D5__1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5__1 hors domaine 0/1" if !inlist(D5__1, 0, 1) & !missing(D5__1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(D5__1, 0, 1) & !missing(D5__1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(D5__1, 0, 1) & !missing(D5__1) & ($audit_scope)
    export excel interview__key cover_district D5__1 commentaire source_regle action_proposee ///
        using "$document\05_D\D5__1_hors_domaine.xlsx", ///
        if !inlist(D5__1, 0, 1) & !missing(D5__1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(D5__2, 0, 1) & !missing(D5__2) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5__2 hors domaine 0/1" if !inlist(D5__2, 0, 1) & !missing(D5__2) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(D5__2, 0, 1) & !missing(D5__2) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(D5__2, 0, 1) & !missing(D5__2) & ($audit_scope)
    export excel interview__key cover_district D5__2 commentaire source_regle action_proposee ///
        using "$document\05_D\D5__2_hors_domaine.xlsx", ///
        if !inlist(D5__2, 0, 1) & !missing(D5__2) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(D5__3, 0, 1) & !missing(D5__3) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5__3 hors domaine 0/1" if !inlist(D5__3, 0, 1) & !missing(D5__3) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(D5__3, 0, 1) & !missing(D5__3) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(D5__3, 0, 1) & !missing(D5__3) & ($audit_scope)
    export excel interview__key cover_district D5__3 commentaire source_regle action_proposee ///
        using "$document\05_D\D5__3_hors_domaine.xlsx", ///
        if !inlist(D5__3, 0, 1) & !missing(D5__3) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(D5__4, 0, 1) & !missing(D5__4) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5__4 hors domaine 0/1" if !inlist(D5__4, 0, 1) & !missing(D5__4) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(D5__4, 0, 1) & !missing(D5__4) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(D5__4, 0, 1) & !missing(D5__4) & ($audit_scope)
    export excel interview__key cover_district D5__4 commentaire source_regle action_proposee ///
        using "$document\05_D\D5__4_hors_domaine.xlsx", ///
        if !inlist(D5__4, 0, 1) & !missing(D5__4) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(D5__5, 0, 1) & !missing(D5__5) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5__5 hors domaine 0/1" if !inlist(D5__5, 0, 1) & !missing(D5__5) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(D5__5, 0, 1) & !missing(D5__5) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(D5__5, 0, 1) & !missing(D5__5) & ($audit_scope)
    export excel interview__key cover_district D5__5 commentaire source_regle action_proposee ///
        using "$document\05_D\D5__5_hors_domaine.xlsx", ///
        if !inlist(D5__5, 0, 1) & !missing(D5__5) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(D5__6, 0, 1) & !missing(D5__6) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5__6 hors domaine 0/1" if !inlist(D5__6, 0, 1) & !missing(D5__6) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(D5__6, 0, 1) & !missing(D5__6) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(D5__6, 0, 1) & !missing(D5__6) & ($audit_scope)
    export excel interview__key cover_district D5__6 commentaire source_regle action_proposee ///
        using "$document\05_D\D5__6_hors_domaine.xlsx", ///
        if !inlist(D5__6, 0, 1) & !missing(D5__6) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(D5__7, 0, 1) & !missing(D5__7) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5__7 hors domaine 0/1" if !inlist(D5__7, 0, 1) & !missing(D5__7) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(D5__7, 0, 1) & !missing(D5__7) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(D5__7, 0, 1) & !missing(D5__7) & ($audit_scope)
    export excel interview__key cover_district D5__7 commentaire source_regle action_proposee ///
        using "$document\05_D\D5__7_hors_domaine.xlsx", ///
        if !inlist(D5__7, 0, 1) & !missing(D5__7) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(D5__8, 0, 1) & !missing(D5__8) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5__8 hors domaine 0/1" if !inlist(D5__8, 0, 1) & !missing(D5__8) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(D5__8, 0, 1) & !missing(D5__8) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(D5__8, 0, 1) & !missing(D5__8) & ($audit_scope)
    export excel interview__key cover_district D5__8 commentaire source_regle action_proposee ///
        using "$document\05_D\D5__8_hors_domaine.xlsx", ///
        if !inlist(D5__8, 0, 1) & !missing(D5__8) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(D5__9, 0, 1) & !missing(D5__9) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5__9 hors domaine 0/1" if !inlist(D5__9, 0, 1) & !missing(D5__9) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(D5__9, 0, 1) & !missing(D5__9) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(D5__9, 0, 1) & !missing(D5__9) & ($audit_scope)
    export excel interview__key cover_district D5__9 commentaire source_regle action_proposee ///
        using "$document\05_D\D5__9_hors_domaine.xlsx", ///
        if !inlist(D5__9, 0, 1) & !missing(D5__9) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(D5__10, 0, 1) & !missing(D5__10) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5__10 hors domaine 0/1" if !inlist(D5__10, 0, 1) & !missing(D5__10) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(D5__10, 0, 1) & !missing(D5__10) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(D5__10, 0, 1) & !missing(D5__10) & ($audit_scope)
    export excel interview__key cover_district D5__10 commentaire source_regle action_proposee ///
        using "$document\05_D\D5__10_hors_domaine.xlsx", ///
        if !inlist(D5__10, 0, 1) & !missing(D5__10) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !inlist(D5__11, 0, 1) & !missing(D5__11) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5__11 hors domaine 0/1" if !inlist(D5__11, 0, 1) & !missing(D5__11) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !inlist(D5__11, 0, 1) & !missing(D5__11) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !inlist(D5__11, 0, 1) & !missing(D5__11) & ($audit_scope)
    export excel interview__key cover_district D5__11 commentaire source_regle action_proposee ///
        using "$document\05_D\D5__11_hors_domaine.xlsx", ///
        if !inlist(D5__11, 0, 1) & !missing(D5__11) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(D5__1) | !missing(D5__2) | !missing(D5__3) | !missing(D5__4) | !missing(D5__5) | !missing(D5__6) | !missing(D5__7) | !missing(D5__8) | !missing(D5__9) | !missing(D5__10) | !missing(D5__11)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & !(!(((!missing(D5__11) & (D5__11 == 1))) & (D5__1 + D5__2 + D5__3 + D5__4 + D5__5 + D5__6 + D5__7 + D5__8 + D5__9 + D5__10 + D5__11) > 1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "D5 viole la validation questionnaire 1" if (!missing(D5__1) | !missing(D5__2) | !missing(D5__3) | !missing(D5__4) | !missing(D5__5) | !missing(D5__6) | !missing(D5__7) | !missing(D5__8) | !missing(D5__9) | !missing(D5__10) | !missing(D5__11)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & !(!(((!missing(D5__11) & (D5__11 == 1))) & (D5__1 + D5__2 + D5__3 + D5__4 + D5__5 + D5__6 + D5__7 + D5__8 + D5__9 + D5__10 + D5__11) > 1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(D5__1) | !missing(D5__2) | !missing(D5__3) | !missing(D5__4) | !missing(D5__5) | !missing(D5__6) | !missing(D5__7) | !missing(D5__8) | !missing(D5__9) | !missing(D5__10) | !missing(D5__11)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & !(!(((!missing(D5__11) & (D5__11 == 1))) & (D5__1 + D5__2 + D5__3 + D5__4 + D5__5 + D5__6 + D5__7 + D5__8 + D5__9 + D5__10 + D5__11) > 1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (!missing(D5__1) | !missing(D5__2) | !missing(D5__3) | !missing(D5__4) | !missing(D5__5) | !missing(D5__6) | !missing(D5__7) | !missing(D5__8) | !missing(D5__9) | !missing(D5__10) | !missing(D5__11)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & !(!(((!missing(D5__11) & (D5__11 == 1))) & (D5__1 + D5__2 + D5__3 + D5__4 + D5__5 + D5__6 + D5__7 + D5__8 + D5__9 + D5__10 + D5__11) > 1)) & ($audit_scope)
    export excel interview__key cover_district D5__1 D5__2 D5__3 D5__4 D5__5 D5__6 D5__7 D5__8 D5__9 D5__10 D5__11 commentaire source_regle action_proposee ///
        using "$document\05_D\D5_validation_1.xlsx", ///
        if (!missing(D5__1) | !missing(D5__2) | !missing(D5__3) | !missing(D5__4) | !missing(D5__5) | !missing(D5__6) | !missing(D5__7) | !missing(D5__8) | !missing(D5__9) | !missing(D5__10) | !missing(D5__11)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & !(!(((!missing(D5__11) & (D5__11 == 1))) & (D5__1 + D5__2 + D5__3 + D5__4 + D5__5 + D5__6 + D5__7 + D5__8 + D5__9 + D5__10 + D5__11) > 1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHD_fin - HHD_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHD_fin) | trim(HHD_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHD_fin manquant dans son univers" if ((missing(HHD_fin) | trim(HHD_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHD_fin) | trim(HHD_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHD_fin) | trim(HHD_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district HHD_fin commentaire source_regle action_proposee ///
        using "$document\05_D\HHD_fin_manquant.xlsx", ///
        if ((missing(HHD_fin) | trim(HHD_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHD_fin) & trim(HHD_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHD_fin renseigne hors univers" if ((!missing(HHD_fin) & trim(HHD_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHD_fin) & trim(HHD_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHD_fin) & trim(HHD_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope)
    export excel interview__key cover_district HHD_fin commentaire source_regle action_proposee ///
        using "$document\05_D\HHD_fin_hors_univers.xlsx", ///
        if ((!missing(HHD_fin) & trim(HHD_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHC_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHD_debut D1 D2 D3 D3X D4 D5__1 D5__2 D5__3 D5__4 D5__5 D5__6 D5__7 D5__8 D5__9 D5__10 D5__11 HHD_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue D."
        exit 459
    }
    save "$section_output\05_D.dta", replace
restore

display as result "Controles section D termines."
