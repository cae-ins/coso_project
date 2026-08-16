# Controles issus des donnees, du PAD ou du raisonnement metier.
# Ils restent a valider et n'entrainent aucune correction automatique.

controler_metier_propose <- function(data, matrix, ctx) {
  rows <- matrix[
    matrix$condition_status == "executable_metier_propose",
    ,
    drop = FALSE
  ]
  output_folder <- file.path(ctx$paths$document, "50_metier_propose")
  dir.create(output_folder, recursive = TRUE, showWarnings = FALSE)
  manifest <- NULL

  extra_context <- list(
    DEM_AGE_DOMAIN = c("C2", "C2A_annee"),
    DEM_AGE_TARGET = character(),
    EMP_HOURS_OVER_84 = c("EMPLOYE", "G3", "G5", "G6"),
    EMP_H4A_LARGE = c("EMPLOYE", "F1", "H4A"),
    INCOME_H5_LARGE = c("EMPLOYE", "F1", "H5"),
    COH_Q2_NUMERIC = "Q2"
  )

  for (index in seq_len(nrow(rows))) {
    row <- rows[index, , drop = FALSE]
    expression <- row$rule_expression_stata[[1]]
    evaluation <- tryCatch(
      list(mask = evaluate_rule_expression(data, expression), error = NULL),
      error = function(error) list(mask = rep(FALSE, nrow(data)), error = error)
    )
    if (!is.null(evaluation$error)) {
      manifest <- append_rows(
        manifest,
        manifest_row(
          row$rule_id[[1]], row$section_code[[1]], row$check_type[[1]],
          row$variable[[1]], row$source_regle[[1]], row$scope_source[[1]],
          row$decision_status[[1]], row$action[[1]], 0L,
          evaluation_status = "ERREUR",
          evaluation_message = conditionMessage(evaluation$error)
        )
      )
      next
    }

    rule_id <- row$rule_id[[1]]
    report_path <- file.path(
      output_folder,
      paste0(tolower(safe_file_part(rule_id)), ".xlsx")
    )
    referenced <- referenced_data_columns(expression, names(data))
    columns <- unique(c(
      ctx$report_context,
      row$variable[[1]],
      referenced,
      extra_context[[rule_id]]
    ))
    message_text <- switch(
      rule_id,
      DEM_AGE_DOMAIN = "Age hors plage plausible 15-99",
      DEM_AGE_TARGET = "Age hors cible PAD provisoire 15-35",
      EMP_HOURS_OVER_84 = "Total hebdomadaire superieur a 84 heures",
      EMP_H4A_LARGE = "Nombre de travailleurs remuneres superieur a 100",
      INCOME_H5_LARGE = "Montant H5 superieur a 5 millions FCFA",
      COH_Q2_NUMERIC = "Q2 non numerique; format cible a valider",
      paste(row$variable[[1]], row$check_type[[1]])
    )
    exported <- export_rule_cases(
      data, evaluation$mask, report_path, columns, rule_id, message_text,
      row$source_regle[[1]], row$scope_source[[1]], row$decision_status[[1]],
      row$action[[1]], pii_columns = ctx$pii_questionnaire
    )
    manifest <- append_rows(
      manifest,
      manifest_row(
        rule_id, row$section_code[[1]], row$check_type[[1]],
        row$variable[[1]], row$source_regle[[1]], row$scope_source[[1]],
        row$decision_status[[1]], row$action[[1]], sum(evaluation$mask),
        if (exported) relative_project_path(report_path, ctx$paths$root) else ""
      )
    )
  }

  errors <- manifest$evaluation_status == "ERREUR"
  if (any(errors)) {
    stop(
      "Echec d'evaluation des regles metier proposees : ",
      paste(
        paste0(
          manifest$rule_id[errors], ": ",
          manifest$evaluation_message[errors]
        ),
        collapse = " | "
      ),
      call. = FALSE
    )
  }
  message("Controles metier proposes termines sans correction.")
  manifest
}
