# Fichier genere : ne pas modifier manuellement.
# Section A.GESTION DES TENTATIVES D’APPEL
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "A",
  section_order = 2L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
