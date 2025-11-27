#' Read a Parquet register
#'
#' If you want to read a partitioned Parquet register, provide the path to the
#' directory (e.g., `path/to/parquet/register/`).
#' If you want to read a single Parquet file, provide the path to the file
#' (e.g., `path/to/parquet/register.parquet`).
#'
#' @param path A character scalar with the path to the Parquet register.
#'
#' @returns The register as a DuckDB table.
#'
#' @export
#' @examples
#' \dontrun{
#' read_register("/path/to/parquet/register")
#' read_register("/path/to/parquet/register.parquet")
#' }
read_register <- function(
  path
) {
  # Check input.
  checkmate::assert_character(path)
  checkmate::assert_scalar(path)
  checkmate::assert(
    checkmate::check_file_exists(path),
    checkmate::check_directory_exists(path)
  )

  # If input path is a directory.
  if (fs::is_dir(path)) {
    data <- read_register_partition(path)
  } else {
    data <- read_register_file(path)
  }

  data
}


#' Read a partitioned Parquet register as DuckDB table
#'
#' @param dir_path A character scalar with the path to the Parquet register
#'    directory.
#'
#' @returns The register as a DuckDB table.
#'
#' @keywords internal
read_register_partition <- function(dir_path) {
  dir_path |>
    arrow::open_dataset(unify_schemas = TRUE) |>
    arrow::to_duckdb()
}

#' Read a Parquet file as DuckDB table
#'
#' @param file_path A character scalar with the path to the Parquet file.
#'
#' @returns The register as a DuckDB table.
#'
#' @keywords internal
read_register_file <- function(file_path) {
  file_path |>
    arrow::read_parquet() |>
    arrow::to_duckdb()
}
