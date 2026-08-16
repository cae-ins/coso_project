# Finalisation de la sortie diagnostique et des manifestes non nominatifs.

finaliser_apurement <- function(data, state) {
  data$apurement_correction_applied <- 0L
  attr(data$apurement_correction_applied, "label") <-
    "Aucune correction metier validee appliquee"
  data$apurement_status <- "diagnostic_only"
  attr(data$apurement_status, "label") <- "Statut de la sortie d'apurement"
  data$apurement_run_date <- format(Sys.Date(), "%Y-%m-%d")

  source_manifest <- read_source_manifest(
    file.path(state$ctx$paths$staging, "source_manifest.txt")
  )
  source_hash <- if ("sha256" %in% names(source_manifest)) {
    unname(source_manifest[["sha256"]])
  } else {
    ""
  }
  data$apurement_source_sha256 <- source_hash
  haven::write_dta(data, state$ctx$paths$final_base, version = 15)

  metrics <- calculate_run_metrics(data)
  ordered_manifest <- state$manifest[order(state$manifest$rule_id), , drop = FALSE]
  write_utf8_csv(metrics, state$ctx$paths$run_summary)
  write_utf8_csv(ordered_manifest, state$ctx$paths$rule_counts)

  executable_questionnaire <- sum(
    state$matrix$source_regle == "questionnaire" &
      state$matrix$action == "export_excel_diagnostic" &
      nzchar(state$matrix$rule_expression_stata)
  )
  executable_metier <- sum(
    state$matrix$condition_status == "executable_metier_propose"
  )
  engine_manifest <- data.frame(
    engine = "R",
    output_status = "diagnostic_only",
    source_sha256 = source_hash,
    raw_rows = nrow(data),
    section_views = nrow(state$sections),
    questionnaire_rules_evaluated = executable_questionnaire,
    proposed_business_rules_evaluated = executable_metier,
    automatic_corrections = state$correction_count,
    questionnaire_scope = state$ctx$audit_scope_label,
    business_scope = state$ctx$metier_scope_label,
    stringsAsFactors = FALSE
  )
  write_utf8_csv(engine_manifest, state$ctx$paths$engine_manifest)

  synthesis_path <- file.path(state$ctx$paths$document, "synthese_apurement_r.xlsx")
  write_excel_atomic(
    list(
      indicateurs_run = metrics,
      synthese_regles = ordered_manifest,
      manifeste_moteur = engine_manifest
    ),
    synthesis_path
  )
  message("Base diagnostique R produite : ", state$ctx$paths$final_base)
  invisible(list(data = data, metrics = metrics, engine_manifest = engine_manifest))
}
