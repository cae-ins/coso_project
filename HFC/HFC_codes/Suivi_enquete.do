/*==============================================================================
  HIGH FREQUENCY CHECK : TABLEAU DE BORD DE SUIVI DE L'ENQUETE
  Auteur : Equipe projet - COSO
  Date   : juillet 2026

  OBJET
  -----
  Produit un classeur Excel de suivi quotidien a partir de :
    - la base brute      : $base_brute/Questionnaire_COSO_V4.dta
    - la base d'erreurs  : $base_erreurs_stata_unique/base_erreur_globale_du_<date>.dta

  Le classeur contient 6 feuilles :
    1. Synthese      : indicateurs cles du jour
    2. Par_region    : interviews et erreurs par region
    3. Par_agent     : classement des agents par taux d'erreur
    4. Par_section   : sections du questionnaire les plus problematiques
    5. Evolution     : historique jour par jour (cumule a chaque execution)
    6. Detail        : liste nominative des erreurs a corriger

  UTILISATION
  -----------
  A executer APRES Main_COSO.do (qui produit la base d'erreurs du jour).
  Aucune modification des dofiles existants n'est necessaire.
==============================================================================*/

clear all
set more off
version 17

*Chargement des chemins d'acces
do "/Users/macbookair/Desktop/CAE/COSO/HFC/HFC_codes/Chemins_acces.do"

*Dossier de sortie du suivi (cree s'il n'existe pas)
global suivi "$dossier_de_travail/Bases/Suivi_enquete"
capture mkdir "$suivi"

*Date du jour : sert au nommage des fichiers, comme dans vos autres dofiles
local jour "`c(current_date)'"
local fichier "$suivi/Suivi_enquete_du_`jour'.xlsx"

*Suppression du classeur du jour s'il existe deja (relance possible sans erreur)
capture erase "`fichier'"


/*==============================================================================
  ETAPE 1 : INDICATEURS ISSUS DE LA BASE BRUTE
==============================================================================*/

use "$base_brute/Questionnaire_COSO_V4.dta", clear

*Nombre total d'interviews recues sur le serveur
local n_interviews = _N

/* Codage Survey Solutions de interview__status :
   -1 Deleted / 0 Restored / 20 Created / 40 SupervisorAssigned
   60 InterviewerAssigned / 65 RejectedBySupervisor / 100 Completed
   (attention : ce n'est PAS un simple 0/1) */

*Interviews achevees par l'agent (statut "Completed")
count if interview__status == 100
local n_completes = r(N)

*Interviews encore chez l'agent (statut "InterviewerAssigned")
count if interview__status == 60
local n_assignees = r(N)

*Taux de completion
local taux_completion = 100 * `n_completes' / `n_interviews'

*Nombre d'agents et de superviseurs actifs (valeurs non manquantes)
levelsof nom_agent, local(liste_agents)
local n_agents : word count `liste_agents'

levelsof nom_sup, local(liste_sups)
local n_sups : word count `liste_sups'

*Nombre de regions couvertes
levelsof cover_region, local(liste_regions)
local n_regions : word count `liste_regions'

*Sauvegarde d'une table de correspondance interview -> agent / sup / region.
*Elle servira a rattacher chaque erreur a sa region, information absente
*de la base d'erreurs.
preserve
    keep interview__key nom_agent nom_sup cover_region interview__status
    duplicates drop interview__key, force
    tempfile correspondance
    save "`correspondance'", replace
restore


/*==============================================================================
  ETAPE 2 : CHARGEMENT ET ENRICHISSEMENT DE LA BASE D'ERREURS
==============================================================================*/

use "$base_erreurs_stata_unique/base_erreur_globale_du_`jour'.dta", clear

*Nombre total d'erreurs detectees
local n_erreurs = _N

/* La base d'erreurs a perdu les libelles des agents lors des append successifs
   (nom_agent y apparait sous forme de codes numeriques). On les recupere depuis
   la base brute, sinon le classeur afficherait des numeros illisibles pour les
   superviseurs. On ecrase les variables locales avant le merge. */
