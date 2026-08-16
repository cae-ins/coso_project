/*===========================================================================
  Section H. REVENU ET CARACTERISTIQUES DE L'ENTREPRISE
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

cap mkdir "$document\09_H"

*---------------------------------------------------------------------------
* HHH_debut - HHH_debut. Heure de debut
* Type questionnaire : date: current time
count if ((missing(HHH_debut) | trim(HHH_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHH_debut manquant dans son univers" if ((missing(HHH_debut) | trim(HHH_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHH_debut) | trim(HHH_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHH_debut) | trim(HHH_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHH_debut commentaire source_regle action_proposee ///
        using "$document\09_H\HHH_debut_manquant.xlsx", ///
        if ((missing(HHH_debut) | trim(HHH_debut) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHH_debut) & trim(HHH_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHH_debut renseigne hors univers" if ((!missing(HHH_debut) & trim(HHH_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHH_debut) & trim(HHH_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHH_debut) & trim(HHH_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHH_debut commentaire source_regle action_proposee ///
        using "$document\09_H\HHH_debut_hors_univers.xlsx", ///
        if ((!missing(HHH_debut) & trim(HHH_debut) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* H1 - H1. Comment etes-vous paye pour cet emploi ?
* Type questionnaire : single-select
count if (missing(H1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H1 manquant dans son univers" if (missing(H1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(H1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(H1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district H1 commentaire source_regle action_proposee ///
        using "$document\09_H\H1_manquant.xlsx", ///
        if (missing(H1)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(H1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H1 renseigne hors univers" if (!missing(H1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(H1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(H1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district H1 commentaire source_regle action_proposee ///
        using "$document\09_H\H1_hors_univers.xlsx", ///
        if (!missing(H1)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(H1, 1, 2, 3))) & (!missing(H1)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H1 hors domaine questionnaire" if !((inlist(H1, 1, 2, 3))) & (!missing(H1)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(H1, 1, 2, 3))) & (!missing(H1)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(H1, 1, 2, 3))) & (!missing(H1)) & ($audit_scope)
    export excel interview__key cover_district H1 commentaire source_regle action_proposee ///
        using "$document\09_H\H1_hors_domaine.xlsx", ///
        if !((inlist(H1, 1, 2, 3))) & (!missing(H1)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* H2 - H2. A quelle frequence etes-vous paye ?
* Type questionnaire : single-select
count if (missing(H2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H2 manquant dans son univers" if (missing(H2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(H2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(H2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district H2 commentaire source_regle action_proposee ///
        using "$document\09_H\H2_manquant.xlsx", ///
        if (missing(H2)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(H2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H2 renseigne hors univers" if (!missing(H2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(H2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(H2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope)
    export excel interview__key cover_district H2 commentaire source_regle action_proposee ///
        using "$document\09_H\H2_hors_univers.xlsx", ///
        if (!missing(H2)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(F1) & (F1 == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(H2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10))) & (!missing(H2)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H2 hors domaine questionnaire" if !((inlist(H2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10))) & (!missing(H2)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(H2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10))) & (!missing(H2)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(H2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10))) & (!missing(H2)) & ($audit_scope)
    export excel interview__key cover_district H2 commentaire source_regle action_proposee ///
        using "$document\09_H\H2_hors_domaine.xlsx", ///
        if !((inlist(H2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10))) & (!missing(H2)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* H3 - H3. Quel a ete votre salaire net (valeur en especes, incluant tout paiement en nature) pour votre derniere periode de paie ?
* Type questionnaire : numeric: integer
count if (missing(H3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H3 manquant dans son univers" if (missing(H3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(H3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(H3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district H3 commentaire source_regle action_proposee ///
        using "$document\09_H\H3_manquant.xlsx", ///
        if (missing(H3)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(H3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H3 renseigne hors univers" if (!missing(H3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(H3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(H3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district H3 commentaire source_regle action_proposee ///
        using "$document\09_H\H3_hors_univers.xlsx", ///
        if (!missing(H3)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (inlist(H3, 99999)) & (!missing(H3)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H3 contient un code special autorise" if (inlist(H3, 99999)) & (!missing(H3)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (inlist(H3, 99999)) & (!missing(H3)) & ($audit_scope)
    replace action_proposee = "recodage_analyse_a_valider" if (inlist(H3, 99999)) & (!missing(H3)) & ($audit_scope)
    export excel interview__key cover_district H3 commentaire source_regle action_proposee ///
        using "$document\09_H\H3_code_special.xlsx", ///
        if (inlist(H3, 99999)) & (!missing(H3)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* H3A - H3A. Pouvez-vous indiquer la tranche svp ?
* Type questionnaire : single-select
count if (missing(H3A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H3) & (H3 == 99999)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H3A manquant dans son univers" if (missing(H3A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H3) & (H3 == 99999)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(H3A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H3) & (H3 == 99999)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(H3A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H3) & (H3 == 99999)))) & ($audit_scope)
    export excel interview__key cover_district H3A commentaire source_regle action_proposee ///
        using "$document\09_H\H3A_manquant.xlsx", ///
        if (missing(H3A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H3) & (H3 == 99999)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(H3A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H3) & (H3 == 99999)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H3A renseigne hors univers" if (!missing(H3A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H3) & (H3 == 99999)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(H3A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H3) & (H3 == 99999)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(H3A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H3) & (H3 == 99999)))) & ($audit_scope)
    export excel interview__key cover_district H3A commentaire source_regle action_proposee ///
        using "$document\09_H\H3A_hors_univers.xlsx", ///
        if (!missing(H3A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H3) & (H3 == 99999)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(H3A, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(H3A)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H3A hors domaine questionnaire" if !((inlist(H3A, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(H3A)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(H3A, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(H3A)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(H3A, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(H3A)) & ($audit_scope)
    export excel interview__key cover_district H3A commentaire source_regle action_proposee ///
        using "$document\09_H\H3A_hors_domaine.xlsx", ///
        if !((inlist(H3A, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(H3A)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* H4 - H4. Cette activite/entreprise est-elle enregistree (par exemple aupres des impots, du registre de commerce, ou des autorites locales) ?
* Type questionnaire : single-select
count if (missing(H4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H4 manquant dans son univers" if (missing(H4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(H4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(H4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
    export excel interview__key cover_district H4 commentaire source_regle action_proposee ///
        using "$document\09_H\H4_manquant.xlsx", ///
        if (missing(H4)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(H4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H4 renseigne hors univers" if (!missing(H4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(H4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(H4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
    export excel interview__key cover_district H4 commentaire source_regle action_proposee ///
        using "$document\09_H\H4_hors_univers.xlsx", ///
        if (!missing(H4)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(H4, 1, 2, 3))) & (!missing(H4)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H4 hors domaine questionnaire" if !((inlist(H4, 1, 2, 3))) & (!missing(H4)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(H4, 1, 2, 3))) & (!missing(H4)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(H4, 1, 2, 3))) & (!missing(H4)) & ($audit_scope)
    export excel interview__key cover_district H4 commentaire source_regle action_proposee ///
        using "$document\09_H\H4_hors_domaine.xlsx", ///
        if !((inlist(H4, 1, 2, 3))) & (!missing(H4)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* H4A - H4A. Combien de travailleurs remuneres avez-vous actuellement, sans vous compter vous-meme ?
* Type questionnaire : numeric: integer
count if (missing(H4A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H4A manquant dans son univers" if (missing(H4A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(H4A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(H4A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3)))) & ($audit_scope)
    export excel interview__key cover_district H4A commentaire source_regle action_proposee ///
        using "$document\09_H\H4A_manquant.xlsx", ///
        if (missing(H4A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(H4A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H4A renseigne hors univers" if (!missing(H4A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(H4A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(H4A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3)))) & ($audit_scope)
    export excel interview__key cover_district H4A commentaire source_regle action_proposee ///
        using "$document\09_H\H4A_hors_univers.xlsx", ///
        if (!missing(H4A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* H5 - H5. Environ combien avez-vous personnellement gagne ou retire de cette activite le mois dernier, apres deduction des depenses de base donnez simplement votre meilleure estimation ?
* Type questionnaire : numeric: integer
count if (missing(H5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H5 manquant dans son univers" if (missing(H5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(H5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(H5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
    export excel interview__key cover_district H5 commentaire source_regle action_proposee ///
        using "$document\09_H\H5_manquant.xlsx", ///
        if (missing(H5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(H5)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H5 renseigne hors univers" if (!missing(H5)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(H5)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(H5)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope)
    export excel interview__key cover_district H5 commentaire source_regle action_proposee ///
        using "$document\09_H\H5_hors_univers.xlsx", ///
        if (!missing(H5)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (inlist(H5, 999999)) & (!missing(H5)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H5 contient un code special autorise" if (inlist(H5, 999999)) & (!missing(H5)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (inlist(H5, 999999)) & (!missing(H5)) & ($audit_scope)
    replace action_proposee = "recodage_analyse_a_valider" if (inlist(H5, 999999)) & (!missing(H5)) & ($audit_scope)
    export excel interview__key cover_district H5 commentaire source_regle action_proposee ///
        using "$document\09_H\H5_code_special.xlsx", ///
        if (inlist(H5, 999999)) & (!missing(H5)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(H5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & !((!missing(H5) & (H5 > 0))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H5 viole la validation questionnaire 1" if (!missing(H5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & !((!missing(H5) & (H5 > 0))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(H5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & !((!missing(H5) & (H5 > 0))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (!missing(H5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & !((!missing(H5) & (H5 > 0))) & ($audit_scope)
    export excel interview__key cover_district H5 commentaire source_regle action_proposee ///
        using "$document\09_H\H5_validation_1.xlsx", ///
        if (!missing(H5)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((inlist(F1, 2, 3, 4)))) & !((!missing(H5) & (H5 > 0))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* H5A - H5A. Pouvez-vous indiquer la tranche svp ?
* Type questionnaire : single-select
count if (missing(H5A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H5) & (H5 == 999999)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H5A manquant dans son univers" if (missing(H5A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H5) & (H5 == 999999)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (missing(H5A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H5) & (H5 == 999999)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if (missing(H5A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H5) & (H5 == 999999)))) & ($audit_scope)
    export excel interview__key cover_district H5A commentaire source_regle action_proposee ///
        using "$document\09_H\H5A_manquant.xlsx", ///
        if (missing(H5A)) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H5) & (H5 == 999999)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if (!missing(H5A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H5) & (H5 == 999999)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H5A renseigne hors univers" if (!missing(H5A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H5) & (H5 == 999999)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if (!missing(H5A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H5) & (H5 == 999999)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if (!missing(H5A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H5) & (H5 == 999999)))) & ($audit_scope)
    export excel interview__key cover_district H5A commentaire source_regle action_proposee ///
        using "$document\09_H\H5A_hors_univers.xlsx", ///
        if (!missing(H5A)) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1))) & ((!missing(H5) & (H5 == 999999)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if !((inlist(H5A, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(H5A)) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "H5A hors domaine questionnaire" if !((inlist(H5A, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(H5A)) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if !((inlist(H5A, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(H5A)) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if !((inlist(H5A, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(H5A)) & ($audit_scope)
    export excel interview__key cover_district H5A commentaire source_regle action_proposee ///
        using "$document\09_H\H5A_hors_domaine.xlsx", ///
        if !((inlist(H5A, 1, 2, 3, 4, 5, 6, 7, 8))) & (!missing(H5A)) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

*---------------------------------------------------------------------------
* HHH_fin - HHH_fin. Heure de fin
* Type questionnaire : date: current time
count if ((missing(HHH_fin) | trim(HHH_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHH_fin manquant dans son univers" if ((missing(HHH_fin) | trim(HHH_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((missing(HHH_fin) | trim(HHH_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "revue_manuelle" if ((missing(HHH_fin) | trim(HHH_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHH_fin commentaire source_regle action_proposee ///
        using "$document\09_H\HHH_fin_manquant.xlsx", ///
        if ((missing(HHH_fin) | trim(HHH_fin) == "")) & (((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}
count if ((!missing(HHH_fin) & trim(HHH_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
if r(N)>0 {
    replace commentaire = "HHH_fin renseigne hors univers" if ((!missing(HHH_fin) & trim(HHH_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace source_regle = "questionnaire+hypothese_apurement" if ((!missing(HHH_fin) & trim(HHH_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    replace action_proposee = "vider_apres_validation" if ((!missing(HHH_fin) & trim(HHH_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope)
    export excel interview__key cover_district HHH_fin commentaire source_regle action_proposee ///
        using "$document\09_H\HHH_fin_hors_univers.xlsx", ///
        if ((!missing(HHH_fin) & trim(HHH_fin) != "")) & !(((!missing(consentement) & (consentement == 1)) & (!missing(EMPLOYE) & (EMPLOYE == 1)))) & ($audit_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

preserve
    keep if $audit_scope
    keep interview__key cover_district HHH_debut H1 H2 H3 H3A H4 H4A H5 H5A HHH_fin
    capture isid interview__key
    if _rc {
        display as error "Cle interview__key non unique dans la vue H."
        exit 459
    }
    save "$section_output\09_H.dta", replace
restore

display as result "Controles section H termines."
