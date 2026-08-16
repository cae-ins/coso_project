# Initialisation sans filtrage, recodage ni correction.

initialiser_base <- function(ctx) {
  if (!file.exists(ctx$paths$raw_main)) {
    stop(
      "Base brute absente : ", ctx$paths$raw_main,
      ". Executer tools/00_build_template.ps1.",
      call. = FALSE
    )
  }
  data <- haven::read_dta(ctx$paths$raw_main)
  required <- c("interview__key", "interview__status", "consentement")
  missing_required <- setdiff(required, names(data))
  if (length(missing_required)) {
    stop(
      "Variables obligatoires absentes : ",
      paste(missing_required, collapse = ", "),
      call. = FALSE
    )
  }
  message("Base initialisee sans filtrage : ", nrow(data), " lignes.")
  data
}
