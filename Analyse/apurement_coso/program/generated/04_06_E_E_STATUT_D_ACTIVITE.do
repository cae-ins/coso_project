/*===========================================================================
  Section E. STATUT D'ACTIVITE
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

cap mkdir "$document\06_E"

*---------------------------------------------------------------------------
* HHE_debut - HHE_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHE_debut) | trim(HHE_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHE_debut manquant dans son univers" if ((missing(HHE_debut) | trim(HHE_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHE_debut) | trim(HHE_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHE_debut) | trim(HHE_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    export excel interview__key cover_district HHE_debut commentaire source_regle action_proposee ///
        using "$document\06_E\HHE_debut_manquant.xlsx", ///
        if ((missing(HHE_debut) | trim(HHE_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHE_debut) & trim(HHE_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHE_debut renseigne hors univers" if ((!missing(HHE_debut) & trim(HHE_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHE_debut) & trim(HHE_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHE_debut) & trim(HHE_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    export excel interview__key cover_district HHE_debut commentaire source_regle action_proposee ///
        using "$document\06_E\HHE_debut_hors_univers.xlsx", ///
        if ((!missing(HHE_debut) & trim(HHE_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* E1 - E1. Au cours des 7 derniers jours, avez-vous travaille en echange dun salaire, traitement, profit, commission, pourboire ou autre remuneration, en espece ou en nature, meme si cela
* Type questionnaire : single-select
count if (missing(E1)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "E1 manquant dans son univers" if (missing(E1)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(E1)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(E1)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    export excel interview__key cover_district E1 commentaire source_regle action_proposee ///
        using "$document\06_E\E1_manquant.xlsx", ///
        if (missing(E1)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(E1)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "E1 renseigne hors univers" if (!missing(E1)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(E1)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(E1)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    export excel interview__key cover_district E1 commentaire source_regle action_proposee ///
        using "$document\06_E\E1_hors_univers.xlsx", ///
        if (!missing(E1)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(E1, 1, 2))) & (!missing(E1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "E1 hors domaine questionnaire" if !((inlist(E1, 1, 2))) & (!missing(E1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(E1, 1, 2))) & (!missing(E1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(E1, 1, 2))) & (!missing(E1)) & ($audit_scope)
    export excel interview__key cover_district E1 commentaire source_regle action_proposee ///
        using "$document\06_E\E1_hors_domaine.xlsx", ///
        if !((inlist(E1, 1, 2))) & (!missing(E1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* E2 - E2. Disposez-vous dun emploi ou dune entreprise dont vous etes temporairement absent(e) (conge, maladie, basse saison) et auquel/a laquelle vous comptez retourner ?
* Type questionnaire : single-select
count if (missing(E2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "E2 manquant dans son univers" if (missing(E2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(E2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(E2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)))) & ($audit_scope)
    export excel interview__key cover_district E2 commentaire source_regle action_proposee ///
        using "$document\06_E\E2_manquant.xlsx", ///
        if (missing(E2)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(E2)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "E2 renseigne hors univers" if (!missing(E2)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(E2)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(E2)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)))) & ($audit_scope)
    export excel interview__key cover_district E2 commentaire source_regle action_proposee ///
        using "$document\06_E\E2_hors_univers.xlsx", ///
        if (!missing(E2)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(E2, 1, 2))) & (!missing(E2)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "E2 hors domaine questionnaire" if !((inlist(E2, 1, 2))) & (!missing(E2)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(E2, 1, 2))) & (!missing(E2)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(E2, 1, 2))) & (!missing(E2)) & ($audit_scope)
    export excel interview__key cover_district E2 commentaire source_regle action_proposee ///
        using "$document\06_E\E2_hors_domaine.xlsx", ///
        if !((inlist(E2, 1, 2))) & (!missing(E2)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* E3 - E3. Avez-vous aide, sans remuneration directe, dans une entreprise ou une exploitation familiale (champ, boutique, atelier) ?
* Type questionnaire : single-select
count if (missing(E3)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)) & (!missing(E2) & (E2 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "E3 manquant dans son univers" if (missing(E3)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)) & (!missing(E2) & (E2 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(E3)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)) & (!missing(E2) & (E2 == 2)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(E3)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)) & (!missing(E2) & (E2 == 2)))) & ($audit_scope)
    export excel interview__key cover_district E3 commentaire source_regle action_proposee ///
        using "$document\06_E\E3_manquant.xlsx", ///
        if (missing(E3)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)) & (!missing(E2) & (E2 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(E3)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)) & (!missing(E2) & (E2 == 2)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "E3 renseigne hors univers" if (!missing(E3)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)) & (!missing(E2) & (E2 == 2)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(E3)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)) & (!missing(E2) & (E2 == 2)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(E3)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)) & (!missing(E2) & (E2 == 2)))) & ($audit_scope)
    export excel interview__key cover_district E3 commentaire source_regle action_proposee ///
        using "$document\06_E\E3_hors_univers.xlsx", ///
        if (!missing(E3)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E1) & (E1 == 2)) & (!missing(E2) & (E2 == 2)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(E3, 1, 2))) & (!missing(E3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "E3 hors domaine questionnaire" if !((inlist(E3, 1, 2))) & (!missing(E3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(E3, 1, 2))) & (!missing(E3)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(E3, 1, 2))) & (!missing(E3)) & ($audit_scope)
    export excel interview__key cover_district E3 commentaire source_regle action_proposee ///
        using "$document\06_E\E3_hors_domaine.xlsx", ///
        if !((inlist(E3, 1, 2))) & (!missing(E3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* E3A - E3A. Les produits ou services de cette activite sont-ils destines principalement a la vente, ou principalement a lusage du menage ?
* Type questionnaire : single-select
count if (missing(E3A)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E3) & (E3 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "E3A manquant dans son univers" if (missing(E3A)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E3) & (E3 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(E3A)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E3) & (E3 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(E3A)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E3) & (E3 == 1)))) & ($audit_scope)
    export excel interview__key cover_district E3A commentaire source_regle action_proposee ///
        using "$document\06_E\E3A_manquant.xlsx", ///
        if (missing(E3A)) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E3) & (E3 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(E3A)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E3) & (E3 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "E3A renseigne hors univers" if (!missing(E3A)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E3) & (E3 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(E3A)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E3) & (E3 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(E3A)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E3) & (E3 == 1)))) & ($audit_scope)
    export excel interview__key cover_district E3A commentaire source_regle action_proposee ///
        using "$document\06_E\E3A_hors_univers.xlsx", ///
        if (!missing(E3A)) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin)) & ((!missing(E3) & (E3 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(E3A, 1, 2))) & (!missing(E3A)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "E3A hors domaine questionnaire" if !((inlist(E3A, 1, 2))) & (!missing(E3A)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(E3A, 1, 2))) & (!missing(E3A)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(E3A, 1, 2))) & (!missing(E3A)) & ($audit_scope)
    export excel interview__key cover_district E3A commentaire source_regle action_proposee ///
        using "$document\06_E\E3A_hors_domaine.xlsx", ///
        if !((inlist(E3A, 1, 2))) & (!missing(E3A)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* EMPLOYE - Variable
* Type questionnaire : variable
* Variable calculee : documentee, sans controle automatique.

*---------------------------------------------------------------------------
* HHE_fin - HHE_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHE_fin) | trim(HHE_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHE_fin manquant dans son univers" if ((missing(HHE_fin) | trim(HHE_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHE_fin) | trim(HHE_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHE_fin) | trim(HHE_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    export excel interview__key cover_district HHE_fin commentaire source_regle action_proposee ///
        using "$document\06_E\HHE_fin_manquant.xlsx", ///
        if ((missing(HHE_fin) | trim(HHE_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHE_fin) & trim(HHE_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHE_fin renseigne hors univers" if ((!missing(HHE_fin) & trim(HHE_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHE_fin) & trim(HHE_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHE_fin) & trim(HHE_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope)
    export excel interview__key cover_district HHE_fin commentaire source_regle action_proposee ///
        using "$document\06_E\HHE_fin_hors_univers.xlsx", ///
        if ((!missing(HHE_fin) & trim(HHE_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & !missing(HHD_fin))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHE_debut E1 E2 E3 E3A EMPLOYE HHE_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue E."
        exit 459
    }
    save "$section_output\06_E.dta", replace
restore

display as result "Controles section E termines."
