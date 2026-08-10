#!/usr/bin/env Rscript

# COSO Nord - Estimation ITT par ANCOVA (v2, 2 juillet 2026)
# References : Suivi_Evaluation/Cadre_Indicateurs_Effets.md (v2)
#              Suivi_Evaluation/Cadre_Estimands_Impact_COSO.md
#
# Y_el = alpha + beta*treat + gamma*Y_bl + strates + eps   (HC1)
#
# v2 :
#  - liste d'outcomes alignee sur la matrice (2 PRIMAIRES + familles)
#  - winsorisation p1/p99 des montants par vague et par bras + IHS
#  - indices d'Anderson (cohesion, statut, resilience) standardises
#    sur le bras temoin de chaque vague
#  - colonnes famille/role dans la sortie ; attrition par outcome conservee
#
# Usage :
#   Rscript Analyse/R/02_estimer_effets_itt.R \
#     chemin/panel_large.dta chemin/resultats_itt.csv [chemin/panel_analytique.csv]
#
# Le 3e argument (optionnel) exporte le panel augmente des variables
# transformees (_w, _ihs) et des indices d'Anderson (idx_*) — requis par
# le script 03 (balance, attrition/Lee, CATE, inference par randomisation).

suppressPackageStartupMessages({
  library(haven)
  library(sandwich)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2L) {
  stop("Fournir le panel large et le fichier CSV de resultats.")
}
panel_file <- args[[1]]
output_file <- args[[2]]

read_data <- function(path) {
  ext <- tolower(tools::file_ext(path))
  switch(
    ext,
    dta = haven::read_dta(path),
    rds = readRDS(path),
    csv = read.csv(path, check.names = FALSE),
    stop("Format d'entree non pris en charge : ", ext)
  )
}

robust_term <- function(fit, term) {
  vc <- sandwich::vcovHC(fit, type = "HC1")
  beta <- unname(stats::coef(fit)[term])
  se <- sqrt(unname(diag(vc)[term]))
  df <- stats::df.residual(fit)
  p <- 2 * stats::pt(abs(beta / se), df = df, lower.tail = FALSE)
  crit <- stats::qt(0.975, df = df)
  c(beta = beta, se = se, pvalue = p,
    ci_low = beta - crit * se, ci_high = beta + crit * se)
}

# Winsorisation p1/p99 au sein de chaque bras (appliquee vague par vague,
# les colonnes _bl et _el etant traitees separement) -- Cadre v2, decision 8
winsorize_by_arm <- function(x, arm, probs = c(0.01, 0.99)) {
  out <- x
  for (a in stats::na.omit(unique(arm))) {
    idx <- which(arm == a & !is.na(x))
    if (length(idx) >= 20L) {
      q <- stats::quantile(x[idx], probs = probs, na.rm = TRUE, type = 2)
      out[idx] <- pmin(pmax(x[idx], q[[1]]), q[[2]])
    }
  }
  out
}

ihs <- function(x) asinh(x)

# Indice d'Anderson (2008) : ponderation par covariance inverse ;
# z-scores standardises sur le bras temoin de la vague ; un indice est
# calcule si >= 50 % des composants sont observes (Cadre v2, decision 6)
anderson_index <- function(data, vars, control) {
  x <- as.matrix(data[vars])
  mu <- colMeans(x[control, , drop = FALSE], na.rm = TRUE)
  sd_ <- apply(x[control, , drop = FALSE], 2, stats::sd, na.rm = TRUE)
  sd_[!is.finite(sd_) | sd_ == 0] <- 1
  z <- sweep(sweep(x, 2, mu, "-"), 2, sd_, "/")
  cc <- stats::complete.cases(z[control, , drop = FALSE])
  if (sum(cc) < length(vars) + 2L) {
    w <- rep(1 / length(vars), length(vars))          # secours : poids egaux
  } else {
    sigma <- stats::cov(z[control, , drop = FALSE][cc, , drop = FALSE])
    inv <- tryCatch(solve(sigma), error = function(e) NULL)
    if (is.null(inv)) {
      w <- rep(1 / length(vars), length(vars))
    } else {
      w <- rowSums(inv) / sum(inv)
    }
  }
  n_obs <- rowSums(!is.na(z))
  idx <- sapply(seq_len(nrow(z)), function(i) {
    obs <- !is.na(z[i, ])
    if (sum(obs) < ceiling(length(vars) / 2)) return(NA_real_)
    sum(z[i, obs] * w[obs]) / sum(w[obs])
  })
  idx
}

data <- read_data(panel_file)
names(data) <- tolower(names(data))

if (!"treat" %in% names(data)) stop("Variable requise absente : treat")
if (!all(stats::na.omit(unique(data$treat)) %in% c(0, 1))) {
  stop("treat doit etre codee 0/1.")
}
control <- data$treat == 0 & !is.na(data$treat)
has_strata <- "lottery_stratum" %in% names(data)

# --------------------------------------------------------------------------
# Transformations : winsorisation par bras + IHS des montants (par vague)
# --------------------------------------------------------------------------
monetary_stems <- c(
  "profit_normal_uncond", "salary_monthly_uncond",
  "main_labor_income_month", "savings_month_amount", "jobs_created_uncond",
  "volunteer_count_30d", "hours_week_uncond"
)
for (stem in monetary_stems) {
  for (wave in c("bl", "el")) {
    v <- paste0(stem, "_", wave)
    if (v %in% names(data)) {
      wv <- paste0(stem, "_w_", wave)
      data[[wv]] <- winsorize_by_arm(data[[v]], data$treat)
      if (stem %in% c("profit_normal_uncond", "salary_monthly_uncond",
                      "main_labor_income_month", "savings_month_amount")) {
        data[[paste0(stem, "_ihs_", wave)]] <- ihs(data[[wv]])
      }
    }
  }
}

# --------------------------------------------------------------------------
# Indices d'Anderson par vague (composants issus du script 01)
# --------------------------------------------------------------------------
index_specs <- list(
  idx_cohesion = c("ind_group_member", "volunteer_count_30d", "trust_general",
                   "trust_intergroup", "trust_institutional"),
  idx_statut = c("ind_no_external_aid", "productive_m1", "productive_m3",
                 "productive_m4"),
  idx_resilience = c("ind_emergency_easy", "resilience_subjective",
                     "ind_saves", "ind_diversified")
)
for (idx_name in names(index_specs)) {
  for (wave in c("bl", "el")) {
    comps <- paste0(index_specs[[idx_name]], "_", wave)
    present <- comps[comps %in% names(data)]
    if (length(present) >= 2L) {
      data[[paste0(idx_name, "_", wave)]] <-
        anderson_index(data, present, control)
    }
  }
}

# Export optionnel du panel analytique (transformations + indices) pour le 03
if (length(args) >= 3L) {
  write.csv(data, args[[3]], row.names = FALSE, na = "")
  message("Panel analytique exporte : ", args[[3]])
}

# --------------------------------------------------------------------------
# Outcomes : (stem, famille, role)
# --------------------------------------------------------------------------
outcome_specs <- rbind(
  # PRIMAIRES
  c("profit_normal_uncond_ihs", "C.2 Revenus", "PRIMAIRE"),
  c("idx_cohesion", "D Cohesion", "PRIMAIRE"),
  # C.1 Insertion
  c("ind_employed", "C.1 Insertion", "secondaire"),
  c("ind_self_employed", "C.1 Insertion", "secondaire"),
  c("ind_unemployed", "C.1 Insertion", "secondaire"),
  c("ind_underemployment", "C.1 Insertion", "secondaire"),
  c("ind_mop", "C.1 Insertion", "secondaire"),
  c("hours_week_uncond_w", "C.1 Insertion", "secondaire"),
  c("ind_activity_12m", "C.1 Insertion", "secondaire"),
  # C.2 Revenus
  c("profit_normal_uncond_w", "C.2 Revenus", "robustesse (FCFA)"),
  c("main_labor_income_month_ihs", "C.2 Revenus", "secondaire"),
  c("ind_saves", "C.2 Revenus", "secondaire"),
  c("savings_month_amount_ihs", "C.2 Revenus", "secondaire"),
  c("ind_financial_inclusion", "C.2 Revenus", "secondaire"),
  c("ind_productive_credit", "C.2 Revenus", "secondaire"),
  # C.3 Entrepreneuriat
  c("ind_ever_created", "C.3 Entrepreneuriat", "secondaire"),
  c("ind_employer", "C.3 Entrepreneuriat", "secondaire"),
  c("jobs_created_uncond_w", "C.3 Entrepreneuriat", "secondaire"),
  c("mgmt_skills_score", "C.3 Entrepreneuriat", "mecanisme"),
  c("ind_entrep_training", "C.3 Entrepreneuriat", "1er stade (enquete)"),
  c("ind_training_12m", "C.3 Entrepreneuriat", "1er stade (enquete)"),
  # C.4 Statut
  c("ind_no_external_aid", "C.4 Statut", "ancre factuelle"),
  c("idx_statut", "C.4 Statut", "secondaire (desirabilite !)"),
  # C.5 Resilience
  c("ind_emergency_easy", "C.5 Resilience", "secondaire"),
  c("resilience_subjective", "C.5 Resilience", "secondaire"),
  c("idx_resilience", "C.5 Resilience", "indice-resume"),
  # D Cohesion (composants)
  c("ind_group_member", "D Cohesion", "composant"),
  c("volunteer_count_30d_w", "D Cohesion", "composant"),
  c("trust_general", "D Cohesion", "composant"),
  c("trust_intergroup", "D Cohesion", "composant"),
  c("trust_institutional", "D Cohesion", "composant")
)
colnames(outcome_specs) <- c("outcome", "family", "role")
outcome_specs <- as.data.frame(outcome_specs, stringsAsFactors = FALSE)

# --------------------------------------------------------------------------
# Boucle d'estimation
# --------------------------------------------------------------------------
results <- list()
for (k in seq_len(nrow(outcome_specs))) {
  outcome <- outcome_specs$outcome[k]
  y_el <- paste0(outcome, "_el")
  y_bl <- paste0(outcome, "_bl")

  if (!y_el %in% names(data)) {
    warning("Outcome absent, ignore : ", y_el)
    next
  }

  rhs <- "treat"
  has_baseline <- y_bl %in% names(data)
  if (has_baseline) rhs <- paste(rhs, y_bl, sep = " + ")
  if (has_strata) rhs <- paste(rhs, "factor(lottery_stratum)", sep = " + ")

  fit <- stats::lm(stats::as.formula(paste(y_el, "~", rhs)),
                   data = data, na.action = stats::na.omit)
  itt <- robust_term(fit, "treat")

  used_rows <- as.integer(rownames(stats::model.frame(fit)))
  control_mean <- mean(
    data[[y_el]][used_rows][data$treat[used_rows] == 0],
    na.rm = TRUE
  )
  control_sd <- stats::sd(
    data[[y_el]][used_rows][data$treat[used_rows] == 0],
    na.rm = TRUE
  )

  observed_el <- as.integer(!is.na(data[[y_el]]))
  attr_rhs <- if (has_strata) "treat + factor(lottery_stratum)" else "treat"
  attr_fit <- stats::lm(stats::as.formula(paste("observed_el ~", attr_rhs)),
                        data = data, na.action = stats::na.omit)
  attr <- robust_term(attr_fit, "treat")

  results[[outcome]] <- data.frame(
    outcome = outcome,
    family = outcome_specs$family[k],
    role = outcome_specs$role[k],
    has_baseline = has_baseline,
    n = stats::nobs(fit),
    control_mean = control_mean,
    beta = itt[["beta"]],
    se = itt[["se"]],
    pvalue = itt[["pvalue"]],
    ci_low = itt[["ci_low"]],
    ci_high = itt[["ci_high"]],
    effect_sd = if (!is.na(control_sd) && control_sd > 0) {
      itt[["beta"]] / control_sd
    } else NA_real_,
    obs_control = mean(observed_el[data$treat == 0], na.rm = TRUE),
    obs_treatment = mean(observed_el[data$treat == 1], na.rm = TRUE),
    attrition_diff = attr[["beta"]],
    attrition_se = attr[["se"]],
    attrition_p = attr[["pvalue"]]
  )
}

if (length(results) == 0L) stop("Aucun outcome endline disponible.")

results <- do.call(rbind, results)
rownames(results) <- NULL

# Rappels de discipline statistique (Cadre v2, decision 7)
message("RAPPEL : seuls les 2 PRIMAIRES s'interpretent sans correction ; ")
message("appliquer Romano-Wolf au sein de chaque famille pour les secondaires")
message("(voir Analyse/estimands/ pour l'implementation sur donnees simulees).")

n_primary <- sum(results$role == "PRIMAIRE")
if (n_primary != 2L) {
  warning("Nombre de primaires estime : ", n_primary,
          " (attendu : 2 -- profit MMW et indice de cohesion).")
}
if (any(results$attrition_p < 0.05, na.rm = TRUE)) {
  warning("Attrition differentielle significative detectee sur au moins un ",
          "outcome : prevoir les bornes de Lee sur les primaires.")
}

write.csv(results, output_file, row.names = FALSE, na = "")
message("Resultats ITT enregistres : ", output_file)
