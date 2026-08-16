# Fichier genere : ne pas modifier manuellement.
# Section K. ENTREPRENEURIAT
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "K",
  section_order = 12L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
