# Fonctions partagees du moteur R d'apurement COSO.

require_apurement_packages <- function() {
  required <- c("haven", "writexl")
  unavailable <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
  if (length(unavailable)) {
    stop(
      "Packages R requis absents : ", paste(unavailable, collapse = ", "),
      call. = FALSE
    )
  }
}

append_rows <- function(left, right) {
  if (is.null(left) || !nrow(left)) return(right)
  if (is.null(right) || !nrow(right)) return(left)
  missing_left <- setdiff(names(right), names(left))
  missing_right <- setdiff(names(left), names(right))
  for (name in missing_left) left[[name]] <- NA
  for (name in missing_right) right[[name]] <- NA
  right <- right[names(left)]
  rbind(left, right)
}

read_utf8_csv <- function(path) {
  utils::read.csv(
    path,
    stringsAsFactors = FALSE,
    check.names = FALSE,
    na.strings = character(),
    fileEncoding = "UTF-8-BOM"
  )
}

write_utf8_csv <- function(data, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(
    data,
    path,
    row.names = FALSE,
    na = "",
    fileEncoding = "UTF-8",
    qmethod = "double"
  )
}

is_blank <- function(x) {
  is.na(x) | !nzchar(trimws(as.character(x)))
}

normalize_mask <- function(mask, n) {
  if (length(mask) == 1L) mask <- rep(mask, n)
  if (length(mask) != n) {
    stop("Une regle n'a pas retourne un masque de longueur ", n, call. = FALSE)
  }
  mask <- as.logical(mask)
  mask[is.na(mask)] <- FALSE
  mask
}

runtime_expression_r <- function(expression) {
  output <- expression
  output <- gsub("$audit_scope", "audit_scope", output, fixed = TRUE)
  output <- gsub("$metier_scope", "metier_scope", output, fixed = TRUE)
  output <- gsub("\\bmissing\\s*\\(", "stata_missing(", output, perl = TRUE)
  output <- gsub("\\btrim\\s*\\(", "stata_trim(", output, perl = TRUE)
  output <- gsub("\\breal\\s*\\(", "stata_real(", output, perl = TRUE)
  output
}

evaluate_rule_expression <- function(data, expression) {
  if (!nzchar(trimws(expression))) {
    stop("Expression de regle vide.", call. = FALSE)
  }

  helper_env <- new.env(parent = baseenv())
  helper_env$stata_missing <- function(x) {
    if (is.character(x) || is.factor(x)) {
      return(is.na(x) | !nzchar(trimws(as.character(x))))
    }
    is.na(x)
  }
  helper_env$stata_trim <- function(x) trimws(as.character(x))
  helper_env$stata_real <- function(x) suppressWarnings(as.numeric(as.character(x)))
  helper_env$inlist <- function(x, ...) {
    values <- unlist(list(...), use.names = FALSE)
    !is.na(x) & x %in% values
  }
  helper_env$inrange <- function(x, lower, upper) {
    !is.na(x) & x >= lower & x <= upper
  }
  helper_env$cond <- function(test, yes, no) {
    test <- as.logical(test)
    test[is.na(test)] <- FALSE
    ifelse(test, yes, no)
  }

  evaluation_env <- list2env(as.list(data), parent = helper_env)
  evaluation_env$audit_scope <-
    !is.na(data$interview__status) & data$interview__status == 100
  evaluation_env$metier_scope <-
    !is.na(data$analysis_eligible_provisoire) &
      data$analysis_eligible_provisoire == 1

  translated <- runtime_expression_r(expression)
  value <- eval(parse(text = translated), envir = evaluation_env)
  normalize_mask(value, nrow(data))
}

safe_file_part <- function(value, max_length = 100L) {
  value <- iconv(value, from = "UTF-8", to = "ASCII//TRANSLIT", sub = "_")
  value <- gsub("[^A-Za-z0-9_]+", "_", value)
  value <- gsub("^_+|_+$", "", value)
  if (!nzchar(value)) value <- "rapport"
  substr(value, 1L, max_length)
}

