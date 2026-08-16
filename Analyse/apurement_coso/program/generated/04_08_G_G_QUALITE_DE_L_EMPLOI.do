/*===========================================================================
  Section G. QUALITE DE L'EMPLOI
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

cap mkdir "$document\08_G"

*---------------------------------------------------------------------------
* HHG_debut - HHG_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHG_debut) | trim(HHG_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHG_debut manquant dans son univers" if ((missing(HHG_debut) | trim(HHG_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHG_debut) | trim(HHG_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHG_debut) | trim(HHG_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHG_debut commentaire source_regle action_proposee ///
        using "$document\08_G\HHG_debut_manquant.xlsx", ///
        if ((missing(HHG_debut) | trim(HHG_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHG_debut) & trim(HHG_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHG_debut renseigne hors univers" if ((!missing(HHG_debut) & trim(HHG_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHG_debut) & trim(HHG_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHG_debut) & trim(HHG_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHG_debut commentaire source_regle action_proposee ///
        using "$document\08_G\HHG_debut_hors_univers.xlsx", ///
        if ((!missing(HHG_debut) & trim(HHG_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* G1 - G1. Disposez-vous dun contrat de travail ?
* Type questionnaire : single-select
count if (missing(G1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G1 manquant dans son univers" if (missing(G1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(G1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(G1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district G1 commentaire source_regle action_proposee ///
        using "$document\08_G\G1_manquant.xlsx", ///
        if (missing(G1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(G1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G1 renseigne hors univers" if (!missing(G1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(G1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(G1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district G1 commentaire source_regle action_proposee ///
        using "$document\08_G\G1_hors_univers.xlsx", ///
        if (!missing(G1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(G1, 1, 2, 3, 4, 5))) & (!missing(G1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G1 hors domaine questionnaire" if !((inlist(G1, 1, 2, 3, 4, 5))) & (!missing(G1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(G1, 1, 2, 3, 4, 5))) & (!missing(G1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(G1, 1, 2, 3, 4, 5))) & (!missing(G1)) & ($audit_scope)
    export excel interview__key cover_district G1 commentaire source_regle action_proposee ///
        using "$document\08_G\G1_hors_domaine.xlsx", ///
        if !((inlist(G1, 1, 2, 3, 4, 5))) & (!missing(G1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* G2 - G2. Beneficiez-vous dune couverture sociale liee a cet emploi ?
* Type questionnaire : single-select
count if (missing(G2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G2 manquant dans son univers" if (missing(G2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(G2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(G2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district G2 commentaire source_regle action_proposee ///
        using "$document\08_G\G2_manquant.xlsx", ///
        if (missing(G2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(G2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G2 renseigne hors univers" if (!missing(G2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(G2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(G2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district G2 commentaire source_regle action_proposee ///
        using "$document\08_G\G2_hors_univers.xlsx", ///
        if (!missing(G2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(G2, 1, 2))) & (!missing(G2)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G2 hors domaine questionnaire" if !((inlist(G2, 1, 2))) & (!missing(G2)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(G2, 1, 2))) & (!missing(G2)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(G2, 1, 2))) & (!missing(G2)) & ($audit_scope)
    export excel interview__key cover_district G2 commentaire source_regle action_proposee ///
        using "$document\08_G\G2_hors_domaine.xlsx", ///
        if !((inlist(G2, 1, 2))) & (!missing(G2)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* G3 - G3. Combien dheures avez-vous travaille dans cet emploi principal la semaine derniere ?
* Type questionnaire : numeric: decimal
count if (missing(G3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G3 manquant dans son univers" if (missing(G3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(G3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(G3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district G3 commentaire source_regle action_proposee ///
        using "$document\08_G\G3_manquant.xlsx", ///
        if (missing(G3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(G3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G3 renseigne hors univers" if (!missing(G3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(G3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(G3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district G3 commentaire source_regle action_proposee ///
        using "$document\08_G\G3_hors_univers.xlsx", ///
        if (!missing(G3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (inlist(G3, 998)) & (!missing(G3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G3 contient un code special autorise" if (inlist(G3, 998)) & (!missing(G3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (inlist(G3, 998)) & (!missing(G3)) & ($audit_scope)
    replace action_proposee = "recodage_analyse_a_valider" if (inlist(G3, 998)) & (!missing(G3)) & ($audit_scope)
    export excel interview__key cover_district G3 commentaire source_regle action_proposee ///
        using "$document\08_G\G3_code_special.xlsx", ///
        if (inlist(G3, 998)) & (!missing(G3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* G4 - G4. Est-ce le nombre dheures que vous travaillez habituellement dans cet emploi ?
* Type questionnaire : single-select
count if (missing(G4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G4 manquant dans son univers" if (missing(G4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(G4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(G4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district G4 commentaire source_regle action_proposee ///
        using "$document\08_G\G4_manquant.xlsx", ///
        if (missing(G4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(G4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G4 renseigne hors univers" if (!missing(G4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(G4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(G4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district G4 commentaire source_regle action_proposee ///
        using "$document\08_G\G4_hors_univers.xlsx", ///
        if (!missing(G4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(G4, 1, 2))) & (!missing(G4)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G4 hors domaine questionnaire" if !((inlist(G4, 1, 2))) & (!missing(G4)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(G4, 1, 2))) & (!missing(G4)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(G4, 1, 2))) & (!missing(G4)) & ($audit_scope)
    export excel interview__key cover_district G4 commentaire source_regle action_proposee ///
        using "$document\08_G\G4_hors_domaine.xlsx", ///
        if !((inlist(G4, 1, 2))) & (!missing(G4)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* G4A - G4A. Si non, combien d'heures avez-vous effectivement travaille ?
* Type questionnaire : numeric: integer
count if (missing(G4A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G4) & (G4 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G4A manquant dans son univers" if (missing(G4A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G4) & (G4 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(G4A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G4) & (G4 == 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(G4A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G4) & (G4 == 2)))) & ($audit_scope)
    export excel interview__key cover_district G4A commentaire source_regle action_proposee ///
        using "$document\08_G\G4A_manquant.xlsx", ///
        if (missing(G4A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G4) & (G4 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(G4A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G4) & (G4 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G4A renseigne hors univers" if (!missing(G4A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G4) & (G4 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(G4A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G4) & (G4 == 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(G4A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G4) & (G4 == 2)))) & ($audit_scope)
    export excel interview__key cover_district G4A commentaire source_regle action_proposee ///
        using "$document\08_G\G4A_hors_univers.xlsx", ///
        if (!missing(G4A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G4) & (G4 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* G5 - G5. Avez-vous un autre emploi ou une autre activite generatrice de revenus en plus de celui-ci ?
* Type questionnaire : single-select
count if (missing(G5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G5 manquant dans son univers" if (missing(G5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(G5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(G5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district G5 commentaire source_regle action_proposee ///
        using "$document\08_G\G5_manquant.xlsx", ///
        if (missing(G5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(G5)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G5 renseigne hors univers" if (!missing(G5)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(G5)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(G5)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district G5 commentaire source_regle action_proposee ///
        using "$document\08_G\G5_hors_univers.xlsx", ///
        if (!missing(G5)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(G5, 1, 2))) & (!missing(G5)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G5 hors domaine questionnaire" if !((inlist(G5, 1, 2))) & (!missing(G5)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(G5, 1, 2))) & (!missing(G5)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(G5, 1, 2))) & (!missing(G5)) & ($audit_scope)
    export excel interview__key cover_district G5 commentaire source_regle action_proposee ///
        using "$document\08_G\G5_hors_domaine.xlsx", ///
        if !((inlist(G5, 1, 2))) & (!missing(G5)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* G5A - G5A. De quelle activite s'agit-il ?
* Type questionnaire : text
count if ((missing(G5A) | trim(G5A) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G5A manquant dans son univers" if ((missing(G5A) | trim(G5A) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(G5A) | trim(G5A) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(G5A) | trim(G5A) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
    export excel interview__key cover_district G5A commentaire source_regle action_proposee ///
        using "$document\08_G\G5A_manquant.xlsx", ///
        if ((missing(G5A) | trim(G5A) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(G5A) & trim(G5A) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G5A renseigne hors univers" if ((!missing(G5A) & trim(G5A) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(G5A) & trim(G5A) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(G5A) & trim(G5A) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
    export excel interview__key cover_district G5A commentaire source_regle action_proposee ///
        using "$document\08_G\G5A_hors_univers.xlsx", ///
        if ((!missing(G5A) & trim(G5A) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* G6 - G6. Combien dheures par semaine consacrez-vous a cet/ces autre(s) emploi(s)/activite(s) ?
* Type questionnaire : numeric: decimal
count if (missing(G6)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G6 manquant dans son univers" if (missing(G6)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(G6)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(G6)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
    export excel interview__key cover_district G6 commentaire source_regle action_proposee ///
        using "$document\08_G\G6_manquant.xlsx", ///
        if (missing(G6)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(G6)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G6 renseigne hors univers" if (!missing(G6)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(G6)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(G6)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope)
    export excel interview__key cover_district G6 commentaire source_regle action_proposee ///
        using "$document\08_G\G6_hors_univers.xlsx", ///
        if (!missing(G6)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G5) & (G5 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* G7 - G7. En tenant compte de tout votre travail cet emploi et tout autre Au cours des 30 derniers jours, auriez-vous voulu travailler plus d'heures par semaine que d'habitude, a conditi
* Type questionnaire : single-select
count if (missing(G7)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G7 manquant dans son univers" if (missing(G7)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(G7)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(G7)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district G7 commentaire source_regle action_proposee ///
        using "$document\08_G\G7_manquant.xlsx", ///
        if (missing(G7)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(G7)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G7 renseigne hors univers" if (!missing(G7)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(G7)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(G7)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district G7 commentaire source_regle action_proposee ///
        using "$document\08_G\G7_hors_univers.xlsx", ///
        if (!missing(G7)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(G7, 1, 2))) & (!missing(G7)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G7 hors domaine questionnaire" if !((inlist(G7, 1, 2))) & (!missing(G7)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(G7, 1, 2))) & (!missing(G7)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(G7, 1, 2))) & (!missing(G7)) & ($audit_scope)
    export excel interview__key cover_district G7 commentaire source_regle action_proposee ///
        using "$document\08_G\G7_hors_domaine.xlsx", ///
        if !((inlist(G7, 1, 2))) & (!missing(G7)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* G7A - G7A. Seriez-vous pret a travailler plus d'heures au cours des deux prochaines semaines ?
* Type questionnaire : single-select
count if (missing(G7A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G7) & (G7 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G7A manquant dans son univers" if (missing(G7A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G7) & (G7 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(G7A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G7) & (G7 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(G7A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G7) & (G7 == 1)))) & ($audit_scope)
    export excel interview__key cover_district G7A commentaire source_regle action_proposee ///
        using "$document\08_G\G7A_manquant.xlsx", ///
        if (missing(G7A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G7) & (G7 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(G7A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G7) & (G7 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G7A renseigne hors univers" if (!missing(G7A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G7) & (G7 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(G7A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G7) & (G7 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(G7A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G7) & (G7 == 1)))) & ($audit_scope)
    export excel interview__key cover_district G7A commentaire source_regle action_proposee ///
        using "$document\08_G\G7A_hors_univers.xlsx", ///
        if (!missing(G7A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(G7) & (G7 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(G7A, 1, 2))) & (!missing(G7A)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "G7A hors domaine questionnaire" if !((inlist(G7A, 1, 2))) & (!missing(G7A)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(G7A, 1, 2))) & (!missing(G7A)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(G7A, 1, 2))) & (!missing(G7A)) & ($audit_scope)
    export excel interview__key cover_district G7A commentaire source_regle action_proposee ///
        using "$document\08_G\G7A_hors_domaine.xlsx", ///
        if !((inlist(G7A, 1, 2))) & (!missing(G7A)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHG_fin - HHG_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHG_fin) | trim(HHG_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHG_fin manquant dans son univers" if ((missing(HHG_fin) | trim(HHG_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHG_fin) | trim(HHG_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHG_fin) | trim(HHG_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHG_fin commentaire source_regle action_proposee ///
        using "$document\08_G\HHG_fin_manquant.xlsx", ///
        if ((missing(HHG_fin) | trim(HHG_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHG_fin) & trim(HHG_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHG_fin renseigne hors univers" if ((!missing(HHG_fin) & trim(HHG_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHG_fin) & trim(HHG_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHG_fin) & trim(HHG_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHG_fin commentaire source_regle action_proposee ///
        using "$document\08_G\HHG_fin_hors_univers.xlsx", ///
        if ((!missing(HHG_fin) & trim(HHG_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHG_debut G1 G2 G3 G4 G4A G5 G5A G6 G7 G7A HHG_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue G."
        exit 459
    }
    save "$section_output\08_G.dta", replace
restore

display as result "Controles section G termines."
