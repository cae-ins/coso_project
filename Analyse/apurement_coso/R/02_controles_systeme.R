# Integrite technique, statut Survey Solutions et consentement.

controler_systeme <- function(data, ctx) {
  output_folder <- file.path(ctx$paths$document, "00_systeme_restreint")
  dir.create(output_folder, recursive = TRUE, showWarnings = FALSE)
  manifest <- NULL

  add_system_check <- function(
    rule_id, mask, filename, columns, message_text, source, action,
    decision_status = "a_valider", restricted = TRUE
  ) {
    mask <- normalize_mask(mask, nrow(data))
    report_path <- file.path(output_folder, filename)
    exported <- export_rule_cases(
      data, mask, report_path, columns, rule_id, message_text, source,
      "donnee_systeme_ou_hypothese_apurement", decision_status, action,
      restricted = restricted, pii_columns = ctx$pii_questionnaire
    )
    append_rows(
      manifest,
      manifest_row(
        rule_id, "SYSTEME", "integrite", "", source,
        "donnee_systeme_ou_hypothese_apurement", decision_status, action,
        sum(mask),
        if (exported) relative_project_path(report_path, ctx$paths$root) else "",
        access_level = if (restricted) "interne_restreint" else "interne"
      )
    )
  }

  key <- as.character(data$interview__key)
  key_missing <- is_blank(key)
  key_duplicate <- !key_missing &
    (duplicated(key) | duplicated(key, fromLast = TRUE))

  manifest <- add_system_check(
    "SYS_INTERVIEW_KEY_MISSING", key_missing, "interview_key_manquante.xlsx",
    c(ctx$report_context, "nom_agent"), "Cle technique absente", "donnee_systeme",
    "bloquer_et_revoir"
  )
  manifest <- add_system_check(
    "SYS_INTERVIEW_KEY_DUPLICATE", key_duplicate, "interview_key_dupliquee.xlsx",
    c(ctx$report_context, "nom_agent", "interview__status", "consentement"),
    "Cle technique dupliquee", "donnee_systeme", "bloquer_et_revoir"
  )

  if ("cover_id" %in% names(data)) {
    cover <- as.character(data$cover_id)
    cover_duplicate <- !is_blank(cover) &
      (duplicated(cover) | duplicated(cover, fromLast = TRUE))
    manifest <- add_system_check(
      "SYS_COVER_ID_DUPLICATE", cover_duplicate, "cover_id_duplique.xlsx",
      c(ctx$report_context, "nom_agent", "cover_id", "interview__status", "consentement"),
      "cover_id repete; statut institutionnel a confirmer",
      "donnee_observee", "revue_manuelle_sans_deduplication"
    )
  }

  status_non_complete <-
    is.na(data$interview__status) | data$interview__status != 100
  manifest <- add_system_check(
    "SYS_STATUS_NOT_COMPLETED", status_non_complete, "statut_non_complete.xlsx",
    c(ctx$report_context, "nom_agent", "interview__status", "consentement"),
    "Entretien hors statut Completed 100",
    "Survey Solutions/hypothese_analytique",
    "exclure_analyse_apres_validation"
  )

  consent_non_positive <- is.na(data$consentement) | data$consentement != 1
  manifest <- add_system_check(
    "SYS_CONSENT_NOT_POSITIVE", consent_non_positive,
    "consentement_non_positif.xlsx",
    c(ctx$report_context, "nom_agent", "interview__status", "consentement"),
    "Consentement absent ou non positif",
    "questionnaire/hypothese_analytique",
    "exclure_analyse_apres_validation"
  )

  data$analysis_eligible_provisoire <- as.integer(
    !status_non_complete & !consent_non_positive & !key_duplicate & !key_missing
  )
  attr(data$analysis_eligible_provisoire, "label") <- paste(
    "Hypothese provisoire: statut 100 + consentement positif + cle unique"
  )
  haven::write_dta(data, ctx$paths$working_base, version = 15)
  message("Controles systeme termines sans suppression ni deduplication.")
  list(data = data, manifest = manifest)
}
