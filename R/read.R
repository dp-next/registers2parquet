#' Read a Parquet register
#'
#' If you want to read a partitioned Parquet register, provide the path to the
#' directory (e.g., `path/to/parquet/register/`).
#' If you want to read a single Parquet file, provide the path to the file
#' (e.g., `path/to/parquet/register.parquet`).
#'
#' @param path Path to a Parquet file or directory.
#'
#' @returns A DuckDB table.
#'
#' @export
#' @examples
#' read_register(fs::path_package(
#'   "fastreg",
#'   "extdata",
#'   "test.parquet"
#' ))
read_register <- function(
  path
) {
  # Check input.
  checkmate::assert_string(path)
  checkmate::assert(
    checkmate::check_file_exists(path),
    checkmate::check_directory_exists(path)
  )
  check_parquet_path(path)

  # If input path is a directory, read as partitioned Parquet register,
  # else read as Parquet file.
  if (fs::is_dir(path)) {
    read_register_partition(path)
  } else {
    read_register_file(path)
  }
}


#' Check whether path is to a Parquet file or directory with Parquet files.
#'
#' @inheritParams read_register
#'
#' @returns `path`, invisibly.
#'
#' @keywords internal
#' @noRd
check_parquet_path <- function(path) {
  if (
    fs::is_dir(path) &&
      length(fs::dir_ls(path, regexp = "\\.(parquet|parq)$", recurse = TRUE)) ==
        0
  ) {
    cli::cli_abort(
      "The path {.path {path}} does not contain any Parquet files."
    )
  } else if (
    fs::is_file(path) &&
      fs::path_ext(path) != "parquet" &&
      fs::path_ext(path) != "parq"
  ) {
    cli::cli_abort(
      "The path {.path {path}} must have a {.val .parquet} or {.val .parq} extension."
    )
  }
  invisible(path)
}

#' Read a partitioned Parquet register as DuckDB table
#'
#' @param path Path to a Parquet register directory.
#'
#' @inherit read_register return
#'
#' @keywords internal
#' @noRd
read_register_partition <- function(path) {
  path |>
    arrow::open_dataset(
      unify_schemas = TRUE,
      # Explicitly set type of partition to int32 to handle when year is
      # missing.
      partitioning = arrow::hive_partition(year = arrow::int32())
    ) |>
    arrow::to_duckdb()
}

#' Read a Parquet file as DuckDB table
#'
#' @param path Path to a Parquet file.
#'
#' @inherit read_register return
#'
#' @keywords internal
#' @noRd
read_register_file <- function(path) {
  path |>
    arrow::read_parquet() |>
    arrow::to_duckdb()
}
