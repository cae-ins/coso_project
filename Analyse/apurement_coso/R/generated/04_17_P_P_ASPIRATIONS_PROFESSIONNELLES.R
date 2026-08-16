# Fichier genere : ne pas modifier manuellement.
# Section P. ASPIRATIONS PROFESSIONNELLES
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "P",
  section_order = 17L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
