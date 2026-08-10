#!/usr/bin/env Rscript

# COSO Nord - Analyses standard d'evaluation d'impact (v1, 2 juillet 2026)
# Complement du 02 (ITT ANCOVA) : diagnostics et analyses recommandes par
# J-PAL (https://www.povertyactionlab.org/resource/data-analysis) :
#   1. Table de balance baseline T vs C + test omnibus (F joint)
#   2. Attrition : differentielle, selective, bornes de Lee sur les primaires
#   3. Tests multiples : Benjamini-Hochberg + sharpened q-values (Anderson
#      2008) au sein des familles, sur les p-values du script 02
#   4. Heterogeneite (CATE) : interactions treat x sous-groupe prespecifie
#   5. Inference par randomisation : p-value exacte (null aigu) pour les
#      2 primaires, permutation de l'assignation au sein des strates
#
# Usage :
#   Rscript Analyse/R/03_analyses_eval_impact.R \
#     chemin/panel_large.csv chemin/resultats_itt.csv chemin/dossier_sorties
#
# Sorties : balance.csv, attrition.csv, lee_bounds.csv, qvalues.csv,
#           cate.csv, randomization_inference.csv

suppressPackageStartupMessages({
  library(haven)
  library(sandwich)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3L) {
  stop("Fournir : panel_large, resultats_itt.csv (du 02), dossier de sorties.")
}
panel_file <- args[[1]]
itt_file <- args[[2]]
out_dir <- args[[3]]
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

read_data <- function(path) {
  ext <- tolower(tools::file_ext(path))
  switch(
    ext,
    dta = haven::read_dta(path),
    rds = readRDS(path),
    csv = read.csv(path, check.names = FALSE),
    stop("Format non pris en charge : ", ext)
  )
}

robust_term <- function(fit, term) {
  vc <- sandwich::vcovHC(fit, type = "HC1")
  beta <- unname(stats::coef(fit)[term])
  se <- sqrt(unname(diag(vc)[term]))
  df <- stats::df.residual(fit)
  p <- 2 * stats::pt(abs(beta / se), df = df, lower.tail = FALSE)
  c(beta = beta, se = se, pvalue = p)
}

data <- read_data(panel_file)
names(data) <- tolower(names(data))
stopifnot("treat" %in% names(data))
has_strata <- "lottery_stratum" %in% names(data)
strata_term <- if (has_strata) " + factor(lottery_stratum)" else ""

itt <- read.csv(itt_file)

# ===========================================================================
# 1. TABLE DE BALANCE BASELINE (J-PAL : tests individuels + omnibus)
# ===========================================================================
balance_candidates <- c(
  "c1", "c2", "c4",                                  # sociodemo si presentes
  "ind_employed", "ind_self_employed", "hours_week_uncond",
  "profit_proxy_h5", "salary_monthly_uncond",
  "ind_saves", "ind_financial_inclusion", "ind_has_debt",
  "ind_group_member", "trust_general", "trust_intergroup",
  "trust_institutional", "volunteer_count_30d",
  "ind_no_external_aid", "ind_emergency_easy", "resilience_subjective",
  "shock_exposed", "ind_training_12m", "ind_ever_created"
)
balance_vars <- paste0(balance_candidates, "_bl")
balance_vars <- balance_vars[balance_vars %in% names(data)]
balance_vars <- balance_vars[sapply(balance_vars, function(v) {
  x <- data[[v]]
  is.numeric(x) && sum(!is.na(x)) > 50 && stats::var(x, na.rm = TRUE) > 0
})]

bal <- lapply(balance_vars, function(v) {
  fit <- stats::lm(stats::as.formula(paste0(v, " ~ treat", strata_term)),
                   data = data, na.action = stats::na.omit)
  rt <- robust_term(fit, "treat")
  m_c <- mean(data[[v]][data$treat == 0], na.rm = TRUE)
  m_t <- mean(data[[v]][data$treat == 1], na.rm = TRUE)
  sd_pool <- sqrt((stats::var(data[[v]][data$treat == 0], na.rm = TRUE) +
                   stats::var(data[[v]][data$treat == 1], na.rm = TRUE)) / 2)
  data.frame(
    variable = v, n = sum(!is.na(data[[v]])),
    mean_control = m_c, mean_treatment = m_t,
    diff_adj = rt[["beta"]], se = rt[["se"]], pvalue = rt[["pvalue"]],
    norm_diff = if (is.finite(sd_pool) && sd_pool > 0) {
      (m_t - m_c) / sd_pool
    } else NA_real_
  )
})
bal <- do.call(rbind, bal)

# Test omnibus (J-PAL) : regresser l'assignation sur toutes les covariables
cc <- stats::complete.cases(data[balance_vars])
omni_fit <- stats::lm(
  stats::as.formula(paste("treat ~", paste(balance_vars, collapse = " + "))),
  data = data[cc, ]
)
omni_null <- stats::lm(treat ~ 1, data = data[cc, ])
omni <- stats::anova(omni_null, omni_fit)
bal_omnibus <- data.frame(
  variable = "OMNIBUS (F joint, treat ~ toutes covariables)",
  n = sum(cc), mean_control = NA, mean_treatment = NA,
  diff_adj = omni$F[2], se = NA, pvalue = omni$`Pr(>F)`[2], norm_diff = NA
)
bal <- rbind(bal, bal_omnibus)
write.csv(bal, file.path(out_dir, "balance.csv"), row.names = FALSE, na = "")
n_unbal <- sum(bal$pvalue < 0.05, na.rm = TRUE)
message(sprintf("Balance : %d variables, %d avec p<0,05 (~5%% attendu par hasard) ; omnibus p=%.3f",
                length(balance_vars), n_unbal, bal_omnibus$pvalue))

# ===========================================================================
# 2. ATTRITION : differentielle, selective, bornes de Lee (J-PAL / Lee 2009)
# ===========================================================================
primary_outcomes <- itt$outcome[itt$role == "PRIMAIRE"]
# Ne garder que les primaires reellement presents dans le panel (le panel
# analytique du 02, 3e argument de ce dernier, les contient tous)
primary_outcomes <- primary_outcomes[
  paste0(primary_outcomes, "_el") %in% names(data)
]
if (length(primary_outcomes) == 0) {
  stop("Aucun outcome primaire dans le panel : utiliser le panel analytique ",
       "exporte par le 02 (3e argument), pas le panel brut du 01.")
}
ref_outcome <- primary_outcomes[1]
obs_var <- paste0(ref_outcome, "_el")
data$observed_el <- as.integer(!is.na(data[[obs_var]]))

# 2a. Attrition differentielle
fit_diff <- stats::lm(stats::as.formula(paste0("observed_el ~ treat", strata_term)),
                      data = data)
rd <- robust_term(fit_diff, "treat")

# 2b. Attrition selective : les caracteristiques baseline des attrites
# different-elles PAR BRAS ? (interaction covariable x treat sur observed)
sel <- lapply(balance_vars, function(v) {
  f <- stats::as.formula(paste0("observed_el ~ treat*", v, strata_term))
  fit <- tryCatch(stats::lm(f, data = data), error = function(e) NULL)
  if (is.null(fit)) return(NULL)
  term <- paste0("treat:", v)
  if (!term %in% names(stats::coef(fit))) return(NULL)
  rt <- robust_term(fit, term)
  data.frame(variable = v, interaction_beta = rt[["beta"]],
             se = rt[["se"]], pvalue = rt[["pvalue"]])
})
sel <- do.call(rbind, sel)
attrition <- data.frame(
  stat = c("taux_observation_temoin", "taux_observation_traite",
           "attrition_differentielle_beta", "attrition_differentielle_p",
           "nb_interactions_selectives_p05"),
  value = c(mean(data$observed_el[data$treat == 0], na.rm = TRUE),
            mean(data$observed_el[data$treat == 1], na.rm = TRUE),
            rd[["beta"]], rd[["pvalue"]],
            sum(sel$pvalue < 0.05, na.rm = TRUE))
)
write.csv(attrition, file.path(out_dir, "attrition.csv"), row.names = FALSE)
write.csv(sel, file.path(out_dir, "attrition_selective.csv"),
          row.names = FALSE, na = "")
message(sprintf("Attrition : C=%.1f%% T=%.1f%% observes ; differentiel p=%.3f",
                100 * attrition$value[1], 100 * attrition$value[2], rd[["pvalue"]]))

# 2c. Bornes de Lee (2009) sur les primaires : rognage du bras le mieux
# observe, hypothese de monotonicite (J-PAL)
lee_bounds <- function(y_el, treat, observed) {
  rT <- mean(observed[treat == 1], na.rm = TRUE)
  rC <- mean(observed[treat == 0], na.rm = TRUE)
  if (is.na(rT) || is.na(rC) || rT == 0 || rC == 0) return(NULL)
  trim_arm <- if (rT >= rC) 1L else 0L
  p0 <- abs(rT - rC) / max(rT, rC)
  y_trim <- y_el[treat == trim_arm & observed == 1]
  y_trim <- y_trim[!is.na(y_trim)]
  y_other <- y_el[treat != trim_arm & observed == 1]
  m_other <- mean(y_other, na.rm = TRUE)
  k <- floor(p0 * length(y_trim))
  y_sorted <- sort(y_trim)
  m_lo <- mean(y_sorted[seq_len(length(y_sorted) - k)])         # rogner le haut
  m_hi <- mean(y_sorted[seq(k + 1, length(y_sorted))])          # rogner le bas
  if (trim_arm == 1L) {
    c(lower = m_lo - m_other, upper = m_hi - m_other, trim_share = p0)
  } else {
    c(lower = m_other - m_hi, upper = m_other - m_lo, trim_share = p0)
  }
}
lee <- lapply(primary_outcomes, function(y) {
  y_el <- data[[paste0(y, "_el")]]
  obs <- as.integer(!is.na(y_el))
  lb <- lee_bounds(y_el, data$treat, obs)
  if (is.null(lb)) return(NULL)
  data.frame(outcome = y, lee_lower = lb[["lower"]], lee_upper = lb[["upper"]],
             trim_share = lb[["trim_share"]],
             beta_itt = itt$beta[itt$outcome == y][1])
})
lee <- do.call(rbind, lee)
write.csv(lee, file.path(out_dir, "lee_bounds.csv"), row.names = FALSE, na = "")

# ===========================================================================
# 3. TESTS MULTIPLES : BH + sharpened q-values (Anderson 2008) par famille
# ===========================================================================
sharpened_q <- function(p) {
  # Anderson (2008), two-stage FDR sharpened q-values
  n <- length(p)
  q <- rep(NA_real_, n)
  ord <- order(p)
  ps <- p[ord]
  for (i in seq(0.001, 1, by = 0.001)) {
    q1 <- i / (1 + i)
    r1 <- sum(ps <= q1 * seq_len(n) / n)
    q2 <- q1 * n / max(1, n - r1 * (1 - q1))
    reject <- ps <= q2 * seq_len(n) / n
    q[ord[reject & is.na(q[ord])]] <- i
  }
  q[is.na(q)] <- 1
  q
}
sec <- itt[!itt$role %in% c("PRIMAIRE") & !is.na(itt$pvalue), ]
qv <- do.call(rbind, lapply(split(sec, sec$family), function(fam) {
  fam$p_bh <- stats::p.adjust(fam$pvalue, method = "BH")
  fam$q_sharpened <- sharpened_q(fam$pvalue)
  fam[, c("outcome", "family", "role", "beta", "pvalue", "p_bh", "q_sharpened")]
}))
write.csv(qv, file.path(out_dir, "qvalues.csv"), row.names = FALSE, na = "")
message(sprintf("Tests multiples : %d secondaires ; %d significatifs a p<0,05 ; %d survivent au q<0,05",
                nrow(qv), sum(qv$pvalue < 0.05), sum(qv$q_sharpened < 0.05)))

# ===========================================================================
# 4. HETEROGENEITE (CATE) : interactions prespecifiees sur les primaires
# ===========================================================================
subgroup_specs <- list(
  sexe_femme = quote(as.integer(c1_bl == 2)),
  sans_instruction = quote(as.integer(c4_bl == 0)),
  employe_baseline = quote(as.integer(ind_employed_bl == 1)),
  choc_baseline = quote(as.integer(shock_exposed_bl == 1))
)
cate <- list()
for (sg_name in names(subgroup_specs)) {
  sg <- tryCatch(eval(subgroup_specs[[sg_name]], data), error = function(e) NULL)
  if (is.null(sg) || sum(!is.na(sg)) < 100 ||
      length(unique(stats::na.omit(sg))) < 2) next
  data$._sg <- sg
  for (y in primary_outcomes) {
    y_el <- paste0(y, "_el")
    y_bl <- paste0(y, "_bl")
    bl_term <- if (y_bl %in% names(data)) paste0(" + ", y_bl) else ""
    f <- stats::as.formula(paste0(y_el, " ~ treat*._sg", bl_term, strata_term))
    fit <- tryCatch(stats::lm(f, data = data), error = function(e) NULL)
    if (is.null(fit) || !"treat:._sg" %in% names(stats::coef(fit))) next
    ri_main <- robust_term(fit, "treat")
    ri_int <- robust_term(fit, "treat:._sg")
    cate[[paste(sg_name, y)]] <- data.frame(
      outcome = y, subgroup = sg_name,
      n = stats::nobs(fit),
      beta_groupe_ref = ri_main[["beta"]],
      beta_interaction = ri_int[["beta"]],
      se_interaction = ri_int[["se"]],
      p_interaction = ri_int[["pvalue"]]
    )
  }
  data$._sg <- NULL
}
cate <- do.call(rbind, cate)
if (!is.null(cate)) {
  write.csv(cate, file.path(out_dir, "cate.csv"), row.names = FALSE, na = "")
  message(sprintf("CATE : %d combinaisons sous-groupe x primaire estimees", nrow(cate)))
} else {
  message("CATE : aucun sous-groupe disponible dans la base (c1/c4 absents ?)")
}

# ===========================================================================
# 5. INFERENCE PAR RANDOMISATION (null aigu, J-PAL) sur les primaires
# ===========================================================================
set.seed(20260702)
n_perm <- 2000
permute_within_strata <- function(treat, strata) {
  out <- treat
  for (s in unique(strata)) {
    idx <- which(strata == s)
    out[idx] <- sample(treat[idx])
  }
  out
}
strata_vec <- if (has_strata) data$lottery_stratum else rep(1L, nrow(data))

ri <- lapply(primary_outcomes, function(y) {
  y_el <- paste0(y, "_el")
  y_bl <- paste0(y, "_bl")
  bl_term <- if (y_bl %in% names(data)) paste0(" + ", y_bl) else ""
  f <- stats::as.formula(paste0(y_el, " ~ treat", bl_term, strata_term))
  fit <- stats::lm(f, data = data, na.action = stats::na.omit)
  b_obs <- unname(stats::coef(fit)["treat"])
  b_perm <- replicate(n_perm, {
    data$._tp <- permute_within_strata(data$treat, strata_vec)
    fp <- stats::as.formula(paste0(y_el, " ~ ._tp", bl_term, strata_term))
    unname(stats::coef(stats::lm(fp, data = data,
                                 na.action = stats::na.omit))["._tp"])
  })
  data.frame(outcome = y, beta_obs = b_obs,
             p_ri = mean(abs(b_perm) >= abs(b_obs)),
             n_permutations = n_perm)
})
ri <- do.call(rbind, ri)
data$._tp <- NULL
write.csv(ri, file.path(out_dir, "randomization_inference.csv"),
          row.names = FALSE, na = "")
message("Inference par randomisation :")
print(ri)

message("Analyses d'evaluation enregistrees dans : ", out_dir)
