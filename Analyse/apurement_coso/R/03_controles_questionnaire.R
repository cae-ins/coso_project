# Orchestration des scripts R generes par section questionnaire.

controler_questionnaire <- function(state) {
  include_file <- file.path(state$ctx$paths$r_generated, "00_generated_sections.R")
  if (!file.exists(include_file)) {
    stop("Liste des scripts R generes absente : ", include_file, call. = FALSE)
  }
  source(include_file, local = environment())
  if (length(generated_section_scripts) != nrow(state$sections)) {
    stop(
      "Nombre de scripts de section inattendu : ",
      length(generated_section_scripts), " au lieu de ", nrow(state$sections), "."
    )
  }
  for (script in generated_section_scripts) {
    source(file.path(state$ctx$paths$r_generated, script), local = environment())
  }
  state
}
