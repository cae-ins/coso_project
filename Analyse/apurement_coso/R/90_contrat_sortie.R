# Contrat de sortie avant production de la base diagnostique.

verifier_contrat_sortie <- function(data, state) {
  required <- c(
    "interview__key", "interview__status", "consentement",
    "analysis_eligible_provisoire"
  )
  missing_required <- setdiff(required, names(data))
  if (length(missing_required)) {
    stop(
      "Variables requises absentes avant sortie : ",
      paste(missing_required, collapse = ", "),
      call. = FALSE
    )
  }
  if (any(is_blank(data$interview__key))) {
    stop("La sortie finale est bloquee : cle interview__key manquante.")
  }
  if (anyDuplicated(as.character(data$interview__key))) {
    stop("La sortie finale est bloquee : cle interview__key non unique.")
  }
  expected_views <- file.path(
    state$ctx$paths$section_output,
    sprintf("%02d_%s.dta", state$sections$section_order, state$sections$section_code)
  )
  missing_views <- expected_views[!file.exists(expected_views)]
  if (length(missing_views)) {
    stop(
      "Vues de section absentes : ", paste(basename(missing_views), collapse = ", ")
    )
  }
  executable <- state$matrix$action == "export_excel_diagnostic" &
    nzchar(state$matrix$rule_expression_stata)
  evaluated_ids <- state$manifest$rule_id[
    state$manifest$evaluation_status == "OK"
  ]
  missing_evaluations <- setdiff(state$matrix$rule_id[executable], evaluated_ids)
  if (length(missing_evaluations)) {
    stop(
      "Regles executables non evaluees : ",
      paste(missing_evaluations, collapse = ", "),
      call. = FALSE
    )
  }
  if (state$correction_count != 0L || any(state$manifest$correction_applied)) {
    stop("Une correction non attendue a ete detectee.", call. = FALSE)
  }
  raw <- haven::read_dta(state$ctx$paths$raw_main)
  if (nrow(raw) != nrow(data)) {
    stop("Le nombre de lignes a change sans correction validee.", call. = FALSE)
  }
  missing_raw_columns <- setdiff(names(raw), names(data))
  if (length(missing_raw_columns)) {
    stop(
      "Colonnes brutes absentes de la sortie : ",
      paste(missing_raw_columns, collapse = ", "),
      call. = FALSE
    )
  }
  raw_comparison <- all.equal(
    raw,
    data[names(raw)],
    check.attributes = TRUE
  )
  if (!isTRUE(raw_comparison)) {
    stop(
      "Les colonnes brutes ont ete modifiees alors qu'aucune correction n'est validee : ",
      paste(raw_comparison, collapse = " | "),
      call. = FALSE
    )
  }
  invisible(TRUE)
}
