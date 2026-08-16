# Configuration du moteur R d'apurement COSO.

create_apurement_context <- function(project_root = NULL) {
  if (is.null(project_root) || !nzchar(project_root)) {
    project_root <- Sys.getenv("COSO_APUREMENT_ROOT", unset = getwd())
  }
  root <- normalizePath(project_root, winslash = "/", mustWork = TRUE)
  marker <- file.path(root, "R", "00_master.R")
  if (!file.exists(marker)) {
    stop(
      "Le dossier fourni n'est pas la racine Analyse/apurement_coso : ",
      root,
      call. = FALSE
    )
  }

  paths <- list(
    root = root,
    datain = file.path(root, "datain"),
    staging = file.path(root, "datain", "staging"),
    brute = file.path(root, "datain", "brute"),
    standard = file.path(root, "datain", "standard"),
    section_output = file.path(root, "dataout", "standard"),
    final_output = file.path(root, "dataout", "final"),
    document = file.path(root, "document"),
    logs = file.path(root, "logs"),
    generated = file.path(root, "generated"),
    r_root = file.path(root, "R"),
    r_generated = file.path(root, "R", "generated"),
    raw_main = file.path(root, "datain", "brute", "Questionnaire_COSO_V5.dta"),
    working_base = file.path(root, "datain", "standard", "coso_v51_standard.dta"),
    final_base = file.path(root, "dataout", "final", "coso_apurement_diagnostic.dta"),
    rule_matrix = file.path(root, "generated", "apurement_rule_matrix.csv"),
    run_summary = file.path(root, "generated", "r_run_summary.csv"),
    rule_counts = file.path(root, "generated", "r_rule_counts.csv"),
    engine_manifest = file.path(root, "generated", "r_engine_manifest.csv")
  )

  for (path in paths[c(
    "datain", "staging", "brute", "standard", "section_output",
    "final_output", "document", "logs", "generated", "r_generated"
  )]) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }

  list(
    paths = paths,
    audit_scope_label = "interview__status == 100",
    audit_scope_source = "hypothese_apurement",
    metier_scope_label = paste(
      "interview__status == 100 & consentement == 1 &",
      "interview__key unique"
    ),
    metier_scope_source = "hypothese_apurement",
    pii_questionnaire = c(
      "cover_id", "nom", "telephone", "nom_agent", "nom_sup", "B7",
      "R1A", "R2A", "R3B", "R4", "R6"
    ),
    report_context = c("interview__key", "cover_district")
  )
}
