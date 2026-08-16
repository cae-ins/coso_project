# Fichier genere : ne pas modifier manuellement.
# Section C. PROFIL SOCIODEMOGRAPHIQUE
section_manifest <- run_section_rules(
  data = state$data,
  matrix = state$matrix,
  ctx = state$ctx,
  section_code = "C",
  section_order = 4L
)
state$manifest <- append_rows(state$manifest, section_manifest)
rm(section_manifest)
