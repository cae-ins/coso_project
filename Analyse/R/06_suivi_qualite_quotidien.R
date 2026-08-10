#!/usr/bin/env Rscript

# COSO Nord - suivi quotidien de qualite des donnees
# Usage: Rscript 06_suivi_qualite_quotidien.R export.zip dossier_sortie
# Le script ne corrige jamais la base d'entree.

suppressPackageStartupMessages(library(haven))
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2L) stop("Fournir : export (.zip/.dta) dossier_sortie")
input_file <- normalizePath(args[[1]], mustWork = TRUE)
root_output <- args[[2]]
run_id <- format(Sys.time(), "%Y%m%d_%H%M%S")
run_dir <- file.path(root_output, run_id)
dir.create(run_dir, recursive = TRUE, showWarnings = FALSE)

script_dir <- file.path(getwd(), "Analyse", "R")
rscript <- file.path(R.home("bin"), "Rscript.exe")
if (!file.exists(rscript)) rscript <- "Rscript"
prep_script <- file.path(script_dir, "00_preparer_export_v51.R")
audit_script <- file.path(script_dir, "05_audit_qualite_coso.R")
prepared <- file.path(run_dir, "base_analytique_preparee.dta")
prep_reports <- file.path(run_dir, "preparation")
dir.create(prep_reports, recursive = TRUE, showWarnings = FALSE)

if (tolower(tools::file_ext(input_file)) == "zip") {
  rc <- system2(rscript, c("--vanilla", shQuote(prep_script), shQuote(input_file), shQuote(prepared), shQuote(prep_reports)))
  if (!identical(rc, 0L)) stop("Echec de la preparation de l'export")
} else file.copy(input_file, prepared, overwrite = TRUE)

audit_dir <- file.path(run_dir, "audit")
rc <- system2(rscript, c("--vanilla", shQuote(audit_script), shQuote(prepared), shQuote(audit_dir)))
if (!identical(rc, 0L)) stop("Echec de l'audit de qualite")

data <- haven::read_dta(prepared)
names(data) <- tolower(names(data))
n <- nrow(data)
read_csv_safe <- function(path) if (file.exists(path)) read.csv(path, check.names = FALSE, stringsAsFactors = FALSE) else data.frame()
rules <- read_csv_safe(file.path(audit_dir, "quality_rules_summary.csv"))
cases <- read_csv_safe(file.path(audit_dir, "quality_cases_for_review.csv"))
num <- function(name) if (name %in% names(data)) suppressWarnings(as.numeric(data[[name]])) else rep(NA_real_, n)

eligible <- rep(TRUE, n)
if ("interview__status" %in% names(data)) eligible <- eligible & num("interview__status") == 100
if ("consentement" %in% names(data)) eligible <- eligible & num("consentement") == 1

core_vars <- intersect(c("age", "d1", "d2", "d3", "e1", "e2", "e3", "e3a",
  "f1", "f4", "g3", "g5", "g6", "g7", "h2", "h3", "h4", "h4a", "h5",
  "i1", "j1", "m1", "m2", "m3", "m4", "n1", "n6", "n7", paste0("q", 1:10)), names(data))

variable_dashboard <- data.frame(
  variable = core_vars,
  n_tested = sum(eligible),
  n_missing = vapply(data[core_vars], function(x) sum(is.na(x[eligible])), integer(1)),
  n_observed = vapply(data[core_vars], function(x) sum(!is.na(x[eligible])), integer(1)),
  n_unique_observed = vapply(data[core_vars], function(x) length(unique(x[eligible & !is.na(x)])), integer(1)),
  stringsAsFactors = FALSE
)
variable_dashboard$pct_missing <- round(100 * variable_dashboard$n_missing / pmax(1, variable_dashboard$n_tested), 1)
conditional_vars <- c("e2", "e3", "e3a", "g6", "h2", "h3", "h4", "h4a", "h5", "j1")
variable_dashboard$missingness_reading <- ifelse(
  variable_dashboard$variable %in% conditional_vars,
  "A lire dans l'univers de la question; ne pas traiter comme omission automatique",
  "A examiner comme couverture de collecte"
)
variable_dashboard$n_flagged <- 0L
if (nrow(cases) && "variable" %in% names(cases)) {
  flagged <- aggregate(rep(1L, nrow(cases)), list(variable = cases$variable), sum)
  variable_dashboard$n_flagged <- flagged$x[match(variable_dashboard$variable, flagged$variable)]
  variable_dashboard$n_flagged[is.na(variable_dashboard$n_flagged)] <- 0L
}
module_of <- function(v) {
  x <- substr(tolower(v), 1, 1)
  labels <- c(a="identification", b="eligibilite", c="demographie", d="actifs",
    e="emploi", f="activite", g="heures", h="revenus", i="recherche", j="chomage",
    k="entrepreneuriat", l="finance", m="statut_percu", n="resilience", o="formation",
    p="exposition", q="cohesion", r="suivi")
  unname(labels[x])
}
variable_dashboard$module <- vapply(variable_dashboard$variable, module_of, character(1))
module_dashboard <- aggregate(cbind(n_tested, n_missing, n_observed, n_flagged) ~ module, variable_dashboard, sum)
module_dashboard$pct_missing <- round(100 * module_dashboard$n_missing / pmax(1, module_dashboard$n_tested), 1)

