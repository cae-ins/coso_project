/*===========================================================================
  Section P. ASPIRATIONS PROFESSIONNELLES
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

cap mkdir "$document\17_P"

*---------------------------------------------------------------------------
* HHP_debut - HHP_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHP_debut) | trim(HHP_debut) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHP_debut manquant dans son univers" if ((missing(HHP_debut) | trim(HHP_debut) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHP_debut) | trim(HHP_debut) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHP_debut) | trim(HHP_debut) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHP_debut commentaire source_regle action_proposee ///
        using "$document\17_P\HHP_debut_manquant.xlsx", ///
        if ((missing(HHP_debut) | trim(HHP_debut) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHP_debut) & trim(HHP_debut) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHP_debut renseigne hors univers" if ((!missing(HHP_debut) & trim(HHP_debut) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHP_debut) & trim(HHP_debut) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHP_debut) & trim(HHP_debut) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHP_debut commentaire source_regle action_proposee ///
        using "$document\17_P\HHP_debut_hors_univers.xlsx", ///
        if ((!missing(HHP_debut) & trim(HHP_debut) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* P1 - N1. Quel metier ou activite souhaiteriez-vous exercer dans les cinq prochaines annees ?
* Type questionnaire : text
count if ((missing(P1) | trim(P1) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P1 manquant dans son univers" if ((missing(P1) | trim(P1) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(P1) | trim(P1) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(P1) | trim(P1) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district P1 commentaire source_regle action_proposee ///
        using "$document\17_P\P1_manquant.xlsx", ///
        if ((missing(P1) | trim(P1) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(P1) & trim(P1) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P1 renseigne hors univers" if ((!missing(P1) & trim(P1) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(P1) & trim(P1) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(P1) & trim(P1) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district P1 commentaire source_regle action_proposee ///
        using "$document\17_P\P1_hors_univers.xlsx", ///
        if ((!missing(P1) & trim(P1) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* P2 - P2. Souhaitez-vous principalement trouver un emploi salarie, creer une entreprise ou developper une activite existante ?
* Type questionnaire : single-select
count if (missing(P2)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P2 manquant dans son univers" if (missing(P2)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(P2)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(P2)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district P2 commentaire source_regle action_proposee ///
        using "$document\17_P\P2_manquant.xlsx", ///
        if (missing(P2)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(P2)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P2 renseigne hors univers" if (!missing(P2)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(P2)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(P2)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district P2 commentaire source_regle action_proposee ///
        using "$document\17_P\P2_hors_univers.xlsx", ///
        if (!missing(P2)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(P2, 1, 2, 3))) & (!missing(P2)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P2 hors domaine questionnaire" if !((inlist(P2, 1, 2, 3))) & (!missing(P2)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(P2, 1, 2, 3))) & (!missing(P2)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(P2, 1, 2, 3))) & (!missing(P2)) & ($audit_scope)
    export excel interview__key cover_district P2 commentaire source_regle action_proposee ///
        using "$document\17_P\P2_hors_domaine.xlsx", ///
        if !((inlist(P2, 1, 2, 3))) & (!missing(P2)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* P3 - P3. Quel revenu mensuel souhaiteriez-vous atteindre ?
* Type questionnaire : numeric: integer
count if (missing(P3)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P3 manquant dans son univers" if (missing(P3)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(P3)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(P3)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district P3 commentaire source_regle action_proposee ///
        using "$document\17_P\P3_manquant.xlsx", ///
        if (missing(P3)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(P3)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P3 renseigne hors univers" if (!missing(P3)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(P3)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(P3)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district P3 commentaire source_regle action_proposee ///
        using "$document\17_P\P3_hors_univers.xlsx", ///
        if (!missing(P3)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* P4 - P4. Quel secteur d'activite vous interesse le plus ?
* Type questionnaire : single-select
count if (missing(P4)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P4 manquant dans son univers" if (missing(P4)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(P4)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(P4)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district P4 commentaire source_regle action_proposee ///
        using "$document\17_P\P4_manquant.xlsx", ///
        if (missing(P4)) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(P4)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P4 renseigne hors univers" if (!missing(P4)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(P4)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(P4)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district P4 commentaire source_regle action_proposee ///
        using "$document\17_P\P4_hors_univers.xlsx", ///
        if (!missing(P4)) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(P4, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) | inlist(P4, 11, 12, 13, 14, 99))) & (!missing(P4)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P4 hors domaine questionnaire" if !((inlist(P4, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) | inlist(P4, 11, 12, 13, 14, 99))) & (!missing(P4)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(P4, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) | inlist(P4, 11, 12, 13, 14, 99))) & (!missing(P4)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(P4, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) | inlist(P4, 11, 12, 13, 14, 99))) & (!missing(P4)) & ($audit_scope)
    export excel interview__key cover_district P4 commentaire source_regle action_proposee ///
        using "$document\17_P\P4_hors_domaine.xlsx", ///
        if !((inlist(P4, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) | inlist(P4, 11, 12, 13, 14, 99))) & (!missing(P4)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* P44X - P4X. Preciser l'autre secteur
* Type questionnaire : text
count if ((missing(P44X) | trim(P44X) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(P4) & (P4 == 99)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P44X manquant dans son univers" if ((missing(P44X) | trim(P44X) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(P4) & (P4 == 99)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(P44X) | trim(P44X) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(P4) & (P4 == 99)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(P44X) | trim(P44X) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(P4) & (P4 == 99)))) & ($audit_scope)
    export excel interview__key cover_district P44X commentaire source_regle action_proposee ///
        using "$document\17_P\P44X_manquant.xlsx", ///
        if ((missing(P44X) | trim(P44X) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(P4) & (P4 == 99)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(P44X) & trim(P44X) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(P4) & (P4 == 99)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P44X renseigne hors univers" if ((!missing(P44X) & trim(P44X) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(P4) & (P4 == 99)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(P44X) & trim(P44X) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(P4) & (P4 == 99)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(P44X) & trim(P44X) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(P4) & (P4 == 99)))) & ($audit_scope)
    export excel interview__key cover_district P44X commentaire source_regle action_proposee ///
        using "$document\17_P\P44X_hors_univers.xlsx", ///
        if ((!missing(P44X) & trim(P44X) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(P4) & (P4 == 99)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* P5 - P5. Quel est selon vous le principal obstacle a la realisation de vos objectifs professionnels ?
* Type questionnaire : text
count if ((missing(P5) | trim(P5) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P5 manquant dans son univers" if ((missing(P5) | trim(P5) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(P5) | trim(P5) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(P5) | trim(P5) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district P5 commentaire source_regle action_proposee ///
        using "$document\17_P\P5_manquant.xlsx", ///
        if ((missing(P5) | trim(P5) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(P5) & trim(P5) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "P5 renseigne hors univers" if ((!missing(P5) & trim(P5) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(P5) & trim(P5) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(P5) & trim(P5) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district P5 commentaire source_regle action_proposee ///
        using "$document\17_P\P5_hors_univers.xlsx", ///
        if ((!missing(P5) & trim(P5) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHP_fin - HHP_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHP_fin) | trim(HHP_fin) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHP_fin manquant dans son univers" if ((missing(HHP_fin) | trim(HHP_fin) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHP_fin) | trim(HHP_fin) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHP_fin) | trim(HHP_fin) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHP_fin commentaire source_regle action_proposee ///
        using "$document\17_P\HHP_fin_manquant.xlsx", ///
        if ((missing(HHP_fin) | trim(HHP_fin) == "")) & ((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHP_fin) & trim(HHP_fin) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHP_fin renseigne hors univers" if ((!missing(HHP_fin) & trim(HHP_fin) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHP_fin) & trim(HHP_fin) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHP_fin) & trim(HHP_fin) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHP_fin commentaire source_regle action_proposee ///
        using "$document\17_P\HHP_fin_hors_univers.xlsx", ///
        if ((!missing(HHP_fin) & trim(HHP_fin) != "")) & !((!missing(HHO_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHP_debut P1 P2 P3 P4 P44X P5 HHP_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue P."
        exit 459
    }
    save "$section_output\17_P.dta", replace
restore

display as result "Controles section P termines."
