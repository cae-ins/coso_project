#!/usr/bin/env Rscript

# COSO Nord - Construction des indicateurs d'effets (v2, 2 juillet 2026)
# Questionnaire : Draft 7 (version du 01/07/2026) + Addendum chomage/sous-emploi
# References : Suivi_Evaluation/Cadre_Indicateurs_Effets.md (v2)
#              Suivi_Evaluation/Matrice_Indicateurs_Eval_Impact_COSO.xlsx
#
# Usage :
#   Rscript Analyse/R/01_construire_indicateurs_effets_draft7.R \
#     chemin/base_entree.dta chemin/base_indicateurs.dta
#
# Variables CONDITIONNELLES (absentes du V7 tant que non adoptees) :
#   - Addendum   : j0, j0a, j0b, g7a  -> chomage BIT, MOP, sous-emploi, LU1-LU4
#   - Note revue : h5a, h5b, h5c      -> profit MMW (outcome primaire economique)
# Le h5 actuel du V7 amalgame profit et prelevements : il n'est conserve que
# comme proxy d'equilibre baseline, jamais comme outcome (Cadre v2, decision 12).

suppressPackageStartupMessages({
  library(dplyr)
  library(haven)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2L) {
  stop("Fournir le fichier d'entree et un fichier de sortie distinct.")
}
input_file <- args[[1]]
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

write_data <- function(data, path) {
  ext <- tolower(tools::file_ext(path))
  switch(
    ext,
    dta = haven::write_dta(data, path),
    rds = saveRDS(data, path),
    csv = write.csv(data, path, row.names = FALSE, na = ""),
    stop("Format de sortie non pris en charge : ", ext)
  )
}

row_mean_strict <- function(data, vars, min_valid = length(vars)) {
  x <- as.data.frame(data[vars])
  n <- rowSums(!is.na(x))
  out <- rowMeans(x, na.rm = TRUE)
  out[n < min_valid] <- NA_real_
  out
}

data <- read_data(input_file)
names(data) <- tolower(names(data))

questionnaire_vars <- c(
  "e1", "e2", "e3", "e3a", "f1", "f2", "f4",
  "g3", "g5", "g6", "g7",
  "h2", "h3", "h4", "h4a", "h5", "i1", "j1", "j2", "j3",
  "k1", "iga6", "iga7",
  "l1", "l2", "l3", "l4", "l6", "l9",
  "m1", "m2", "m3", "m4",
  "n1", "n2", "n3", "n4", "n5", "n6a", "n7",
  "o3", "o5", "o6",
  "q1", "q2", "q3", "q4", "q5", "q6", "q7", "q8", "q9", "q10"
)

missing_vars <- setdiff(questionnaire_vars, names(data))
if (length(missing_vars) > 0L) {
  warning(
    "Variables absentes, creees manquantes : ",
    paste(missing_vars, collapse = ", ")
  )
  for (v in missing_vars) data[[v]] <- NA_real_
}

# Disponibilite des modules conditionnels
has_addendum <- all(c("j0", "j0a", "j0b", "g7a") %in% names(data))
has_mmw <- all(c("h5a", "h5b", "h5c") %in% names(data))
if (!has_addendum) {
  message("Addendum (j0/j0a/j0b/g7a) absent : chomage, MOP et sous-emploi ",
          "strict ne seront PAS calcules (Cadre v2, decision 11).")
}
if (!has_mmw) {
  message("Sequence MMW (h5a/h5b/h5c) absente : le profit MMW ne sera PAS ",
          "calcule ; h5 reste un proxy non valide (Cadre v2, decision 12).")
}

# ---------------------------------------------------------------------------
# 1. Statut d'activite (famille C.1) -- definitions ENE/BIT
# ---------------------------------------------------------------------------
data <- data %>%
  mutate(
    ind_employed = case_when(
      e1 == 1 | e2 == 1 | (e3 == 1 & e3a == 1) ~ 1L,
      e1 == 2 & e2 == 2 & (e3 == 2 | (e3 == 1 & e3a == 2)) ~ 0L,
      TRUE ~ NA_integer_
    ),
    ind_self_employed = case_when(
      ind_employed == 0 ~ 0L,
      ind_employed == 1 & !is.na(f1) ~ as.integer(f1 %in% c(2, 3)),
      TRUE ~ NA_integer_
    ),
    ind_salaried = case_when(
      ind_employed == 0 ~ 0L,
      ind_employed == 1 & !is.na(f1) ~ as.integer(f1 == 1),
      TRUE ~ NA_integer_
    ),
    ind_employer = case_when(
      ind_employed == 0 ~ 0L,
      ind_employed == 1 & !is.na(f1) ~ as.integer(f1 == 2),
      TRUE ~ NA_integer_
    ),
    # Emplois remuneres crees (h4a, V7) -- zero structurel observe
    jobs_created_uncond = case_when(
      ind_employed == 0 ~ 0,
      ind_employed == 1 & f1 %in% c(1, 5, 6, 7) ~ 0,
      ind_employed == 1 & f1 %in% c(2, 3, 4) & h4a >= 0 ~ as.numeric(h4a),
      TRUE ~ NA_real_
    ),
    # Perennite : activite principale >= 12 mois sans interruption
    ind_activity_12m = case_when(
      ind_employed == 0 ~ 0L,
      ind_employed == 1 & f4 %in% 1:5 ~ as.integer(f4 %in% c(3, 4, 5)),
      TRUE ~ NA_integer_
    ),
    # Formalisation parmi les independants (descriptif conditionnel)
    ind_registered_cond = case_when(
      ind_employed == 1 & f1 %in% c(2, 3, 4) & h4 %in% c(1, 2, 3) ~
        as.integer(h4 == 1),
      TRUE ~ NA_integer_
    )
  )

# Chomage BIT, main-d'oeuvre potentielle, decourages (addendum requis)
if (has_addendum) {
  data <- data %>%
    mutate(
      # Chomeur = sans emploi & (recherche 30j | future starter) & disponible
      ind_unemployed = case_when(
        ind_employed == 1 ~ 0L,
        ind_employed == 0 & j0 == 1 & j3 == 1 ~ 1L,
        ind_employed == 0 & j0 == 2 & j0a == 8 & j3 == 1 ~ 1L,  # future starters
        ind_employed == 0 & j0 == 1 & j3 == 2 ~ 0L,
        ind_employed == 0 & j0 == 2 & !(j0a == 8 & j3 == 1) &
          !is.na(j0a) & j3 %in% c(1, 2) ~ 0L,
        TRUE ~ NA_integer_
      ),
      # Main-d'oeuvre potentielle (LU3/LU4)
      ind_mop = case_when(
        ind_employed == 1 | ind_unemployed == 1 ~ 0L,
        ind_employed == 0 & j0 == 1 & j3 == 2 ~ 1L,
        ind_employed == 0 & j0 == 2 & j0b == 1 & j3 == 1 ~ 1L,
        ind_employed == 0 & j0 == 2 & (j0b == 2 | j3 == 2) ~ 0L,
        TRUE ~ NA_integer_
      ),
      ind_discouraged = case_when(
        ind_employed == 0 & j0 == 2 & j0a %in% 1:9 ~ as.integer(j0a == 1),
        ind_employed == 1 ~ 0L,
        TRUE ~ NA_integer_
      ),
      ind_inactive = case_when(
        ind_employed == 1 | ind_unemployed == 1 | ind_mop == 1 ~ 0L,
        ind_employed == 0 & ind_unemployed == 0 & ind_mop == 0 ~ 1L,
        TRUE ~ NA_integer_
      ),
      ind_active_search = case_when(
        ind_employed == 0 & j0 %in% c(1, 2) ~ as.integer(j0 == 1),
        TRUE ~ NA_integer_
      )
    )
} else {
  data$ind_unemployed <- NA_integer_
  data$ind_mop <- NA_integer_
  data$ind_discouraged <- NA_integer_
  data$ind_inactive <- NA_integer_
  data$ind_active_search <- NA_integer_
}

# ---------------------------------------------------------------------------
# 2. Heures et sous-emploi -- seuil 40 h (decision alignee ENE, Cadre v2 #3)
# ---------------------------------------------------------------------------
hours_threshold <- 40
data <- data %>%
  mutate(
    hours_week_cond = case_when(
      ind_employed == 1 & g5 == 2 & !is.na(g3) ~ as.numeric(g3),
      ind_employed == 1 & g5 == 1 & !is.na(g3) & !is.na(g6) ~
        as.numeric(g3 + g6),
      TRUE ~ NA_real_
    ),
    hours_week_uncond = case_when(
      ind_employed == 0 ~ 0,
      ind_employed == 1 ~ hours_week_cond,
      TRUE ~ NA_real_
    ),
    flag_hours_over_84 = case_when(
      !is.na(hours_week_cond) ~ as.integer(hours_week_cond > 84),
      TRUE ~ NA_integer_
    ),
    ind_diversified = case_when(
      ind_employed == 0 ~ 0L,
      ind_employed == 1 & g5 %in% c(1, 2) ~ as.integer(g5 == 1),
      TRUE ~ NA_integer_
    )
  )

if (has_addendum) {
  data <- data %>%
    mutate(
      # Sous-emploi BIT : < 40 h & souhait (g7) & disponibilite (g7a)
      ind_underemployment = case_when(
        ind_employed == 0 ~ 0L,
        ind_employed == 1 & !is.na(hours_week_cond) & g7 == 2 ~ 0L,
        ind_employed == 1 & !is.na(hours_week_cond) &
          g7 == 1 & g7a %in% c(1, 2) ~
          as.integer(hours_week_cond < hours_threshold & g7a == 1),
        TRUE ~ NA_integer_
      )
    )
} else {
  data$ind_underemployment <- NA_integer_
}
# Proxy majorant (sans disponibilite) -- garde pour comparaison uniquement
data <- data %>%
  mutate(
    ind_underemployment_proxy = case_when(
      ind_employed == 0 ~ 0L,
      ind_employed == 1 & !is.na(hours_week_cond) & !is.na(g7) ~
        as.integer(hours_week_cond < hours_threshold & g7 == 1),
      TRUE ~ NA_integer_
    )
  )

# ---------------------------------------------------------------------------
# 3. Revenus (famille C.2)
# ---------------------------------------------------------------------------
data <- data %>%
  mutate(
    salary_monthly_provisional = case_when(
      ind_salaried == 1 & h2 == 1 & h3 >= 0 ~ h3 * 26,        # quotidien
      ind_salaried == 1 & h2 == 2 & h3 >= 0 ~ h3 * 52 / 12,   # hebdomadaire
      ind_salaried == 1 & h2 == 3 & h3 >= 0 ~ h3 * 26 / 12,   # bimensuel
      ind_salaried == 1 & h2 == 4 & h3 >= 0 ~ as.numeric(h3), # mensuel
      TRUE ~ NA_real_
    ),
    flag_salary_irregular = case_when(
      ind_salaried == 1 & h2 == 5 ~ 1L,
      ind_salaried == 1 & h2 %in% 1:4 ~ 0L,
      TRUE ~ NA_integer_
    ),
    salary_monthly_uncond = case_when(
      ind_salaried == 0 ~ 0,
      ind_salaried == 1 ~ salary_monthly_provisional,
      TRUE ~ NA_real_
    ),
    # h5 V7 : proxy NON VALIDE (amalgame) -- equilibre baseline uniquement
    profit_proxy_h5 = case_when(
      ind_self_employed == 1 & h5 >= 0 ~ as.numeric(h5),
      TRUE ~ NA_real_
    )
  )

if (has_mmw) {
  # Codage suppose de h5b : 1 = bon mois, 2 = mois ordinaire, 3 = mauvais mois
  # >>> A CONFIRMER contre le questionnaire programme avant tout calcul <<<
  mois_ordinaire_code <- 2
  data <- data %>%
    mutate(
      profit_last_month = case_when(
        ind_self_employed == 1 & !is.na(h5a) ~ as.numeric(h5a),
        TRUE ~ NA_real_
      ),
      profit_normal_month = case_when(
        ind_self_employed == 1 & h5b == mois_ordinaire_code & !is.na(h5a) ~
          as.numeric(h5a),
        ind_self_employed == 1 & h5b != mois_ordinaire_code & !is.na(h5c) ~
          as.numeric(h5c),
        TRUE ~ NA_real_
      ),
      # OUTCOME PRIMAIRE ECONOMIQUE (non conditionnel, zero structurel observe)
      profit_normal_uncond = case_when(
        ind_employed == 0 ~ 0,
        ind_employed == 1 & ind_self_employed == 0 ~ 0,
        ind_self_employed == 1 ~ profit_normal_month,
        TRUE ~ NA_real_
      )
    )
} else {
  data$profit_last_month <- NA_real_
  data$profit_normal_month <- NA_real_
  data$profit_normal_uncond <- NA_real_
}

data <- data %>%
  mutate(
    main_labor_income_month = case_when(
      ind_employed == 0 ~ 0,
      ind_salaried == 1 ~ salary_monthly_provisional,
      ind_self_employed == 1 ~ profit_normal_month,
      TRUE ~ NA_real_
    ),
    ind_saves = case_when(
      l3 %in% c(1, 2, 3) ~ as.integer(l3 %in% c(1, 2)),
      TRUE ~ NA_integer_
    ),
    savings_month_amount = case_when(
      l3 == 3 ~ 0,
      l3 %in% c(1, 2) & l4 >= 0 ~ as.numeric(l4),
      TRUE ~ NA_real_
    ),
    ind_financial_inclusion = case_when(
      l1 %in% c(1, 2) & l2 %in% c(1, 2) ~ as.integer(l1 == 1 | l2 == 1),
      l1 == 1 | l2 == 1 ~ 1L,
      TRUE ~ NA_integer_
    ),
    ind_has_debt = case_when(
      l6 %in% c(1, 2) ~ as.integer(l6 == 1),
      TRUE ~ NA_integer_
    ),
    ind_productive_credit = case_when(
      l6 == 2 ~ 0L,
      l6 == 1 & l9 %in% 1:6 ~ as.integer(l9 == 1),
      TRUE ~ NA_integer_
    )
  )

# ---------------------------------------------------------------------------
# 4. Entrepreneuriat, recherche et formation (famille C.3 / mecanismes)
# ---------------------------------------------------------------------------
data <- data %>%
  mutate(
    ind_ever_created = case_when(
      k1 %in% c(1, 2) ~ as.integer(k1 == 1),
      TRUE ~ NA_integer_
    ),
    ind_entrep_training = case_when(
      iga6 %in% c(1, 2) ~ as.integer(iga6 == 1),
      TRUE ~ NA_integer_
    ),
    mgmt_skills_score = case_when(
      iga7 %in% 1:5 ~ as.numeric(iga7),
      TRUE ~ NA_real_
    ),
    ind_search_other_job = case_when(
      ind_employed == 1 & i1 %in% c(1, 2) ~ as.integer(i1 == 1),
      TRUE ~ NA_integer_
    ),
    ind_training_12m = case_when(
      o3 %in% c(1, 2) ~ as.integer(o3 == 1),
      TRUE ~ NA_integer_
    ),
    ind_training_gov = case_when(
      o3 == 2 ~ 0L,
      o3 == 1 & o5 %in% 1:7 ~ as.integer(o5 == 3),
      TRUE ~ NA_integer_
    ),
    ind_training_useful = case_when(
      o3 == 1 & o6 %in% 1:3 ~ as.integer(o6 %in% c(2, 3)),
      TRUE ~ NA_integer_
    )
  )

# ---------------------------------------------------------------------------
# 5. Resilience (famille C.5) -- capacites seulement dans l'indice
# ---------------------------------------------------------------------------
asset_vars <- grep("^d5__", names(data), value = TRUE)
if (length(asset_vars) > 0L) {
  asset_data <- as.data.frame(data[asset_vars])
  n_asset_answered <- rowSums(!is.na(asset_data))
  data$asset_count <- rowSums(asset_data, na.rm = TRUE)
  data$asset_count[n_asset_answered == 0L] <- NA_real_
} else {
  data$asset_count <- NA_real_
}

data <- data %>%
  mutate(
    shock_exposed = case_when(          # COVARIABLE, pas un outcome
      n1 %in% c(1, 2) ~ as.integer(n1 == 1),
      TRUE ~ NA_integer_
    ),
    negative_coping_cond = case_when(   # descriptif conditionnel uniquement
      shock_exposed == 1 & n4 %in% 1:7 ~ as.integer(n4 %in% c(2, 6)),
      TRUE ~ NA_integer_
    ),
    recovery_cond = case_when(          # descriptif conditionnel uniquement
      shock_exposed == 1 & n5 %in% 1:5 ~ (5 - n5) / 4,
      TRUE ~ NA_real_
    ),
    emergency_capacity = case_when(
      n6a %in% 1:3 ~ (3 - n6a) / 2,
      TRUE ~ NA_real_
    ),
    ind_emergency_easy = case_when(
      n6a %in% 1:3 ~ as.integer(n6a == 1),
      TRUE ~ NA_integer_
    ),
    resilience_subjective = case_when(
      n7 %in% 1:10 ~ (n7 - 1) / 9,
      TRUE ~ NA_real_
    )
  )

# Composants de l'indice de capacite (agregation Anderson dans 02) ;
# moyenne simple conservee en secours (>= 3 composants sur 5 observes)
resilience_components <- c(
  "ind_emergency_easy", "resilience_subjective", "ind_saves",
  "ind_diversified"
)
data$resilience_capacity_simple <- row_mean_strict(
  data, resilience_components, min_valid = 3L
)

# ---------------------------------------------------------------------------
# 6. Changement de statut (famille C.4) -- hierarchie v2
# ---------------------------------------------------------------------------
# ANCRE FACTUELLE : m2 (aide externe recue sur 12 mois)
data <- data %>%
  mutate(
    ind_no_external_aid = case_when(
      m2 %in% 1:3 ~ as.integer(m2 == 3),
      TRUE ~ NA_integer_
    ),
    # Composants PERCEPTUELS : libelles calques sur la TOC -> risque de
    # desirabilite differentielle entre bras ; interpreter a l'aune de
    # ind_no_external_aid (Cadre v2, section 3.9)
    productive_m1 = case_when(m1 %in% 1:3 ~ (m1 - 1) / 2, TRUE ~ NA_real_),
    productive_m3 = case_when(m3 %in% 1:5 ~ (m3 - 1) / 4, TRUE ~ NA_real_),
    productive_m4 = case_when(m4 %in% 1:3 ~ (3 - m4) / 2, TRUE ~ NA_real_)
  )

data$productive_status_index <- row_mean_strict(
  data,
  c("ind_no_external_aid", "productive_m1", "productive_m3", "productive_m4"),
  min_valid = 2L
)

# ---------------------------------------------------------------------------
# 7. Cohesion sociale (famille D) -- composants ; Anderson dans 02
# ---------------------------------------------------------------------------
data <- data %>%
  mutate(
    ind_group_member = case_when(
      q1 %in% c(1, 2) ~ as.integer(q1 == 1),
      TRUE ~ NA_integer_
    ),
    volunteer_count_30d = case_when(q2 >= 0 ~ as.numeric(q2),
                                    TRUE ~ NA_real_),
    trust_general = case_when(
      q3 %in% c(1, 2) ~ as.integer(q3 == 1),
      TRUE ~ NA_integer_
    ),
    trust_intergroup = case_when(
      q4 %in% 1:4 ~ (q4 - 1) / 3,
      TRUE ~ NA_real_           # q4 == 9 (NSP) -> manquant
    )
  )

institution_vars <- paste0("q", 5:10)
institution_norm <- as.data.frame(lapply(data[institution_vars], function(x) {
  ifelse(x %in% 1:4, (x - 1) / 3, NA_real_)  # 9 (NSP) -> manquant
}))
names(institution_norm) <- paste0("norm_", institution_vars)
data[names(institution_norm)] <- institution_norm
data$trust_institutional <- row_mean_strict(
  data, names(institution_norm), min_valid = 4L
)

# ---------------------------------------------------------------------------
# 8. Controles de qualite (Cadre v2)
# ---------------------------------------------------------------------------
quality_counts <- c(
  employment_missing = sum(is.na(data$ind_employed)),
  employed_without_f1 = sum(data$ind_employed == 1 & is.na(data$f1),
                            na.rm = TRUE),
  h4a_out_of_universe = sum(
    !is.na(data$h4a) & data$h4a > 0 & !(data$f1 %in% c(2, 3, 4)),
    na.rm = TRUE
  ),
  selfemp_without_profit = if (has_mmw) {
    sum(data$ind_self_employed == 1 & is.na(data$profit_normal_month),
        na.rm = TRUE)
  } else NA_integer_,
  j1_with_j0_no = if (has_addendum) {
    sum(!is.na(data$j1) & data$j0 == 2, na.rm = TRUE)
  } else NA_integer_,
  g7a_with_g7_no = if (has_addendum) {
    sum(!is.na(data$g7a) & data$g7 == 2, na.rm = TRUE)
  } else NA_integer_,
  hours_over_84 = sum(data$flag_hours_over_84 == 1, na.rm = TRUE),
  shock_answers_out_of_universe = sum(
    data$shock_exposed == 0 &
      (!is.na(data$n3) | !is.na(data$n4) | !is.na(data$n5)),
    na.rm = TRUE
  )
)
print(quality_counts)

# Tabulation descriptive LU1-LU4 (verification, pas un resultat causal)
if (has_addendum) {
  E <- sum(data$ind_employed == 1, na.rm = TRUE)
  C <- sum(data$ind_unemployed == 1, na.rm = TRUE)
  S <- sum(data$ind_underemployment == 1, na.rm = TRUE)
  P <- sum(data$ind_mop == 1, na.rm = TRUE)
  lu <- c(
    LU1 = C / (E + C),
    LU2 = (C + S) / (E + C),
    LU3 = (C + P) / (E + C + P),
    LU4 = (C + S + P) / (E + C + P)
  )
  message("Taux de sous-utilisation (echantillon, non ponderes) :")
  print(round(lu, 4))
}

write_data(data, output_file)
message("Base d'indicateurs enregistree : ", output_file)
