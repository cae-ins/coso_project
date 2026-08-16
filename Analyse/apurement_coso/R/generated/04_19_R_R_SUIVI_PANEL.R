# Fichier genere : ne pas modifier manuellement.
# Section R. SUIVI PANEL
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "R",
  section_order = 19L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