relative_project_path <- function(path, root) {
  normalized_path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  normalized_root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  prefix <- paste0(normalized_root, "/")
  if (!startsWith(tolower(normalized_path), tolower(prefix))) {
    stop("Chemin de sortie hors du projet : ", normalized_path, call. = FALSE)
  }
  substring(normalized_path, nchar(prefix) + 1L)
}

excel_ready <- function(data) {
  output <- as.data.frame(data, stringsAsFactors = FALSE)
  for (name in names(output)) {
    column <- output[[name]]
    if (inherits(column, "haven_labelled") || inherits(column, "labelled")) {
      output[[name]] <- as.character(haven::as_factor(column, levels = "both"))
    } else if (is.factor(column)) {
      output[[name]] <- as.character(column)
    } else if (inherits(column, "POSIXt")) {
      output[[name]] <- format(column, "%Y-%m-%d %H:%M:%S", tz = "UTC")
    }
  }
  output
}

write_excel_atomic <- function(sheets, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  temporary <- tempfile(
    pattern = paste0(safe_file_part(tools::file_path_sans_ext(basename(path))), "_"),
    tmpdir = dirname(path),
    fileext = ".xlsx"
  )
  on.exit(if (file.exists(temporary)) unlink(temporary, force = TRUE), add = TRUE)
  writexl::write_xlsx(lapply(sheets, excel_ready), temporary)
  if (file.exists(path)) unlink(path, force = TRUE)
  if (!file.rename(temporary, path)) {
    stop("Impossible de finaliser le rapport Excel : ", path, call. = FALSE)
  }
  invisible(path)
}

rule_message <- function(row) {
  variable <- row$variable[[1]]
  check_type <- row$check_type[[1]]
  labels <- c(
    manquant_univers = "manquant dans son univers",
    manquant_univers_multiselect = "multi-select manquant dans son univers",
    saut_univers = "renseigne hors univers",
    saut_univers_multiselect = "multi-select renseigne hors univers",
    domaine = "hors domaine questionnaire",
    domaine_multiselect = "modalite multi-select hors domaine 0/1",
    validation = "viole une validation du questionnaire",
    validation_multiselect = "viole une validation multi-select",
    code_special_autorise = "contient un code special autorise"
  )
  suffix <- unname(labels[check_type])
  if (is.na(suffix) || !nzchar(suffix)) suffix <- check_type
  paste(variable, suffix)
}

referenced_data_columns <- function(expression, data_names) {
  tokens <- unique(regmatches(
    expression,
    gregexpr("\\b[A-Za-z][A-Za-z0-9_]*\\b", expression, perl = TRUE)
  )[[1]])
  data_names[tolower(data_names) %in% tolower(tokens)]
}

export_rule_cases <- function(
  data,
  mask,
  path,
  columns,
  rule_id,
  message,
  source_regle,
  scope_source,
  decision_status,
  action,
  correction_appliquee = FALSE,
  restricted = FALSE,
  pii_columns = character()
) {
  mask <- normalize_mask(mask, nrow(data))
  count <- sum(mask)
  if (!count) return(FALSE)

  columns <- unique(intersect(columns, names(data)))
  if (!restricted) columns <- setdiff(columns, pii_columns)
  report <- as.data.frame(data[mask, columns, drop = FALSE])
  report$rule_id <- rule_id
  report$commentaire <- message
  report$source_regle <- source_regle
  report$source_perimetre <- scope_source
  report$decision_status <- decision_status
  report$action_proposee <- action
  report$correction_appliquee <- correction_appliquee
  write_excel_atomic(list(anomalies = report), path)
  TRUE
}

manifest_row <- function(
  rule_id,
  section_code,
  check_type,
  variable,
  source_regle,
  scope_source,
  decision_status,
  action,
  count,
  report_path = "",
  access_level = "interne",
  evaluation_status = "OK",
  evaluation_message = "",
  correction_applied = FALSE
) {
  data.frame(
    rule_id = rule_id,
    section_code = section_code,
    check_type = check_type,
    variable = variable,
    source_regle = source_regle,
    scope_source = scope_source,
    decision_status = decision_status,
    action = action,
    anomaly_count = as.integer(count),
    report_path = report_path,
    access_level = access_level,
    evaluation_status = evaluation_status,
    evaluation_message = evaluation_message,
    correction_applied = correction_applied,
    stringsAsFactors = FALSE
  )
}

