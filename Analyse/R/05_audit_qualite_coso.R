#!/usr/bin/env Rscript

# COSO Nord - audit reproductible de la qualite des donnees
#
# Usage:
#   Rscript 05_audit_qualite_coso.R input.dta output_dir
#
# Le script applique uniquement des controles. Il ne modifie jamais la base
# d'entree et ne recode aucune reponse. Chaque anomalie est exportee pour
# validation manuelle avec son code de regle, sa source et son action proposee.
#
# Les regles sont organisees selon le modele ENE :
#   1. manquants dans l'univers ; 2. coherence des sauts ;
#   3. domaine legal ; 4. plausibilite / coherence metier.

suppressPackageStartupMessages(library(haven))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2L) {
  stop("Fournir : input.dta output_dir")
}

input_file <- normalizePath(args[[1]], mustWork = TRUE)
output_dir <- args[[2]]
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

data <- haven::read_dta(input_file)
names(data) <- tolower(names(data))
n <- nrow(data)

id <- if ("interview__key" %in% names(data)) {
  as.character(data$interview__key)
} else {
  sprintf("row_%05d", seq_len(n))
}

num <- function(name) {
  if (!name %in% names(data)) return(rep(NA_real_, n))
  suppressWarnings(as.numeric(data[[name]]))
}

has <- function(...) all(c(...) %in% names(data))
available <- function(name) name %in% names(data)

rules <- list()
cases <- list()

add_rule <- function(rule_id, category, variable, condition, severity,
                     source_rule, proposed_action, message) {
  condition <- as.logical(condition)
  condition[is.na(condition)] <- FALSE
  count <- sum(condition)
  rules[[length(rules) + 1L]] <<- data.frame(
    rule_id = rule_id,
    category = category,
    variable = variable,
    n_tested = n,
    n_flagged = count,
    severity = severity,
    source_rule = source_rule,
    proposed_action = proposed_action,
    stringsAsFactors = FALSE
  )
  if (count > 0L) {
    value <- if (variable %in% names(data)) as.character(data[[variable]][condition]) else rep(NA_character_, count)
    get_context <- function(name) {
      if (name %in% names(data)) as.character(data[[name]][condition]) else rep(NA_character_, count)
    }
    cases[[length(cases) + 1L]] <<- data.frame(
      rule_id = rule_id,
      category = category,
      severity = severity,
      message = message,
      source_rule = source_rule,
      proposed_action = proposed_action,
      variable = variable,
      interview__key = id[condition],
      interview__id = get_context("interview__id"),
      cover_id = get_context("cover_id"),
      cover_district = get_context("cover_district"),
      observed_value = value,
      stringsAsFactors = FALSE
    )
  }
}

# -----------------------------------------------------------------------------
# 0. Integrite technique et statut
# -----------------------------------------------------------------------------
key_missing <- is.na(id) | !nzchar(trimws(id))
key_duplicate <- duplicated(id) | duplicated(id, fromLast = TRUE)
add_rule("SYS_KEY_MISSING", "systeme", "interview__key", key_missing,
         "error", "donnee_systeme", "manual_review",
         "Cle technique absente")
add_rule("SYS_KEY_DUPLICATE", "systeme", "interview__key", key_duplicate,
         "error", "donnee_systeme", "manual_review",
         "Cle technique dupliquee")

if (available("interview__status")) {
  status <- num("interview__status")
  add_rule("SYS_STATUS_NOT_COMPLETED", "systeme", "interview__status",
           !is.na(status) & status != 100, "warning", "Survey Solutions",
           "exclude_or_revoir", "Entretien hors statut Completed (100)")
}
if (available("consentement")) {
  consent <- num("consentement")
  add_rule("SYS_CONSENT_NOT_POSITIVE", "systeme", "consentement",
           is.na(consent) | consent != 1, "error", "questionnaire",
           "exclude_or_revoir", "Consentement absent ou non positif")
}

# -----------------------------------------------------------------------------
# 1. Manquants dans l'univers
# -----------------------------------------------------------------------------
employed <- num("employe")
f1 <- num("f1")
f4 <- num("f4")
g3 <- num("g3")
g5 <- num("g5")
g6 <- num("g6")
g7 <- num("g7")
h4 <- num("h4")
h4a <- num("h4a")
h5 <- num("h5")
j1 <- num("j1")
n1 <- num("n1")

add_rule("EMP_F1_MISSING", "manquant_univers", "f1",
         employed == 1 & is.na(f1), "error", "questionnaire",
         "manual_review", "Situation dans l'emploi manquante pour une personne en emploi")
