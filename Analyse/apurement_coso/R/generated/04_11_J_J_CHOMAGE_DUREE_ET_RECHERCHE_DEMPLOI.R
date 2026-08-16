# Fichier genere : ne pas modifier manuellement.
# Section J. CHOMAGE – DUREE ET RECHERCHE D’EMPLOI
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "J",
  section_order = 11L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
