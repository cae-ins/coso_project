/*===========================================================================
  Section A.GESTION DES TENTATIVES DAPPEL
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

cap mkdir "$document\02_A"

*---------------------------------------------------------------------------
* nom_sup - Nom du superviseur
* Type questionnaire : single-select
count if (missing(nom_sup)) & (1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "nom_sup manquant dans son univers" if (missing(nom_sup)) & (1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(nom_sup)) & (1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(nom_sup)) & (1) & ($audit_scope)
    export excel interview__key cover_district commentaire source_regle action_proposee ///
        using "$document\02_A\nom_sup_manquant.xlsx", ///
        if (missing(nom_sup)) & (1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(nom_sup, 1, 2))) & (!missing(nom_sup)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "nom_sup hors domaine questionnaire" if !((inlist(nom_sup, 1, 2))) & (!missing(nom_sup)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(nom_sup, 1, 2))) & (!missing(nom_sup)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(nom_sup, 1, 2))) & (!missing(nom_sup)) & ($audit_scope)
    export excel interview__key cover_district commentaire source_regle action_proposee ///
        using "$document\02_A\nom_sup_hors_domaine.xlsx", ///
        if !((inlist(nom_sup, 1, 2))) & (!missing(nom_sup)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* nom_agent - Nom de l'agent
* Type questionnaire : single-select: cascading
count if (missing(nom_agent)) & (1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "nom_agent manquant dans son univers" if (missing(nom_agent)) & (1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(nom_agent)) & (1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(nom_agent)) & (1) & ($audit_scope)
    export excel interview__key cover_district commentaire source_regle action_proposee ///
        using "$document\02_A\nom_agent_manquant.xlsx", ///
        if (missing(nom_agent)) & (1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
* A_VALIDER : domaine et coherence parent-enfant de la cascade; les options du HTML Preview peuvent etre tronquees.

*---------------------------------------------------------------------------
* HHA_debut - HHA_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHA_debut) | trim(HHA_debut) == "")) & (1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHA_debut manquant dans son univers" if ((missing(HHA_debut) | trim(HHA_debut) == "")) & (1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHA_debut) | trim(HHA_debut) == "")) & (1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHA_debut) | trim(HHA_debut) == "")) & (1) & ($audit_scope)
    export excel interview__key cover_district HHA_debut commentaire source_regle action_proposee ///
        using "$document\02_A\HHA_debut_manquant.xlsx", ///
        if ((missing(HHA_debut) | trim(HHA_debut) == "")) & (1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* A1 - A1. Numero de la tentative dappel en cours
* Type questionnaire : single-select
count if (missing(A1)) & ((!missing(HHA_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A1 manquant dans son univers" if (missing(A1)) & ((!missing(HHA_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(A1)) & ((!missing(HHA_debut))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(A1)) & ((!missing(HHA_debut))) & ($audit_scope)
    export excel interview__key cover_district A1 commentaire source_regle action_proposee ///
        using "$document\02_A\A1_manquant.xlsx", ///
        if (missing(A1)) & ((!missing(HHA_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(A1)) & !((!missing(HHA_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A1 renseigne hors univers" if (!missing(A1)) & !((!missing(HHA_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(A1)) & !((!missing(HHA_debut))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(A1)) & !((!missing(HHA_debut))) & ($audit_scope)
    export excel interview__key cover_district A1 commentaire source_regle action_proposee ///
        using "$document\02_A\A1_hors_univers.xlsx", ///
        if (!missing(A1)) & !((!missing(HHA_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(A1, 1, 2, 3))) & (!missing(A1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A1 hors domaine questionnaire" if !((inlist(A1, 1, 2, 3))) & (!missing(A1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(A1, 1, 2, 3))) & (!missing(A1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(A1, 1, 2, 3))) & (!missing(A1)) & ($audit_scope)
    export excel interview__key cover_district A1 commentaire source_regle action_proposee ///
        using "$document\02_A\A1_hors_domaine.xlsx", ///
        if !((inlist(A1, 1, 2, 3))) & (!missing(A1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* A2_date - A2. Date de l'appel
* Type questionnaire : date
count if ((missing(A2_date) | trim(A2_date) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A2_date manquant dans son univers" if ((missing(A2_date) | trim(A2_date) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(A2_date) | trim(A2_date) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(A2_date) | trim(A2_date) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
    export excel interview__key cover_district A2_date commentaire source_regle action_proposee ///
        using "$document\02_A\A2_date_manquant.xlsx", ///
        if ((missing(A2_date) | trim(A2_date) == "")) & ((!missing(HHA_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(A2_date) & trim(A2_date) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A2_date renseigne hors univers" if ((!missing(A2_date) & trim(A2_date) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(A2_date) & trim(A2_date) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(A2_date) & trim(A2_date) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
    export excel interview__key cover_district A2_date commentaire source_regle action_proposee ///
        using "$document\02_A\A2_date_hors_univers.xlsx", ///
        if ((!missing(A2_date) & trim(A2_date) != "")) & !((!missing(HHA_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* A2_heure - A2. Heure de l'appel
* Type questionnaire : text
count if ((missing(A2_heure) | trim(A2_heure) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A2_heure manquant dans son univers" if ((missing(A2_heure) | trim(A2_heure) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(A2_heure) | trim(A2_heure) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(A2_heure) | trim(A2_heure) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
    export excel interview__key cover_district A2_heure commentaire source_regle action_proposee ///
        using "$document\02_A\A2_heure_manquant.xlsx", ///
        if ((missing(A2_heure) | trim(A2_heure) == "")) & ((!missing(HHA_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(A2_heure) & trim(A2_heure) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A2_heure renseigne hors univers" if ((!missing(A2_heure) & trim(A2_heure) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(A2_heure) & trim(A2_heure) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(A2_heure) & trim(A2_heure) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
    export excel interview__key cover_district A2_heure commentaire source_regle action_proposee ///
        using "$document\02_A\A2_heure_hors_univers.xlsx", ///
        if ((!missing(A2_heure) & trim(A2_heure) != "")) & !((!missing(HHA_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* A4 - A4. Resultat de cette tentative dappel
* Type questionnaire : single-select
count if (missing(A4)) & ((!missing(HHA_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A4 manquant dans son univers" if (missing(A4)) & ((!missing(HHA_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(A4)) & ((!missing(HHA_debut))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(A4)) & ((!missing(HHA_debut))) & ($audit_scope)
    export excel interview__key cover_district A4 commentaire source_regle action_proposee ///
        using "$document\02_A\A4_manquant.xlsx", ///
        if (missing(A4)) & ((!missing(HHA_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(A4)) & !((!missing(HHA_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A4 renseigne hors univers" if (!missing(A4)) & !((!missing(HHA_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(A4)) & !((!missing(HHA_debut))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(A4)) & !((!missing(HHA_debut))) & ($audit_scope)
    export excel interview__key cover_district A4 commentaire source_regle action_proposee ///
        using "$document\02_A\A4_hors_univers.xlsx", ///
        if (!missing(A4)) & !((!missing(HHA_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(A4, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(A4)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A4 hors domaine questionnaire" if !((inlist(A4, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(A4)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(A4, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(A4)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(A4, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(A4)) & ($audit_scope)
    export excel interview__key cover_district A4 commentaire source_regle action_proposee ///
        using "$document\02_A\A4_hors_domaine.xlsx", ///
        if !((inlist(A4, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(A4)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* A4X - A4X. Preciser l'autre resultat de la tentative
* Type questionnaire : text
count if ((missing(A4X) | trim(A4X) == "")) & (((!missing(A4) & (A4 == 8)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A4X manquant dans son univers" if ((missing(A4X) | trim(A4X) == "")) & (((!missing(A4) & (A4 == 8)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(A4X) | trim(A4X) == "")) & (((!missing(A4) & (A4 == 8)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(A4X) | trim(A4X) == "")) & (((!missing(A4) & (A4 == 8)))) & ($audit_scope)
    export excel interview__key cover_district A4X commentaire source_regle action_proposee ///
        using "$document\02_A\A4X_manquant.xlsx", ///
        if ((missing(A4X) | trim(A4X) == "")) & (((!missing(A4) & (A4 == 8)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(A4X) & trim(A4X) != "")) & !(((!missing(A4) & (A4 == 8)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A4X renseigne hors univers" if ((!missing(A4X) & trim(A4X) != "")) & !(((!missing(A4) & (A4 == 8)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(A4X) & trim(A4X) != "")) & !(((!missing(A4) & (A4 == 8)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(A4X) & trim(A4X) != "")) & !(((!missing(A4) & (A4 == 8)))) & ($audit_scope)
    export excel interview__key cover_district A4X commentaire source_regle action_proposee ///
        using "$document\02_A\A4X_hors_univers.xlsx", ///
        if ((!missing(A4X) & trim(A4X) != "")) & !(((!missing(A4) & (A4 == 8)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* A5_date - A5. Indiquez la date prevue pour la prochaine tentative
* Type questionnaire : date
count if ((missing(A5_date) | trim(A5_date) == "")) & (((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A5_date manquant dans son univers" if ((missing(A5_date) | trim(A5_date) == "")) & (((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(A5_date) | trim(A5_date) == "")) & (((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(A5_date) | trim(A5_date) == "")) & (((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
    export excel interview__key cover_district A5_date commentaire source_regle action_proposee ///
        using "$document\02_A\A5_date_manquant.xlsx", ///
        if ((missing(A5_date) | trim(A5_date) == "")) & (((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(A5_date) & trim(A5_date) != "")) & !(((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A5_date renseigne hors univers" if ((!missing(A5_date) & trim(A5_date) != "")) & !(((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(A5_date) & trim(A5_date) != "")) & !(((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(A5_date) & trim(A5_date) != "")) & !(((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
    export excel interview__key cover_district A5_date commentaire source_regle action_proposee ///
        using "$document\02_A\A5_date_hors_univers.xlsx", ///
        if ((!missing(A5_date) & trim(A5_date) != "")) & !(((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* A5_heure - A5. Indiquez lheure prevues pour la prochaine tentative
* Type questionnaire : date
count if ((missing(A5_heure) | trim(A5_heure) == "")) & (((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A5_heure manquant dans son univers" if ((missing(A5_heure) | trim(A5_heure) == "")) & (((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(A5_heure) | trim(A5_heure) == "")) & (((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(A5_heure) | trim(A5_heure) == "")) & (((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
    export excel interview__key cover_district A5_heure commentaire source_regle action_proposee ///
        using "$document\02_A\A5_heure_manquant.xlsx", ///
        if ((missing(A5_heure) | trim(A5_heure) == "")) & (((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(A5_heure) & trim(A5_heure) != "")) & !(((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "A5_heure renseigne hors univers" if ((!missing(A5_heure) & trim(A5_heure) != "")) & !(((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(A5_heure) & trim(A5_heure) != "")) & !(((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(A5_heure) & trim(A5_heure) != "")) & !(((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope)
    export excel interview__key cover_district A5_heure commentaire source_regle action_proposee ///
        using "$document\02_A\A5_heure_hors_univers.xlsx", ///
        if ((!missing(A5_heure) & trim(A5_heure) != "")) & !(((!missing(A4) & (A4 == 5)) | (!missing(A4) & (A4 == 7)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHA_fin - HHA_fin.Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHA_fin) | trim(HHA_fin) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHA_fin manquant dans son univers" if ((missing(HHA_fin) | trim(HHA_fin) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHA_fin) | trim(HHA_fin) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHA_fin) | trim(HHA_fin) == "")) & ((!missing(HHA_debut))) & ($audit_scope)
    export excel interview__key cover_district HHA_fin commentaire source_regle action_proposee ///
        using "$document\02_A\HHA_fin_manquant.xlsx", ///
        if ((missing(HHA_fin) | trim(HHA_fin) == "")) & ((!missing(HHA_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHA_fin) & trim(HHA_fin) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHA_fin renseigne hors univers" if ((!missing(HHA_fin) & trim(HHA_fin) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHA_fin) & trim(HHA_fin) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHA_fin) & trim(HHA_fin) != "")) & !((!missing(HHA_debut))) & ($audit_scope)
    export excel interview__key cover_district HHA_fin commentaire source_regle action_proposee ///
        using "$document\02_A\HHA_fin_hors_univers.xlsx", ///
        if ((!missing(HHA_fin) & trim(HHA_fin) != "")) & !((!missing(HHA_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district nom_sup nom_agent HHA_debut A1 A2_date A2_heure A4 A4X A5_date A5_heure HHA_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue A."
        exit 459
    }
    save "$section_output\02_A.dta", replace
restore

display as result "Controles section A termines."
