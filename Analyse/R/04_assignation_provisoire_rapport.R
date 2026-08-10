#!/usr/bin/env Rscript

# COSO Nord - assignation aleatoire provisoire et rapport transmissible
# Usage: Rscript 04_assignation_provisoire_rapport.R indicateurs.dta dossier [graine]
# Cette assignation est une simulation de travail, pas le tirage officiel.

suppressPackageStartupMessages({
  library(haven)
  library(dplyr)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2L) stop("Fournir : indicateurs.dta dossier_sortie [graine].")
input_file <- normalizePath(args[[1]], mustWork = TRUE)
out_dir <- args[[2]]
seed <- if (length(args) >= 3L) as.integer(args[[3]]) else 20260810L
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

data <- haven::read_dta(input_file)
names(data) <- tolower(names(data))
needed <- c("interview__key", "cover_district")
if (length(setdiff(needed, names(data)))) stop("Variables absentes.")
if (anyDuplicated(data$interview__key)) stop("interview__key n'est pas unique.")

# Allocation exacte 1:1, stratifiee par district.
strata <- data %>% count(cover_district, name = "n") %>% arrange(cover_district)
target_total <- floor(nrow(data) / 2)
raw <- strata$n * target_total / nrow(data)
strata$take_treat <- floor(raw)
remaining <- target_total - sum(strata$take_treat)
if (remaining > 0) {
  ord <- order(raw - floor(raw), decreasing = TRUE)
  strata$take_treat[ord[seq_len(remaining)]] <- strata$take_treat[ord[seq_len(remaining)]] + 1L
}

set.seed(seed)
data$sim_id <- sprintf("COSO-SIM-%03d", seq_len(nrow(data)))
data$treat <- 0L
for (i in seq_len(nrow(strata))) {
  idx <- which(data$cover_district == strata$cover_district[[i]])
  selected <- sample(idx, size = strata$take_treat[[i]], replace = FALSE)
  data$treat[selected] <- 1L
}
data$assignment_label <- ifelse(data$treat == 1L, "Offre COSO (simulee)", "Temoin (simule)")
data$female_sim <- if ("c1" %in% names(data)) as.numeric(data$c1 == 2) else NA_real_
data$rural_sim <- if ("b5" %in% names(data)) as.numeric(data$b5 == 2) else NA_real_

candidate <- c(
  age = "age", female = "female_sim", rural = "rural_sim",
  employed = "ind_employed", self_employed = "ind_self_employed",
  hours_week = "hours_week_uncond",
  productive_status = "productive_status_index",
  resilience = "resilience_subjective", group_member = "ind_group_member",
  trust_general = "trust_general"
)
candidate <- candidate[candidate %in% names(data)]

balance_one <- function(v, label) {
  x <- suppressWarnings(as.numeric(data[[v]]))
  if (label %in% c("hours_week", "profit_proxy")) x[x >= 900] <- NA_real_
  tmean <- mean(x[data$treat == 1], na.rm = TRUE)
  cmean <- mean(x[data$treat == 0], na.rm = TRUE)
  nt <- sum(!is.na(x[data$treat == 1]))
  nc <- sum(!is.na(x[data$treat == 0]))
  p <- NA_real_
  if (nt >= 2 && nc >= 2) p <- tryCatch(t.test(x ~ data$treat)$p.value, error = function(e) NA_real_)
  pooled <- sqrt((var(x[data$treat == 1], na.rm = TRUE) + var(x[data$treat == 0], na.rm = TRUE)) / 2)
  data.frame(variable = label, n_treat = nt, n_control = nc,
             mean_treat = tmean, mean_control = cmean,
             difference = tmean - cmean,
             standardized_difference = ifelse(is.finite(pooled) && pooled > 0,
                                              (tmean - cmean) / pooled, NA_real_),
             p_value = p)
}
balance <- bind_rows(lapply(names(candidate), function(label) balance_one(candidate[[label]], label)))

district <- strata %>% transmute(cover_district, treatment = take_treat, control = n - take_treat)
assignment_internal <- data %>% select(sim_id, interview__key, cover_id, cover_district,
                                       cover_region, treat, assignment_label)
write.csv(assignment_internal, file.path(out_dir, "assignation_simulee_interne.csv"), row.names = FALSE, na = "")
write.csv(balance, file.path(out_dir, "equilibre_balance.csv"), row.names = FALSE, na = "")
write.csv(district, file.path(out_dir, "repartition_district.csv"), row.names = FALSE, na = "")
haven::write_dta(data, file.path(out_dir, "base_indicateurs_assignation_simulee.dta"), version = 15)

esc <- function(x) {
  x <- as.character(x)
  x <- gsub("\\\\", "\\\\textbackslash{}", x)
  x <- gsub("([#$%&_{}])", "\\\\\\1", x)
  x <- gsub("~", "\\\\textasciitilde{}", x, fixed = TRUE)
  x <- gsub("\\^", "\\\\textasciicircum{}", x)
  x
}
fmt <- function(x) ifelse(is.na(x), "--", formatC(x, format = "f", digits = 3))
tex <- file.path(out_dir, "Rapport_assignation_provisoire_COSO.tex")
con <- file(tex, open = "wt", encoding = "UTF-8")
writeLines(enc2utf8(c(
  "\\documentclass[11pt,a4paper]{article}",
  "\\usepackage[margin=2.3cm]{geometry}",
  "\\usepackage{fontspec}",
  "\\setmainfont{Latin Modern Roman}",
  "\\usepackage[french]{babel}",
  "\\usepackage{booktabs,longtable,xcolor,hyperref}",
  "\\hypersetup{colorlinks=true,linkcolor=blue,urlcolor=blue}",
  "\\title{Assignation aléatoire provisoire -- COSO Nord}",
  "\\author{Document de travail transmissible à l'équipe COSO}",
  "\\date{10 août 2026}",
  "\\begin{document}\\maketitle",
  "\\begin{center}\\fcolorbox{red}{red!8}{\\parbox{0.9\\textwidth}{\\textbf{ATTENTION -- SIMULATION DE TRAVAIL.} Cette assignation est générée sur les 90 fiches provisoirement exploitables. Elle ne constitue pas le tirage officiel.}}\\end{center}",
  "\\section{Objet}",
  "Ce rapport montre ce que donnerait une assignation aléatoire 1:1 sur la base questionnaire disponible. L'assignation est stratifiée par district et la graine pseudo-aléatoire est documentée pour permettre la reproduction.",
  "\\section{Base et règle}",
  paste0("Source : \\texttt{", esc(basename(input_file)), "}.\\\\"),
  "Échantillon : 90 entretiens avec \\texttt{interview\\_\\_status=100} (Completed) et consentement positif. Le code 130 (ApprovedByHeadquarters) n'est pas présent dans l'export.",
  paste0("Graine : \\texttt{", seed, "}.\\\\"),
  "Unité : entretien/jeune. Strate : district. Allocation : 45 offres COSO simulées et 45 témoins simulés.",
  "\\section{Répartition par district}",
  "\\begin{center}\\begin{tabular}{lrr}\\toprule District & Offre COSO & Témoin \\\\ \\midrule",
  paste(apply(district, 1, function(z) paste(esc(z[[1]]), z[[2]], z[[3]], sep = " & ")), collapse = " \\\\ "),
  " \\\\ \\bottomrule\\end{tabular}\\end{center}",
  "\\section{Équilibre observé}",
  "Ces différences sont des diagnostics de balance et non des effets du programme. Avec 90 observations, des écarts accidentels sont normaux.",
  "{\\small\\begin{longtable}{lrrrrr}\\toprule Variable & N COSO & N témoin & Moy. COSO & Moy. témoin & Diff. \\\\ \\midrule",
  paste(apply(balance, 1, function(z) paste(esc(z[[1]]), z[[2]], z[[3]], fmt(as.numeric(z[[4]])), fmt(as.numeric(z[[5]])), fmt(as.numeric(z[[6]])), sep = " & ")), collapse = " \\\\ "),
  " \\\\ \\bottomrule\\end{longtable}}",
  "\\section{Interprétation et limites}",
  "La simulation montre que la randomisation peut être mise en œuvre techniquement sur la base préparée, avec une allocation équilibrée globalement et par district. Elle ne permet pas encore d'estimer un ITT réel : l'assignation n'est pas officielle, la baseline complète n'est pas documentée et les fichiers d'assignation/SIG ne sont pas joints.",
  "Le fichier interne contient les clés techniques nécessaires au rapprochement, mais ce PDF ne contient ni nom ni téléphone. Avant toute notification, il faut valider l'unité de randomisation, les strates, le ratio, la liste finale éligible et la procédure officielle de tirage.",
  "\\section{Fichiers produits}",
  "\\begin{itemize}",
  "\\item \\texttt{assignation\\_simulee\\_interne.csv} : correspondance technique entre identifiant et bras simulé ;",
  "\\item \\texttt{equilibre\\_balance.csv} : diagnostics numériques ;",
  "\\item \\texttt{repartition\\_district.csv} : quotas réalisés ;",
  "\\item \\texttt{Rapport\\_assignation\\_provisoire\\_COSO.pdf} : présent rapport.",
  "\\end{itemize}",
  "\\end{document}"
)), con)
close(con)
cat("Assignation produite : N=", nrow(data), ", COSO=", sum(data$treat == 1),
    ", temoin=", sum(data$treat == 0), ", graine=", seed, "\\n", sep = "")
