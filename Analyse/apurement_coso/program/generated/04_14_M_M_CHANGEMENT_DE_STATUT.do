/*===========================================================================
  Section M. CHANGEMENT DE STATUT
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

cap mkdir "$document\14_M"

*---------------------------------------------------------------------------
* HHM_debut - HHM_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHM_debut) | trim(HHM_debut) == "")) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHM_debut manquant dans son univers" if ((missing(HHM_debut) | trim(HHM_debut) == "")) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHM_debut) | trim(HHM_debut) == "")) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHM_debut) | trim(HHM_debut) == "")) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHM_debut commentaire source_regle action_proposee ///
        using "$document\14_M\HHM_debut_manquant.xlsx", ///
        if ((missing(HHM_debut) | trim(HHM_debut) == "")) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHM_debut) & trim(HHM_debut) != "")) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHM_debut renseigne hors univers" if ((!missing(HHM_debut) & trim(HHM_debut) != "")) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHM_debut) & trim(HHM_debut) != "")) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHM_debut) & trim(HHM_debut) != "")) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHM_debut commentaire source_regle action_proposee ///
        using "$document\14_M\HHM_debut_hors_univers.xlsx", ///
        if ((!missing(HHM_debut) & trim(HHM_debut) != "")) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* M1 - M1. Comment est-ce que tu gagnes ta vie ou tu t'en sors financierement en ce moment ?
* Type questionnaire : single-select
count if (missing(M1)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "M1 manquant dans son univers" if (missing(M1)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(M1)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(M1)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district M1 commentaire source_regle action_proposee ///
        using "$document\14_M\M1_manquant.xlsx", ///
        if (missing(M1)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(M1)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "M1 renseigne hors univers" if (!missing(M1)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(M1)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(M1)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district M1 commentaire source_regle action_proposee ///
        using "$document\14_M\M1_hors_univers.xlsx", ///
        if (!missing(M1)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(M1, 1, 2, 3))) & (!missing(M1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "M1 hors domaine questionnaire" if !((inlist(M1, 1, 2, 3))) & (!missing(M1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(M1, 1, 2, 3))) & (!missing(M1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(M1, 1, 2, 3))) & (!missing(M1)) & ($audit_scope)
    export excel interview__key cover_district M1 commentaire source_regle action_proposee ///
        using "$document\14_M\M1_hors_domaine.xlsx", ///
        if !((inlist(M1, 1, 2, 3))) & (!missing(M1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* M2 - M2. Au cours des 12 derniers mois, avez-vous recu une aide financiere ou materielle externe (famille, ONG, Etat) pour couvrir vos besoins de base ?
* Type questionnaire : single-select
count if (missing(M2)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "M2 manquant dans son univers" if (missing(M2)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(M2)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(M2)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district M2 commentaire source_regle action_proposee ///
        using "$document\14_M\M2_manquant.xlsx", ///
        if (missing(M2)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(M2)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "M2 renseigne hors univers" if (!missing(M2)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(M2)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(M2)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district M2 commentaire source_regle action_proposee ///
        using "$document\14_M\M2_hors_univers.xlsx", ///
        if (!missing(M2)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(M2, 1, 2, 3))) & (!missing(M2)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "M2 hors domaine questionnaire" if !((inlist(M2, 1, 2, 3))) & (!missing(M2)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(M2, 1, 2, 3))) & (!missing(M2)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(M2, 1, 2, 3))) & (!missing(M2)) & ($audit_scope)
    export excel interview__key cover_district M2 commentaire source_regle action_proposee ///
        using "$document\14_M\M2_hors_domaine.xlsx", ///
        if !((inlist(M2, 1, 2, 3))) & (!missing(M2)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* M3 - M3. Votre entourage (famille, communaute) vous percoit comme une personne qui contribue economiquement ?
* Type questionnaire : single-select
count if (missing(M3)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "M3 manquant dans son univers" if (missing(M3)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(M3)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(M3)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district M3 commentaire source_regle action_proposee ///
        using "$document\14_M\M3_manquant.xlsx", ///
        if (missing(M3)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(M3)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "M3 renseigne hors univers" if (!missing(M3)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(M3)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(M3)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district M3 commentaire source_regle action_proposee ///
        using "$document\14_M\M3_hors_univers.xlsx", ///
        if (!missing(M3)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(M3, 1, 2, 3, 4, 5))) & (!missing(M3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "M3 hors domaine questionnaire" if !((inlist(M3, 1, 2, 3, 4, 5))) & (!missing(M3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(M3, 1, 2, 3, 4, 5))) & (!missing(M3)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(M3, 1, 2, 3, 4, 5))) & (!missing(M3)) & ($audit_scope)
    export excel interview__key cover_district M3 commentaire source_regle action_proposee ///
        using "$document\14_M\M3_hors_domaine.xlsx", ///
        if !((inlist(M3, 1, 2, 3, 4, 5))) & (!missing(M3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* M4 - M4. Si vous deviez vous projeter dans 12 mois, vous voyez-vous plutot quelquun qui arrive a se prendre en charge ou comme dependant dune aide exterieure ?
* Type questionnaire : single-select
count if (missing(M4)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "M4 manquant dans son univers" if (missing(M4)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(M4)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(M4)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district M4 commentaire source_regle action_proposee ///
        using "$document\14_M\M4_manquant.xlsx", ///
        if (missing(M4)) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(M4)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "M4 renseigne hors univers" if (!missing(M4)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(M4)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(M4)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district M4 commentaire source_regle action_proposee ///
        using "$document\14_M\M4_hors_univers.xlsx", ///
        if (!missing(M4)) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(M4, 1, 2, 3))) & (!missing(M4)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "M4 hors domaine questionnaire" if !((inlist(M4, 1, 2, 3))) & (!missing(M4)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(M4, 1, 2, 3))) & (!missing(M4)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(M4, 1, 2, 3))) & (!missing(M4)) & ($audit_scope)
    export excel interview__key cover_district M4 commentaire source_regle action_proposee ///
        using "$document\14_M\M4_hors_domaine.xlsx", ///
        if !((inlist(M4, 1, 2, 3))) & (!missing(M4)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHM_fin - HHM_fin
* Type questionnaire : date: current time
count if ((missing(HHM_fin) | trim(HHM_fin) == "")) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHM_fin manquant dans son univers" if ((missing(HHM_fin) | trim(HHM_fin) == "")) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHM_fin) | trim(HHM_fin) == "")) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHM_fin) | trim(HHM_fin) == "")) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHM_fin commentaire source_regle action_proposee ///
        using "$document\14_M\HHM_fin_manquant.xlsx", ///
        if ((missing(HHM_fin) | trim(HHM_fin) == "")) & ((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHM_fin) & trim(HHM_fin) != "")) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHM_fin renseigne hors univers" if ((!missing(HHM_fin) & trim(HHM_fin) != "")) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHM_fin) & trim(HHM_fin) != "")) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHM_fin) & trim(HHM_fin) != "")) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHM_fin commentaire source_regle action_proposee ///
        using "$document\14_M\HHM_fin_hors_univers.xlsx", ///
        if ((!missing(HHM_fin) & trim(HHM_fin) != "")) & !((!missing(HHL_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHM_debut M1 M2 M3 M4 HHM_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue M."
        exit 459
    }
    save "$section_output\14_M.dta", replace
restore

display as result "Controles section M termines."