agent <- if ("nom_agent" %in% names(data)) as.character(data$nom_agent) else rep("Agent non disponible", n)
agent[is.na(agent) | !nzchar(trimws(agent))] <- "Agent non renseigne"
missing_core <- if (length(core_vars)) rowSums(is.na(data[core_vars])) else rep(0L, n)
agent_df <- data.frame(agent = agent, eligible = eligible, missing_core = missing_core,
  interview_key = if ("interview__key" %in% names(data)) as.character(data$interview__key) else as.character(seq_len(n)))
agent_summary <- aggregate(cbind(eligible, missing_core) ~ agent, agent_df, sum)
names(agent_summary)[names(agent_summary) == "eligible"] <- "n_completed"
agent_summary$pct_missing_core <- round(100 * agent_summary$missing_core / pmax(1, agent_summary$n_completed * length(core_vars)), 1)
agent_summary$n_flagged_cases <- 0L
if (nrow(cases) && "interview__key" %in% names(cases)) {
  case_agent <- merge(unique(cases["interview__key"]), agent_df[c("interview_key", "agent")], by.x = "interview__key", by.y = "interview_key")
  counts <- aggregate(rep(1L, nrow(case_agent)), list(agent = case_agent$agent), sum)
  agent_summary$n_flagged_cases <- counts$x[match(agent_summary$agent, counts$agent)]
  agent_summary$n_flagged_cases[is.na(agent_summary$n_flagged_cases)] <- 0L
}
agent_summary$flagged_rate <- round(100 * agent_summary$n_flagged_cases / pmax(1, agent_summary$n_completed), 1)
agent_summary$action <- "Aucune alerte automatique"
agent_summary$action[agent_summary$pct_missing_core >= 20 | agent_summary$flagged_rate >= 25] <- "Recadrage prioritaire + revue des fiches"
agent_summary$action[agent_summary$action == "Aucune alerte automatique" & (agent_summary$pct_missing_core >= 10 | agent_summary$flagged_rate >= 10)] <- "Retour cible et controle renforce"

write.csv(variable_dashboard, file.path(run_dir, "dashboard_variables.csv"), row.names = FALSE, na = "")
write.csv(module_dashboard, file.path(run_dir, "dashboard_modules.csv"), row.names = FALSE, na = "")
write.csv(agent_summary, file.path(run_dir, "dashboard_agents.csv"), row.names = FALSE, na = "")

esc <- function(x) { x <- gsub("&", "&amp;", as.character(x), fixed = TRUE); x <- gsub("<", "&lt;", x, fixed = TRUE); gsub(">", "&gt;", x, fixed = TRUE) }
html_table <- function(df, max_rows = 50L) {
  if (!nrow(df)) return("<p>Aucune ligne.</p>")
  df <- head(df, max_rows)
  rows <- apply(df, 1, function(z) paste0("<tr>", paste0("<td>", esc(z), "</td>", collapse = ""), "</tr>"))
  paste0("<table><thead><tr>", paste0("<th>", esc(names(df)), "</th>", collapse = ""), "</tr></thead><tbody>", paste(rows, collapse = ""), "</tbody></table>")
}
html <- c("<!doctype html><html lang='fr'><head><meta charset='utf-8'><title>Dashboard qualite COSO</title>",
  "<style>body{font-family:Arial;margin:2rem;color:#1f2937}h1{color:#123b5d}h2{color:#245b7a;margin-top:2rem}table{border-collapse:collapse;width:100%;font-size:12px}th,td{border:1px solid #d1d5db;padding:5px;text-align:left}th{background:#e5eef2}tr:nth-child(even){background:#f8fafc}.alert{background:#fff4e5;border-left:5px solid #d97706;padding:1rem}</style></head><body>",
  paste0("<h1>Dashboard quotidien — qualité COSO</h1><p><b>Source :</b> ", esc(basename(input_file)), "<br><b>Run :</b> ", run_id, "</p>"),
  paste0("<div class='alert'><b>", nrow(cases), " cas à revoir.</b> Les signaux ne sont pas des corrections validées.</div>"),
  "<h2>Agents</h2>", html_table(agent_summary), "<h2>Variables</h2>", html_table(variable_dashboard), "<h2>Modules</h2>", html_table(module_dashboard), "<h2>Regles</h2>", html_table(rules), "</body></html>")
