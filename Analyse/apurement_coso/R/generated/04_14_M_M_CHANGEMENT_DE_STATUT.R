# Fichier genere : ne pas modifier manuellement.
# Section M. CHANGEMENT DE STATUT
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "M",
  section_order = 14L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
