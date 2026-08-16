/* Contrat minimal avant production de la base diagnostique. */

capture confirm file "$generated\apurement_rule_matrix.csv"
if _rc {
    display as error "Matrice de regles absente : $generated\apurement_rule_matrix.csv"
    exit 601
}

local sections 01_COVER 02_A 03_B 04_C 05_D 06_E 07_F 08_G 09_H 10_I 11_J 12_K 13_L 14_M 15_N 16_O 17_P 18_Q 19_R
local missing_outputs 0
foreach section of local sections {
    capture confirm file "$section_output\`section'.dta"
    if _rc {
        display as error "Vue diagnostique absente : `section'.dta"
        local missing_outputs = `missing_outputs' + 1
    }
}
if `missing_outputs' > 0 {
    display as error "`missing_outputs' vue(s) de section absente(s)."
    exit 601
}

use "$working_base", clear
foreach variable in interview__key interview__status consentement analysis_eligible_provisoire {
    capture confirm variable `variable'
    if _rc {
        display as error "Variable requise absente avant sortie : `variable'"
        exit 111
    }
}

capture isid interview__key
if _rc {
    display as error "La cle interview__key n'est pas unique. Sortie finale bloquee."
    duplicates report interview__key
    exit 459
}

display as result "Contrat de sortie satisfait."
