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
#' # Returns an empty character vector as there are no SAS files in the extdata folder.
#' list_sas_registers(fs::path_package("registers2parquet", "extdata"))
list_sas_registers <- function(path) {
  # Check input.
  checkmate::assert_directory(path)
  checkmate::assert_scalar(path)

  # List all SAS files in the directory and its subdirectories.
  # (?i) makes the regex case-insensitive.
  fs::dir_ls(path, regexp = "(?i).*\\.sas7bdat$", recurse = TRUE) |>
    sort()
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
#' list_parquet_registers(fs::path_package(
#'   "registers2parquet",
#'   "extdata",
#' )))
list_parquet_registers <- function(path) {
  # Check input.
  checkmate::assert_directory(path)
  checkmate::assert_character(path, len = 1)

  # List all Parquet files in the directory and its subdirectories.
  # (?i) makes the regex case-insensitive.
  fs::dir_ls(path, regexp = "(?i)\\.(parquet|parq)$", recurse = TRUE) |>
    sort()
}
