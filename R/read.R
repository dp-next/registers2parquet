#' Read a Parquet register
#'
#' This function uses the options `fastreg.project_rawdata_dir` and
#' `fastreg.project_workdata_dir` when set in [options()] or will try to guess
#' the path by using the project ID and the base directories
#' `E:/<project-id>/rawdata/` and `E:/<project-id>/workdata/`. It only reads
#' Parquet datasets (those that are partitioned with the pattern `year=`). If
#' this function doesn't work, use [read_parquet_dataset()] or
#' [read_parquet_file()] instead.
#'
#' @param name Name of the Parquet dataset (i.e, the register name). See a list of available datasets with
#'   [list_parquet_datasets()].
#'
#' @returns A DuckDB table.
#'
#' @export
read_register <- function(
  name
) {
  checkmate::assert_string(name)
  dataset_paths <- list_parquet_datasets()
  name <- rlang::arg_match(name, fs::path_file(dataset_paths))

  parquet_path <- dataset_paths |>
    fs::path_filter(regexp = glue::glue("/{name}$")) |>
    unique()

  if (length(parquet_path) > 1) {
    cli::cli_abort(
      c(
        "There seems to be multiple Parquet datasets with the same name but in different locations.",
        "i" = "The paths are: {.path {parquet_path}}.",
        "i" = "Use {.code list_parquet_datasets()} to see available datasets."
      )
    )
  }

  read_parquet_dataset(parquet_path)
}

#' Read a single Parquet file or a partitioned dataset as DuckDB table
#'
#' This is useful when the [read_register()] incorrectly guesses or can't find
#' the register.
#'
#' @name read_parquet
#' @rdname read_parquet
#' @param path Path to a directory with the Parquet files within or a path to a
#'   Parquet file.
#' @inherit read_register return
NULL

#' @describeIn read_parquet Reads a Parquet partitioned directory.
#' @export
read_parquet_dataset <- function(path) {
  checkmate::assert_string(path)
  checkmate::assert_directory_exists(path)
  assert_directory_not_empty(path)
  path |>
    arrow::open_dataset(
      unify_schemas = TRUE,
      # Explicitly set type of partition to int32 to handle when year is
      # missing.
      partitioning = arrow::hive_partition(year = arrow::int32())
    ) |>
    arrow::to_duckdb()
}

#' @describeIn read_parquet Reads a single Parquet file.
#' @export
read_parquet_file <- function(path) {
  checkmate::assert_string(path)
  checkmate::assert_file_exists(path)
  assert_is_parquet(path)
  path |>
    arrow::read_parquet() |>
    arrow::to_duckdb()
}

assert_is_parquet <- function(path) {
  if (!fs::path_ext(path) %in% c("parquet", "parq")) {
    cli::cli_abort(
      c(
        "The file {.path {path}} does not have a Parquet extension.",
        "i" = "Only files with extensions {.file .parquet} and {.file .parq} are supported."
      )
    )
  }
}

assert_directory_not_empty <- function(path) {
  if (length(fs::dir_ls(path, glob = "*.parquet", recurse = TRUE)) == 0) {
    cli::cli_abort(
      c(
        "The directory {.path {path}} does not contain any Parquet files.",
        "i" = "Did you mistype the path?"
      )
    )
  }
}
