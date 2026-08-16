#!/usr/bin/env Rscript

# Validation dynamique minimale du perimetre et des controles COSO proposes.
# Cette verification ne modifie aucune donnee et ne remplace pas l'execution Stata.

suppressPackageStartupMessages(library(haven))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2L) {
  stop("Usage : 05_validate_data_evidence.R input.zip|input.dta output.csv")
}

input_file <- normalizePath(args[[1]], mustWork = TRUE)
output_file <- args[[2]]
dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)

read_main <- function(path) {
  if (tolower(tools::file_ext(path)) == "dta") return(haven::read_dta(path))
  listing <- utils::unzip(path, list = TRUE)
  entry <- listing$Name[basename(listing$Name) == "Questionnaire_COSO_V5.dta"]
  if (length(entry) != 1L) stop("Questionnaire_COSO_V5.dta non identifie.")
  temp_root <- tempfile("coso_evidence_")
  dir.create(temp_root)
  on.exit(unlink(temp_root, recursive = TRUE, force = TRUE), add = TRUE)
  utils::unzip(path, files = entry, exdir = temp_root)
  haven::read_dta(file.path(temp_root, entry))
}

data <- read_main(input_file)
required <- c("interview__key", "interview__status", "consentement")
missing_required <- setdiff(required, names(data))
if (length(missing_required)) {
  stop("Variables obligatoires absentes : ", paste(missing_required, collapse = ", "))
}

key <- as.character(data$interview__key)
key_duplicate <- duplicated(key) | duplicated(key, fromLast = TRUE)
scope_questionnaire <- !is.na(data$interview__status) & data$interview__status == 100
scope_metier <- scope_questionnaire & !is.na(data$consentement) &
  data$consentement == 1 & !key_duplicate

num <- function(variable) {
  if (!variable %in% names(data)) return(rep(NA_real_, nrow(data)))
  suppressWarnings(as.numeric(data[[variable]]))
}

age <- num("age")
employed <- num("EMPLOYE")
f1 <- num("F1")
g3 <- num("G3")
g5 <- num("G5")
g6 <- num("G6")
h4a <- num("H4A")
h5 <- num("H5")
hours_total <- ifelse(
  employed == 1 & !is.na(g3) & g3 >= 0 & g3 <= 168,
  g3 + ifelse(g5 == 1 & !is.na(g6) & g6 <= 168, g6, 0),
  NA_real_
)

q2 <- if ("Q2" %in% names(data)) trimws(as.character(data$Q2)) else rep(NA_character_, nrow(data))
q2_blank <- is.na(q2) | !nzchar(q2)
q2_non_numeric <- !q2_blank & is.na(suppressWarnings(as.numeric(q2)))

cover_duplicate <- rep(FALSE, nrow(data))
if ("cover_id" %in% names(data)) {
  cover <- as.character(data$cover_id)
  cover_duplicate <- !is.na(cover) & nzchar(trimws(cover)) &
    (duplicated(cover) | duplicated(cover, fromLast = TRUE))
}

metrics <- data.frame(
  metric = c(
    "raw_rows",
    "questionnaire_scope_status_100",
    "metier_scope_status_100_consent_1_unique_key",
    "duplicate_interview_key_rows",
    "duplicate_cover_id_rows_raw",
    "duplicate_cover_id_rows_metier_scope",
    "age_outside_15_99_metier_scope",
    "age_outside_15_35_metier_scope",
    "g3_special_998_metier_scope",
    "h5_special_999999_metier_scope",
    "hours_over_84_metier_scope",
    "h4a_over_100_metier_scope",
    "h5_over_5m_excluding_special_metier_scope",
    "q2_blank_metier_scope",
    "q2_non_numeric_nonblank_metier_scope"
  ),
  value = c(
    nrow(data),
    sum(scope_questionnaire),
    sum(scope_metier),
    sum(key_duplicate),
    sum(cover_duplicate),
    sum(cover_duplicate & scope_metier),
    sum(scope_metier & !is.na(age) & (age < 15 | age > 99)),
    sum(scope_metier & !is.na(age) & (age < 15 | age > 35)),
    sum(scope_metier & !is.na(g3) & g3 == 998),
    sum(scope_metier & !is.na(h5) & h5 == 999999),
    sum(scope_metier & !is.na(hours_total) & hours_total > 84),
    sum(scope_metier & employed == 1 & f1 %in% c(2, 3) & !is.na(h4a) & h4a > 100),
    sum(scope_metier & employed == 1 & f1 %in% c(2, 3, 4) & !is.na(h5) & h5 != 999999 & h5 > 5000000),
    sum(scope_metier & q2_blank),
    sum(scope_metier & q2_non_numeric)
  ),
  source = c(
    rep("donnee_systeme", 6),
    "metier_propose",
    "PAD/metier_propose",
    "questionnaire_code_special",
    "questionnaire_code_special",
    rep("metier_propose", 3),
    "donnee_observee",
    "donnee_observee/metier_propose"
  ),
  correction_applied = FALSE,
  stringsAsFactors = FALSE
)

utils::write.csv(metrics, output_file, row.names = FALSE, na = "", fileEncoding = "UTF-8")
cat("Validation dynamique R terminee :", normalizePath(output_file, mustWork = FALSE), "\n")
for (index in seq_len(nrow(metrics))) {
  cat(metrics$metric[[index]], "=", metrics$value[[index]], "\n")
}
