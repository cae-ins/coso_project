/*
COSO Nord - Construction des indicateurs d'effets (v2, 2 juillet 2026)
Questionnaire : Draft 7 (version du 01/07/2026) + Addendum chomage/sous-emploi
References : Suivi_Evaluation/Cadre_Indicateurs_Effets.md (v2)
             Suivi_Evaluation/Matrice_Indicateurs_Eval_Impact_COSO.xlsx
Miroir Stata de : Analyse/R/01_construire_indicateurs_effets_draft7.R (v2)

Usage :
    do "Analyse/stata/01_construire_indicateurs_effets_draft7.do" ///
       "chemin/base_entree.dta" "chemin/base_indicateurs.dta"

Variables CONDITIONNELLES (absentes du V7 tant que non adoptees) :
  - Addendum   : j0, j0a, j0b, g7a  -> chomage BIT, MOP, sous-emploi, LU1-LU4
  - Note revue : h5a, h5b, h5c      -> profit MMW (outcome primaire economique)
Le h5 actuel du V7 amalgame profit et prelevements : proxy d'equilibre
baseline uniquement, jamais un outcome (Cadre v2, decision 12).

PROTOCOLE DE COMPARAISON R/Stata (a executer sur un poste Stata 17+) :
  1. regenerer les CSV simules via scratchpad/smoke_test_v2.R (graine 20260702)
  2. import delimited -> executer ce do-file sur sim_bl.csv puis sim_el.csv
  3. assembler le panel large (suffixes _bl/_el), executer 02_estimer_effets_itt.do
  4. comparer resultats_itt.csv Stata vs R : |dbeta|,|dse| < 1e-6
     (tolerance 1e-3 sur les indices d'Anderson, inversion matricielle)
*/

version 17
set more off

args input_file output_file

if `"`input_file'"' == "" | `"`output_file'"' == "" {
    di as error "Fournir le fichier d'entree et un fichier de sortie distinct."
    exit 198
}

* Lecture .dta ou .csv
local ext = lower(substr(`"`input_file'"', strrpos(`"`input_file'"', ".") + 1, .))
if "`ext'" == "csv" {
    import delimited `"`input_file'"', clear case(lower)
}
else {
    use `"`input_file'"', clear
}
capture rename *, lower

* 0. Variables minimales du V7
local questionnaire_vars ///
    e1 e2 e3 e3a f1 f2 f4 g3 g5 g6 g7 ///
    h2 h3 h4 h4a h5 i1 j1 j2 j3 ///
    k1 iga6 iga7 ///
    l1 l2 l3 l4 l6 l9 ///
    m1 m2 m3 m4 ///
    n1 n2 n3 n4 n5 n6a n7 ///
    o3 o5 o6 q1 q2 q3 q4 q5 q6 q7 q8 q9 q10

local vars_absentes ""
foreach v of local questionnaire_vars {
    capture confirm variable `v'
    if _rc {
        local vars_absentes "`vars_absentes' `v'"
        gen double `v' = .
    }
}
if `"`vars_absentes'"' != "" {
    di as error "Variables absentes, creees manquantes :`vars_absentes'"
}

* Disponibilite des modules conditionnels
local has_addendum = 1
foreach v in j0 j0a j0b g7a {
    capture confirm variable `v'
    if _rc local has_addendum = 0
}
local has_mmw = 1
foreach v in h5a h5b h5c {
    capture confirm variable `v'
    if _rc local has_mmw = 0
}
if !`has_addendum' {
    di as error "Addendum (j0/j0a/j0b/g7a) absent : chomage, MOP et " ///
        "sous-emploi strict ne seront PAS calcules (Cadre v2, decision 11)."
}
if !`has_mmw' {
    di as error "Sequence MMW (h5a/h5b/h5c) absente : profit MMW non " ///
        "calcule ; h5 reste un proxy non valide (Cadre v2, decision 12)."
}

