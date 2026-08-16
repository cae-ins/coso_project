# Fichier genere : ne pas modifier manuellement.
# Section Couverture
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "COVER",
  section_order = 1L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
