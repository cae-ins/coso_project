/* Parametrage du template d'apurement COSO. */

version 15
set more off

local configured_root : environment COSO_APUREMENT_ROOT
if `"`configured_root'"' != "" {
    global folderpath `"`configured_root'"'
}
else {
    global folderpath `"`c(pwd)'"'
}

capture confirm file "$folderpath\program\00_paths.do"
if _rc {
    display as error "Le dossier courant n'est pas la racine Analyse/apurement_coso."
    display as error "Faire cd vers ce dossier ou definir COSO_APUREMENT_ROOT."
    exit 601
}

global datain "$folderpath\datain"
global datain_staging "$datain\staging"
global datain_brute "$datain\brute"
global datain_standard "$datain\standard"
global dataout "$folderpath\dataout"
global section_output "$dataout\standard"
global final_output "$dataout\final"
global document "$folderpath\document"
global logs "$folderpath\logs"
global dofiles "$folderpath\program"
global generated_dofiles "$dofiles\generated"
global tools "$folderpath\tools"
global generated "$folderpath\generated"

global raw_main "$datain_brute\Questionnaire_COSO_V5.dta"
global working_base "$datain_standard\coso_v51_standard.dta"
global final_base "$final_output\coso_apurement_diagnostic.dta"

* Perimetres de diagnostic provisoires; ils ne suppriment aucune fiche.
global audit_scope "interview__status == 100"
global metier_scope "analysis_eligible_provisoire == 1"

cap mkdir "$datain"
cap mkdir "$datain_staging"
cap mkdir "$datain_brute"
cap mkdir "$datain_standard"
cap mkdir "$dataout"
cap mkdir "$section_output"
cap mkdir "$final_output"
cap mkdir "$document"
cap mkdir "$logs"
