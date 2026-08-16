/* Produit une base diagnostique, pas une base declaree completement apuree. */

use "$working_base", clear
cap drop apurement_correction_applied
gen byte apurement_correction_applied = 0
label variable apurement_correction_applied "Aucune correction metier validee appliquee"

cap drop apurement_status
gen str24 apurement_status = "diagnostic_only"
label variable apurement_status "Statut de la sortie d'apurement"

cap drop apurement_run_date
gen str20 apurement_run_date = "`c(current_date)' `c(current_time)'"

compress
save "$final_base", replace