drop nom_agent nom_sup
merge m:1 interview__key using "`correspondance'", keep(master match) nogenerate

/* La variable "section" est creee par chaque dofile de section mais supprimee
   par le keep de Suppression_doublons.do. On la reconstruit a partir du prefixe
   de la variable en erreur, qui suit la nomenclature du questionnaire. */
generate str60 section = ""
replace section = "A. Gestion des tentatives d'appel"        if regexm(variable, "^A")
replace section = "B. Identification et consentement"        if regexm(variable, "^B")
replace section = "C. Profil sociodemographique"             if regexm(variable, "^C")
replace section = "D. Menage"                                if regexm(variable, "^D")
replace section = "E. Statut d'activite"                     if regexm(variable, "^E")
replace section = "F. Emploi principal"                      if regexm(variable, "^F")
replace section = "G. Qualite de l'emploi"                   if regexm(variable, "^G")
replace section = "H. Revenu et caracteristiques entreprise" if regexm(variable, "^H")
replace section = "I. Recherche d'un autre emploi"           if regexm(variable, "^I")
replace section = "J. Chomage, duree et recherche"           if regexm(variable, "^J")
replace section = "K. Entrepreneuriat / IGA"                 if regexm(variable, "^K")
replace section = "L. Inclusion financiere et epargne"       if regexm(variable, "^L")
replace section = "M. Changement de statut"                  if regexm(variable, "^M")
replace section = "N. Resilience face aux chocs"             if regexm(variable, "^N")
replace section = "O. Experience professionnelle"            if regexm(variable, "^O")
replace section = "P. Aspirations professionnelles"          if regexm(variable, "^P")
replace section = "Q. Cohesion sociale et engagement"        if regexm(variable, "^Q")
replace section = "R. Suivi panel"                           if regexm(variable, "^R")
replace section = "Autre / non classee"                      if section == ""

*Nombre d'interviews distinctes concernees par au moins une erreur
preserve
    duplicates drop interview__key, force
    local n_interviews_err = _N
restore

*Taux d'erreur : nombre moyen d'erreurs pour 100 interviews recues
local taux_erreur = 100 * `n_erreurs' / `n_interviews'

*Part des interviews touchees par au moins une erreur
local part_touchees = 100 * `n_interviews_err' / `n_interviews'

*Conservation de la base enrichie pour les feuilles suivantes
tempfile erreurs
save "`erreurs'", replace


/*==============================================================================
  ETAPE 3 : FEUILLE "SYNTHESE"
==============================================================================*/

clear
set obs 12
generate str50 Indicateur = ""
generate str30 Valeur     = ""

replace Indicateur = "TABLEAU DE BORD - ENQUETE COSO"        in 1
replace Valeur     = "`jour'"                                 in 1

replace Indicateur = "COLLECTE"                               in 2

replace Indicateur = "Interviews recues sur le serveur"       in 3
replace Valeur     = "`n_interviews'"                         in 3

replace Indicateur = "Interviews achevees (Completed)"        in 4
replace Valeur     = "`n_completes'"                          in 4

replace Indicateur = "Interviews en cours chez l'agent"       in 5
replace Valeur     = "`n_assignees'"                          in 5

