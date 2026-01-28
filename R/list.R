#' List SAS registers in a directory
#'
#' This function lists all SAS register files (with the extension `.sas7bdat`
#' case-insensitively) in the specified directory and its subdirectories.
#'
#' @param path The path to the directory to search for SAS files.
#'
#' @returns A character vector of paths to the SAS files found.
#'
#' @export
#' @examples
#' list_sas_files(fs::path_package("registers2parquet", "extdata"))
list_sas_files <- function(path) {
  # Check input.
  checkmate::assert_directory(path)
  checkmate::assert_scalar(path)

  # List all SAS files in the directory and its subdirectories.
  # (?i) makes the regex case-insensitive.
  sas_files <- fs::dir_ls(
    path,
    regexp = "(?i).*\\.sas7bdat$",
    recurse = TRUE
  ) |>
    sort()

  if (length(sas_files) == 0) {
    cli::cli_abort("No SAS files found in {.path {path}}.")
  }

  sas_files
}

#' List Parquet registers in a directory
#'
#' This function lists all Parquet register files (with the extension `.parquet`
#' or `.parq` case-insensitively) in the specified directory and its
#' subdirectories.
#'
#' @param path The path to the directory to search for Parquet files.
#'
#' @returns A character vector of paths to the Parquet files found.
#'
#' @export
#' @examples
#' list_parquet_files(fs::path_package("registers2parquet", "extdata"))
list_parquet_files <- function(path) {
  # Check input.
  checkmate::assert_directory(path)
  checkmate::assert_scalar(path)

  # List all Parquet files in the directory and its subdirectories.
  # (?i) makes the regex case-insensitive.
  parquet_files <- fs::dir_ls(
    path,
    regexp = "(?i)\\.(parquet|parq)$",
    recurse = TRUE
  ) |>
    sort()

  if (length(parquet_files) == 0) {
    cli::cli_abort("No SAS files found in {.path {path}}.")
  }

  parquet_files
}