* ---------------------------------------------------------------------------
* 1. Statut d'activite (famille C.1) -- definitions ENE/BIT
* ---------------------------------------------------------------------------
gen byte ind_employed = .
replace ind_employed = 1 if e1==1 | e2==1 | (e3==1 & e3a==1)
replace ind_employed = 0 if e1==2 & e2==2 & (e3==2 | (e3==1 & e3a==2))
label variable ind_employed "En emploi (BIT, E1-E3A)"

gen byte ind_self_employed = .
replace ind_self_employed = 0 if ind_employed==0
replace ind_self_employed = inlist(f1,2,3) if ind_employed==1 & !missing(f1)
label variable ind_self_employed "Employeur ou compte propre"

gen byte ind_salaried = .
replace ind_salaried = 0 if ind_employed==0
replace ind_salaried = (f1==1) if ind_employed==1 & !missing(f1)
label variable ind_salaried "Emploi salarie"

gen byte ind_employer = .
replace ind_employer = 0 if ind_employed==0
replace ind_employer = (f1==2) if ind_employed==1 & !missing(f1)
label variable ind_employer "Statut d'employeur"

* Emplois remuneres crees (h4a, V7) -- zero structurel observe
gen double jobs_created_uncond = .
replace jobs_created_uncond = 0 if ind_employed==0
replace jobs_created_uncond = 0 if ind_employed==1 & inlist(f1,1,5,6,7)
replace jobs_created_uncond = h4a if ind_employed==1 & inlist(f1,2,3,4) ///
    & !missing(h4a) & h4a >= 0
label variable jobs_created_uncond "Emplois remuneres crees (non cond.)"

* Perennite : activite principale >= 12 mois sans interruption
gen byte ind_activity_12m = .
replace ind_activity_12m = 0 if ind_employed==0
replace ind_activity_12m = inlist(f4,3,4,5) if ind_employed==1 & inrange(f4,1,5)
label variable ind_activity_12m "Activite principale >= 12 mois"

* Formalisation parmi les independants (descriptif conditionnel)
gen byte ind_registered_cond = .
replace ind_registered_cond = (h4==1) if ind_employed==1 & inlist(f1,2,3,4) ///
    & inlist(h4,1,2,3)
label variable ind_registered_cond "Activite enregistree (cond. indep.)"

