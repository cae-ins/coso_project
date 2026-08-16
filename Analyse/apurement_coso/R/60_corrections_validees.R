# Registre executable reserve aux corrections explicitement validees.

appliquer_corrections_validees <- function(data, ctx) {
  # Aucune correction n'a ete validee a la date de cette version.
  # Toute future correction devra documenter : identifiant, source, date,
  # condition avant correction, transformation deterministe et test apres.
  list(data = data, correction_count = 0L, correction_log = data.frame())
}
