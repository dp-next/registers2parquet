#' Load a specific Parquet database into the R session
#'
#' The loaded database will be converted into DuckDB so it can be used via
#' [arrow::to_duckdb()].
#'
#' @param name Name of the database to load.
#'
#' @returns The database as an Arrow dataset.
#' @export
#'
load_database <- function(name) {
  name <- rlang::arg_match(name, list_databases())
  register_paths <- stringr::str_subset(
    list_databases(full_path = TRUE),
    paste0("/", name, "$")
  )
  read_parquet_partition(register_paths)
}

# Register Parquet DB -----------------------------------------------------

#' Load a specific register into the R session
#'
#' `r lifecycle::badge("deprecated")`
#'
#' The loaded register will be converted into DuckDB so it can be used via
#' [arrow::to_duckdb()].
#'
#' @param name Name of the register to load.
#'
#' @returns The register dataset as an Arrow dataset.
#' @export
#'
load_register <- function(name) {
  lifecycle::deprecate_warn(
    when = "0.1.0",
    what = "load_register()",
    with = "load_database()"
  )
  load_database(name)
}

# Misc Parquet DB ---------------------------------------------------------

#' Load a specific misc database into the R session
#'
#' `r lifecycle::badge("deprecated")`
#'
#' The loaded database will be converted into DuckDB so it can be used via
#' [arrow::to_duckdb()].
#'
#' @param name Name of the register to load.
#'
#' @returns The register dataset as an Arrow dataset.
#' @export
#'
load_misc_db <- function(name) {
  lifecycle::deprecate_warn(
    when = "0.1.0",
    what = "load_misc_db()",
    with = "load_database()"
  )
  load_database(name)
}
