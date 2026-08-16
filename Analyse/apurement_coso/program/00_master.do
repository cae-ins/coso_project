/* Point d'entree du template d'apurement COSO. */

clear all
version 15
set more off

do "program/00_paths.do"

capture log close _all
local log_date = subinstr("`c(current_date)'", " ", "_", .)
local log_time = subinstr("`c(current_time)'", ":", "-", .)
log using "$logs\apurement_`log_date'_`log_time'.log", replace text

display as text "Debut du diagnostic d'apurement COSO."
display as text "Aucune correction metier non validee ne sera appliquee."

do "$dofiles\01_initialiser_base.do"
do "$dofiles\02_controles_systeme.do"
do "$dofiles\03_controles_questionnaire.do"
do "$dofiles\50_controles_metier_proposes.do"
do "$dofiles\60_corrections_validees.do"
do "$dofiles\90_contrat_sortie.do"
do "$dofiles\99_finaliser.do"

display as result "Diagnostic d'apurement termine : $final_base"
log close
