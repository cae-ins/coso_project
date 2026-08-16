# Fichier genere : ne pas modifier manuellement.
# Section G. QUALITE DE L'EMPLOI
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "G",
  section_order = 8L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