add_rule("EMP_F4_MISSING", "manquant_univers", "f4",
         employed == 1 & is.na(f4), "warning", "questionnaire",
         "manual_review", "Duree de l'activite manquante pour une personne en emploi")
add_rule("EMP_G3_MISSING", "manquant_univers", "g3",
         employed == 1 & is.na(g3), "error", "questionnaire",
         "manual_review", "Heures de travail manquantes pour une personne en emploi")
add_rule("EMP_G5_MISSING", "manquant_univers", "g5",
         employed == 1 & is.na(g5), "warning", "questionnaire",
         "manual_review", "Type d'heures manquant pour une personne en emploi")
add_rule("EMP_H4_MISSING", "manquant_univers", "h4",
         employed == 1 & f1 %in% c(2, 3, 4) & is.na(h4), "warning", "questionnaire",
         "manual_review", "Formalisation manquante dans l'univers independant/employeur")
add_rule("COH_Q1_MISSING", "manquant_univers", "q1",
         is.na(num("q1")), "warning", "cadre_indicateurs",
         "manual_review", "Composante appartenance/cohesion manquante")

# -----------------------------------------------------------------------------
# 2. Coherence des sauts / univers
# -----------------------------------------------------------------------------
add_rule("EMP_F1_OUTSIDE", "saut_univers", "f1",
         !is.na(f1) & employed != 1, "error", "questionnaire",
         "clear_or_revoir", "F1 renseignee hors univers emploi")
add_rule("EMP_G3_OUTSIDE", "saut_univers", "g3",
         !is.na(g3) & employed != 1, "error", "questionnaire",
         "clear_or_revoir", "G3 renseignee hors univers emploi")
add_rule("EMP_G6_OUTSIDE", "saut_univers", "g6",
         !is.na(g6) & !(employed == 1 & g5 == 1), "error", "questionnaire",
         "clear_or_revoir", "G6 renseignee hors univers activite secondaire/heures supplementaires")
add_rule("EMP_H4_OUTSIDE", "saut_univers", "h4",
         !is.na(h4) & !(employed == 1 & f1 %in% c(2, 3, 4)), "error", "questionnaire",
         "clear_or_revoir", "H4 renseignee hors univers independant/employeur")
add_rule("EMP_H4A_OUTSIDE", "saut_univers", "h4a",
         !is.na(h4a) & !(employed == 1 & f1 %in% c(2, 3, 4)), "error", "questionnaire",
         "clear_or_revoir", "H4A renseignee hors univers independant/employeur")
add_rule("EMP_H5_OUTSIDE", "saut_univers", "h5",
         !is.na(h5) & !(employed == 1 & f1 %in% c(2, 3, 4)), "error", "questionnaire",
         "clear_or_revoir", "H5 renseignee hors univers independant/employeur")
add_rule("SEARCH_J1_OUTSIDE", "saut_univers", "j1",
         !is.na(j1) & employed == 1, "warning", "questionnaire",
         "revoir", "J1 renseignee pour une personne classee en emploi")
add_rule("SHOCK_N2_N5_OUTSIDE", "saut_univers", "n2",
         n1 == 2 & (!is.na(num("n2")) | !is.na(num("n3")) |
                      !is.na(num("n4")) | !is.na(num("n5"))),
         "warning", "questionnaire", "revoir",
         "Reponses aux consequences du choc alors que N1 indique l'absence de choc")
add_rule("UNDEREMP_G7A_OUTSIDE", "saut_univers", "g7a",
         !is.na(num("g7a")) & g7 == 2, "warning", "questionnaire",
         "revoir", "G7A renseignee alors que G7 indique l'absence de souhait")

# -----------------------------------------------------------------------------
# 3. Domaines legaux et codes speciaux
# -----------------------------------------------------------------------------
age <- num("age")
add_rule("DEM_AGE_DOMAIN", "domaine", "age",
         !is.na(age) & (age < 15 | age > 99), "error", "questionnaire/metier_propose",
         "manual_review", "Age hors domaine plausible 15-99")
add_rule("DEM_AGE_TARGET", "domaine", "age",
         !is.na(age) & (age < 15 | age > 35), "warning", "PAD/metier_propose",
         "revoir_ciblage", "Age hors cible PAD provisoire 15-35")
add_rule("EMP_G3_DOMAIN", "domaine", "g3",
         !is.na(g3) & (g3 < 0 | g3 > 168), "error", "questionnaire/metier_propose",
         "manual_review", "Heures hebdomadaires hors domaine 0-168")
