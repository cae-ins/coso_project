/*
Controles issus des donnees, du PAD ou du raisonnement metier.
Ils restent a valider et n'entrainent aucune correction automatique.
*/

use "$working_base", clear
cap mkdir "$document\50_metier_propose"

cap drop commentaire
gen str244 commentaire = ""
cap drop source_regle
gen str60 source_regle = ""
cap drop action_proposee
gen str60 action_proposee = ""

* Age plausible 15-99 : metier_propose car age est une variable calculee.
count if !missing(age) & (age < 15 | age > 99) & ($metier_scope)
if r(N)>0 {
    replace commentaire = "Age hors plage plausible 15-99" if !missing(age) & (age < 15 | age > 99) & ($metier_scope)
    replace source_regle = "metier_propose" if !missing(age) & (age < 15 | age > 99) & ($metier_scope)
    replace action_proposee = "revue_manuelle" if !missing(age) & (age < 15 | age > 99) & ($metier_scope)
    export excel interview__key cover_district nom_agent age C2 C2A_annee commentaire source_regle action_proposee ///
        using "$document\50_metier_propose\age_hors_domaine.xlsx", ///
        if !missing(age) & (age < 15 | age > 99) & ($metier_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

* Cible PAD provisoire 15-35 : controle de ciblage, jamais exclusion automatique.
count if !missing(age) & (age < 15 | age > 35) & ($metier_scope)
if r(N)>0 {
    replace commentaire = "Age hors cible PAD provisoire 15-35" if !missing(age) & (age < 15 | age > 35) & ($metier_scope)
    replace source_regle = "PAD/metier_propose" if !missing(age) & (age < 15 | age > 35) & ($metier_scope)
    replace action_proposee = "revoir_ciblage" if !missing(age) & (age < 15 | age > 35) & ($metier_scope)
    export excel interview__key cover_district nom_agent age commentaire source_regle action_proposee ///
        using "$document\50_metier_propose\age_hors_cible_pad.xlsx", ///
        if !missing(age) & (age < 15 | age > 35) & ($metier_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

* Total d'heures : exclut les codes speciaux du calcul de plausibilite.
cap drop __heures_total
gen double __heures_total = G3 + cond(G5 == 1 & !missing(G6) & G6 <= 168, G6, 0) ///
    if EMPLOYE == 1 & !missing(G3) & inrange(G3, 0, 168) & ($metier_scope)
count if !missing(__heures_total) & __heures_total > 84 & ($metier_scope)
if r(N)>0 {
    replace commentaire = "Total hebdomadaire superieur a 84 heures" if !missing(__heures_total) & __heures_total > 84 & ($metier_scope)
    replace source_regle = "metier_propose" if !missing(__heures_total) & __heures_total > 84 & ($metier_scope)
    replace action_proposee = "revue_manuelle" if !missing(__heures_total) & __heures_total > 84 & ($metier_scope)
    export excel interview__key cover_district nom_agent EMPLOYE G3 G5 G6 __heures_total commentaire source_regle action_proposee ///
        using "$document\50_metier_propose\heures_superieures_84.xlsx", ///
        if !missing(__heures_total) & __heures_total > 84 & ($metier_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

count if EMPLOYE == 1 & inlist(F1, 2, 3) & !missing(H4A) & H4A > 100 & ($metier_scope)
if r(N)>0 {
    replace commentaire = "Nombre de travailleurs remuneres superieur a 100" if EMPLOYE == 1 & inlist(F1, 2, 3) & !missing(H4A) & H4A > 100 & ($metier_scope)
    replace source_regle = "metier_propose" if EMPLOYE == 1 & inlist(F1, 2, 3) & !missing(H4A) & H4A > 100 & ($metier_scope)
    replace action_proposee = "revue_manuelle" if EMPLOYE == 1 & inlist(F1, 2, 3) & !missing(H4A) & H4A > 100 & ($metier_scope)
    export excel interview__key cover_district nom_agent EMPLOYE F1 H4A commentaire source_regle action_proposee ///
        using "$document\50_metier_propose\h4a_superieur_100.xlsx", ///
        if EMPLOYE == 1 & inlist(F1, 2, 3) & !missing(H4A) & H4A > 100 & ($metier_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

count if EMPLOYE == 1 & inlist(F1, 2, 3, 4) & !missing(H5) & H5 != 999999 & H5 > 5000000 & ($metier_scope)
if r(N)>0 {
    replace commentaire = "Montant H5 superieur a 5 millions FCFA" if EMPLOYE == 1 & inlist(F1, 2, 3, 4) & !missing(H5) & H5 != 999999 & H5 > 5000000 & ($metier_scope)
    replace source_regle = "metier_propose" if EMPLOYE == 1 & inlist(F1, 2, 3, 4) & !missing(H5) & H5 != 999999 & H5 > 5000000 & ($metier_scope)
    replace action_proposee = "revue_manuelle" if EMPLOYE == 1 & inlist(F1, 2, 3, 4) & !missing(H5) & H5 != 999999 & H5 > 5000000 & ($metier_scope)
    export excel interview__key cover_district nom_agent EMPLOYE F1 H5 commentaire source_regle action_proposee ///
        using "$document\50_metier_propose\h5_superieur_5m.xlsx", ///
        if EMPLOYE == 1 & inlist(F1, 2, 3, 4) & !missing(H5) & H5 != 999999 & H5 > 5000000 & ($metier_scope), firstrow(variables) replace
    replace commentaire = ""
    replace source_regle = ""
    replace action_proposee = ""
}

* Q2 est textuelle dans le questionnaire; sa codification numerique reste a valider.
capture confirm string variable Q2
if !_rc {
    count if !missing(Q2) & trim(Q2) != "" & missing(real(trim(Q2))) & ($metier_scope)
    if r(N)>0 {
        replace commentaire = "Q2 non numerique; format cible a valider" if !missing(Q2) & trim(Q2) != "" & missing(real(trim(Q2))) & ($metier_scope)
        replace source_regle = "donnee_observee/metier_propose" if !missing(Q2) & trim(Q2) != "" & missing(real(trim(Q2))) & ($metier_scope)
        replace action_proposee = "codification_manuelle" if !missing(Q2) & trim(Q2) != "" & missing(real(trim(Q2))) & ($metier_scope)
        export excel interview__key cover_district nom_agent Q2 commentaire source_regle action_proposee ///
            using "$document\50_metier_propose\q2_non_numerique.xlsx", ///
            if !missing(Q2) & trim(Q2) != "" & missing(real(trim(Q2))) & ($metier_scope), firstrow(variables) replace
        replace commentaire = ""
        replace source_regle = ""
        replace action_proposee = ""
    }
}

drop commentaire source_regle action_proposee __heures_total
display as result "Controles metier proposes termines sans correction."
