/* Charge la copie brute extraite et cree une base standardisee regenerable. */

capture confirm file "$raw_main"
if _rc {
    display as error "Base brute absente : $raw_main"
    display as error "Executer tools/00_build_template.ps1 avec un export Survey Solutions."
    exit 601
}

use "$raw_main", clear

foreach variable in interview__key interview__status consentement {
    capture confirm variable `variable'
    if _rc {
        display as error "Variable obligatoire absente : `variable'"
        exit 111
    }
}

capture program drop save_working_safe
program define save_working_safe
    capture confirm variable interview__key
    if _rc {
        display as error "Sauvegarde de travail refusee : interview__key absente."
        exit 459
    }
    capture confirm variable interview__status
    if _rc {
        display as error "Sauvegarde de travail refusee : interview__status absente."
        exit 459
    }
    save "$working_base", replace
end

save_working_safe
display as result "Base standardisee initialisee sans filtrage ni recodage."
