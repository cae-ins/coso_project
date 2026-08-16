# Fichier genere : ne pas modifier manuellement.
# Section F. EMPLOI PRINCIPAL
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "F",
  section_order = 7L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
