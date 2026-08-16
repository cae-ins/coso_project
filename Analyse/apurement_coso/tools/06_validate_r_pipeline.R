#!/usr/bin/env Rscript

# Validation de bout en bout du moteur R et de ses sorties non nominatives.

suppressPackageStartupMessages({
  library(haven)
  library(readxl)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1L) {
  stop("Usage : 06_validate_r_pipeline.R project_root")
}
root <- normalizePath(args[[1]], winslash = "/", mustWork = TRUE)
source(file.path(root, "R", "lib_apurement.R"))

toy <- data.frame(
  interview__status = c(100, 100, 100),
  analysis_eligible_provisoire = c(1, 1, 1),
  trigger = c(NA_character_, "  ", "2026-08-16"),
  stringsAsFactors = FALSE
)
stopifnot(identical(
  evaluate_rule_expression(toy, "!missing(trigger) & ($audit_scope)"),
  c(FALSE, FALSE, TRUE)
))

read_csv_clean <- function(path) {
  utils::read.csv(
    path,
    stringsAsFactors = FALSE,
    check.names = FALSE,
    na.strings = character(),
    fileEncoding = "UTF-8-BOM"
  )
}

r_files <- list.files(
  file.path(root, "R"),
  pattern = "\\.R$",
  recursive = TRUE,
  full.names = TRUE
)
parse_errors <- vapply(r_files, function(path) {
  tryCatch({
    parse(path)
    ""
  }, error = conditionMessage)
}, character(1))
if (any(nzchar(parse_errors))) {
  stop(
    "Erreurs de syntaxe R : ",
    paste(names(parse_errors)[nzchar(parse_errors)], collapse = ", ")
  )
}

matrix <- read_csv_clean(file.path(root, "generated", "apurement_rule_matrix.csv"))
counts <- read_csv_clean(file.path(root, "generated", "r_rule_counts.csv"))
metrics <- read_csv_clean(file.path(root, "generated", "r_run_summary.csv"))
evidence <- read_csv_clean(file.path(root, "generated", "data_evidence_validation.csv"))
engine <- read_csv_clean(file.path(root, "generated", "r_engine_manifest.csv"))
dictionary <- read_csv_clean(file.path(root, "generated", "dictionnaire_variables.csv"))
questionnaire <- read_csv_clean(file.path(root, "generated", "questionnaire_rules.csv"))
sections <- read_csv_clean(file.path(root, "generated", "sections_questionnaire.csv"))

expected_questionnaire_rules <- sum(
  matrix$source_regle == "questionnaire" &
    matrix$action == "export_excel_diagnostic" &
    nzchar(matrix$rule_expression_stata)
)
expected_business_rules <- sum(
  matrix$condition_status == "executable_metier_propose"
)
expected_executable_rules <- expected_questionnaire_rules + expected_business_rules
stopifnot(!anyDuplicated(matrix$rule_id))
stopifnot(!anyDuplicated(counts$rule_id))
stopifnot(sum(counts$evaluation_status == "ERREUR") == 0L)
stopifnot(sum(
  counts$evaluation_status == "OK" & counts$section_code != "SYSTEME"
) == expected_executable_rules)
stopifnot(
  as.integer(engine$questionnaire_rules_evaluated[[1]]) ==
    expected_questionnaire_rules
)
stopifnot(
  as.integer(engine$proposed_business_rules_evaluated[[1]]) ==
    expected_business_rules
)
stopifnot(as.integer(engine$automatic_corrections[[1]]) == 0L)
stopifnot(engine$output_status[[1]] == "diagnostic_only")
stopifnot(as.integer(engine$section_views[[1]]) == nrow(sections))
stopifnot(all(
  dictionary$observed_values_sample[
    tolower(dictionary$sample_restricted) == "true"
  ] == "[REDACTED]"
))
stopifnot(all(
  dictionary$value_labels[tolower(dictionary$pii_restricted) == "true"] %in%
    c("", "[REDACTED]")
))
staff_questionnaire <- questionnaire[
  tolower(questionnaire$variable) %in% c("nom_agent", "nom_sup"),
  ,
  drop = FALSE
]
stopifnot(nrow(staff_questionnaire) >= 1L)
staff_option_items <- unlist(strsplit(staff_questionnaire$options, "|", fixed = TRUE))
stopifnot(length(staff_option_items) >= nrow(staff_questionnaire))
stopifnot(all(grepl("^[^:]+:\\[REDACTED\\]$", staff_option_items)))
stopifnot(all(!grepl("^[A-Za-z]:[/\\\\]", counts$report_path)))
stopifnot(all(!grepl("^[A-Za-z]:[/\\\\]", questionnaire$source_document)))

comparison <- merge(
  metrics[c("metric", "value")],
  evidence[c("metric", "value")],
  by = "metric",
  suffixes = c("_r_engine", "_evidence"),
  all = TRUE
)
if (any(is.na(comparison$value_r_engine)) || any(is.na(comparison$value_evidence))) {
  stop("Les listes d'indicateurs R et de validation dynamique divergent.")
}
if (any(as.integer(comparison$value_r_engine) != as.integer(comparison$value_evidence))) {
  stop("Les valeurs du moteur R divergent de la validation dynamique existante.")
}

final_path <- file.path(root, "dataout", "final", "coso_apurement_diagnostic.dta")
final <- haven::read_dta(final_path)
raw <- haven::read_dta(file.path(root, "datain", "brute", "Questionnaire_COSO_V5.dta"))
staff_names <- unique(c(
  names(attr(raw$nom_agent, "labels", exact = TRUE)),
  names(attr(raw$nom_sup, "labels", exact = TRUE))
))
staff_names <- staff_names[!is.na(staff_names) & nzchar(staff_names)]
text_artifacts <- unique(c(
  list.files(file.path(root, "generated"), full.names = TRUE, recursive = TRUE),
  list.files(file.path(root, "R"), full.names = TRUE, recursive = TRUE),
  list.files(file.path(root, "program"), full.names = TRUE, recursive = TRUE),
  list.files(file.path(root, "tools"), full.names = TRUE, recursive = TRUE),
  list.files(file.path(root, "config"), full.names = TRUE, recursive = TRUE),
  file.path(root, "README.md")
))
text_artifacts <- text_artifacts[
  file.exists(text_artifacts) &
    grepl("\\.(csv|md|R|py|ps1|do)$", text_artifacts, ignore.case = TRUE)
]
staff_name_leaks <- character()
for (path in text_artifacts) {
  content <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  leaked_names <- staff_names[vapply(
    staff_names,
    function(name) grepl(name, content, fixed = TRUE),
    logical(1)
  )]
  if (length(leaked_names)) {
    staff_name_leaks <- c(
      staff_name_leaks,
      paste0(relative_project_path(path, root), ": ", paste(leaked_names, collapse = " | "))
    )
  }
}
if (length(staff_name_leaks)) {
  stop(
    "Noms de personnel presents dans des artefacts tracables : ",
    paste(staff_name_leaks, collapse = "; ")
  )
}
metric_value <- function(name) {
  values <- metrics$value[metrics$metric == name]
  if (length(values) != 1L) stop("Indicateur absent ou duplique : ", name)
  as.integer(values)
}
stopifnot(nrow(final) == metric_value("raw_rows"))
stopifnot(nrow(final) == nrow(raw))
stopifnot(identical(names(final)[seq_along(names(raw))], names(raw)))
allowed_new_columns <- c(
  "analysis_eligible_provisoire", "apurement_correction_applied",
  "apurement_status", "apurement_run_date", "apurement_source_sha256"
)
stopifnot(setequal(setdiff(names(final), names(raw)), allowed_new_columns))
stopifnot(isTRUE(all.equal(
  raw,
  final[names(raw)],
  check.attributes = TRUE
)))
stopifnot(!anyDuplicated(as.character(final$interview__key)))
stopifnot(all(final$apurement_correction_applied == 0L))
stopifnot(all(final$apurement_status == "diagnostic_only"))
stopifnot(length(unique(final$apurement_source_sha256)) == 1L)
source_manifest_path <- file.path(root, "datain", "staging", "source_manifest.txt")
source_manifest_lines <- readLines(source_manifest_path, warn = FALSE, encoding = "UTF-8")
source_hash_line <- source_manifest_lines[grepl("^sha256=", source_manifest_lines)]
stopifnot(length(source_hash_line) == 1L)
source_hash <- sub("^sha256=", "", source_hash_line)
stopifnot(unique(final$apurement_source_sha256) == source_hash)
stopifnot(engine$source_sha256[[1]] == source_hash)

normalized_final <- final
for (name in names(normalized_final)) {
  if (is.character(normalized_final[[name]])) {
    blank <- !is.na(normalized_final[[name]]) &
      !nzchar(trimws(normalized_final[[name]]))
    normalized_final[[name]][blank] <- NA_character_
  }
}
executable_rows <- matrix[
  matrix$action == "export_excel_diagnostic" &
    nzchar(matrix$rule_expression_stata),
  ,
  drop = FALSE
]
blank_semantic_differences <- vapply(seq_len(nrow(executable_rows)), function(index) {
  expression <- executable_rows$rule_expression_stata[[index]]
  !identical(
    evaluate_rule_expression(final, expression),
    evaluate_rule_expression(normalized_final, expression)
  )
}, logical(1))
if (any(blank_semantic_differences)) {
  stop(
    "Semantique des chaines vides divergente pour : ",
    paste(executable_rows$rule_id[blank_semantic_differences], collapse = ", ")
  )
}

section_files <- list.files(
  file.path(root, "dataout", "standard"),
  pattern = "^[0-9]{2}_[A-Z0-9]+\\.dta$",
  full.names = TRUE
)
section_rows <- vapply(section_files, function(path) nrow(haven::read_dta(path)), integer(1))
stopifnot(length(section_files) == nrow(sections))
stopifnot(all(section_rows == metric_value("questionnaire_scope_status_100")))

sensitive <- c(
  "cover_id", "nom", "telephone", "nom_agent", "nom_sup", "B7", "R1A",
  "R2A", "R3B", "R4", "R6"
)
report_paths <- counts$report_path[nzchar(counts$report_path)]
questionnaire_reports <- report_paths[
  !grepl("^document/00_systeme_restreint/", report_paths, ignore.case = TRUE)
]
for (relative in questionnaire_reports) {
  path <- file.path(root, relative)
  columns <- names(readxl::read_xlsx(path, n_max = 0L))
  leaked <- intersect(columns, sensitive)
  if (length(leaked)) {
    stop(
      "Colonnes sensibles dans un rapport non restreint : ",
      relative, " [", paste(leaked, collapse = ", "), "]"
    )
  }
}

cat("Validation du moteur R : OK\n")
cat("Scripts R parses :", length(r_files), "\n")
cat("Regles questionnaire evaluees :", expected_questionnaire_rules, "\n")
cat("Regles metier proposees evaluees :", expected_business_rules, "\n")
cat(
  "Vues de section :", nrow(sections), "x",
  metric_value("questionnaire_scope_status_100"), "lignes\n"
)
cat("Corrections automatiques : 0\n")
