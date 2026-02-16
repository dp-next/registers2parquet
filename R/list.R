#' List SAS files in a directory
#'
#' Lists all SAS register files (with the extension `.sas7bdat`
#' case-insensitively) in the specified directory and its subdirectories.
#'
#' @param path Directory to search.
#'
#' @returns The path(s) to the found SAS file(s).
#'
#' @export
#' @examples
#' list_sas_files(fs::path_package("fastreg", "extdata"))
list_sas_files <- function(path) {
  # Check input.
  checkmate::assert_directory(path)
  checkmate::assert_string(path)

  # List all SAS files in the directory and its subdirectories.
  # (?i) makes the regex case-insensitive.
  sas_files <- fs::dir_ls(
    path,
    regexp = "(?i)\\.sas7bdat$",
    recurse = TRUE
  ) |>
    sort()

  if (length(sas_files) == 0) {
    cli::cli_abort("No SAS files found in {.path {path}}.")
  }

  sas_files
}

#' List Parquet files in a directory
#'
#' Lists all Parquet register files (with the extension `.parquet`
#' or `.parq` case-insensitively) in the specified directory and its
#' subdirectories.
#'
#' @inheritParams list_sas_files
#'
#' @returns The path(s) to the found Parquet file(s).
#'
#' @export
#' @examples
#' list_parquet_files(fs::path_package("fastreg", "extdata"))
list_parquet_files <- function(path) {
  # Check input.
  checkmate::assert_directory(path)
  checkmate::assert_string(path)

  # List all Parquet files in the directory and its subdirectories.
  # (?i) makes the regex case-insensitive.
  parquet_files <- fs::dir_ls(
    path,
    regexp = "(?i)\\.(parquet|parq)$",
    recurse = TRUE
  ) |>
    sort()

  if (length(parquet_files) == 0) {
    cli::cli_abort("No Parquet files found in {.path {path}}.")
  }

  parquet_files
}
