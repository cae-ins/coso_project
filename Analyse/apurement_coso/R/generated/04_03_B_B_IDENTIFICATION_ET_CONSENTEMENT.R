# Fichier genere : ne pas modifier manuellement.
# Section B. IDENTIFICATION ET CONSENTEMENT
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "B",
  section_order = 3L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
