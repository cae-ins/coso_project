/*===========================================================================
  Section R. SUIVI PANEL
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

cap mkdir "$document\19_R"

*---------------------------------------------------------------------------
* HHR_debut - HHR_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHR_debut) | trim(HHR_debut) == "")) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHR_debut manquant dans son univers" if ((missing(HHR_debut) | trim(HHR_debut) == "")) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHR_debut) | trim(HHR_debut) == "")) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHR_debut) | trim(HHR_debut) == "")) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHR_debut commentaire source_regle action_proposee ///
        using "$document\19_R\HHR_debut_manquant.xlsx", ///
        if ((missing(HHR_debut) | trim(HHR_debut) == "")) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHR_debut) & trim(HHR_debut) != "")) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHR_debut renseigne hors univers" if ((!missing(HHR_debut) & trim(HHR_debut) != "")) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHR_debut) & trim(HHR_debut) != "")) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHR_debut) & trim(HHR_debut) != "")) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHR_debut commentaire source_regle action_proposee ///
        using "$document\19_R\HHR_debut_hors_univers.xlsx", ///
        if ((!missing(HHR_debut) & trim(HHR_debut) != "")) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* R1 - R1. Est-ce que le numero avec lequel nous vous avons joint aujourdhui est le meilleur moyen de vous contacter pour les prochaines vagues de cette etude ?
* Type questionnaire : single-select
count if (missing(R1)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R1 manquant dans son univers" if (missing(R1)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(R1)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(R1)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district R1 commentaire source_regle action_proposee ///
        using "$document\19_R\R1_manquant.xlsx", ///
        if (missing(R1)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(R1)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R1 renseigne hors univers" if (!missing(R1)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(R1)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(R1)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district R1 commentaire source_regle action_proposee ///
        using "$document\19_R\R1_hors_univers.xlsx", ///
        if (!missing(R1)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(R1, 1, 2))) & (!missing(R1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R1 hors domaine questionnaire" if !((inlist(R1, 1, 2))) & (!missing(R1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(R1, 1, 2))) & (!missing(R1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(R1, 1, 2))) & (!missing(R1)) & ($audit_scope)
    export excel interview__key cover_district R1 commentaire source_regle action_proposee ///
        using "$document\19_R\R1_hors_domaine.xlsx", ///
        if !((inlist(R1, 1, 2))) & (!missing(R1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* R1A - R1A. Quel est le meilleur numero pour vous contacter a l'avenir ?
* Type questionnaire : text
* Variable sensible exclue des rapports automatiques.

*---------------------------------------------------------------------------
* R2 - R2. Avez-vous un autre numero que nous pourrions essayer si celui-ci ne fonctionne pas ?
* Type questionnaire : single-select
count if (missing(R2)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R2 manquant dans son univers" if (missing(R2)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(R2)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(R2)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district R2 commentaire source_regle action_proposee ///
        using "$document\19_R\R2_manquant.xlsx", ///
        if (missing(R2)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(R2)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R2 renseigne hors univers" if (!missing(R2)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(R2)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(R2)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district R2 commentaire source_regle action_proposee ///
        using "$document\19_R\R2_hors_univers.xlsx", ///
        if (!missing(R2)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(R2, 1, 2))) & (!missing(R2)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R2 hors domaine questionnaire" if !((inlist(R2, 1, 2))) & (!missing(R2)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(R2, 1, 2))) & (!missing(R2)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(R2, 1, 2))) & (!missing(R2)) & ($audit_scope)
    export excel interview__key cover_district R2 commentaire source_regle action_proposee ///
        using "$document\19_R\R2_hors_domaine.xlsx", ///
        if !((inlist(R2, 1, 2))) & (!missing(R2)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* R2A - R2A. Quel est ce numero ?
* Type questionnaire : text
* Variable sensible exclue des rapports automatiques.

*---------------------------------------------------------------------------
* R3 - R3. Utilisez-vous WhatsApp ?
* Type questionnaire : single-select
count if (missing(R3)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R3 manquant dans son univers" if (missing(R3)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(R3)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(R3)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district R3 commentaire source_regle action_proposee ///
        using "$document\19_R\R3_manquant.xlsx", ///
        if (missing(R3)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(R3)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R3 renseigne hors univers" if (!missing(R3)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(R3)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(R3)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district R3 commentaire source_regle action_proposee ///
        using "$document\19_R\R3_hors_univers.xlsx", ///
        if (!missing(R3)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(R3, 1, 2))) & (!missing(R3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R3 hors domaine questionnaire" if !((inlist(R3, 1, 2))) & (!missing(R3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(R3, 1, 2))) & (!missing(R3)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(R3, 1, 2))) & (!missing(R3)) & ($audit_scope)
    export excel interview__key cover_district R3 commentaire source_regle action_proposee ///
        using "$document\19_R\R3_hors_domaine.xlsx", ///
        if !((inlist(R3, 1, 2))) & (!missing(R3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* R3A - R3A. Ce compte WhatsApp est-il lie au meme numero que nous utiliserons pour vous contacter a l'avenir ?
* Type questionnaire : single-select
count if (missing(R3A)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(R3) & (R3 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R3A manquant dans son univers" if (missing(R3A)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(R3) & (R3 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(R3A)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(R3) & (R3 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(R3A)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(R3) & (R3 == 1)))) & ($audit_scope)
    export excel interview__key cover_district R3A commentaire source_regle action_proposee ///
        using "$document\19_R\R3A_manquant.xlsx", ///
        if (missing(R3A)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(R3) & (R3 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(R3A)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(R3) & (R3 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R3A renseigne hors univers" if (!missing(R3A)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(R3) & (R3 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(R3A)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(R3) & (R3 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(R3A)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(R3) & (R3 == 1)))) & ($audit_scope)
    export excel interview__key cover_district R3A commentaire source_regle action_proposee ///
        using "$document\19_R\R3A_hors_univers.xlsx", ///
        if (!missing(R3A)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & ((!missing(R3) & (R3 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(R3A, 1, 2))) & (!missing(R3A)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R3A hors domaine questionnaire" if !((inlist(R3A, 1, 2))) & (!missing(R3A)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(R3A, 1, 2))) & (!missing(R3A)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(R3A, 1, 2))) & (!missing(R3A)) & ($audit_scope)
    export excel interview__key cover_district R3A commentaire source_regle action_proposee ///
        using "$document\19_R\R3A_hors_domaine.xlsx", ///
        if !((inlist(R3A, 1, 2))) & (!missing(R3A)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* R3B - R3B. Quuel numero est lie a votre compte WhatsApp ?
* Type questionnaire : text
* Variable sensible exclue des rapports automatiques.

*---------------------------------------------------------------------------
* R4 - R4. Pouvez-vous fournir le contact d'une personne pouvant vous joindre facilement, au cas ou nous narriverions pas a vous contacter directement ?
* Type questionnaire : text
* Variable sensible exclue des rapports automatiques.

*---------------------------------------------------------------------------
* R5 - R5. Acceptez-vous d'etre recontacte pour les prochaines vagues de cette etude ?
* Type questionnaire : single-select
count if (missing(R5)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R5 manquant dans son univers" if (missing(R5)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(R5)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(R5)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district R5 commentaire source_regle action_proposee ///
        using "$document\19_R\R5_manquant.xlsx", ///
        if (missing(R5)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(R5)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R5 renseigne hors univers" if (!missing(R5)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(R5)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(R5)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district R5 commentaire source_regle action_proposee ///
        using "$document\19_R\R5_hors_univers.xlsx", ///
        if (!missing(R5)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(R5, 1, 2))) & (!missing(R5)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R5 hors domaine questionnaire" if !((inlist(R5, 1, 2))) & (!missing(R5)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(R5, 1, 2))) & (!missing(R5)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(R5, 1, 2))) & (!missing(R5)) & ($audit_scope)
    export excel interview__key cover_district R5 commentaire source_regle action_proposee ///
        using "$document\19_R\R5_hors_domaine.xlsx", ///
        if !((inlist(R5, 1, 2))) & (!missing(R5)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* R6 - R6. Veuillez nous indiquer un contact sur lequel vous pouvez recevoir un depot Wave
* Type questionnaire : text
* Variable sensible exclue des rapports automatiques.

*---------------------------------------------------------------------------
* R7 - R7. A qui appartient ce contact ?
* Type questionnaire : single-select
count if (missing(R7)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(R6))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R7 manquant dans son univers" if (missing(R7)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(R6))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(R7)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(R6))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(R7)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(R6))) & ($audit_scope)
    export excel interview__key cover_district R7 commentaire source_regle action_proposee ///
        using "$document\19_R\R7_manquant.xlsx", ///
        if (missing(R7)) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(R6))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(R7)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(R6))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R7 renseigne hors univers" if (!missing(R7)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(R6))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(R7)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(R6))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(R7)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(R6))) & ($audit_scope)
    export excel interview__key cover_district R7 commentaire source_regle action_proposee ///
        using "$document\19_R\R7_hors_univers.xlsx", ///
        if (!missing(R7)) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1))) & (!missing(R6))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(R7, 1, 2, 3))) & (!missing(R7)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "R7 hors domaine questionnaire" if !((inlist(R7, 1, 2, 3))) & (!missing(R7)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(R7, 1, 2, 3))) & (!missing(R7)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(R7, 1, 2, 3))) & (!missing(R7)) & ($audit_scope)
    export excel interview__key cover_district R7 commentaire source_regle action_proposee ///
        using "$document\19_R\R7_hors_domaine.xlsx", ///
        if !((inlist(R7, 1, 2, 3))) & (!missing(R7)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHR_fin - HHR_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHR_fin) | trim(HHR_fin) == "")) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHR_fin manquant dans son univers" if ((missing(HHR_fin) | trim(HHR_fin) == "")) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHR_fin) | trim(HHR_fin) == "")) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHR_fin) | trim(HHR_fin) == "")) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHR_fin commentaire source_regle action_proposee ///
        using "$document\19_R\HHR_fin_manquant.xlsx", ///
        if ((missing(HHR_fin) | trim(HHR_fin) == "")) & ((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHR_fin) & trim(HHR_fin) != "")) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHR_fin renseigne hors univers" if ((!missing(HHR_fin) & trim(HHR_fin) != "")) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHR_fin) & trim(HHR_fin) != "")) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHR_fin) & trim(HHR_fin) != "")) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHR_fin commentaire source_regle action_proposee ///
        using "$document\19_R\HHR_fin_hors_univers.xlsx", ///
        if ((!missing(HHR_fin) & trim(HHR_fin) != "")) & !((!missing(HHQ_fin) & (!missing(consentement) & (consentement == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHR_debut R1 R1A R2 R2A R3 R3A R3B R4 R5 R6 R7 HHR_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue R."
        exit 459
    }
    save "$section_output\19_R.dta", replace
restore

display as result "Controles section R termines."
