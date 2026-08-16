# Fichier genere : ne pas modifier manuellement.
# Section I. RECHERCHE D’UN AUTRE EMPLOI
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "I",
  section_order = 10L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
