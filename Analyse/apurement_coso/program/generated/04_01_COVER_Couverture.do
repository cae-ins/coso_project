/*===========================================================================
  Section Couverture
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

cap mkdir "$document\01_COVER"

*---------------------------------------------------------------------------
* cover_id - Cover0.Identifiant
* Type questionnaire : text
* Variable sensible exclue des rapports automatiques.

*---------------------------------------------------------------------------
* cover_district - Cover1.District
* Type questionnaire : text
count if ((missing(cover_district) | trim(cover_district) == "")) & (1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "cover_district manquant dans son univers" if ((missing(cover_district) | trim(cover_district) == "")) & (1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(cover_district) | trim(cover_district) == "")) & (1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(cover_district) | trim(cover_district) == "")) & (1) & ($audit_scope)
    export excel interview__key cover_district commentaire source_regle action_proposee ///
        using "$document\01_COVER\cover_district_manquant.xlsx", ///
        if ((missing(cover_district) | trim(cover_district) == "")) & (1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* cover_region - Cover2.Region
* Type questionnaire : text
count if ((missing(cover_region) | trim(cover_region) == "")) & (1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "cover_region manquant dans son univers" if ((missing(cover_region) | trim(cover_region) == "")) & (1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(cover_region) | trim(cover_region) == "")) & (1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(cover_region) | trim(cover_region) == "")) & (1) & ($audit_scope)
    export excel interview__key cover_district cover_region commentaire source_regle action_proposee ///
        using "$document\01_COVER\cover_region_manquant.xlsx", ///
        if ((missing(cover_region) | trim(cover_region) == "")) & (1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* localite - Localite
* Type questionnaire : text
count if ((missing(localite) | trim(localite) == "")) & (1) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "localite manquant dans son univers" if ((missing(localite) | trim(localite) == "")) & (1) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(localite) | trim(localite) == "")) & (1) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(localite) | trim(localite) == "")) & (1) & ($audit_scope)
    export excel interview__key cover_district localite commentaire source_regle action_proposee ///
        using "$document\01_COVER\localite_manquant.xlsx", ///
        if ((missing(localite) | trim(localite) == "")) & (1) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* nom - Nom
* Type questionnaire : text
* Variable sensible exclue des rapports automatiques.

*---------------------------------------------------------------------------
* telephone - Telephone
* Type questionnaire : text
* Variable sensible exclue des rapports automatiques.

preserve
    keep if $audit_scope
    keep interview__key cover_district cover_id cover_region localite nom telephone
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue COVER."
        exit 459
    }
    save "$section_output\01_COVER.dta", replace
restore

display as result "Controles section COVER termines."
