#' Log chunk information as a table
#'
#' Turns the log information returned by [convert()] into a pretty
#' table, showing relative input/output paths and row counts.
#'
#' @param log A tibble returned by [convert()], with columns
#'   `input_path`, `output_path`, and `row_count`.
#'
#' @returns `log` invisibly.
#'
#' @export
#' @examples
#' sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
#' conversion_log <- convert(sas_file, output_dir = fs::path_temp("output"))
#' print_log_row_count(conversion_log)
print_log_row_count <- function(log) {
  log |>
    dplyr::mutate(
      dplyr::across(c("input_path", "output_path"), fs::path_rel)
    ) |>
    dplyr::select("input_path", "output_path", "row_count") |>
    knitr::kable() |>
    print()

  invisible(log)
}


#' Print log schema comparison
#'
#' Prints the log schema information in a section that compares the schemas
#' within one register. Finds the most common schema and if there's differences
#' between schemas, it prints these differences.
#'
#' @param register_log A tibble returned by [convert()], filtered to only
#'   contain rows from a single register.
#'
#' @returns register_log invisibly.
#'
#' @export
#' @examples
#' sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
#' log <- convert(sas_file, output_dir = fs::path_temp("output"))
#' print_log_schema(log)
print_log_schema <- function(register_log) {
  file_schemas <- register_log |>
    # Only keep first chunk per file.
    dplyr::slice_head(n = 1, by = "input_path") |>
    dplyr::mutate(
      input_file = fs::path_file(.data$input_path) |> fs::path_ext_remove()
    ) |>
    dplyr::select(c("input_file", "schema"))

  # If two schemas occur with the same frequency, only one is chosen as ref.
  reference <- dplyr::count(file_schemas, .data$schema) |>
    dplyr::slice_max(.data$n, with_ties = FALSE)
  # Get schema tibble, instead of list.
  reference_schema <- reference$schema[[1]]
  n_reference <- reference$n
  n_total <- nrow(file_schemas)
  has_diffs <- n_reference < n_total

  # Prepare schema difference lines.
  description <- "All files in this register share the same schema."
  schema_differences <- ""
  if (has_diffs) {
    description <- glue::glue(
      "The most common schema occurs in {n_reference}/{n_total} files."
    )

    schema_differences <- c(
      "### Schema differences",
      "",
      "Files with schemas differing from the most common (only showing differing columns):",
      "",
      get_schema_diffs(file_schemas, reference_schema) |>
        chunk_diff_table() |>
        purrr::map_chr(collapse_kable)
    )
  }

  lines <- c(
    # Description.
    description,
    # Reference schema.
    collapse_kable(reference_schema),
    # Schema differences.
    schema_differences
  )
  cat(glue::glue_collapse(lines, sep = "\n\n"), "\n")

  invisible(register_log)
}

#' @noRd
collapse_kable <- function(table) {
  glue::glue_collapse(knitr::kable(table), "\n")
}


#' Get schema differences
#'
#' @param schema_log The register log with the schemas.
#' @param reference_schema The most common schema.
#'
#' @returns A wide-format tibble with the files and columns that differ from the
#'   reference schema.
#'
#' @keywords internal
#' @noRd
get_schema_diffs <- function(schema_log, reference_schema) {
  diffs <- dplyr::anti_join(
    schema_log,
    tibble::tibble(schema = list(reference_schema))
  )

  diffs |>
    tidyr::unnest("schema") |>
    # Complete with column names from the reference schema in case the diffs
    # are missing any columns.
    tidyr::complete(
      .data$input_file,
      column_name = unique(c(column_name = reference_schema$column_name))
    ) |>
    # Pivot so file names are columns.
    tidyr::pivot_wider(names_from = "input_file", values_from = "data_type") |>
    # Add reference data_type column.
    dplyr::left_join(reference_schema, by = "column_name") |>
    # Keep only schema columns where at least one file has a different type or
    # is missing the column.
    dplyr::filter(
      dplyr::if_any(
        c(-"column_name", -"data_type"),
        \(col_type) {
          is.na(.data$data_type) | is.na(col_type) | col_type != .data$data_type
        }
      )
    ) |>
    dplyr::select(-"data_type")
}


#' Chunk table with schema differences
#'
#' @param diff_table The tibble output by `get_schema_diffs()`.
#' @param max_file_cols The maximum number of files to include in the table
#'   column. If there's more files than this, the tibble will be chunked into
#'   multiple tables for printing purposes.
#'
#' @returns A list of tibble(s).
#'
#' @keywords internal
#' @noRd
chunk_diff_table <- function(diff_table, max_file_cols = 6L) {
  file_cols <- names(diff_table) |> setdiff("column_name")
  chunked_file_cols <- split(
    file_cols,
    ceiling(seq_along(file_cols) / max_file_cols)
  )
  purrr::map(chunked_file_cols, \(cols) {
    dplyr::select(diff_table, "column_name", dplyr::all_of(cols))
  })
}