* Chomage BIT, main-d'oeuvre potentielle, decourages (addendum requis)
if `has_addendum' {
    * Chomeur = sans emploi & (recherche 30j | future starter) & disponible
    gen byte ind_unemployed = .
    replace ind_unemployed = 0 if ind_employed==1
    replace ind_unemployed = 1 if missing(ind_unemployed) & ind_employed==0 ///
        & j0==1 & j3==1
    replace ind_unemployed = 1 if missing(ind_unemployed) & ind_employed==0 ///
        & j0==2 & j0a==8 & j3==1                        // future starters
    replace ind_unemployed = 0 if missing(ind_unemployed) & ind_employed==0 ///
        & j0==1 & j3==2
    replace ind_unemployed = 0 if missing(ind_unemployed) & ind_employed==0 ///
        & j0==2 & !(j0a==8 & j3==1) & !missing(j0a) & inlist(j3,1,2)
    label variable ind_unemployed "Chomeur BIT (yc future starters)"

    * Main-d'oeuvre potentielle (LU3/LU4)
    gen byte ind_mop = .
    replace ind_mop = 0 if ind_employed==1 | ind_unemployed==1
    replace ind_mop = 1 if missing(ind_mop) & ind_employed==0 & j0==1 & j3==2
    replace ind_mop = 1 if missing(ind_mop) & ind_employed==0 & j0==2 ///
        & j0b==1 & j3==1
    replace ind_mop = 0 if missing(ind_mop) & ind_employed==0 & j0==2 ///
        & (j0b==2 | j3==2)
    label variable ind_mop "Main-d'oeuvre potentielle"

    gen byte ind_discouraged = .
    replace ind_discouraged = 0 if ind_employed==1
    replace ind_discouraged = (j0a==1) if ind_employed==0 & j0==2 ///
        & inrange(j0a,1,9)
    label variable ind_discouraged "Travailleur decourage"

    gen byte ind_inactive = .
    replace ind_inactive = 0 if ind_employed==1 | ind_unemployed==1 | ind_mop==1
    replace ind_inactive = 1 if missing(ind_inactive) & ind_employed==0 ///
        & ind_unemployed==0 & ind_mop==0
    label variable ind_inactive "Inactif (hors main-d'oeuvre elargie)"

    gen byte ind_active_search = .
    replace ind_active_search = (j0==1) if ind_employed==0 & inlist(j0,1,2)
    label variable ind_active_search "Recherche active 30 j (non-employes)"
}
else {
    gen byte ind_unemployed = .
    gen byte ind_mop = .
    gen byte ind_discouraged = .
    gen byte ind_inactive = .
    gen byte ind_active_search = .
}

* ---------------------------------------------------------------------------
* 2. Heures et sous-emploi -- seuil 40 h (decision alignee ENE, Cadre v2 #3)
* ---------------------------------------------------------------------------
local hours_threshold = 40

gen double hours_week_cond = .
replace hours_week_cond = g3 if ind_employed==1 & g5==2 & !missing(g3)
replace hours_week_cond = g3 + g6 if ind_employed==1 & g5==1 ///
    & !missing(g3) & !missing(g6)
label variable hours_week_cond "Heures hebdo totales (employes)"

gen double hours_week_uncond = .
replace hours_week_uncond = 0 if ind_employed==0
replace hours_week_uncond = hours_week_cond if ind_employed==1
label variable hours_week_uncond "Heures hebdo (0 si non-employe)"

gen byte flag_hours_over_84 = .
replace flag_hours_over_84 = (hours_week_cond > 84) if !missing(hours_week_cond)
label variable flag_hours_over_84 "Heures > 84/semaine"

gen byte ind_diversified = .
replace ind_diversified = 0 if ind_employed==0
replace ind_diversified = (g5==1) if ind_employed==1 & inlist(g5,1,2)
label variable ind_diversified "Plus d'une activite"

if `has_addendum' {
    * Sous-emploi BIT : < 40 h & souhait (g7) & disponibilite (g7a)
    gen byte ind_underemployment = .
    replace ind_underemployment = 0 if ind_employed==0
    replace ind_underemployment = 0 if missing(ind_underemployment) ///
        & ind_employed==1 & !missing(hours_week_cond) & g7==2
    replace ind_underemployment = ///
        (hours_week_cond < `hours_threshold' & g7a==1) ///
        if missing(ind_underemployment) & ind_employed==1 ///
        & !missing(hours_week_cond) & g7==1 & inlist(g7a,1,2)
    label variable ind_underemployment "Sous-emploi horaire BIT (<40h)"
}
else {
    gen byte ind_underemployment = .
}

* Proxy majorant (sans disponibilite) -- comparaison uniquement
gen byte ind_underemployment_proxy = .
replace ind_underemployment_proxy = 0 if ind_employed==0
replace ind_underemployment_proxy = ///
    (hours_week_cond < `hours_threshold' & g7==1) ///
    if ind_employed==1 & !missing(hours_week_cond) & !missing(g7)
label variable ind_underemployment_proxy "Sous-emploi proxy (sans dispo)"

* ---------------------------------------------------------------------------
* 3. Revenus (famille C.2)
* ---------------------------------------------------------------------------
gen double salary_monthly_provisional = .
replace salary_monthly_provisional = h3 * 26      if ind_salaried==1 & h2==1 ///
    & !missing(h3) & h3 >= 0
replace salary_monthly_provisional = h3 * 52/12   if ind_salaried==1 & h2==2 ///
    & !missing(h3) & h3 >= 0
replace salary_monthly_provisional = h3 * 26/12   if ind_salaried==1 & h2==3 ///
    & !missing(h3) & h3 >= 0
replace salary_monthly_provisional = h3           if ind_salaried==1 & h2==4 ///
    & !missing(h3) & h3 >= 0
label variable salary_monthly_provisional "Salaire mensualise"

gen byte flag_salary_irregular = .
replace flag_salary_irregular = 1 if ind_salaried==1 & h2==5
replace flag_salary_irregular = 0 if ind_salaried==1 & inrange(h2,1,4)
label variable flag_salary_irregular "Paie irreguliere (h2=5)"

gen double salary_monthly_uncond = .
replace salary_monthly_uncond = 0 if ind_salaried==0
replace salary_monthly_uncond = salary_monthly_provisional if ind_salaried==1
label variable salary_monthly_uncond "Salaire mensualise (0 si non salarie)"

* h5 V7 : proxy NON VALIDE (amalgame) -- equilibre baseline uniquement
gen double profit_proxy_h5 = .
replace profit_proxy_h5 = h5 if ind_self_employed==1 & !missing(h5) & h5 >= 0
label variable profit_proxy_h5 "h5 brut - proxy non valide"

if `has_mmw' {
    * Codage suppose de h5b : 1 = bon mois, 2 = mois ordinaire, 3 = mauvais
    * >>> A CONFIRMER contre le questionnaire programme <<<
    local mois_ordinaire_code = 2

    gen double profit_last_month = .
    replace profit_last_month = h5a if ind_self_employed==1 & !missing(h5a)
    label variable profit_last_month "Profit net dernier mois (MMW)"

    gen double profit_normal_month = .
    replace profit_normal_month = h5a if ind_self_employed==1 ///
        & h5b==`mois_ordinaire_code' & !missing(h5a)
    replace profit_normal_month = h5c if ind_self_employed==1 ///
        & h5b!=`mois_ordinaire_code' & !missing(h5b) & !missing(h5c)
    label variable profit_normal_month "Profit mois ordinaire (MMW)"

    * OUTCOME PRIMAIRE ECONOMIQUE (non conditionnel, zero structurel observe)
    gen double profit_normal_uncond = .
    replace profit_normal_uncond = 0 if ind_employed==0
    replace profit_normal_uncond = 0 if ind_employed==1 & ind_self_employed==0
    replace profit_normal_uncond = profit_normal_month if ind_self_employed==1
    label variable profit_normal_uncond "PRIMAIRE : profit mois ordinaire (0 si sans activite)"
}
else {
    gen double profit_last_month = .
    gen double profit_normal_month = .
    gen double profit_normal_uncond = .
}

gen double main_labor_income_month = .
replace main_labor_income_month = 0 if ind_employed==0
replace main_labor_income_month = salary_monthly_provisional if ind_salaried==1
replace main_labor_income_month = profit_normal_month if ind_self_employed==1
label variable main_labor_income_month "Revenu mensuel du travail"

gen byte ind_saves = .
replace ind_saves = inlist(l3,1,2) if inlist(l3,1,2,3)
label variable ind_saves "Epargne reguliere/occasionnelle"

gen double savings_month_amount = .
replace savings_month_amount = 0 if l3==3
replace savings_month_amount = l4 if inlist(l3,1,2) & !missing(l4) & l4 >= 0
label variable savings_month_amount "Epargne mensuelle typique (FCFA)"

gen byte ind_financial_inclusion = .
replace ind_financial_inclusion = (l1==1 | l2==1) if inlist(l1,1,2) & inlist(l2,1,2)
replace ind_financial_inclusion = 1 if l1==1 | l2==1
label variable ind_financial_inclusion "Compte mobile money ou bancaire"

gen byte ind_has_debt = .
replace ind_has_debt = (l6==1) if inlist(l6,1,2)
label variable ind_has_debt "Pret/dette en cours"

gen byte ind_productive_credit = .
replace ind_productive_credit = 0 if l6==2
replace ind_productive_credit = (l9==1) if l6==1 & inrange(l9,1,6)
label variable ind_productive_credit "Credit a motif productif"

* ---------------------------------------------------------------------------
* 4. Entrepreneuriat, recherche et formation (famille C.3 / mecanismes)
* ---------------------------------------------------------------------------
gen byte ind_ever_created = .
replace ind_ever_created = (k1==1) if inlist(k1,1,2)
label variable ind_ever_created "A deja cree une activite"

gen byte ind_entrep_training = .
replace ind_entrep_training = (iga6==1) if inlist(iga6,1,2)
label variable ind_entrep_training "Formation entrepreneuriale recue"

gen double mgmt_skills_score = .
replace mgmt_skills_score = iga7 if inrange(iga7,1,5)
label variable mgmt_skills_score "Competences de gestion percues (1-5)"

gen byte ind_search_other_job = .
replace ind_search_other_job = (i1==1) if ind_employed==1 & inlist(i1,1,2)
label variable ind_search_other_job "Recherche un autre emploi (employes)"

gen byte ind_training_12m = .
replace ind_training_12m = (o3==1) if inlist(o3,1,2)
label variable ind_training_12m "Formation professionnelle 12 mois"

gen byte ind_training_gov = .
replace ind_training_gov = 0 if o3==2
replace ind_training_gov = (o5==3) if o3==1 & inrange(o5,1,7)
label variable ind_training_gov "Formation via programme gouvernemental"

gen byte ind_training_useful = .
replace ind_training_useful = inlist(o6,2,3) if o3==1 & inrange(o6,1,3)
label variable ind_training_useful "Formation jugee utile"

* ---------------------------------------------------------------------------
* 5. Resilience (famille C.5) -- capacites seulement dans l'indice
* ---------------------------------------------------------------------------
capture unab asset_vars : d5__*
if !_rc {
    egen double asset_count = rowtotal(`asset_vars'), missing
    egen byte _n_assets = rownonmiss(`asset_vars')
    replace asset_count = . if _n_assets==0
    drop _n_assets
}
else {
    gen double asset_count = .
}
label variable asset_count "Nombre de biens du menage"

gen byte shock_exposed = .
replace shock_exposed = (n1==1) if inlist(n1,1,2)
label variable shock_exposed "Choc subi 12 mois (COVARIABLE)"

gen byte negative_coping_cond = .
replace negative_coping_cond = inlist(n4,2,6) if shock_exposed==1 & inrange(n4,1,7)
label variable negative_coping_cond "Strategie negative (cond. choc)"

gen double recovery_cond = .
replace recovery_cond = (5 - n5) / 4 if shock_exposed==1 & inrange(n5,1,5)
label variable recovery_cond "Recuperation (cond. choc)"

gen double emergency_capacity = .
replace emergency_capacity = (3 - n6a) / 2 if inrange(n6a,1,3)
label variable emergency_capacity "Capacite depense imprevue (0-1)"

gen byte ind_emergency_easy = .
replace ind_emergency_easy = (n6a==1) if inrange(n6a,1,3)
label variable ind_emergency_easy "Reunit 250k FCFA facilement"

gen double resilience_subjective = .
replace resilience_subjective = (n7 - 1) / 9 if inrange(n7,1,10)
label variable resilience_subjective "Resilience percue (0-1)"

* Moyenne simple de secours (>= 3 composants sur 4 ; Anderson dans 02)
egen byte _n_res = rownonmiss(ind_emergency_easy resilience_subjective ///
    ind_saves ind_diversified)
egen double resilience_capacity_simple = rowmean(ind_emergency_easy ///
    resilience_subjective ind_saves ind_diversified)
replace resilience_capacity_simple = . if _n_res < 3
drop _n_res
label variable resilience_capacity_simple "Indice capacite (moyenne simple)"

* ---------------------------------------------------------------------------
* 6. Changement de statut (famille C.4) -- hierarchie v2
* ---------------------------------------------------------------------------
* ANCRE FACTUELLE : m2 (aide externe recue sur 12 mois)
gen byte ind_no_external_aid = .
replace ind_no_external_aid = (m2==3) if inrange(m2,1,3)
label variable ind_no_external_aid "ANCRE : aucune aide externe 12 mois"

* Composants PERCEPTUELS : libelles calques sur la TOC -> risque de
* desirabilite differentielle entre bras ; interpreter a l'aune de
* ind_no_external_aid (Cadre v2, section 3.9)
gen double productive_m1 = .
replace productive_m1 = (m1 - 1) / 2 if inrange(m1,1,3)
gen double productive_m3 = .
replace productive_m3 = (m3 - 1) / 4 if inrange(m3,1,5)
gen double productive_m4 = .
replace productive_m4 = (3 - m4) / 2 if inrange(m4,1,3)

egen byte _n_stat = rownonmiss(ind_no_external_aid productive_m1 ///
    productive_m3 productive_m4)
egen double productive_status_index = rowmean(ind_no_external_aid ///
    productive_m1 productive_m3 productive_m4)
replace productive_status_index = . if _n_stat < 2
drop _n_stat
label variable productive_status_index "Indice statut (desirabilite !)"

* ---------------------------------------------------------------------------
* 7. Cohesion sociale (famille D) -- composants ; Anderson dans 02
* ---------------------------------------------------------------------------
gen byte ind_group_member = .
replace ind_group_member = (q1==1) if inlist(q1,1,2)
label variable ind_group_member "Membre d'un groupe/association"

gen double volunteer_count_30d = .
replace volunteer_count_30d = q2 if !missing(q2) & q2 >= 0
label variable volunteer_count_30d "Volontariat 30 j (comptage)"

gen byte trust_general = .
replace trust_general = (q3==1) if inlist(q3,1,2)
label variable trust_general "Confiance generalisee"

gen double trust_intergroup = .
replace trust_intergroup = (q4 - 1) / 3 if inrange(q4,1,4)   // q4==9 -> manquant
label variable trust_intergroup "Confiance intergroupe (0-1)"

forvalues k = 5/10 {
    gen double norm_q`k' = .
    replace norm_q`k' = (q`k' - 1) / 3 if inrange(q`k',1,4)  // 9 -> manquant
}
egen byte _n_inst = rownonmiss(norm_q5 norm_q6 norm_q7 norm_q8 norm_q9 norm_q10)
egen double trust_institutional = rowmean(norm_q5 norm_q6 norm_q7 norm_q8 ///
    norm_q9 norm_q10)