replace Indicateur = "Taux de completion (%)"                 in 6
replace Valeur     = string(`taux_completion', "%9.1f")       in 6

replace Indicateur = "QUALITE DES DONNEES"                    in 7

replace Indicateur = "Erreurs detectees"                      in 8
replace Valeur     = "`n_erreurs'"                            in 8

replace Indicateur = "Interviews avec au moins une erreur"    in 9
replace Valeur     = "`n_interviews_err'"                     in 9

replace Indicateur = "Part des interviews touchees (%)"       in 10
replace Valeur     = string(`part_touchees', "%9.1f")         in 10

replace Indicateur = "Erreurs pour 100 interviews"            in 11
replace Valeur     = string(`taux_erreur', "%9.1f")           in 11

replace Indicateur = "DISPOSITIF"                             in 12
replace Valeur     = "`n_agents' agents / `n_sups' sup. / `n_regions' regions" in 12

export excel using "`fichier'", sheet("1.Synthese") firstrow(variables) replace


/*==============================================================================
  ETAPE 4 : FEUILLE "PAR REGION"
==============================================================================*/

*Interviews recues et achevees par region
use "`correspondance'", clear
generate byte completes = (interview__status == 100)
generate byte unite     = 1
collapse (sum) unite (sum) completes, by(cover_region)
rename unite     Interviews
rename completes Achevees
tempfile parregion
save "`parregion'", replace

*Erreurs par region
use "`erreurs'", clear
generate byte unite = 1
collapse (sum) unite, by(cover_region)
rename unite Erreurs

merge 1:1 cover_region using "`parregion'", nogenerate
recode Erreurs (. = 0)

*Indicateurs derives, arrondis a une decimale pour la lisibilite du classeur
generate Taux_completion  = round(100 * Achevees / Interviews, 0.1)
generate Erreurs_p100     = round(100 * Erreurs / Interviews, 0.1)
format Taux_completion Erreurs_p100 %9.1f

*Tri par volume d'erreurs decroissant : les regions a surveiller en premier
gsort -Erreurs_p100
order cover_region Interviews Achevees Taux_completion Erreurs Erreurs_p100

/* Les variables issues de collapse heritent d'un libelle du type "(sum) unite".
   On les renomme explicitement, sinon l'export (firstrow(varlabels)) reprend ce
   libelle technique comme en-tete de colonne. */
label variable cover_region     "Region"
label variable Interviews       "Interviews recues"
label variable Achevees         "Interviews achevees"
label variable Taux_completion  "Taux completion (%)"
label variable Erreurs          "Erreurs"
label variable Erreurs_p100     "Erreurs / 100 interviews"

export excel using "`fichier'", sheet("2.Par_region") firstrow(varlabels) sheetreplace


/*==============================================================================
  ETAPE 5 : FEUILLE "PAR AGENT"
==============================================================================*/

*Interviews par agent
use "`correspondance'", clear
drop if missing(nom_agent)
generate byte completes = (interview__status == 100)
generate byte unite     = 1
collapse (sum) unite (sum) completes, by(nom_agent nom_sup)
rename unite     Interviews
rename completes Achevees
tempfile paragent
save "`paragent'", replace

*Erreurs par agent
use "`erreurs'", clear
drop if missing(nom_agent)
generate byte unite = 1
collapse (sum) unite, by(nom_agent)
rename unite Erreurs

merge 1:m nom_agent using "`paragent'", nogenerate
recode Erreurs (. = 0)

generate Erreurs_p100 = round(100 * Erreurs / Interviews, 0.1)
format Erreurs_p100 %9.1f

/* Classement par taux d'erreur decroissant. Les agents en tete de liste sont
   ceux vers qui orienter en priorite les rappels et le recyclage. */
gsort -Erreurs_p100
generate Rang = _n
order Rang nom_agent nom_sup Interviews Achevees Erreurs Erreurs_p100
label variable nom_agent    "Agent enqueteur"
label variable nom_sup      "Superviseur"
label variable Interviews   "Interviews recues"
label variable Achevees     "Interviews achevees"
label variable Erreurs      "Erreurs"
label variable Erreurs_p100 "Erreurs / 100 interviews"

export excel using "`fichier'", sheet("3.Par_agent") firstrow(varlabels) sheetreplace


/*==============================================================================
  ETAPE 6 : FEUILLE "PAR SECTION"
==============================================================================*/

use "`erreurs'", clear
generate byte unite = 1

*Nombre d'erreurs et nombre d'interviews concernees, par section
preserve
    collapse (sum) unite, by(section)
    rename unite Erreurs
    tempfile err_section
    save "`err_section'", replace
restore

*Interviews distinctes touchees par section
duplicates drop interview__key section, force
collapse (sum) unite, by(section)
rename unite Interviews_touchees

merge 1:1 section using "`err_section'", nogenerate

*Part de chaque section dans le total des erreurs
egen total = total(Erreurs)
generate Part_pct = round(100 * Erreurs / total, 0.1)
format Part_pct %9.1f
drop total

gsort -Erreurs
order section Erreurs Part_pct Interviews_touchees
label variable section             "Section du questionnaire"
label variable Erreurs             "Erreurs"
label variable Part_pct            "Part des erreurs (%)"
label variable Interviews_touchees "Interviews concernees"

export excel using "`fichier'", sheet("4.Par_section") firstrow(varlabels) sheetreplace


/*==============================================================================
  ETAPE 7 : FEUILLE "EVOLUTION"

  Cette feuille cumule une ligne par jour d'execution. L'historique est conserve
  dans un fichier .dta dedie, relu et complete a chaque passage : c'est lui qui
  permet de voir si la qualite de la collecte s'ameliore dans le temps.
==============================================================================*/

*Construction de la ligne du jour
clear
set obs 1
generate str30 Date_suivi          = "`jour'"
generate double Interviews         = `n_interviews'
generate double Achevees           = `n_completes'
generate double Taux_completion    = round(`taux_completion', 0.1)
generate double Erreurs            = `n_erreurs'
generate double Interviews_erreur  = `n_interviews_err'
generate double Erreurs_p100       = round(`taux_erreur', 0.1)
generate double Agents_actifs      = `n_agents'

tempfile ligne_jour
save "`ligne_jour'", replace

*Ajout a l'historique existant, ou creation si premiere execution
capture confirm file "$suivi/Historique_suivi.dta"
if _rc == 0 {
    use "$suivi/Historique_suivi.dta", clear
    *Une seule ligne par date : la relance d'un meme jour met a jour la ligne
    drop if Date_suivi == "`jour'"
    append using "`ligne_jour'"
}
else {
    use "`ligne_jour'", clear
}

format Taux_completion Erreurs_p100 %9.1f
save "$suivi/Historique_suivi.dta", replace

label variable Date_suivi        "Date du suivi"
label variable Taux_completion   "Taux completion (%)"
label variable Interviews_erreur "Interviews avec erreur"
label variable Erreurs_p100      "Erreurs / 100 interviews"
label variable Agents_actifs     "Agents actifs"

export excel using "`fichier'", sheet("5.Evolution") firstrow(varlabels) sheetreplace


/*==============================================================================
  ETAPE 8 : FEUILLE "DETAIL"

  Liste nominative des erreurs, triee par superviseur puis agent : c'est le
  document de travail que le superviseur transmet a ses enqueteurs.
==============================================================================*/

use "`erreurs'", clear

keep interview__key cover_region nom_sup nom_agent section variable commentaire
order interview__key cover_region nom_sup nom_agent section variable commentaire
gsort nom_sup nom_agent interview__key section variable

label variable interview__key "Cle interview"
label variable cover_region   "Region"
label variable nom_sup        "Superviseur"
label variable nom_agent      "Agent enqueteur"
label variable section        "Section"
label variable variable       "Variable"
label variable commentaire    "Erreur a corriger"

export excel using "`fichier'", sheet("6.Detail") firstrow(varlabels) sheetreplace


/*==============================================================================
  FIN : recapitulatif affiche dans la fenetre de resultats
==============================================================================*/

display as text _n "{hline 70}"
display as result "  SUIVI DE L'ENQUETE COSO - `jour'"
display as text "{hline 70}"
display as text "  Interviews recues        : " as result `n_interviews'
display as text "  Interviews achevees      : " as result `n_completes' ///
                as text " (" as result %4.1f `taux_completion' as text " %)"
display as text "  Erreurs detectees        : " as result `n_erreurs'
display as text "  Interviews avec erreur   : " as result `n_interviews_err' ///
                as text " (" as result %4.1f `part_touchees' as text " %)"
display as text "  Erreurs / 100 interviews : " as result %4.1f `taux_erreur'
display as text "{hline 70}"
display as text "  Classeur produit : " as result "`fichier'"
display as text "{hline 70}" _n
