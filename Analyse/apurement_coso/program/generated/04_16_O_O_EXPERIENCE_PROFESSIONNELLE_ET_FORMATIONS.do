/*===========================================================================
  Section O. EXPERIENCE PROFESSIONNELLE ET FORMATIONS
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

cap mkdir "$document\16_O"

*---------------------------------------------------------------------------
* HHO_debut - HHO_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHO_debut) | trim(HHO_debut) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHO_debut manquant dans son univers" if ((missing(HHO_debut) | trim(HHO_debut) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHO_debut) | trim(HHO_debut) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHO_debut) | trim(HHO_debut) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHO_debut commentaire source_regle action_proposee ///
        using "$document\16_O\HHO_debut_manquant.xlsx", ///
        if ((missing(HHO_debut) | trim(HHO_debut) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHO_debut) & trim(HHO_debut) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHO_debut renseigne hors univers" if ((!missing(HHO_debut) & trim(HHO_debut) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHO_debut) & trim(HHO_debut) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHO_debut) & trim(HHO_debut) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHO_debut commentaire source_regle action_proposee ///
        using "$document\16_O\HHO_debut_hors_univers.xlsx", ///
        if ((!missing(HHO_debut) & trim(HHO_debut) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* O1 - O1. En dehors de votre activite principale actuelle, avez-vous deja eu un autre emploi ou une autre activite generatrice de revenus auparavant ?
* Type questionnaire : single-select
count if (missing(O1)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(HHO_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O1 manquant dans son univers" if (missing(O1)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(HHO_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(O1)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(HHO_debut))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(O1)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(HHO_debut))) & ($audit_scope)
    export excel interview__key cover_district O1 commentaire source_regle action_proposee ///
        using "$document\16_O\O1_manquant.xlsx", ///
        if (missing(O1)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(HHO_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(O1)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(HHO_debut))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O1 renseigne hors univers" if (!missing(O1)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(HHO_debut))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(O1)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(HHO_debut))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(O1)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(HHO_debut))) & ($audit_scope)
    export excel interview__key cover_district O1 commentaire source_regle action_proposee ///
        using "$document\16_O\O1_hors_univers.xlsx", ///
        if (!missing(O1)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(HHO_debut))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(O1, 1, 2))) & (!missing(O1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O1 hors domaine questionnaire" if !((inlist(O1, 1, 2))) & (!missing(O1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(O1, 1, 2))) & (!missing(O1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(O1, 1, 2))) & (!missing(O1)) & ($audit_scope)
    export excel interview__key cover_district O1 commentaire source_regle action_proposee ///
        using "$document\16_O\O1_hors_domaine.xlsx", ///
        if !((inlist(O1, 1, 2))) & (!missing(O1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* O2 - O2. A quel age avez-vous commence votre tout premier emploi ou votre toute premiere activite generatrice de revenus ?
* Type questionnaire : numeric: integer
count if (missing(O2)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O1) & (O1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O2 manquant dans son univers" if (missing(O2)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O1) & (O1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(O2)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O1) & (O1 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(O2)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O1) & (O1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district O2 commentaire source_regle action_proposee ///
        using "$document\16_O\O2_manquant.xlsx", ///
        if (missing(O2)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O1) & (O1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(O2)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O1) & (O1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O2 renseigne hors univers" if (!missing(O2)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O1) & (O1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(O2)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O1) & (O1 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(O2)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O1) & (O1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district O2 commentaire source_regle action_proposee ///
        using "$document\16_O\O2_hors_univers.xlsx", ///
        if (!missing(O2)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O1) & (O1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* O3 - O3. Avez-vous suivi une formation professionnelle ou technique, ou un apprentissage (formel ou informel), au cours des 12 derniers mois ?
* Type questionnaire : single-select
count if (missing(O3)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O3 manquant dans son univers" if (missing(O3)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(O3)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(O3)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district O3 commentaire source_regle action_proposee ///
        using "$document\16_O\O3_manquant.xlsx", ///
        if (missing(O3)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(O3)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O3 renseigne hors univers" if (!missing(O3)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(O3)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(O3)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district O3 commentaire source_regle action_proposee ///
        using "$document\16_O\O3_hors_univers.xlsx", ///
        if (!missing(O3)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(O3, 1, 2))) & (!missing(O3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O3 hors domaine questionnaire" if !((inlist(O3, 1, 2))) & (!missing(O3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(O3, 1, 2))) & (!missing(O3)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(O3, 1, 2))) & (!missing(O3)) & ($audit_scope)
    export excel interview__key cover_district O3 commentaire source_regle action_proposee ///
        using "$document\16_O\O3_hors_domaine.xlsx", ///
        if !((inlist(O3, 1, 2))) & (!missing(O3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* O4 - O4. Dans quel metier ou domaine avez-vous suivi cette formation ?
* Type questionnaire : text
count if ((missing(O4) | trim(O4) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O4 manquant dans son univers" if ((missing(O4) | trim(O4) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(O4) | trim(O4) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(O4) | trim(O4) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    export excel interview__key cover_district O4 commentaire source_regle action_proposee ///
        using "$document\16_O\O4_manquant.xlsx", ///
        if ((missing(O4) | trim(O4) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(O4) & trim(O4) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O4 renseigne hors univers" if ((!missing(O4) & trim(O4) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(O4) & trim(O4) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(O4) & trim(O4) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    export excel interview__key cover_district O4 commentaire source_regle action_proposee ///
        using "$document\16_O\O4_hors_univers.xlsx", ///
        if ((!missing(O4) & trim(O4) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* O5 - O5. Qui a principalement dispense cette formation ?
* Type questionnaire : single-select
count if (missing(O5)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O5 manquant dans son univers" if (missing(O5)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(O5)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(O5)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    export excel interview__key cover_district O5 commentaire source_regle action_proposee ///
        using "$document\16_O\O5_manquant.xlsx", ///
        if (missing(O5)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(O5)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O5 renseigne hors univers" if (!missing(O5)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(O5)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(O5)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    export excel interview__key cover_district O5 commentaire source_regle action_proposee ///
        using "$document\16_O\O5_hors_univers.xlsx", ///
        if (!missing(O5)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(O5, 1, 2, 3, 4, 5, 6, 9))) & (!missing(O5)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O5 hors domaine questionnaire" if !((inlist(O5, 1, 2, 3, 4, 5, 6, 9))) & (!missing(O5)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(O5, 1, 2, 3, 4, 5, 6, 9))) & (!missing(O5)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(O5, 1, 2, 3, 4, 5, 6, 9))) & (!missing(O5)) & ($audit_scope)
    export excel interview__key cover_district O5 commentaire source_regle action_proposee ///
        using "$document\16_O\O5_hors_domaine.xlsx", ///
        if !((inlist(O5, 1, 2, 3, 4, 5, 6, 9))) & (!missing(O5)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* O6 - O6. Dans quelle mesure cette formation vous a-t-elle ete utile pour trouver un emploi ou ameliorer vos revenus ?
* Type questionnaire : single-select
count if (missing(O6)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O6 manquant dans son univers" if (missing(O6)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(O6)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(O6)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    export excel interview__key cover_district O6 commentaire source_regle action_proposee ///
        using "$document\16_O\O6_manquant.xlsx", ///
        if (missing(O6)) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(O6)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O6 renseigne hors univers" if (!missing(O6)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(O6)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(O6)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope)
    export excel interview__key cover_district O6 commentaire source_regle action_proposee ///
        using "$document\16_O\O6_hors_univers.xlsx", ///
        if (!missing(O6)) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(O3) & (O3 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(O6, 1, 2, 3))) & (!missing(O6)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "O6 hors domaine questionnaire" if !((inlist(O6, 1, 2, 3))) & (!missing(O6)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(O6, 1, 2, 3))) & (!missing(O6)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(O6, 1, 2, 3))) & (!missing(O6)) & ($audit_scope)
    export excel interview__key cover_district O6 commentaire source_regle action_proposee ///
        using "$document\16_O\O6_hors_domaine.xlsx", ///
        if !((inlist(O6, 1, 2, 3))) & (!missing(O6)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHO_fin - HHO_fin. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHO_fin) | trim(HHO_fin) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHO_fin manquant dans son univers" if ((missing(HHO_fin) | trim(HHO_fin) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHO_fin) | trim(HHO_fin) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHO_fin) | trim(HHO_fin) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHO_fin commentaire source_regle action_proposee ///
        using "$document\16_O\HHO_fin_manquant.xlsx", ///
        if ((missing(HHO_fin) | trim(HHO_fin) == "")) & ((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHO_fin) & trim(HHO_fin) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHO_fin renseigne hors univers" if ((!missing(HHO_fin) & trim(HHO_fin) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHO_fin) & trim(HHO_fin) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHO_fin) & trim(HHO_fin) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHO_fin commentaire source_regle action_proposee ///
        using "$document\16_O\HHO_fin_hors_univers.xlsx", ///
        if ((!missing(HHO_fin) & trim(HHO_fin) != "")) & !((!missing(HHN_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHO_debut O1 O2 O3 O4 O5 O6 HHO_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue O."
        exit 459
    }
    save "$section_output\16_O.dta", replace
restore

display as result "Controles section O termines."
