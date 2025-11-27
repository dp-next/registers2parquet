#' Read an individual Parquet partitioned database
#'
#' @param dir The folder that holds the Parquet database.
#'
#' @return A DuckDB database connection.
#' @keywords internal
#'
read_parquet_partition <- function(dir) {
  checkmate::assert_scalar(dir)
  fs::dir_exists(dir)
  dir |>
    arrow::open_dataset(unify_schemas = TRUE) |>
    arrow::to_duckdb()
}
