/*===========================================================================
  Section B. IDENTIFICATION ET CONSENTEMENT
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

cap mkdir "$document\03_B"

*---------------------------------------------------------------------------
* HHB_debut - HHB_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHB_debut) | trim(HHB_debut) == "")) & (1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHB_debut manquant dans son univers" if ((missing(HHB_debut) | trim(HHB_debut) == "")) & (1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHB_debut) | trim(HHB_debut) == "")) & (1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHB_debut) | trim(HHB_debut) == "")) & (1) & ($audit_scope)
    export excel interview__key cover_district HHB_debut commentaire source_regle action_proposee ///
        using "$document\03_B\HHB_debut_manquant.xlsx", ///
        if ((missing(HHB_debut) | trim(HHB_debut) == "")) & (1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* B1 - B1. District
* Type questionnaire : single-select
count if (missing(B1)) & (1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B1 manquant dans son univers" if (missing(B1)) & (1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(B1)) & (1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(B1)) & (1) & ($audit_scope)
    export excel interview__key cover_district B1 commentaire source_regle action_proposee ///
        using "$document\03_B\B1_manquant.xlsx", ///
        if (missing(B1)) & (1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(B1, 105, 111, 113, 114))) & (!missing(B1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B1 hors domaine questionnaire" if !((inlist(B1, 105, 111, 113, 114))) & (!missing(B1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(B1, 105, 111, 113, 114))) & (!missing(B1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(B1, 105, 111, 113, 114))) & (!missing(B1)) & ($audit_scope)
    export excel interview__key cover_district B1 commentaire source_regle action_proposee ///
        using "$document\03_B\B1_hors_domaine.xlsx", ///
        if !((inlist(B1, 105, 111, 113, 114))) & (!missing(B1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* B2 - B2. Region
* Type questionnaire : single-select: cascading
count if (missing(B2)) & (1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B2 manquant dans son univers" if (missing(B2)) & (1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(B2)) & (1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(B2)) & (1) & ($audit_scope)
    export excel interview__key cover_district B2 commentaire source_regle action_proposee ///
        using "$document\03_B\B2_manquant.xlsx", ///
        if (missing(B2)) & (1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
* A_VALIDER : domaine et coherence parent-enfant de la cascade; les options du HTML Preview peuvent etre tronquees.

*---------------------------------------------------------------------------
* B3 - B3. Departement
* Type questionnaire : single-select: cascading
count if (missing(B3)) & (1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B3 manquant dans son univers" if (missing(B3)) & (1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(B3)) & (1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(B3)) & (1) & ($audit_scope)
    export excel interview__key cover_district B3 commentaire source_regle action_proposee ///
        using "$document\03_B\B3_manquant.xlsx", ///
        if (missing(B3)) & (1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
* A_VALIDER : domaine et coherence parent-enfant de la cascade; les options du HTML Preview peuvent etre tronquees.

*---------------------------------------------------------------------------
* B4 - B4.Sous-prefecture/Commune
* Type questionnaire : single-select: cascading
count if (missing(B4)) & (1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B4 manquant dans son univers" if (missing(B4)) & (1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(B4)) & (1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(B4)) & (1) & ($audit_scope)
    export excel interview__key cover_district B4 commentaire source_regle action_proposee ///
        using "$document\03_B\B4_manquant.xlsx", ///
        if (missing(B4)) & (1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
* A_VALIDER : domaine et coherence parent-enfant de la cascade; les options du HTML Preview peuvent etre tronquees.

*---------------------------------------------------------------------------
* B5 - B5. Milieu de residence
* Type questionnaire : single-select
count if (missing(B5)) & (1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B5 manquant dans son univers" if (missing(B5)) & (1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(B5)) & (1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(B5)) & (1) & ($audit_scope)
    export excel interview__key cover_district B5 commentaire source_regle action_proposee ///
        using "$document\03_B\B5_manquant.xlsx", ///
        if (missing(B5)) & (1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(B5, 1, 2))) & (!missing(B5)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B5 hors domaine questionnaire" if !((inlist(B5, 1, 2))) & (!missing(B5)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(B5, 1, 2))) & (!missing(B5)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(B5, 1, 2))) & (!missing(B5)) & ($audit_scope)
    export excel interview__key cover_district B5 commentaire source_regle action_proposee ///
        using "$document\03_B\B5_hors_domaine.xlsx", ///
        if !((inlist(B5, 1, 2))) & (!missing(B5)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* B6 - B6. Bonjour, Je m'appelle %nom_agent% et je vous appelle dans le cadre d'une etude sur la situation des jeunes candidats au Programme Jeunesse COSO . Suis-je bien en train de parle
* Type questionnaire : single-select
count if (missing(B6)) & (1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6 manquant dans son univers" if (missing(B6)) & (1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(B6)) & (1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(B6)) & (1) & ($audit_scope)
    export excel interview__key cover_district B6 commentaire source_regle action_proposee ///
        using "$document\03_B\B6_manquant.xlsx", ///
        if (missing(B6)) & (1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(B6, 1, 2))) & (!missing(B6)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6 hors domaine questionnaire" if !((inlist(B6, 1, 2))) & (!missing(B6)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(B6, 1, 2))) & (!missing(B6)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(B6, 1, 2))) & (!missing(B6)) & ($audit_scope)
    export excel interview__key cover_district B6 commentaire source_regle action_proposee ///
        using "$document\03_B\B6_hors_domaine.xlsx", ///
        if !((inlist(B6, 1, 2))) & (!missing(B6)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* B6A - B6A. Puis-je parler a %nom% ?
* Type questionnaire : single-select
count if (missing(B6A)) & (((!missing(B6) & (B6 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6A manquant dans son univers" if (missing(B6A)) & (((!missing(B6) & (B6 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(B6A)) & (((!missing(B6) & (B6 == 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(B6A)) & (((!missing(B6) & (B6 == 2)))) & ($audit_scope)
    export excel interview__key cover_district B6A commentaire source_regle action_proposee ///
        using "$document\03_B\B6A_manquant.xlsx", ///
        if (missing(B6A)) & (((!missing(B6) & (B6 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(B6A)) & !(((!missing(B6) & (B6 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6A renseigne hors univers" if (!missing(B6A)) & !(((!missing(B6) & (B6 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(B6A)) & !(((!missing(B6) & (B6 == 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(B6A)) & !(((!missing(B6) & (B6 == 2)))) & ($audit_scope)
    export excel interview__key cover_district B6A commentaire source_regle action_proposee ///
        using "$document\03_B\B6A_hors_univers.xlsx", ///
        if (!missing(B6A)) & !(((!missing(B6) & (B6 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(B6A, 1, 2))) & (!missing(B6A)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6A hors domaine questionnaire" if !((inlist(B6A, 1, 2))) & (!missing(B6A)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(B6A, 1, 2))) & (!missing(B6A)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(B6A, 1, 2))) & (!missing(B6A)) & ($audit_scope)
    export excel interview__key cover_district B6A commentaire source_regle action_proposee ///
        using "$document\03_B\B6A_hors_domaine.xlsx", ///
        if !((inlist(B6A, 1, 2))) & (!missing(B6A)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* B6B - B6B. Ce nest peut-etre pas le bon moment pour parler a %nom% . Puis-je rappeler a un moment qui lui conviendrait mieux ?
* Type questionnaire : single-select
count if (missing(B6B)) & (((!missing(B6A) & (B6A == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6B manquant dans son univers" if (missing(B6B)) & (((!missing(B6A) & (B6A == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(B6B)) & (((!missing(B6A) & (B6A == 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(B6B)) & (((!missing(B6A) & (B6A == 2)))) & ($audit_scope)
    export excel interview__key cover_district B6B commentaire source_regle action_proposee ///
        using "$document\03_B\B6B_manquant.xlsx", ///
        if (missing(B6B)) & (((!missing(B6A) & (B6A == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(B6B)) & !(((!missing(B6A) & (B6A == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6B renseigne hors univers" if (!missing(B6B)) & !(((!missing(B6A) & (B6A == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(B6B)) & !(((!missing(B6A) & (B6A == 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(B6B)) & !(((!missing(B6A) & (B6A == 2)))) & ($audit_scope)
    export excel interview__key cover_district B6B commentaire source_regle action_proposee ///
        using "$document\03_B\B6B_hors_univers.xlsx", ///
        if (!missing(B6B)) & !(((!missing(B6A) & (B6A == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(B6B, 1, 2))) & (!missing(B6B)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6B hors domaine questionnaire" if !((inlist(B6B, 1, 2))) & (!missing(B6B)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(B6B, 1, 2))) & (!missing(B6B)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(B6B, 1, 2))) & (!missing(B6B)) & ($audit_scope)
    export excel interview__key cover_district B6B commentaire source_regle action_proposee ///
        using "$document\03_B\B6B_hors_domaine.xlsx", ///
        if !((inlist(B6B, 1, 2))) & (!missing(B6B)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* B6C - B6C. Veuillez indiquer la date et l'heure souhaitees pour le rappel ?
* Type questionnaire : date
count if ((missing(B6C) | trim(B6C) == "")) & (((!missing(B6B) & (B6B == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6C manquant dans son univers" if ((missing(B6C) | trim(B6C) == "")) & (((!missing(B6B) & (B6B == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(B6C) | trim(B6C) == "")) & (((!missing(B6B) & (B6B == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(B6C) | trim(B6C) == "")) & (((!missing(B6B) & (B6B == 1)))) & ($audit_scope)
    export excel interview__key cover_district B6C commentaire source_regle action_proposee ///
        using "$document\03_B\B6C_manquant.xlsx", ///
        if ((missing(B6C) | trim(B6C) == "")) & (((!missing(B6B) & (B6B == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(B6C) & trim(B6C) != "")) & !(((!missing(B6B) & (B6B == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6C renseigne hors univers" if ((!missing(B6C) & trim(B6C) != "")) & !(((!missing(B6B) & (B6B == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(B6C) & trim(B6C) != "")) & !(((!missing(B6B) & (B6B == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(B6C) & trim(B6C) != "")) & !(((!missing(B6B) & (B6B == 1)))) & ($audit_scope)
    export excel interview__key cover_district B6C commentaire source_regle action_proposee ///
        using "$document\03_B\B6C_hors_univers.xlsx", ///
        if ((!missing(B6C) & trim(B6C) != "")) & !(((!missing(B6B) & (B6B == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* B6D - B6D. L'Agence Nationale de Statistique (Anstat) , en partenariat avec la Banque Mondiale , mene une etude pour mieux comprendre les resultats sur le marche du travail et les aspira
* Type questionnaire : single-select
count if (missing(B6D)) & (((!missing(B6) & (B6 == 1)) | (!missing(B6A) & (B6A == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6D manquant dans son univers" if (missing(B6D)) & (((!missing(B6) & (B6 == 1)) | (!missing(B6A) & (B6A == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(B6D)) & (((!missing(B6) & (B6 == 1)) | (!missing(B6A) & (B6A == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(B6D)) & (((!missing(B6) & (B6 == 1)) | (!missing(B6A) & (B6A == 1)))) & ($audit_scope)
    export excel interview__key cover_district B6D commentaire source_regle action_proposee ///
        using "$document\03_B\B6D_manquant.xlsx", ///
        if (missing(B6D)) & (((!missing(B6) & (B6 == 1)) | (!missing(B6A) & (B6A == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(B6D)) & !(((!missing(B6) & (B6 == 1)) | (!missing(B6A) & (B6A == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6D renseigne hors univers" if (!missing(B6D)) & !(((!missing(B6) & (B6 == 1)) | (!missing(B6A) & (B6A == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(B6D)) & !(((!missing(B6) & (B6 == 1)) | (!missing(B6A) & (B6A == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(B6D)) & !(((!missing(B6) & (B6 == 1)) | (!missing(B6A) & (B6A == 1)))) & ($audit_scope)
    export excel interview__key cover_district B6D commentaire source_regle action_proposee ///
        using "$document\03_B\B6D_hors_univers.xlsx", ///
        if (!missing(B6D)) & !(((!missing(B6) & (B6 == 1)) | (!missing(B6A) & (B6A == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(B6D, 1, 2))) & (!missing(B6D)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6D hors domaine questionnaire" if !((inlist(B6D, 1, 2))) & (!missing(B6D)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(B6D, 1, 2))) & (!missing(B6D)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(B6D, 1, 2))) & (!missing(B6D)) & ($audit_scope)
    export excel interview__key cover_district B6D commentaire source_regle action_proposee ///
        using "$document\03_B\B6D_hors_domaine.xlsx", ///
        if !((inlist(B6D, 1, 2))) & (!missing(B6D)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* B6E - B6E. Ce nest peut-etre pas le bon moment. Puis-je rappeler a un moment qui vous conviendrait mieux ?
* Type questionnaire : single-select
count if (missing(B6E)) & (((!missing(B6D) & (B6D == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6E manquant dans son univers" if (missing(B6E)) & (((!missing(B6D) & (B6D == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(B6E)) & (((!missing(B6D) & (B6D == 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(B6E)) & (((!missing(B6D) & (B6D == 2)))) & ($audit_scope)
    export excel interview__key cover_district B6E commentaire source_regle action_proposee ///
        using "$document\03_B\B6E_manquant.xlsx", ///
        if (missing(B6E)) & (((!missing(B6D) & (B6D == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(B6E)) & !(((!missing(B6D) & (B6D == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6E renseigne hors univers" if (!missing(B6E)) & !(((!missing(B6D) & (B6D == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(B6E)) & !(((!missing(B6D) & (B6D == 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(B6E)) & !(((!missing(B6D) & (B6D == 2)))) & ($audit_scope)
    export excel interview__key cover_district B6E commentaire source_regle action_proposee ///
        using "$document\03_B\B6E_hors_univers.xlsx", ///
        if (!missing(B6E)) & !(((!missing(B6D) & (B6D == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(B6E, 1, 2))) & (!missing(B6E)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6E hors domaine questionnaire" if !((inlist(B6E, 1, 2))) & (!missing(B6E)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(B6E, 1, 2))) & (!missing(B6E)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(B6E, 1, 2))) & (!missing(B6E)) & ($audit_scope)
    export excel interview__key cover_district B6E commentaire source_regle action_proposee ///
        using "$document\03_B\B6E_hors_domaine.xlsx", ///
        if !((inlist(B6E, 1, 2))) & (!missing(B6E)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* B6F - B6F. Veuillez indiquer la date et l'heure souhaitees pour le rappel ?
* Type questionnaire : date
count if ((missing(B6F) | trim(B6F) == "")) & (((!missing(B6E) & (B6E == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6F manquant dans son univers" if ((missing(B6F) | trim(B6F) == "")) & (((!missing(B6E) & (B6E == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(B6F) | trim(B6F) == "")) & (((!missing(B6E) & (B6E == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(B6F) | trim(B6F) == "")) & (((!missing(B6E) & (B6E == 1)))) & ($audit_scope)
    export excel interview__key cover_district B6F commentaire source_regle action_proposee ///
        using "$document\03_B\B6F_manquant.xlsx", ///
        if ((missing(B6F) | trim(B6F) == "")) & (((!missing(B6E) & (B6E == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(B6F) & trim(B6F) != "")) & !(((!missing(B6E) & (B6E == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "B6F renseigne hors univers" if ((!missing(B6F) & trim(B6F) != "")) & !(((!missing(B6E) & (B6E == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(B6F) & trim(B6F) != "")) & !(((!missing(B6E) & (B6E == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(B6F) & trim(B6F) != "")) & !(((!missing(B6E) & (B6E == 1)))) & ($audit_scope)
    export excel interview__key cover_district B6F commentaire source_regle action_proposee ///
        using "$document\03_B\B6F_hors_univers.xlsx", ///
        if ((!missing(B6F) & trim(B6F) != "")) & !(((!missing(B6E) & (B6E == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* consentement - Variable
* Type questionnaire : variable
* Variable calculee : documentee, sans controle automatique.

*---------------------------------------------------------------------------
* B7 - B7. Veuillez donner votre nom complet svp
* Type questionnaire : text
* Variable sensible exclue des rapports automatiques.

*---------------------------------------------------------------------------
* HHB_fin - HHB_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHB_fin) | trim(HHB_fin) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHB_fin manquant dans son univers" if ((missing(HHB_fin) | trim(HHB_fin) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHB_fin) | trim(HHB_fin) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHB_fin) | trim(HHB_fin) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
    export excel interview__key cover_district HHB_fin commentaire source_regle action_proposee ///
        using "$document\03_B\HHB_fin_manquant.xlsx", ///
        if ((missing(HHB_fin) | trim(HHB_fin) == "")) & ((!missing(HHA_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHB_fin) & trim(HHB_fin) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHB_fin renseigne hors univers" if ((!missing(HHB_fin) & trim(HHB_fin) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHB_fin) & trim(HHB_fin) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHB_fin) & trim(HHB_fin) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
    export excel interview__key cover_district HHB_fin commentaire source_regle action_proposee ///
        using "$document\03_B\HHB_fin_hors_univers.xlsx", ///
        if ((!missing(HHB_fin) & trim(HHB_fin) != "")) & !((!missing(HHA_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHB_debut B1 B2 B3 B4 B5 B6 B6A B6B B6C B6D B6E B6F consentement B7 HHB_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue B."
        exit 459
    }
    save "$section_output\03_B.dta", replace
restore

display as result "Controles section B termines."
