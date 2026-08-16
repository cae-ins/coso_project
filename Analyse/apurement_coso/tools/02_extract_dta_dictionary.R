#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(haven))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2L) {
  stop("Usage : 02_extract_dta_dictionary.R input.zip|input.dta output.csv")
}

input_file <- normalizePath(args[[1]], mustWork = TRUE)
output_file <- args[[2]]
dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)

read_main_dta <- function(path) {
  ext <- tolower(tools::file_ext(path))
  if (ext == "dta") {
    return(haven::read_dta(path))
  }
  if (ext != "zip") {
    stop("Format non pris en charge : ", ext)
  }

  listing <- utils::unzip(path, list = TRUE)
  exact <- listing$Name[basename(listing$Name) == "Questionnaire_COSO_V5.dta"]
  if (!length(exact)) {
    candidates <- listing$Name[
      grepl("\\.dta$", listing$Name, ignore.case = TRUE) &
        !grepl("(^|/)(assignment|interview)__", listing$Name, ignore.case = TRUE)
    ]
    if (length(candidates) != 1L) {
      stop("Impossible d'identifier sans ambiguite le fichier .dta principal.")
    }
    exact <- candidates[[1]]
  }

  temp_root <- tempfile("coso_dictionary_")
  dir.create(temp_root)
  on.exit(unlink(temp_root, recursive = TRUE, force = TRUE), add = TRUE)
  utils::unzip(path, files = exact[[1]], exdir = temp_root)
  haven::read_dta(file.path(temp_root, exact[[1]]))
}

collapse_values <- function(x, max_values = 40L) {
  if (inherits(x, "POSIXt") || inherits(x, "Date")) {
    values <- unique(as.character(x[!is.na(x)]))
  } else if (is.character(x)) {
    values <- unique(trimws(x[!is.na(x) & nzchar(trimws(x))]))
  } else {
    values <- unique(as.character(x[!is.na(x)]))
  }
  values <- head(values, max_values)
  paste(values, collapse = "|")
}

collapse_labels <- function(x) {
  labels <- attr(x, "labels", exact = TRUE)
  if (is.null(labels) || !length(labels)) return("")
  paste(paste0(unname(labels), ":", names(labels)), collapse = "|")
}

data <- read_main_dta(input_file)
n_rows <- nrow(data)
pii_names <- tolower(c(
  "interview__key", "interview__id", "assignment__id", "cover_id",
  "nom", "telephone", "nom_agent", "nom_sup", "B7", "R1A", "R2A",
  "R3B", "R4", "R6"
))
control_excluded_names <- tolower(c(
  "cover_id", "nom", "telephone", "B7", "R1A", "R2A", "R3B", "R4", "R6"
))

`%||%` <- function(x, y) if (is.null(x) || !length(x)) y else x

dictionary <- do.call(rbind, lapply(names(data), function(variable) {
  x <- data[[variable]]
  nonmissing <- !is.na(x)
  blank <- if (is.character(x)) is.na(x) | !nzchar(trimws(x)) else is.na(x)
  numeric_x <- if (is.numeric(x)) suppressWarnings(as.numeric(x)) else rep(NA_real_, length(x))
  finite_x <- numeric_x[is.finite(numeric_x)]
  pii_restricted <- tolower(variable) %in% pii_names
  control_excluded <- tolower(variable) %in% control_excluded_names
  sample_restricted <- pii_restricted || is.character(x)
  data.frame(
    variable = variable,
    variable_lower = tolower(variable),
    r_class = paste(class(x), collapse = "|"),
    storage_type = typeof(x),
    stata_format = as.character(attr(x, "format.stata", exact = TRUE) %||% ""),
    variable_label = as.character(attr(x, "label", exact = TRUE) %||% ""),
    value_labels = if (pii_restricted) "[REDACTED]" else collapse_labels(x),
    n_rows = n_rows,
    n_missing = sum(is.na(x)),
    n_blank_or_missing = sum(blank),
    n_unique_nonmissing = length(unique(x[nonmissing])),
    observed_values_sample = if (sample_restricted) "[REDACTED]" else collapse_values(x),
    min_observed = if (!pii_restricted && length(finite_x)) min(finite_x) else NA_real_,
    max_observed = if (!pii_restricted && length(finite_x)) max(finite_x) else NA_real_,
    pii_restricted = pii_restricted,
    control_excluded = control_excluded,
    sample_restricted = sample_restricted,
    stringsAsFactors = FALSE
  )
}))

utils::write.csv(dictionary, output_file, row.names = FALSE, na = "", fileEncoding = "UTF-8")
cat("Dictionnaire ecrit :", normalizePath(output_file, mustWork = FALSE), "\n")
cat("Observations :", n_rows, " Variables :", ncol(data), "\n")