run_section_rules <- function(data, matrix, ctx, section_code, section_order) {
  rows <- matrix[
    matrix$section_code == section_code & matrix$source_regle == "questionnaire",
    ,
    drop = FALSE
  ]
  if (!nrow(rows)) {
    stop("Aucune regle questionnaire pour la section ", section_code, call. = FALSE)
  }

  section_folder <- file.path(
    ctx$paths$document,
    sprintf("%02d_%s", as.integer(section_order), safe_file_part(section_code))
  )
  dir.create(section_folder, recursive = TRUE, showWarnings = FALSE)
  manifest <- NULL

  for (index in seq_len(nrow(rows))) {
    row <- rows[index, , drop = FALSE]
    expression <- row$rule_expression_stata[[1]]
    executable <- nzchar(expression) && row$action[[1]] == "export_excel_diagnostic"
    if (!executable) {
      manifest <- append_rows(
        manifest,
        manifest_row(
          row$rule_id[[1]], section_code, row$check_type[[1]],
          row$variable[[1]], row$source_regle[[1]], row$scope_source[[1]],
          row$decision_status[[1]], row$action[[1]], 0L,
          evaluation_status = "NON_EXECUTEE",
          evaluation_message = row$condition_status[[1]]
        )
      )
      next
    }

    evaluation <- tryCatch(
      list(mask = evaluate_rule_expression(data, expression), error = NULL),
      error = function(error) list(mask = rep(FALSE, nrow(data)), error = error)
    )
    if (!is.null(evaluation$error)) {
      manifest <- append_rows(
        manifest,
        manifest_row(
          row$rule_id[[1]], section_code, row$check_type[[1]],
          row$variable[[1]], row$source_regle[[1]], row$scope_source[[1]],
          row$decision_status[[1]], row$action[[1]], 0L,
          evaluation_status = "ERREUR",
          evaluation_message = conditionMessage(evaluation$error)
        )
      )
      next
    }

    count <- sum(evaluation$mask)
    report_path <- file.path(
      section_folder,
      paste0(safe_file_part(row$rule_id[[1]]), ".xlsx")
    )
    data_variables <- strsplit(row$data_variables[[1]], "|", fixed = TRUE)[[1]]
    export_columns <- unique(c(ctx$report_context, data_variables))
    exported <- export_rule_cases(
      data = data,
      mask = evaluation$mask,
      path = report_path,
      columns = export_columns,
      rule_id = row$rule_id[[1]],
      message = rule_message(row),
      source_regle = "questionnaire",
      scope_source = row$scope_source[[1]],
      decision_status = row$decision_status[[1]],
      action = "revue_manuelle",
      pii_columns = ctx$pii_questionnaire
    )
    manifest <- append_rows(
      manifest,
      manifest_row(
        row$rule_id[[1]], section_code, row$check_type[[1]],
        row$variable[[1]], row$source_regle[[1]], row$scope_source[[1]],
        row$decision_status[[1]], row$action[[1]], count,
        if (exported) relative_project_path(report_path, ctx$paths$root) else ""
      )
    )
  }

  errors <- manifest$evaluation_status == "ERREUR"
  if (any(errors)) {
    details <- paste(
      paste0(manifest$rule_id[errors], ": ", manifest$evaluation_message[errors]),
      collapse = "\n"
    )
    stop("Echec d'evaluation des regles de la section ", section_code, ":\n", details)
  }

  audit_scope <-
    !is.na(data$interview__status) & data$interview__status == 100
  section_variables <- unique(unlist(
    strsplit(rows$data_variables[nzchar(rows$data_variables)], "|", fixed = TRUE)
  ))
  output_columns <- unique(intersect(c(ctx$report_context, section_variables), names(data)))
  section_view <- data[audit_scope, output_columns, drop = FALSE]
  if (anyDuplicated(as.character(section_view$interview__key))) {
    stop("Cle interview__key non unique dans la vue ", section_code, call. = FALSE)
  }
  section_path <- file.path(
    ctx$paths$section_output,
    sprintf("%02d_%s.dta", as.integer(section_order), section_code)
  )
  haven::write_dta(section_view, section_path, version = 15)
  message(
    "Section ", section_code, " : ", nrow(rows), " regles, ",
    sum(manifest$anomaly_count), " couples fiche-regle."
  )
  manifest
}

