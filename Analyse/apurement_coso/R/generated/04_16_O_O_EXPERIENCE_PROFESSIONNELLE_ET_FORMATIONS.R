# Fichier genere : ne pas modifier manuellement.
# Section O. EXPERIENCE PROFESSIONNELLE ET FORMATIONS
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "O",
  section_order = 16L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
