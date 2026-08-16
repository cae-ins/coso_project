# Fichier genere : ne pas modifier manuellement.
# Section H. REVENU ET CARACTERISTIQUES DE L'ENTREPRISE
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "H",
  section_order = 9L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
