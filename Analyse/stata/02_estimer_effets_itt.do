/*
COSO Nord - Estimation ITT par ANCOVA (v2, 2 juillet 2026)
References : Suivi_Evaluation/Cadre_Indicateurs_Effets.md (v2)
             Suivi_Evaluation/Cadre_Estimands_Impact_COSO.md
Miroir Stata de : Analyse/R/02_estimer_effets_itt.R (v2)

    Y_el = alpha + beta*treat + gamma*Y_bl + strates + eps    (vce robust)

v2 :
  - liste d'outcomes alignee sur la matrice (2 PRIMAIRES + familles)
  - winsorisation p1/p99 des montants par vague et par bras + IHS (asinh)
  - indices d'Anderson (cohesion, statut, resilience) standardises sur le
    bras temoin de chaque vague (poids covariance inverse via Mata)
  - colonnes famille/role/effect_sd ; attrition par outcome conservee

Usage :
    do "Analyse/stata/02_estimer_effets_itt.do" ///
       "chemin/panel_large.dta" "chemin/dossier_resultats"

PROTOCOLE DE COMPARAISON R/Stata : voir l'en-tete du do-file 01.
Tolerances attendues : |dbeta|,|dse| < 1e-6 ; indices d'Anderson < 1e-3
(quantiles et inversion matricielle peuvent differer numeriquement).
*/

version 17
set more off

args panel_file output_dir
if `"`panel_file'"' == "" | `"`output_dir'"' == "" {
    di as error "Fournir le panel large et le dossier de resultats."
    exit 198
}

capture mkdir `"`output_dir'"'

local ext = lower(substr(`"`panel_file'"', strrpos(`"`panel_file'"', ".") + 1, .))
if "`ext'" == "csv" {
    import delimited `"`panel_file'"', clear case(lower)
}
else {
    use `"`panel_file'"', clear
}
capture rename *, lower

confirm variable treat
assert inlist(treat,0,1) if !missing(treat)

local strata_term ""
capture confirm variable lottery_stratum
if !_rc local strata_term "i.lottery_stratum"

* ===========================================================================
* Programmes auxiliaires
* ===========================================================================

* Winsorisation p1/p99 au sein de chaque bras (Cadre v2, decision 8)
capture program drop _winsor_by_arm
program define _winsor_by_arm
    args invar outvar
    quietly gen double `outvar' = `invar'
    forvalues a = 0/1 {
        quietly count if treat==`a' & !missing(`invar')
        if r(N) >= 20 {
            quietly _pctile `invar' if treat==`a', percentiles(1 99)
            local p1 = r(r1)
            local p99 = r(r2)
            quietly replace `outvar' = min(max(`invar', `p1'), `p99') ///
                if treat==`a' & !missing(`invar')
        }
    }
end

