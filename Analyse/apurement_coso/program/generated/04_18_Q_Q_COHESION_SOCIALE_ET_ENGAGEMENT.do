/*===========================================================================
  Section Q.COHESION SOCIALE ET ENGAGEMENT
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

cap mkdir "$document\18_Q"

*---------------------------------------------------------------------------
* HHQ_debut - HHQ_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHQ_debut) | trim(HHQ_debut) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHQ_debut manquant dans son univers" if ((missing(HHQ_debut) | trim(HHQ_debut) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHQ_debut) | trim(HHQ_debut) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHQ_debut) | trim(HHQ_debut) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHQ_debut commentaire source_regle action_proposee ///
        using "$document\18_Q\HHQ_debut_manquant.xlsx", ///
        if ((missing(HHQ_debut) | trim(HHQ_debut) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHQ_debut) & trim(HHQ_debut) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHQ_debut renseigne hors univers" if ((!missing(HHQ_debut) & trim(HHQ_debut) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHQ_debut) & trim(HHQ_debut) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHQ_debut) & trim(HHQ_debut) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHQ_debut commentaire source_regle action_proposee ///
        using "$document\18_Q\HHQ_debut_hors_univers.xlsx", ///
        if ((!missing(HHQ_debut) & trim(HHQ_debut) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* Q1 - Q1. Etes-vous membre d'une association, cooperative, groupe ou organisation communautaire ?
* Type questionnaire : single-select
count if (missing(Q1)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q1 manquant dans son univers" if (missing(Q1)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(Q1)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(Q1)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q1 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q1_manquant.xlsx", ///
        if (missing(Q1)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(Q1)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q1 renseigne hors univers" if (!missing(Q1)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(Q1)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(Q1)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q1 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q1_hors_univers.xlsx", ///
        if (!missing(Q1)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(Q1, 1, 2))) & (!missing(Q1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q1 hors domaine questionnaire" if !((inlist(Q1, 1, 2))) & (!missing(Q1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(Q1, 1, 2))) & (!missing(Q1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(Q1, 1, 2))) & (!missing(Q1)) & ($audit_scope)
    export excel interview__key cover_district Q1 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q1_hors_domaine.xlsx", ///
        if !((inlist(Q1, 1, 2))) & (!missing(Q1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* Q2 - Q2. Au cours des 30 derniers jours, combien de fois avez-vous donne de votre temps libre pour une activite dinteret general, comme un nettoyage, une collecte de fonds, ou lorganisa
* Type questionnaire : text
count if ((missing(Q2) | trim(Q2) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q2 manquant dans son univers" if ((missing(Q2) | trim(Q2) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(Q2) | trim(Q2) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(Q2) | trim(Q2) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q2 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q2_manquant.xlsx", ///
        if ((missing(Q2) | trim(Q2) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(Q2) & trim(Q2) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q2 renseigne hors univers" if ((!missing(Q2) & trim(Q2) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(Q2) & trim(Q2) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(Q2) & trim(Q2) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q2 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q2_hors_univers.xlsx", ///
        if ((!missing(Q2) & trim(Q2) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* Q3 - Q3. De maniere generale, diriez-vous quon peut faire confiance a la plupart des gens, ou quil faut etre tres prudent dans ses relations avec les autres ?
* Type questionnaire : single-select
count if (missing(Q3)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q3 manquant dans son univers" if (missing(Q3)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(Q3)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(Q3)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q3 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q3_manquant.xlsx", ///
        if (missing(Q3)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(Q3)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q3 renseigne hors univers" if (!missing(Q3)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(Q3)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(Q3)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q3 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q3_hors_univers.xlsx", ///
        if (!missing(Q3)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(Q3, 1, 2))) & (!missing(Q3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q3 hors domaine questionnaire" if !((inlist(Q3, 1, 2))) & (!missing(Q3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(Q3, 1, 2))) & (!missing(Q3)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(Q3, 1, 2))) & (!missing(Q3)) & ($audit_scope)
    export excel interview__key cover_district Q3 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q3_hors_domaine.xlsx", ///
        if !((inlist(Q3, 1, 2))) & (!missing(Q3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* Q4 - Q4. Dans quelle mesure faites-vous confiance aux jeunes dorigine differente de la votre (region, religion ou ethnie differente) ?
* Type questionnaire : single-select
count if (missing(Q4)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q4 manquant dans son univers" if (missing(Q4)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(Q4)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(Q4)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q4 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q4_manquant.xlsx", ///
        if (missing(Q4)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(Q4)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q4 renseigne hors univers" if (!missing(Q4)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(Q4)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(Q4)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q4 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q4_hors_univers.xlsx", ///
        if (!missing(Q4)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(Q4, 1, 2, 3, 4, 9))) & (!missing(Q4)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q4 hors domaine questionnaire" if !((inlist(Q4, 1, 2, 3, 4, 9))) & (!missing(Q4)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(Q4, 1, 2, 3, 4, 9))) & (!missing(Q4)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(Q4, 1, 2, 3, 4, 9))) & (!missing(Q4)) & ($audit_scope)
    export excel interview__key cover_district Q4 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q4_hors_domaine.xlsx", ///
        if !((inlist(Q4, 1, 2, 3, 4, 9))) & (!missing(Q4)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* Q5 - Q5. Dans quelle mesure faites-vous confiance a la police pour agir dans votre interet ?
* Type questionnaire : single-select
count if (missing(Q5)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q5 manquant dans son univers" if (missing(Q5)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(Q5)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(Q5)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q5 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q5_manquant.xlsx", ///
        if (missing(Q5)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(Q5)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q5 renseigne hors univers" if (!missing(Q5)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(Q5)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(Q5)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q5 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q5_hors_univers.xlsx", ///
        if (!missing(Q5)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(Q5, 1, 2, 3, 4, 9))) & (!missing(Q5)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q5 hors domaine questionnaire" if !((inlist(Q5, 1, 2, 3, 4, 9))) & (!missing(Q5)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(Q5, 1, 2, 3, 4, 9))) & (!missing(Q5)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(Q5, 1, 2, 3, 4, 9))) & (!missing(Q5)) & ($audit_scope)
    export excel interview__key cover_district Q5 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q5_hors_domaine.xlsx", ///
        if !((inlist(Q5, 1, 2, 3, 4, 9))) & (!missing(Q5)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* Q6 - Q6. Dans quelle mesure faites-vous confiance aux forces armees de Cote dIvoire pour agir dans votre interet ?
* Type questionnaire : single-select
count if (missing(Q6)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q6 manquant dans son univers" if (missing(Q6)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(Q6)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(Q6)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q6 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q6_manquant.xlsx", ///
        if (missing(Q6)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(Q6)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q6 renseigne hors univers" if (!missing(Q6)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(Q6)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(Q6)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q6 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q6_hors_univers.xlsx", ///
        if (!missing(Q6)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(Q6, 1, 2, 3, 4, 9))) & (!missing(Q6)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q6 hors domaine questionnaire" if !((inlist(Q6, 1, 2, 3, 4, 9))) & (!missing(Q6)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(Q6, 1, 2, 3, 4, 9))) & (!missing(Q6)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(Q6, 1, 2, 3, 4, 9))) & (!missing(Q6)) & ($audit_scope)
    export excel interview__key cover_district Q6 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q6_hors_domaine.xlsx", ///
        if !((inlist(Q6, 1, 2, 3, 4, 9))) & (!missing(Q6)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* Q7 - Q7. Dans quelle mesure faites-vous confiance aux chefs traditionnels pour agir dans votre interet ?
* Type questionnaire : single-select
count if (missing(Q7)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q7 manquant dans son univers" if (missing(Q7)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(Q7)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(Q7)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q7 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q7_manquant.xlsx", ///
        if (missing(Q7)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(Q7)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q7 renseigne hors univers" if (!missing(Q7)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(Q7)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(Q7)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q7 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q7_hors_univers.xlsx", ///
        if (!missing(Q7)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(Q7, 1, 2, 3, 4, 9))) & (!missing(Q7)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q7 hors domaine questionnaire" if !((inlist(Q7, 1, 2, 3, 4, 9))) & (!missing(Q7)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(Q7, 1, 2, 3, 4, 9))) & (!missing(Q7)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(Q7, 1, 2, 3, 4, 9))) & (!missing(Q7)) & ($audit_scope)
    export excel interview__key cover_district Q7 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q7_hors_domaine.xlsx", ///
        if !((inlist(Q7, 1, 2, 3, 4, 9))) & (!missing(Q7)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* Q8 - Q8. Dans quelle mesure faites-vous confiance aux chefs religieux pour agir dans votre interet ?
* Type questionnaire : single-select
count if (missing(Q8)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q8 manquant dans son univers" if (missing(Q8)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(Q8)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(Q8)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q8 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q8_manquant.xlsx", ///
        if (missing(Q8)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(Q8)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q8 renseigne hors univers" if (!missing(Q8)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(Q8)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(Q8)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q8 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q8_hors_univers.xlsx", ///
        if (!missing(Q8)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(Q8, 1, 2, 3, 4, 9))) & (!missing(Q8)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q8 hors domaine questionnaire" if !((inlist(Q8, 1, 2, 3, 4, 9))) & (!missing(Q8)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(Q8, 1, 2, 3, 4, 9))) & (!missing(Q8)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(Q8, 1, 2, 3, 4, 9))) & (!missing(Q8)) & ($audit_scope)
    export excel interview__key cover_district Q8 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q8_hors_domaine.xlsx", ///
        if !((inlist(Q8, 1, 2, 3, 4, 9))) & (!missing(Q8)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* Q9 - Q9. Dans quelle mesure faites-vous confiance aux autorites gouvernementales locales (par exemple prefecture, sous-prefecture) pour agir dans votre interet ?
* Type questionnaire : single-select
count if (missing(Q9)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q9 manquant dans son univers" if (missing(Q9)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(Q9)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(Q9)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q9 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q9_manquant.xlsx", ///
        if (missing(Q9)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(Q9)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q9 renseigne hors univers" if (!missing(Q9)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(Q9)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(Q9)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q9 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q9_hors_univers.xlsx", ///
        if (!missing(Q9)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(Q9, 1, 2, 3, 4, 9))) & (!missing(Q9)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q9 hors domaine questionnaire" if !((inlist(Q9, 1, 2, 3, 4, 9))) & (!missing(Q9)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(Q9, 1, 2, 3, 4, 9))) & (!missing(Q9)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(Q9, 1, 2, 3, 4, 9))) & (!missing(Q9)) & ($audit_scope)
    export excel interview__key cover_district Q9 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q9_hors_domaine.xlsx", ///
        if !((inlist(Q9, 1, 2, 3, 4, 9))) & (!missing(Q9)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* Q10 - Q10. Dans quelle mesure faites-vous confiance aux autorites gouvernementales centrales pour agir dans votre interet ?
* Type questionnaire : single-select
count if (missing(Q10)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q10 manquant dans son univers" if (missing(Q10)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(Q10)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(Q10)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q10 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q10_manquant.xlsx", ///
        if (missing(Q10)) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(Q10)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q10 renseigne hors univers" if (!missing(Q10)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(Q10)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(Q10)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district Q10 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q10_hors_univers.xlsx", ///
        if (!missing(Q10)) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(Q10, 1, 2, 3, 4, 9))) & (!missing(Q10)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "Q10 hors domaine questionnaire" if !((inlist(Q10, 1, 2, 3, 4, 9))) & (!missing(Q10)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(Q10, 1, 2, 3, 4, 9))) & (!missing(Q10)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(Q10, 1, 2, 3, 4, 9))) & (!missing(Q10)) & ($audit_scope)
    export excel interview__key cover_district Q10 commentaire source_regle action_proposee ///
        using "$document\18_Q\Q10_hors_domaine.xlsx", ///
        if !((inlist(Q10, 1, 2, 3, 4, 9))) & (!missing(Q10)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHQ_fin - HHQ_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHQ_fin) | trim(HHQ_fin) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHQ_fin manquant dans son univers" if ((missing(HHQ_fin) | trim(HHQ_fin) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHQ_fin) | trim(HHQ_fin) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHQ_fin) | trim(HHQ_fin) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHQ_fin commentaire source_regle action_proposee ///
        using "$document\18_Q\HHQ_fin_manquant.xlsx", ///
        if ((missing(HHQ_fin) | trim(HHQ_fin) == "")) & ((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHQ_fin) & trim(HHQ_fin) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHQ_fin renseigne hors univers" if ((!missing(HHQ_fin) & trim(HHQ_fin) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHQ_fin) & trim(HHQ_fin) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHQ_fin) & trim(HHQ_fin) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHQ_fin commentaire source_regle action_proposee ///
        using "$document\18_Q\HHQ_fin_hors_univers.xlsx", ///
        if ((!missing(HHQ_fin) & trim(HHQ_fin) != "")) & !((!missing(HHP_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHQ_debut Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10 HHQ_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue Q."
        exit 459
    }
    save "$section_output\18_Q.dta", replace
restore

display as result "Controles section Q termines."
