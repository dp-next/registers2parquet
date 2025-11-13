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
