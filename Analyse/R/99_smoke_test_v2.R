# Test de bout en bout des scripts v2 sur donnees simulees V7+addendum+MMW
set.seed(20260702)
n <- 1688

simulate_wave <- function(n, treat, effect = 0) {
  emp_p <- plogis(qlogis(0.45) + effect * treat)
  e1 <- ifelse(runif(n) < emp_p, 1, 2)
  e2 <- ifelse(e1 == 2 & runif(n) < 0.05, 1, 2)
  e3 <- ifelse(e1 == 2 & e2 == 2 & runif(n) < 0.10, 1, 2)
  e3a <- ifelse(e3 == 1, sample(1:2, n, TRUE, c(0.6, 0.4)), NA)
  employed <- e1 == 1 | e2 == 1 | (e3 == 1 & !is.na(e3a) & e3a == 1)

  f1 <- ifelse(employed, sample(1:7, n, TRUE, c(.15, .1, .5, .05, .1, .07, .03)), NA)
  f4 <- ifelse(employed, sample(1:5, n, TRUE), NA)
  g3 <- ifelse(employed, pmax(2, round(rnorm(n, 38, 12))), NA)
  g5 <- ifelse(employed, sample(1:2, n, TRUE, c(.25, .75)), NA)
  g6 <- ifelse(employed & g5 == 1, pmax(1, round(rnorm(n, 10, 5))), NA)
  g7 <- ifelse(employed, sample(1:2, n, TRUE, c(.55, .45)), NA)
  g7a <- ifelse(employed & g7 == 1, sample(1:2, n, TRUE, c(.7, .3)), NA)

  selfemp <- employed & f1 %in% c(2, 3)
  h2 <- ifelse(employed & f1 == 1, sample(1:5, n, TRUE, c(.2, .2, .1, .45, .05)), NA)
  h3 <- ifelse(employed & f1 == 1, round(exp(rnorm(n, 10.5, .6))), NA)
  h4 <- ifelse(employed & f1 %in% 2:4, sample(1:3, n, TRUE, c(.2, .7, .1)), NA)
  h4a <- ifelse(employed & f1 %in% 2:3, rpois(n, 0.4 + 0.3 * treat), NA)
  h5 <- ifelse(selfemp, round(exp(rnorm(n, 10.8, .8))), NA)
  h5a <- ifelse(selfemp, round(exp(rnorm(n, 10.9 + 0.25 * treat, .7))), NA)
  h5b <- ifelse(selfemp, sample(1:3, n, TRUE, c(.25, .5, .25)), NA)
  h5c <- ifelse(selfemp & h5b != 2, round(exp(rnorm(n, 10.8 + 0.25 * treat, .7))), NA)

  i1 <- ifelse(employed, sample(1:2, n, TRUE, c(.3, .7)), NA)
  j0 <- ifelse(!employed, sample(1:2, n, TRUE, c(.6, .4)), NA)
  j0a <- ifelse(!employed & j0 == 2, sample(1:9, n, TRUE, c(.3, .1, .1, .05, .15, .1, .05, .05, .1)), NA)
  j0b <- ifelse(!employed & j0 == 2, sample(1:2, n, TRUE, c(.65, .35)), NA)
  j1 <- ifelse(!employed & j0 == 1, sample(1:7, n, TRUE), NA)
  j2 <- ifelse(!employed & j0 == 1, sample(1:6, n, TRUE), NA)
  j3 <- ifelse(!employed, sample(1:2, n, TRUE, c(.8, .2)), NA)

  k1 <- ifelse(runif(n) < .4 + .1 * treat, 1, 2)
  iga6 <- ifelse(runif(n) < .25 + .3 * treat, 1, 2)
  iga7 <- pmin(5, pmax(1, round(rnorm(n, 2.8 + .4 * treat, 1))))
  l1 <- sample(1:2, n, TRUE, c(.7, .3)); l2 <- sample(1:2, n, TRUE, c(.15, .85))
  l3 <- sample(1:3, n, TRUE, c(.25, .35, .4))
  l4 <- ifelse(l3 %in% 1:2, round(exp(rnorm(n, 9, .8))), NA)
  l6 <- sample(1:2, n, TRUE, c(.3, .7))
  l9 <- ifelse(l6 == 1, sample(1:6, n, TRUE), NA)
  m1 <- sample(1:3, n, TRUE); m2 <- sample(1:3, n, TRUE)
  m3 <- sample(1:5, n, TRUE); m4 <- sample(1:4, n, TRUE, c(.4, .3, .2, .1))
  n1 <- sample(1:2, n, TRUE, c(.45, .55))
  n2 <- ifelse(n1 == 1, sample(1:6, n, TRUE), NA)
  n3 <- ifelse(n1 == 1, sample(1:4, n, TRUE), NA)
  n4 <- ifelse(n1 == 1, sample(1:7, n, TRUE), NA)
  n5 <- ifelse(n1 == 1, sample(1:5, n, TRUE), NA)
  n6a <- sample(1:3, n, TRUE, c(.15, .35, .5))
  n7 <- sample(1:10, n, TRUE)
  o3 <- ifelse(runif(n) < .2 + .5 * treat, 1, 2)
  o5 <- ifelse(o3 == 1, sample(1:7, n, TRUE, c(.1, .1, .5, .1, .1, .05, .05)), NA)
  o6 <- ifelse(o3 == 1, sample(1:3, n, TRUE), NA)
  q1 <- ifelse(runif(n) < .35 + .05 * treat, 1, 2)
  q2 <- rpois(n, 1.2 + .3 * treat)
  q3 <- sample(1:2, n, TRUE, c(.3, .7))
  q4 <- sample(c(1:4, 9), n, TRUE, c(.2, .3, .3, .15, .05))
  qk <- function() sample(c(1:4, 9), n, TRUE, c(.15, .25, .3, .25, .05))

  data.frame(e1, e2, e3, e3a, f1, f2 = ifelse(employed, sample(1:15, n, TRUE), NA), f4,
             g3, g5, g6, g7, g7a, h2, h3, h4, h4a, h5, h5a, h5b, h5c,
             i1, j0, j0a, j0b, j1, j2, j3, k1, iga6, iga7,
             l1, l2, l3, l4, l6, l9, m1, m2, m3, m4,
             n1, n2, n3, n4, n5, n6a, n7, o3, o5, o6,
             q1, q2, q3, q4, q5 = qk(), q6 = qk(), q7 = qk(), q8 = qk(),
             q9 = qk(), q10 = qk())
}

