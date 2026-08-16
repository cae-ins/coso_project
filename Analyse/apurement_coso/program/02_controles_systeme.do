/* Integrite technique, statut Survey Solutions et consentement. */

use "$working_base", clear
cap mkdir "$document\00_systeme_restreint"

cap drop commentaire
gen str244 commentaire = ""
cap drop source_regle
gen str60 source_regle = ""
cap drop action_proposee
gen str60 action_proposee = ""

* Cle technique manquante.
count if missing(interview__key) | trim(interview__key) == ""
if r(N)>0 {
    replace commentaire = "Cle technique absente" if missing(interview__key) | trim(interview__key) == ""
    replace source_regle = "donnee_systeme" if missing(interview__key) | trim(interview__key) == ""
    replace action_proposee = "bloquer_et_revoir" if missing(interview__key) | trim(interview__key) == ""
    export excel interview__key cover_district nom_agent commentaire source_regle action_proposee ///
        using "$document\00_systeme_restreint\interview_key_manquante.xlsx", ///
        if missing(interview__key) | trim(interview__key) == "", firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

* Cle technique dupliquee : aucun choix de fiche n'est fait automatiquement.
cap drop __n_key
bysort interview__key: gen long __n_key = _N if !missing(interview__key)
count if __n_key > 1
if r(N)>0 {
    replace commentaire = "Cle technique dupliquee" if __n_key > 1
    replace source_regle = "donnee_systeme" if __n_key > 1
    replace action_proposee = "bloquer_et_revoir" if __n_key > 1
    export excel interview__key cover_district nom_agent interview__status consentement commentaire source_regle action_proposee ///
        using "$document\00_systeme_restreint\interview_key_dupliquee.xlsx", ///
        if __n_key > 1, firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

* cover_id duplique : rapport interne restreint, sans deduplication.
capture confirm variable cover_id
if !_rc {
    cap drop __n_cover
    bysort cover_id: gen long __n_cover = _N if !missing(cover_id)
    count if __n_cover > 1
    if r(N)>0 {
        replace commentaire = "cover_id repete; statut institutionnel a confirmer" if __n_cover > 1
        replace source_regle = "donnee_observee" if __n_cover > 1
        replace action_proposee = "revue_manuelle_sans_deduplication" if __n_cover > 1
        export excel interview__key cover_id cover_district nom_agent interview__status consentement commentaire source_regle action_proposee ///
            using "$document\00_systeme_restreint\cover_id_duplique.xlsx", ///
            if __n_cover > 1, firstrow(variables) replace
        replace commentaire = ""
        replace source_regle = ""
        replace action_proposee = ""
    }
}

* Statut et consentement : hypothese analytique, pas une suppression.
count if missing(interview__status) | interview__status != 100
if r(N)>0 {
    replace commentaire = "Entretien hors statut Completed 100" if missing(interview__status) | interview__status != 100
    replace source_regle = "Survey Solutions/hypothese_analytique" if missing(interview__status) | interview__status != 100
    replace action_proposee = "exclure_analyse_apres_validation" if missing(interview__status) | interview__status != 100
    export excel interview__key cover_district nom_agent interview__status consentement commentaire source_regle action_proposee ///
        using "$document\00_systeme_restreint\statut_non_complete.xlsx", ///
        if missing(interview__status) | interview__status != 100, firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

count if missing(consentement) | consentement != 1
if r(N)>0 {
    replace commentaire = "Consentement absent ou non positif" if missing(consentement) | consentement != 1
    replace source_regle = "questionnaire/hypothese_analytique" if missing(consentement) | consentement != 1
    replace action_proposee = "exclure_analyse_apres_validation" if missing(consentement) | consentement != 1
    export excel interview__key cover_district nom_agent interview__status consentement commentaire source_regle action_proposee ///
        using "$document\00_systeme_restreint\consentement_non_positif.xlsx", ///
        if missing(consentement) | consentement != 1, firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

cap drop analysis_eligible_provisoire
gen byte analysis_eligible_provisoire = interview__status == 100 & consentement == 1 & (__n_key == 1)
label variable analysis_eligible_provisoire "Hypothese provisoire: statut 100 + consentement positif + cle unique"

drop commentaire source_regle action_proposee __n_key
cap drop __n_cover
save_working_safe
