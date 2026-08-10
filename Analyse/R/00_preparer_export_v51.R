#!/usr/bin/env Rscript

# COSO Nord - preparation de l'export Survey Solutions V5.1
#
# Usage:
#   Rscript 00_preparer_export_v51.R input.dta output.dta dossier_rapports
#   Rscript 00_preparer_export_v51.R export.zip output.dta dossier_rapports
#
# Ce script ne corrige pas silencieusement les reponses questionnaire.
# Il applique uniquement le contrat de preparation :
#   1. lire l'archive ou le .dta principal ;
#   2. verifier la cle technique interview__key ;
#   3. documenter les statuts et le consentement ;
#   4. conserver les fiches completes (status 100) avec consentement positif ;
#   5. signaler les doublons cover_id sans les supprimer automatiquement ;
#   6. produire les rapports de controle et une base analytique provisoire.
#
# Les codes Survey Solutions sont ceux de la documentation d'export :
# 60 = InterviewerAssigned, 100 = Completed, 130 = ApprovedByHeadquarters.
# Dans l'export du 10/08/2026, seuls 60 et 100 sont observes.

suppressPackageStartupMessages({
  library(haven)
  library(dplyr)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3L) {
  stop("Fournir : input (.zip ou .dta), output .dta, dossier de rapports.")
}

input_file <- normalizePath(args[[1]], mustWork = TRUE)
output_file <- args[[2]]
report_dir <- args[[3]]
dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)

read_main <- function(path) {
  ext <- tolower(tools::file_ext(path))
  if (ext == "dta") return(haven::read_dta(path))
  if (ext == "csv") return(read.csv(path, check.names = FALSE, stringsAsFactors = FALSE))
  if (ext == "zip") {
    td <- tempfile("coso_v51_")
    dir.create(td)
    utils::unzip(path, exdir = td)
    candidates <- list.files(td, pattern = "^Questionnaire_COSO_V5\\.dta$",
                              recursive = TRUE, full.names = TRUE)
    if (!length(candidates)) stop("Archive sans Questionnaire_COSO_V5.dta")
    return(haven::read_dta(candidates[[1]]))
  }
  stop("Format non pris en charge : ", ext)
}

data <- read_main(input_file)
names(data) <- tolower(names(data))
has_cover_id <- "cover_id" %in% names(data)

required <- c("interview__key", "interview__status", "consentement")
missing_required <- setdiff(required, names(data))
if (length(missing_required)) {
  stop("Variables systeme/consentement absentes : ",
       paste(missing_required, collapse = ", "))
}

data <- data %>%
  mutate(
    source_row = row_number(),
    interview_status_label = case_when(
      interview__status == 60 ~ "InterviewerAssigned",
      interview__status == 100 ~ "Completed",
      interview__status == 130 ~ "ApprovedByHeadquarters",
      interview__status == 120 ~ "ApprovedBySupervisor",
      interview__status == 65 ~ "RejectedBySupervisor",
      interview__status == 125 ~ "RejectedByHeadquarters",
      TRUE ~ paste0("Status_", interview__status)
    ),
    technical_key_duplicate = duplicated(interview__key) |
      duplicated(interview__key, fromLast = TRUE),
    status_completed = interview__status == 100,
    status_hq_approved = interview__status == 130,
    consent_positive = consentement == 1,
    analysis_eligible = status_completed & consent_positive &
      !technical_key_duplicate,
    exclusion_reason = case_when(
      technical_key_duplicate ~ "duplicate_interview__key",
      is.na(interview__status) ~ "missing_interview__status",
      interview__status != 100 ~ "not_completed_status_100",
      is.na(consentement) ~ "missing_consentement",
      consentement != 1 ~ "consentement_not_positive",
      TRUE ~ "eligible"
    )
  )

data$cover_id_duplicate <- FALSE
if (has_cover_id) {
  data$cover_id_duplicate <- duplicated(data$cover_id) |
    duplicated(data$cover_id, fromLast = TRUE)
}

# The technical key must be unique. Do not silently choose a record if it is not.
technical_dups <- data %>%
  filter(technical_key_duplicate) %>%
  select(any_of(c("interview__key", "interview__id", "cover_id",
                  "interview__status", "consentement", "source_row")))

cover_dups <- data %>%
  filter(cover_id_duplicate) %>%
  select(any_of(c("interview__key", "interview__id", "cover_id",
                  "interview__status", "consentement", "source_row")))

excluded <- data %>%
  filter(!analysis_eligible) %>%
  select(any_of(c("interview__key", "interview__id", "cover_id",
                  "interview__status", "interview_status_label", "consentement",
                  "source_row", "exclusion_reason")))

eligible_data <- data %>% filter(analysis_eligible)
missingness <- data.frame(
  variable = names(eligible_data),
  n_missing = vapply(eligible_data, function(x) sum(is.na(x)), integer(1)),
  stringsAsFactors = FALSE
) %>%
  mutate(n_eligible = nrow(eligible_data),
         pct_missing = ifelse(n_eligible > 0, 100 * n_missing / n_eligible, NA_real_))

summary <- data %>%
  count(interview__status, interview_status_label, consentement,
        analysis_eligible, name = "n") %>%
  arrange(interview__status, consentement, desc(analysis_eligible))

write.csv(summary, file.path(report_dir, "preparation_summary.csv"),
          row.names = FALSE, na = "")
write.csv(excluded, file.path(report_dir, "excluded_interviews.csv"),
          row.names = FALSE, na = "")
write.csv(technical_dups, file.path(report_dir, "duplicate_interview_key.csv"),
          row.names = FALSE, na = "")
write.csv(cover_dups, file.path(report_dir, "duplicate_cover_id.csv"),
          row.names = FALSE, na = "")
write.csv(missingness, file.path(report_dir, "missingness_eligible.csv"),
          row.names = FALSE, na = "")

analytic <- data %>% filter(analysis_eligible)
haven::write_dta(analytic, output_file, version = 15)
write.csv(analytic, sub("\\.dta$", ".csv", output_file, ignore.case = TRUE),
          row.names = FALSE, na = "")

cat("Preparation terminee\n")
cat("Fiches brutes :", nrow(data), "\n")
cat("Fiches analytiques provisoires :", nrow(analytic), "\n")
cat("Doublons interview__key :", nrow(technical_dups), "\n")
cat("Fiches avec cover_id duplique :", nrow(cover_dups), "\n")
cat("Sortie :", output_file, "\n")
cat("Rapports :", report_dir, "\n")
