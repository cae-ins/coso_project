# Fichier genere : ne pas modifier manuellement.
# Section L. INCLUSION FINANCIERE & EPARGNE
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "L",
  section_order = 13L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
