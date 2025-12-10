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
#' read_register(fs::path_package(
#'   "registers2parquet",
#'   "extdata",
#'   "test_register.parquet"
#' ))
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
  if (
    fs::is_dir(path) &&
      length(fs::dir_ls(path, regexp = "\\.(parquet|parq)$", recurse = TRUE)) ==
        0
  ) {
    cli::cli_abort("The path {path} does not contain any Parquet files.")
  } else if (
    fs::is_file(path) &&
      fs::path_ext(path) != "parquet" &&
      fs::path_ext(path) != "parq"
  ) {
    cli::cli_abort(
      "The path {path} must have a `.parquet` or `.parq` extension."
    )
  }

  # If input path is a directory, read as partitioned Parquet register,
  # else read as Parquet file.
  if (fs::is_dir(path)) {
    read_register_partition(path)
  } else {
    read_register_file(path)
  }
}


#' Read a partitioned Parquet register as DuckDB table
#'
#' @param dir_path A character scalar with the path to the Parquet register
#'    directory.
#'
#' @inherit read_register return
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
#' @inherit read_register return
#'
#' @keywords internal
read_register_file <- function(file_path) {
  file_path |>
    arrow::read_parquet() |>
    arrow::to_duckdb()
}