writeLines(html, file.path(run_dir, "dashboard_qualite.html"), useBytes = TRUE)

# Version publiable : aucun tableau par agent, aucune règle contenant des clés
# techniques, aucun cas individuel. GitHub Pages étant public, cette séparation
# est volontaire même lorsque l'identifiant agent est pseudonymisé.
public_html <- c("<!doctype html><html lang='fr'><head><meta charset='utf-8'><title>Dashboard qualite COSO</title>",
  "<style>body{font-family:Arial;margin:2rem;color:#1f2937}h1{color:#123b5d}h2{color:#245b7a;margin-top:2rem}table{border-collapse:collapse;width:100%;font-size:12px}th,td{border:1px solid #d1d5db;padding:5px;text-align:left}th{background:#e5eef2}tr:nth-child(even){background:#f8fafc}.alert{background:#fff4e5;border-left:5px solid #d97706;padding:1rem}.note{background:#eef6ff;border-left:5px solid #2563eb;padding:1rem}</style></head><body>",
  paste0("<h1>Dashboard public — qualité COSO</h1><p><b>Mise à jour :</b> ", run_id, "</p>"),
  paste0("<div class='alert'><b>", nrow(cases), " cas à revoir en interne.</b> Les signaux ne sont pas des corrections validées.</div>"),
  "<div class='note'>Cette version publique ne contient ni identifiant d'entretien, ni nom, ni téléphone, ni tableau de performance individuelle des agents.</div>",
  "<h2>Variables</h2>", html_table(variable_dashboard),
  "<h2>Modules</h2>", html_table(module_dashboard),
  "</body></html>")
writeLines(public_html, file.path(run_dir, "dashboard_public.html"), useBytes = TRUE)

top_agents <- agent_summary[agent_summary$action != "Aucune alerte automatique", ]
top_vars <- variable_dashboard[variable_dashboard$pct_missing > 0 | variable_dashboard$n_flagged > 0, ]
md <- c("---", "title: 'Suivi quotidien de la qualité des données COSO'", "lang: fr-FR", "geometry: margin=1.8cm", "---", "",
  paste0("**Source :** `", basename(input_file), "`  "), paste0("**Run :** ", run_id, "  "), "**Principe :** aucun recodage automatique.", "",
  "## Synthèse décisionnelle", "", paste0("L'export contient **", n, " fiches** et **", sum(eligible), " fiches éligibles**. **", nrow(cases), " cas** sont à revoir sur **", nrow(rules), " règles** exécutées."), "",
  "Les seuils de priorisation sont transparents : recadrage prioritaire à partir de 20 % de variables cœur manquantes en moyenne ou 25 % de fiches signalées ; retour ciblé à partir de 10 %.", "",
  "## Agents à traiter", "", if (nrow(top_agents)) paste0("- **", top_agents$agent, "** : ", top_agents$action, " — ", top_agents$flagged_rate, "% de fiches signalées, ", top_agents$pct_missing_core, "% de valeurs cœur manquantes.") else "Aucun agent ne franchit les seuils automatiques.", "",
  "## Variables à renforcer", "", if (nrow(top_vars)) paste0("- **", top_vars$variable, "** : ", top_vars$pct_missing, "% manquants ; ", top_vars$n_flagged, " cas signalés. ", top_vars$missingness_reading) else "Aucun signal sur les variables cœur.", "",
  "## Livrables détaillés", "", "- `dashboard_variables.csv` ;", "- `dashboard_modules.csv` ;", "- `dashboard_agents.csv` ;", "- `audit/quality_cases_for_review.csv` ;", "- `dashboard_qualite.html`.", "",
  "Les décisions de revue doivent être enregistrées dans une table séparée : conserver, corriger la source, recoder, mettre en manquant, exclure ou laisser non résolu.")
writeLines(md, file.path(run_dir, "rapport_qualite_quotidien.md"), useBytes = TRUE)
writeLines(c(paste0("input=", input_file), paste0("run_dir=", normalizePath(run_dir, mustWork = FALSE)), paste0("n_rows=", n), paste0("n_eligible=", sum(eligible)), paste0("n_cases=", nrow(cases)), "correction_applied=FALSE"), file.path(run_dir, "run_metadata.txt"))
cat("Run qualite COSO termine\nRun directory :", normalizePath(run_dir, mustWork = FALSE), "\n")