calculate_run_metrics <- function(data) {
  key <- as.character(data$interview__key)
  key_duplicate <- !is_blank(key) &
    (duplicated(key) | duplicated(key, fromLast = TRUE))
  scope_questionnaire <-
    !is.na(data$interview__status) & data$interview__status == 100
  scope_metier <-
    !is.na(data$analysis_eligible_provisoire) &
      data$analysis_eligible_provisoire == 1

  numeric_column <- function(variable) {
    if (!variable %in% names(data)) return(rep(NA_real_, nrow(data)))
    suppressWarnings(as.numeric(data[[variable]]))
  }
  age <- numeric_column("age")
  employed <- numeric_column("EMPLOYE")
  f1 <- numeric_column("F1")
  g3 <- numeric_column("G3")
  g5 <- numeric_column("G5")
  g6 <- numeric_column("G6")
  h4a <- numeric_column("H4A")
  h5 <- numeric_column("H5")
  hours_total <- ifelse(
    employed == 1 & !is.na(g3) & g3 >= 0 & g3 <= 168,
    g3 + ifelse(g5 == 1 & !is.na(g6) & g6 <= 168, g6, 0),
    NA_real_
  )
  q2 <- if ("Q2" %in% names(data)) trimws(as.character(data$Q2)) else NA_character_
  q2_blank <- is.na(q2) | !nzchar(q2)
  q2_non_numeric <- !q2_blank & is.na(suppressWarnings(as.numeric(q2)))

  cover_duplicate <- rep(FALSE, nrow(data))
  if ("cover_id" %in% names(data)) {
    cover <- as.character(data$cover_id)
    cover_duplicate <- !is_blank(cover) &
      (duplicated(cover) | duplicated(cover, fromLast = TRUE))
  }

  values <- c(
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
  )
  data.frame(
    metric = c(
      "raw_rows", "questionnaire_scope_status_100",
      "metier_scope_status_100_consent_1_unique_key",
      "duplicate_interview_key_rows", "duplicate_cover_id_rows_raw",
      "duplicate_cover_id_rows_metier_scope", "age_outside_15_99_metier_scope",
      "age_outside_15_35_metier_scope", "g3_special_998_metier_scope",
      "h5_special_999999_metier_scope", "hours_over_84_metier_scope",
      "h4a_over_100_metier_scope", "h5_over_5m_excluding_special_metier_scope",
      "q2_blank_metier_scope", "q2_non_numeric_nonblank_metier_scope"
    ),
    value = as.integer(values),
    source = c(
      rep("donnee_systeme", 6), "metier_propose", "PAD/metier_propose",
      "questionnaire_code_special", "questionnaire_code_special",
      rep("metier_propose", 3), "donnee_observee",
      "donnee_observee/metier_propose"
    ),
    correction_applied = FALSE,
    stringsAsFactors = FALSE
  )
}

read_source_manifest <- function(path) {
  if (!file.exists(path)) return(character())
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  keys <- sub("=.*$", "", lines)
  values <- sub("^[^=]*=", "", lines)
  stats::setNames(values, keys)
}

prepare_generated_outputs <- function(ctx, sections) {
  known_document_paths <- c(
    file.path(ctx$paths$document, "00_systeme_restreint"),
    file.path(ctx$paths$document, "50_metier_propose"),
    file.path(ctx$paths$document, "synthese_apurement_r.xlsx"),
    file.path(
      ctx$paths$document,
      sprintf("%02d_%s", sections$section_order, sections$section_code)
    )
  )
  known_output_paths <- c(
    ctx$paths$working_base,
    ctx$paths$final_base,
    file.path(
      ctx$paths$section_output,
      sprintf("%02d_%s.dta", sections$section_order, sections$section_code)
    )
  )
  targets <- c(known_document_paths, known_output_paths)
  invisible(lapply(targets, function(path) {
    relative_project_path(path, ctx$paths$root)
    if (dir.exists(path)) unlink(path, recursive = TRUE, force = TRUE)
    if (file.exists(path)) unlink(path, force = TRUE)
  }))
}
