# Fichier genere : ne pas modifier manuellement.
# Section N. RESILIENCE FACE AUX CHOCS
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "N",
  section_order = 15L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
