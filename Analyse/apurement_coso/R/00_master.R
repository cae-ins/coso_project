#!/usr/bin/env Rscript

# Orchestrateur du moteur R d'apurement COSO.

args <- commandArgs(trailingOnly = TRUE)
project_root <- if (length(args)) args[[1]] else Sys.getenv(
  "COSO_APUREMENT_ROOT",
  unset = getwd()
)
project_root <- normalizePath(project_root, winslash = "/", mustWork = TRUE)

source(file.path(project_root, "R", "00_config.R"))
source(file.path(project_root, "R", "lib_apurement.R"))
require_apurement_packages()

ctx <- create_apurement_context(project_root)
log_file <- file.path(
  ctx$paths$logs,
  paste0("apurement_r_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".log")
)
log_connection <- file(log_file, open = "wt", encoding = "UTF-8")
sink(log_connection, split = TRUE)
sink(log_connection, type = "message")
on.exit({
  sink(type = "message")
  sink()
  close(log_connection)
}, add = TRUE)

message("Debut du pipeline R d'apurement COSO.")
message("Racine : ", ctx$paths$root)

module_files <- c(
  "01_initialiser_base.R", "02_controles_systeme.R",
  "03_controles_questionnaire.R", "50_controles_metier_proposes.R",
  "60_corrections_validees.R", "90_contrat_sortie.R", "99_finaliser.R"
)
for (module in module_files) source(file.path(ctx$paths$r_root, module))

matrix <- read_utf8_csv(ctx$paths$rule_matrix)
sections <- read_utf8_csv(file.path(ctx$paths$generated, "sections_questionnaire.csv"))
sections$section_order <- as.integer(sections$section_order)
prepare_generated_outputs(ctx, sections)

data <- initialiser_base(ctx)
system_result <- controler_systeme(data, ctx)
state <- new.env(parent = emptyenv())
state$ctx <- ctx
state$data <- system_result$data
state$matrix <- matrix
state$sections <- sections
state$manifest <- system_result$manifest
state$correction_count <- 0L

state <- controler_questionnaire(state)
state$manifest <- append_rows(
  state$manifest,
  controler_metier_propose(state$data, state$matrix, state$ctx)
)
correction_result <- appliquer_corrections_validees(state$data, state$ctx)
state$data <- correction_result$data
state$correction_count <- correction_result$correction_count

verifier_contrat_sortie(state$data, state)
finaliser_apurement(state$data, state)
message("Pipeline R termine sans correction automatique.")
