#' Log chunk information as a table
#'
#' Turns the log information returned by [convert()] into a pretty
#' table, showing relative input/output paths and row counts.
#'
#' @param register_log A tibble returned by [convert()], filtered to only
#'   contain rows from a single register.
#'
#' @returns A `knitr_kable` table.
#'
#' @export
#' @examples
#' sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
#' conversion_log <- convert(sas_file, output_dir = fs::path_temp("output"))
#' log_as_table(conversion_log)
log_as_table <- function(register_log) {
  register_log |>
    dplyr::mutate(
      dplyr::across(c("input_path", "output_path"), fs::path_rel)
    ) |>
    dplyr::select("input_path", "output_path", "row_count") |>
    knitr::kable()
}


#' Log schema information
#'
#' Turns the log schema information into a section that compares the schemas
#' within one register. Finds the most common schema and if there's differences
#' between schemas, it reports these differences.
#'
#' @param register_log A tibble returned by [convert()], filtered to only
#'   contain rows from a single register.
#'
#' @returns A `s3` object `fastreg_schema` with the structure:
#'   - description: Character describing the schemas (diff or no diff).
#'   - reference_schema: Tibble with the most common schema.
#'   - diff_tables: A list with tibble(s) showing the columns that differ from
#'       the reference schema. If there's many files with schema differences,
#'       there will be multiple tables, for printing purposes.
#'
#' @importFrom rlang .data
#' @export
#' @examples
#' sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
#' conversion_log <- convert(sas_file, output_dir = fs::path_temp("output"))
#' log_schema(conversion_log)
log_schema <- function(register_log) {
  schema_log <- register_log |>
    # Only keep first chunk per file.
    dplyr::slice_head(n = 1, by = "input_path") |>
    dplyr::mutate(
      input_file = fs::path_file(.data$input_path) |> fs::path_ext_remove()
    ) |>
    dplyr::select(c("input_file", "schema"))

  # If two schemas occur with the same frequency, only one is chosen as ref.
  reference <- dplyr::count(schema_log, .data$schema) |>
    dplyr::slice_max(.data$n, with_ties = FALSE)
  reference_schema <- reference$schema[[1]] # Get schema tibble, instead of list.
  n_reference <- reference$n
  n_total <- nrow(schema_log)
  has_diffs <- n_reference < n_total

  structure(
    list(
      description = if (has_diffs) {
        glue::glue(
          "The most common schema occurs in {n_reference}/{n_total} files."
        )
      } else {
        "All files in this register share the same schema."
      },
      reference_schema = reference_schema,
      diff_tables = if (has_diffs) {
        get_schema_diffs(schema_log, reference_schema) |> chunk_diff_table()
      } else {
        list()
      }
    ),
    class = "fastreg_schema"
  )
}


#' Print method for the S3 class fastreg_schema
#'
#' @param schema The fastreg_schema returned by [log_schema()].
#' @param ... Not used; included for S3 method compatibility.
#'
#' @returns The schema invisibly.
#'
#' @export
#' @examples
#' sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
#' conversion_log <- convert(sas_file, output_dir = fs::path_temp("output"))
#' log_schema(conversion_log) |> print()
print.fastreg_schema <- function(schema, ...) {
  cat(schema$description, "\n\n")
  schema$reference_schema |>
    knitr::kable() |>
    print()
  if (length(schema$diff_tables) > 0) {
    cat("### Schema differences\n\n")
    cat(
      "The table below shows the files have a schema that differs from the most common schema, only showing the columns that differ:\n\n"
    )
    purrr::walk(schema$diff_tables, \(table) {
      table |>
        knitr::kable() |>
        print()
    })
  }

  invisible(schema)
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
    # Drop rows (column_names and data types) that match the reference schema.
    dplyr::anti_join(reference_schema, by = c("column_name", "data_type")) |>
    # Pivot so file names are columns.
    tidyr::pivot_wider(names_from = "input_file", values_from = "data_type")
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