add_rule("EMP_G6_DOMAIN", "domaine", "g6",
         !is.na(g6) & (g6 < 0 | g6 > 168), "error", "questionnaire/metier_propose",
         "manual_review", "Heures supplementaires hors domaine 0-168")
add_rule("EMP_H4A_DOMAIN", "domaine", "h4a",
         !is.na(h4a) & h4a < 0, "error", "questionnaire",
         "manual_review", "Nombre d'emplois crees negatif")
add_rule("INCOME_H5_SPECIAL", "domaine", "h5",
         !is.na(h5) & h5 %in% c(9998, 9999, 99999, 999999), "warning", "questionnaire",
         "recode_special_missing", "Code special ou valeur sentinelle dans H5")
add_rule("COH_Q2_NON_NUMERIC", "domaine", "q2",
         available("q2") & !is.na(data$q2) &
           is.na(suppressWarnings(as.numeric(as.character(data$q2)))),
         "warning", "donnee_observee", "manual_codification",
         "Q2 contient une reponse textuelle ou non numerique")

# -----------------------------------------------------------------------------
# 4. Plausibilite et coherences metier
# -----------------------------------------------------------------------------
hours_total <- g3 + ifelse(g5 == 1 & !is.na(g6), g6, 0)
add_rule("EMP_HOURS_OVER_84", "plausibilite", "g3",
         employed == 1 & !is.na(hours_total) & hours_total > 84,
         "warning", "metier_propose", "manual_review",
         "Total d'heures superieur a 84 par semaine")
add_rule("EMP_H4A_LARGE", "plausibilite", "h4a",
         employed == 1 & f1 %in% c(2, 3, 4) & !is.na(h4a) & h4a > 100,
         "warning", "metier_propose", "manual_review",
         "Nombre d'emplois crees exceptionnellement eleve")
add_rule("INCOME_H5_LARGE", "plausibilite", "h5",
         employed == 1 & f1 %in% c(2, 3, 4) & !is.na(h5) &
           h5 >= 0 & h5 != 999999 & h5 > 5000000,
         "warning", "metier_propose", "manual_review",
         "Montant H5 exceptionnellement eleve")
add_rule("COH_Q_DOMAIN", "domaine", "q3",
         !is.na(num("q3")) & !num("q3") %in% c(1, 2), "warning", "questionnaire",
         "manual_review", "Modalite Q3 hors domaine attendu")
for (q in paste0("q", 4:10)) {
  add_rule(paste0("COH_", toupper(q), "_DOMAIN"), "domaine", q,
           !is.na(num(q)) & !num(q) %in% c(1, 2, 3, 4, 9),
           "warning", "questionnaire", "manual_review",
           paste0("Modalite ", toupper(q), " hors domaine attendu"))
}

# -----------------------------------------------------------------------------
# Confidentialite : on ne sort jamais les valeurs des variables personnelles.
# -----------------------------------------------------------------------------
pii_vars <- intersect(c("nom", "telephone", "r4", "r6"), names(data))
pii_summary <- data.frame(
  variable = pii_vars,
  n_nonmissing = vapply(data[pii_vars], function(x) sum(!is.na(x) & x != ""), integer(1)),
  treatment = "exclude_from_quality_case_exports",
  stringsAsFactors = FALSE
)

rules_df <- if (length(rules)) do.call(rbind, rules) else data.frame()
cases_df <- if (length(cases)) do.call(rbind, cases) else data.frame()

write.csv(rules_df, file.path(output_dir, "quality_rules_summary.csv"),
          row.names = FALSE, na = "")
write.csv(cases_df, file.path(output_dir, "quality_cases_for_review.csv"),
          row.names = FALSE, na = "")
write.csv(pii_summary, file.path(output_dir, "pii_exposure_summary_restricted.csv"),
          row.names = FALSE, na = "")

metadata <- c(
  paste0("input_file=", input_file),
  paste0("n_rows=", n),
  paste0("run_date=", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  "correction_applied=FALSE",
  "raw_data_modified=FALSE",
  "manual_review_required=TRUE"
)
writeLines(metadata, file.path(output_dir, "quality_run_metadata.txt"))

cat("Audit COSO termine\n")
cat("Observations testees :", n, "\n")
cat("Regles executees :", nrow(rules_df), "\n")
cat("Cas exportes pour revue :", nrow(cases_df), "\n")
cat("Sortie :", normalizePath(output_dir, mustWork = FALSE), "\n")