* Poids d'Anderson : covariance inverse (repli poids egaux si singuliere)
capture mata mata drop _and_w()
mata:
void _and_w(string scalar sname, string scalar wname)
{
    real matrix S, V
    real colvector w
    S = st_matrix(sname)
    V = invsym(S)
    if (missing(V) > 0 | sum(abs(V)) == 0) {
        w = J(rows(S), 1, 1/rows(S))
    }
    else {
        w = rowsum(V) / sum(V)
        if (missing(w) > 0) w = J(rows(S), 1, 1/rows(S))
    }
    st_matrix(wname, w')
}
end

* Indice d'Anderson (2008) : z-scores standardises sur treat==0 de la vague,
* indice calcule si >= 50 % des composants observes (Cadre v2, decision 6)
capture program drop _anderson_index
program define _anderson_index
    syntax, gen(name) suffix(string) comps(string)

    local zvars ""
    foreach c of local comps {
        capture confirm variable `c'_`suffix'
        if _rc continue
        quietly summarize `c'_`suffix' if treat==0
        if r(N) < 2 continue
        local mu = r(mean)
        local sd = r(sd)
        if missing(`sd') | `sd'==0 local sd = 1
        tempvar z
        quietly gen double `z' = (`c'_`suffix' - `mu') / `sd'
        local zvars "`zvars' `z'"
    }
    local k : word count `zvars'
    if `k' < 2 {
        di as error "_anderson_index : composants insuffisants pour `gen'_`suffix'"
        exit
    }

    quietly correlate `zvars' if treat==0, covariance
    local ncc = r(N)
    matrix _S = r(C)
    if "`ncc'" == "." | `ncc' < `k' + 2 {
        matrix _W = J(1, `k', 1/`k')
    }
    else {
        mata: _and_w("_S", "_W")
    }

    tempvar num den nobs
    quietly gen double `num' = 0
    quietly gen double `den' = 0
    quietly gen double `nobs' = 0
    local i = 0
    foreach z of local zvars {
        local ++i
        local wi = el(_W, 1, `i')
        quietly replace `num' = `num' + `wi' * `z' if !missing(`z')
        quietly replace `den' = `den' + `wi' if !missing(`z')
        quietly replace `nobs' = `nobs' + !missing(`z')
    }
    quietly gen double `gen'_`suffix' = `num' / `den' ///
        if `nobs' >= ceil(`k' / 2) & `den' != 0
    capture matrix drop _S _W
end

* ===========================================================================
* Transformations : winsorisation par bras + IHS des montants (par vague)
* ===========================================================================
local monetary_stems "profit_normal_uncond salary_monthly_uncond main_labor_income_month savings_month_amount jobs_created_uncond volunteer_count_30d hours_week_uncond"
local ihs_stems "profit_normal_uncond salary_monthly_uncond main_labor_income_month savings_month_amount"

foreach stem of local monetary_stems {
    foreach w in bl el {
        capture confirm variable `stem'_`w'
        if _rc continue
        _winsor_by_arm `stem'_`w' `stem'_w_`w'
        if strpos(" `ihs_stems' ", " `stem' ") {
            quietly gen double `stem'_ihs_`w' = asinh(`stem'_w_`w')
        }
    }
}

* ===========================================================================
* Indices d'Anderson par vague (composants issus du script 01)
* ===========================================================================
foreach w in bl el {
    capture noisily _anderson_index, gen(idx_cohesion) suffix(`w') ///
        comps("ind_group_member volunteer_count_30d trust_general trust_intergroup trust_institutional")
    capture noisily _anderson_index, gen(idx_statut) suffix(`w') ///
        comps("ind_no_external_aid productive_m1 productive_m3 productive_m4")
    capture noisily _anderson_index, gen(idx_resilience) suffix(`w') ///
        comps("ind_emergency_easy resilience_subjective ind_saves ind_diversified")
}

* ===========================================================================
* Outcomes : (stem ; famille ; role) -- aligne sur outcome_specs du R v2
* ===========================================================================
local n_out = 0
local ++n_out
local out`n_out' "profit_normal_uncond_ihs"
local fam`n_out' "C.2 Revenus"
local rol`n_out' "PRIMAIRE"
local ++n_out
local out`n_out' "idx_cohesion"
local fam`n_out' "D Cohesion"
local rol`n_out' "PRIMAIRE"
local ++n_out
local out`n_out' "ind_employed"
local fam`n_out' "C.1 Insertion"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "ind_self_employed"
local fam`n_out' "C.1 Insertion"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "ind_unemployed"
local fam`n_out' "C.1 Insertion"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "ind_underemployment"
local fam`n_out' "C.1 Insertion"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "ind_mop"
local fam`n_out' "C.1 Insertion"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "hours_week_uncond_w"
local fam`n_out' "C.1 Insertion"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "ind_activity_12m"
local fam`n_out' "C.1 Insertion"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "profit_normal_uncond_w"
local fam`n_out' "C.2 Revenus"
local rol`n_out' "robustesse (FCFA)"
local ++n_out
local out`n_out' "main_labor_income_month_ihs"
local fam`n_out' "C.2 Revenus"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "ind_saves"
local fam`n_out' "C.2 Revenus"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "savings_month_amount_ihs"
local fam`n_out' "C.2 Revenus"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "ind_financial_inclusion"
local fam`n_out' "C.2 Revenus"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "ind_productive_credit"
local fam`n_out' "C.2 Revenus"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "ind_ever_created"
local fam`n_out' "C.3 Entrepreneuriat"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "ind_employer"
local fam`n_out' "C.3 Entrepreneuriat"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "jobs_created_uncond_w"
local fam`n_out' "C.3 Entrepreneuriat"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "mgmt_skills_score"
local fam`n_out' "C.3 Entrepreneuriat"
local rol`n_out' "mecanisme"
local ++n_out
local out`n_out' "ind_entrep_training"
local fam`n_out' "C.3 Entrepreneuriat"
local rol`n_out' "1er stade (enquete)"
local ++n_out
local out`n_out' "ind_training_12m"
local fam`n_out' "C.3 Entrepreneuriat"
local rol`n_out' "1er stade (enquete)"
local ++n_out
local out`n_out' "ind_no_external_aid"
local fam`n_out' "C.4 Statut"
local rol`n_out' "ancre factuelle"
local ++n_out
local out`n_out' "idx_statut"
local fam`n_out' "C.4 Statut"
local rol`n_out' "secondaire (desirabilite !)"
local ++n_out
local out`n_out' "ind_emergency_easy"
local fam`n_out' "C.5 Resilience"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "resilience_subjective"
local fam`n_out' "C.5 Resilience"
local rol`n_out' "secondaire"
local ++n_out
local out`n_out' "idx_resilience"
local fam`n_out' "C.5 Resilience"
local rol`n_out' "indice-resume"
local ++n_out
local out`n_out' "ind_group_member"
local fam`n_out' "D Cohesion"
local rol`n_out' "composant"
local ++n_out
local out`n_out' "volunteer_count_30d_w"
local fam`n_out' "D Cohesion"
local rol`n_out' "composant"
local ++n_out
local out`n_out' "trust_general"
local fam`n_out' "D Cohesion"
local rol`n_out' "composant"
local ++n_out
local out`n_out' "trust_intergroup"
local fam`n_out' "D Cohesion"
local rol`n_out' "composant"
local ++n_out
local out`n_out' "trust_institutional"
local fam`n_out' "D Cohesion"
local rol`n_out' "composant"

* ===========================================================================
* Boucle d'estimation
* ===========================================================================
tempfile itt_results
tempname post_itt

postfile `post_itt' ///
    str40 outcome str25 family str30 role byte has_baseline ///
    double n control_mean beta se pvalue ci_low ci_high effect_sd ///
    double obs_control obs_treatment attrition_diff attrition_se attrition_p ///
    using `itt_results', replace

local n_primary = 0
local attr_warn = 0

forvalues j = 1/`n_out' {
    local y "`out`j''"

    capture confirm variable `y'_el
    if _rc {
        di as error "Outcome absent, ignore : `y'_el"
        continue
    }

    local baseline_term ""
    local has_bl = 0
    capture confirm variable `y'_bl
    if !_rc {
        local baseline_term "`y'_bl"
        local has_bl = 1
    }

    tempvar observed_el
    gen byte `observed_el' = !missing(`y'_el)

    quietly summarize `observed_el' if treat==0
    local obs_c = r(mean)
    quietly summarize `observed_el' if treat==1
    local obs_t = r(mean)

    quietly regress `observed_el' treat `strata_term', vce(robust)
    local attr_b = _b[treat]
    local attr_se = _se[treat]
    local attr_p = 2*ttail(e(df_r), abs(`attr_b'/`attr_se'))
    if `attr_p' < 0.05 local attr_warn = 1

    quietly regress `y'_el treat `baseline_term' `strata_term', vce(robust)
    local b = _b[treat]
    local s = _se[treat]
    local p = 2*ttail(e(df_r), abs(`b'/`s'))
    local lo = `b' - invttail(e(df_r), 0.025)*`s'
    local hi = `b' + invttail(e(df_r), 0.025)*`s'
    local n = e(N)

    quietly summarize `y'_el if treat==0 & e(sample)
    local cm = r(mean)
    local csd = r(sd)
    local esd = .
    if !missing(`csd') & `csd' > 0 local esd = `b' / `csd'

    if "`rol`j''" == "PRIMAIRE" local ++n_primary

    post `post_itt' ///
        ("`y'") ("`fam`j''") ("`rol`j''") (`has_bl') ///
        (`n') (`cm') (`b') (`s') (`p') (`lo') (`hi') (`esd') ///
        (`obs_c') (`obs_t') (`attr_b') (`attr_se') (`attr_p')

    drop `observed_el'
}

postclose `post_itt'

* Rappels de discipline statistique (Cadre v2, decision 7)
di as result "RAPPEL : seuls les 2 PRIMAIRES s'interpretent sans correction ;"
di as result "appliquer Romano-Wolf au sein de chaque famille (rwolf2) pour"
di as result "les secondaires (cf. Analyse/estimands/ pour l'implementation)."
if `n_primary' != 2 {
    di as error "Nombre de primaires estime : `n_primary' (attendu : 2 --" ///
        " profit MMW et indice de cohesion)."
}
if `attr_warn' {
    di as error "Attrition differentielle significative sur au moins un " ///
        "outcome : prevoir les bornes de Lee sur les primaires."
}

use `itt_results', clear
label variable beta "Effet ITT"
label variable control_mean "Moyenne endline du controle"
label variable effect_sd "Effet en ecarts-types du controle"
label variable attrition_diff "Difference de taux d'observation T-C"

save `"`output_dir'/resultats_itt.dta"', replace
export delimited using `"`output_dir'/resultats_itt.csv"', replace
di as result "Resultats ITT enregistres dans : `output_dir'"
