/* Execute les controles generes depuis le questionnaire Survey Solutions. */

capture confirm file "$generated_dofiles\00_generated_sections.do"
if _rc {
    display as error "Do-files questionnaire absents. Executer tools/00_build_template.ps1."
    exit 601
}

do "$generated_dofiles\00_generated_sections.do"