replace trust_institutional = . if _n_inst < 4
drop _n_inst
label variable trust_institutional "Confiance institutionnelle (0-1)"

* ---------------------------------------------------------------------------
* 8. Controles de qualite (Cadre v2)
* ---------------------------------------------------------------------------
quietly count if missing(ind_employed)
di as result "employment_missing            : " r(N)
quietly count if ind_employed==1 & missing(f1)
di as result "employed_without_f1           : " r(N)
quietly count if !missing(h4a) & h4a > 0 & !inlist(f1,2,3,4)
di as result "h4a_out_of_universe           : " r(N)
if `has_mmw' {
    quietly count if ind_self_employed==1 & missing(profit_normal_month)
    di as result "selfemp_without_profit        : " r(N)
}
if `has_addendum' {
    quietly count if !missing(j1) & j0==2
    di as result "j1_with_j0_no                 : " r(N)
    quietly count if !missing(g7a) & g7==2
    di as result "g7a_with_g7_no                : " r(N)
}
quietly count if flag_hours_over_84==1
di as result "hours_over_84                 : " r(N)
quietly count if shock_exposed==0 & (!missing(n3) | !missing(n4) | !missing(n5))
di as result "shock_answers_out_of_universe : " r(N)

* Tabulation descriptive LU1-LU4 (verification, pas un resultat causal)
if `has_addendum' {
    quietly count if ind_employed==1
    local E = r(N)
    quietly count if ind_unemployed==1
    local C = r(N)
    quietly count if ind_underemployment==1
    local S = r(N)
    quietly count if ind_mop==1
    local P = r(N)
    di as result "LU1 = " %6.4f (`C'/(`E'+`C'))
    di as result "LU2 = " %6.4f ((`C'+`S')/(`E'+`C'))
    di as result "LU3 = " %6.4f ((`C'+`P')/(`E'+`C'+`P'))
    di as result "LU4 = " %6.4f ((`C'+`S'+`P')/(`E'+`C'+`P'))
}

* Sauvegarde (.dta ou .csv selon l'extension demandee)
local extout = lower(substr(`"`output_file'"', strrpos(`"`output_file'"', ".") + 1, .))
if "`extout'" == "csv" {
    export delimited using `"`output_file'"', replace
}
else {
    save `"`output_file'"', replace
}
di as result "Base d'indicateurs enregistree : `output_file'"