treat <- rep(c(1, 0), length.out = n)
stratum <- sample(1:8, n, TRUE)

bl <- simulate_wave(n, treat = rep(0, n), effect = 0)   # baseline pre-traitement
el <- simulate_wave(n, treat = treat, effect = 0.35)

dir <- Sys.getenv("SMOKE_DIR")
write.csv(bl, file.path(dir, "sim_bl.csv"), row.names = FALSE, na = "")
write.csv(el, file.path(dir, "sim_el.csv"), row.names = FALSE, na = "")

# ---- Script 01 sur chaque vague ----
s01 <- Sys.getenv("SCRIPT01")
for (w in c("bl", "el")) {
  cmd <- sprintf('"%s" "%s" "%s" "%s"',
                 file.path(R.home("bin"), "Rscript.exe"), s01,
                 file.path(dir, paste0("sim_", w, ".csv")),
                 file.path(dir, paste0("ind_", w, ".csv")))
  status <- system(cmd)
  stopifnot(status == 0)
}

# ---- Panel large ----
ib <- read.csv(file.path(dir, "ind_bl.csv"))
ie <- read.csv(file.path(dir, "ind_el.csv"))
names(ib) <- paste0(names(ib), "_bl")
names(ie) <- paste0(names(ie), "_el")
panel <- cbind(ib, ie)
panel$treat <- treat
panel$lottery_stratum <- stratum
# attrition simulee a l'endline (25 %, non differentielle)
drop <- runif(n) < 0.25
panel[drop, grepl("_el$", names(panel))] <- NA
write.csv(panel, file.path(dir, "panel.csv"), row.names = FALSE, na = "")

# ---- Script 02 ----
s02 <- Sys.getenv("SCRIPT02")
cmd <- sprintf('"%s" "%s" "%s" "%s"',
               file.path(R.home("bin"), "Rscript.exe"), s02,
               file.path(dir, "panel.csv"), file.path(dir, "res_itt.csv"))
status <- system(cmd)
stopifnot(status == 0)

res <- read.csv(file.path(dir, "res_itt.csv"))
cat("\n=== RESULTATS (extraits) ===\n")
print(res[, c("outcome", "family", "role", "n", "control_mean", "beta", "pvalue")],
      digits = 3)

# ---- Assertions ----
stopifnot(sum(res$role == "PRIMAIRE") == 2)
emp <- res[res$outcome == "ind_employed", ]
stopifnot(emp$beta > 0, emp$pvalue < 0.05)          # effet emploi injecte ~0.35 logit
prof <- res[res$outcome == "profit_normal_uncond_ihs", ]
stopifnot(prof$beta > 0)                             # effet profit injecte
tr <- res[res$outcome == "ind_training_12m", ]
stopifnot(tr$beta > 0.3)                             # 1er stade injecte (+50 pts)
stopifnot(all(c("ind_unemployed", "ind_underemployment", "ind_mop",
                "jobs_created_uncond_w", "idx_cohesion", "idx_statut",
                "ind_no_external_aid") %in% res$outcome))
cat("\nTOUTES LES ASSERTIONS PASSENT — scripts v2 valides sur simulation.\n")
