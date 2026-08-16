/*===========================================================================
  Section L. INCLUSION FINANCIERE & EPARGNE
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

cap mkdir "$document\13_L"

*---------------------------------------------------------------------------
* HHL_debut - HHL_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHL_debut) | trim(HHL_debut) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHL_debut manquant dans son univers" if ((missing(HHL_debut) | trim(HHL_debut) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHL_debut) | trim(HHL_debut) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHL_debut) | trim(HHL_debut) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHL_debut commentaire source_regle action_proposee ///
        using "$document\13_L\HHL_debut_manquant.xlsx", ///
        if ((missing(HHL_debut) | trim(HHL_debut) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHL_debut) & trim(HHL_debut) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHL_debut renseigne hors univers" if ((!missing(HHL_debut) & trim(HHL_debut) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHL_debut) & trim(HHL_debut) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHL_debut) & trim(HHL_debut) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHL_debut commentaire source_regle action_proposee ///
        using "$document\13_L\HHL_debut_hors_univers.xlsx", ///
        if ((!missing(HHL_debut) & trim(HHL_debut) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* L1 - L1. Possedez-vous un compte Mobile Money ?
* Type questionnaire : single-select
count if (missing(L1)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L1 manquant dans son univers" if (missing(L1)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(L1)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(L1)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district L1 commentaire source_regle action_proposee ///
        using "$document\13_L\L1_manquant.xlsx", ///
        if (missing(L1)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(L1)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L1 renseigne hors univers" if (!missing(L1)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(L1)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(L1)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district L1 commentaire source_regle action_proposee ///
        using "$document\13_L\L1_hors_univers.xlsx", ///
        if (!missing(L1)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(L1, 1, 2))) & (!missing(L1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L1 hors domaine questionnaire" if !((inlist(L1, 1, 2))) & (!missing(L1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(L1, 1, 2))) & (!missing(L1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(L1, 1, 2))) & (!missing(L1)) & ($audit_scope)
    export excel interview__key cover_district L1 commentaire source_regle action_proposee ///
        using "$document\13_L\L1_hors_domaine.xlsx", ///
        if !((inlist(L1, 1, 2))) & (!missing(L1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* L2 - L2. Possedez-vous un compte bancaire ?
* Type questionnaire : single-select
count if (missing(L2)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L2 manquant dans son univers" if (missing(L2)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(L2)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(L2)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district L2 commentaire source_regle action_proposee ///
        using "$document\13_L\L2_manquant.xlsx", ///
        if (missing(L2)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(L2)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L2 renseigne hors univers" if (!missing(L2)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(L2)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(L2)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district L2 commentaire source_regle action_proposee ///
        using "$document\13_L\L2_hors_univers.xlsx", ///
        if (!missing(L2)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(L2, 1, 2))) & (!missing(L2)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L2 hors domaine questionnaire" if !((inlist(L2, 1, 2))) & (!missing(L2)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(L2, 1, 2))) & (!missing(L2)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(L2, 1, 2))) & (!missing(L2)) & ($audit_scope)
    export excel interview__key cover_district L2 commentaire source_regle action_proposee ///
        using "$document\13_L\L2_hors_domaine.xlsx", ///
        if !((inlist(L2, 1, 2))) & (!missing(L2)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* L3 - L3. Mettez-vous regulierement de l'argent de cote (epargne) ?
* Type questionnaire : single-select
count if (missing(L3)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L3 manquant dans son univers" if (missing(L3)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(L3)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(L3)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district L3 commentaire source_regle action_proposee ///
        using "$document\13_L\L3_manquant.xlsx", ///
        if (missing(L3)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(L3)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L3 renseigne hors univers" if (!missing(L3)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(L3)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(L3)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district L3 commentaire source_regle action_proposee ///
        using "$document\13_L\L3_hors_univers.xlsx", ///
        if (!missing(L3)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(L3, 1, 2, 3))) & (!missing(L3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L3 hors domaine questionnaire" if !((inlist(L3, 1, 2, 3))) & (!missing(L3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(L3, 1, 2, 3))) & (!missing(L3)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(L3, 1, 2, 3))) & (!missing(L3)) & ($audit_scope)
    export excel interview__key cover_district L3 commentaire source_regle action_proposee ///
        using "$document\13_L\L3_hors_domaine.xlsx", ///
        if !((inlist(L3, 1, 2, 3))) & (!missing(L3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* L4 - L4. Environ combien metez-vous de cote dans uns mois typique ?
* Type questionnaire : numeric: integer
count if (missing(L4)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L4 manquant dans son univers" if (missing(L4)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(L4)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(L4)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
    export excel interview__key cover_district L4 commentaire source_regle action_proposee ///
        using "$document\13_L\L4_manquant.xlsx", ///
        if (missing(L4)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(L4)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L4 renseigne hors univers" if (!missing(L4)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(L4)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(L4)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
    export excel interview__key cover_district L4 commentaire source_regle action_proposee ///
        using "$document\13_L\L4_hors_univers.xlsx", ///
        if (!missing(L4)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (inlist(L4, 999998)) & (!missing(L4)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L4 contient un code special autorise" if (inlist(L4, 999998)) & (!missing(L4)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (inlist(L4, 999998)) & (!missing(L4)) & ($audit_scope)
    replace action_proposee = "recodage_analyse_a_valider" if (inlist(L4, 999998)) & (!missing(L4)) & ($audit_scope)
    export excel interview__key cover_district L4 commentaire source_regle action_proposee ///
        using "$document\13_L\L4_code_special.xlsx", ///
        if (inlist(L4, 999998)) & (!missing(L4)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* L5 - L5. Ou conservez-vous principalement votre epargne ?
* Type questionnaire : single-select
count if (missing(L5)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L5 manquant dans son univers" if (missing(L5)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(L5)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(L5)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
    export excel interview__key cover_district L5 commentaire source_regle action_proposee ///
        using "$document\13_L\L5_manquant.xlsx", ///
        if (missing(L5)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(L5)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L5 renseigne hors univers" if (!missing(L5)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(L5)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(L5)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope)
    export excel interview__key cover_district L5 commentaire source_regle action_proposee ///
        using "$document\13_L\L5_hors_univers.xlsx", ///
        if (!missing(L5)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L3) & (L3 == 1)) | (!missing(L3) & (L3 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(L5, 1, 2, 3, 4, 5))) & (!missing(L5)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L5 hors domaine questionnaire" if !((inlist(L5, 1, 2, 3, 4, 5))) & (!missing(L5)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(L5, 1, 2, 3, 4, 5))) & (!missing(L5)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(L5, 1, 2, 3, 4, 5))) & (!missing(L5)) & ($audit_scope)
    export excel interview__key cover_district L5 commentaire source_regle action_proposee ///
        using "$document\13_L\L5_hors_domaine.xlsx", ///
        if !((inlist(L5, 1, 2, 3, 4, 5))) & (!missing(L5)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* L5X - L5X. Precisez l'autre endroit ou vous epargnez
* Type questionnaire : text
count if ((missing(L5X) | trim(L5X) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L5) & (L5 == 5)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L5X manquant dans son univers" if ((missing(L5X) | trim(L5X) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L5) & (L5 == 5)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(L5X) | trim(L5X) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L5) & (L5 == 5)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(L5X) | trim(L5X) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L5) & (L5 == 5)))) & ($audit_scope)
    export excel interview__key cover_district L5X commentaire source_regle action_proposee ///
        using "$document\13_L\L5X_manquant.xlsx", ///
        if ((missing(L5X) | trim(L5X) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L5) & (L5 == 5)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(L5X) & trim(L5X) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L5) & (L5 == 5)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L5X renseigne hors univers" if ((!missing(L5X) & trim(L5X) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L5) & (L5 == 5)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(L5X) & trim(L5X) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L5) & (L5 == 5)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(L5X) & trim(L5X) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L5) & (L5 == 5)))) & ($audit_scope)
    export excel interview__key cover_district L5X commentaire source_regle action_proposee ///
        using "$document\13_L\L5X_hors_univers.xlsx", ///
        if ((!missing(L5X) & trim(L5X) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L5) & (L5 == 5)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* L6 - L6. Avez-vous actuellement un pret ou une dette en cours aupres dune banque, une institution de microfinance, un credit mobile money, une tontine/AVEC, la famille/des amis, ou tout
* Type questionnaire : single-select
count if (missing(L6)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L6 manquant dans son univers" if (missing(L6)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(L6)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(L6)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district L6 commentaire source_regle action_proposee ///
        using "$document\13_L\L6_manquant.xlsx", ///
        if (missing(L6)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(L6)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L6 renseigne hors univers" if (!missing(L6)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(L6)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(L6)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district L6 commentaire source_regle action_proposee ///
        using "$document\13_L\L6_hors_univers.xlsx", ///
        if (!missing(L6)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(L6, 1, 2))) & (!missing(L6)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L6 hors domaine questionnaire" if !((inlist(L6, 1, 2))) & (!missing(L6)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(L6, 1, 2))) & (!missing(L6)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(L6, 1, 2))) & (!missing(L6)) & ($audit_scope)
    export excel interview__key cover_district L6 commentaire source_regle action_proposee ///
        using "$document\13_L\L6_hors_domaine.xlsx", ///
        if !((inlist(L6, 1, 2))) & (!missing(L6)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* L7 - L7. Quelle est la principale source de ce pret/cette dette ?
* Type questionnaire : single-select
count if (missing(L7)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L7 manquant dans son univers" if (missing(L7)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(L7)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(L7)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    export excel interview__key cover_district L7 commentaire source_regle action_proposee ///
        using "$document\13_L\L7_manquant.xlsx", ///
        if (missing(L7)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(L7)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L7 renseigne hors univers" if (!missing(L7)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(L7)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(L7)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    export excel interview__key cover_district L7 commentaire source_regle action_proposee ///
        using "$document\13_L\L7_hors_univers.xlsx", ///
        if (!missing(L7)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(L7, 1, 2, 3, 4, 5, 6, 7, 9))) & (!missing(L7)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L7 hors domaine questionnaire" if !((inlist(L7, 1, 2, 3, 4, 5, 6, 7, 9))) & (!missing(L7)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(L7, 1, 2, 3, 4, 5, 6, 7, 9))) & (!missing(L7)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(L7, 1, 2, 3, 4, 5, 6, 7, 9))) & (!missing(L7)) & ($audit_scope)
    export excel interview__key cover_district L7 commentaire source_regle action_proposee ///
        using "$document\13_L\L7_hors_domaine.xlsx", ///
        if !((inlist(L7, 1, 2, 3, 4, 5, 6, 7, 9))) & (!missing(L7)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* L7X - L7X. Preciser l'autre source
* Type questionnaire : text
count if ((missing(L7X) | trim(L7X) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L7) & (L7 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L7X manquant dans son univers" if ((missing(L7X) | trim(L7X) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L7) & (L7 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(L7X) | trim(L7X) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L7) & (L7 == 9)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(L7X) | trim(L7X) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L7) & (L7 == 9)))) & ($audit_scope)
    export excel interview__key cover_district L7X commentaire source_regle action_proposee ///
        using "$document\13_L\L7X_manquant.xlsx", ///
        if ((missing(L7X) | trim(L7X) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L7) & (L7 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(L7X) & trim(L7X) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L7) & (L7 == 9)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L7X renseigne hors univers" if ((!missing(L7X) & trim(L7X) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L7) & (L7 == 9)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(L7X) & trim(L7X) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L7) & (L7 == 9)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(L7X) & trim(L7X) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L7) & (L7 == 9)))) & ($audit_scope)
    export excel interview__key cover_district L7X commentaire source_regle action_proposee ///
        using "$document\13_L\L7X_hors_univers.xlsx", ///
        if ((!missing(L7X) & trim(L7X) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L7) & (L7 == 9)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* L8 - L8. Environ combien devez-vous au total actuellement ?
* Type questionnaire : numeric: integer
count if (missing(L8)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L8 manquant dans son univers" if (missing(L8)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(L8)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(L8)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    export excel interview__key cover_district L8 commentaire source_regle action_proposee ///
        using "$document\13_L\L8_manquant.xlsx", ///
        if (missing(L8)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(L8)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L8 renseigne hors univers" if (!missing(L8)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(L8)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(L8)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    export excel interview__key cover_district L8 commentaire source_regle action_proposee ///
        using "$document\13_L\L8_hors_univers.xlsx", ///
        if (!missing(L8)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (inlist(L8, 99998)) & (!missing(L8)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L8 contient un code special autorise" if (inlist(L8, 99998)) & (!missing(L8)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (inlist(L8, 99998)) & (!missing(L8)) & ($audit_scope)
    replace action_proposee = "recodage_analyse_a_valider" if (inlist(L8, 99998)) & (!missing(L8)) & ($audit_scope)
    export excel interview__key cover_district L8 commentaire source_regle action_proposee ///
        using "$document\13_L\L8_code_special.xlsx", ///
        if (inlist(L8, 99998)) & (!missing(L8)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* L9 - L9. Quel etait le principal motif de ce pret ?
* Type questionnaire : single-select
count if (missing(L9)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L9 manquant dans son univers" if (missing(L9)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(L9)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(L9)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    export excel interview__key cover_district L9 commentaire source_regle action_proposee ///
        using "$document\13_L\L9_manquant.xlsx", ///
        if (missing(L9)) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(L9)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L9 renseigne hors univers" if (!missing(L9)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(L9)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(L9)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope)
    export excel interview__key cover_district L9 commentaire source_regle action_proposee ///
        using "$document\13_L\L9_hors_univers.xlsx", ///
        if (!missing(L9)) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(L6) & (L6 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(L9, 1, 2, 3, 4, 5, 9))) & (!missing(L9)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "L9 hors domaine questionnaire" if !((inlist(L9, 1, 2, 3, 4, 5, 9))) & (!missing(L9)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(L9, 1, 2, 3, 4, 5, 9))) & (!missing(L9)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(L9, 1, 2, 3, 4, 5, 9))) & (!missing(L9)) & ($audit_scope)
    export excel interview__key cover_district L9 commentaire source_regle action_proposee ///
        using "$document\13_L\L9_hors_domaine.xlsx", ///
        if !((inlist(L9, 1, 2, 3, 4, 5, 9))) & (!missing(L9)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHL_fin - HHL_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHL_fin) | trim(HHL_fin) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHL_fin manquant dans son univers" if ((missing(HHL_fin) | trim(HHL_fin) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHL_fin) | trim(HHL_fin) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHL_fin) | trim(HHL_fin) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHL_fin commentaire source_regle action_proposee ///
        using "$document\13_L\HHL_fin_manquant.xlsx", ///
        if ((missing(HHL_fin) | trim(HHL_fin) == "")) & ((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHL_fin) & trim(HHL_fin) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHL_fin renseigne hors univers" if ((!missing(HHL_fin) & trim(HHL_fin) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHL_fin) & trim(HHL_fin) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHL_fin) & trim(HHL_fin) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHL_fin commentaire source_regle action_proposee ///
        using "$document\13_L\HHL_fin_hors_univers.xlsx", ///
        if ((!missing(HHL_fin) & trim(HHL_fin) != "")) & !((!missing(HHK_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHL_debut L1 L2 L3 L4 L5 L5X L6 L7 L7X L8 L9 HHL_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue L."
        exit 459
    }
    save "$section_output\13_L.dta", replace
restore

display as result "Controles section L termines."
