#' Path to SAS formats
#'
#' @returns Paths with SAS formats.
#'
#' @export
#' @examples
#' path_sas_formats()
path_sas_formats <- function() {
  fs::path(
    "e:",
    "Formatter",
    "SAS formatter i Danmarks Statistik",
    "TXT_filer",
    "Times_Personstatistik"
  )
}

#' Path to external Parquet files
#'
#' @param id The project ID.
#'
#' @returns Path to external Parquet files within the project.
#'
#' @export
#' @examples
#'\dontrun{
#' path_parquet_external()
#' }
path_parquet_external <- function(id = "708421") {
  path_parquet_dirs(id = id) |>
    stringr::str_subset("parquet-external")
}

#' Path to Parquet registers
#'
#' @param id The project ID.
#'
#' @returns Path to the Parquet registers within the project.
#'
#' @export
#' @examples
#' \dontrun{
#' path_parquet_registers()
#' }
path_parquet_registers <- function(id = "708421") {
  path_parquet_dirs(id = id) |>
    stringr::str_subset("parquet-registers")
}

#' Path to Parquet directory
#'
#' @param id The project ID.
#'
#' @returns Path to the Parquet directory.
#'
#' @export
#' @examples
#' \dontrun{
#' path_parquet_dirs()
#' }
path_parquet_dirs <- function(id = "708421") {
  path_workdata(id) |>
    path_subdir("cleaned-data") |>
    fs::dir_ls(regexp = "parquet-", type = "directory")
}

#' Path to external directory
#'
#' @param id The project ID.
#'
#' @returns Path to the external directory.
#'
#' @export
#' @examples
#' \dontrun{
#' path_eksterne_dir()
#' }
path_eksterne_dir <- function(id = "708421") {
  path_rawdata(id) |>
    path_subdir("Eksterne data")
}

#' Path to "grunddata" directory
#'
#' @param id The project ID.
#'
#' @returns Path to the "grunddata" directory within the project.
#'
#' @export
#' @examples
#' \dontrun{
#' path_grunddata_dir()
#' }
path_grunddata_dir <- function(id = "708421") {
  path_rawdata(id) |>
    path_subdir("Grunddata")
}

#' Path to population file
#'
#' @param id The project ID.
#'
#' @returns The path to the population file within the project.
#'
#' @export
#' @examples
#' \dontrun{
#' path_population_file()
#' }
path_population_file <- function(id = "708421") {
  path_rawdata(id) |>
    path_subdir("Population") |>
    fs::dir_ls(type = "file", recurse = TRUE) |>
    fs::file_info() |>
    dplyr::filter(.data$modification_time == max(.data$modification_time)) |>
    dplyr::pull(.data$path)
}

#' Path to rawdata directory
#'
#' @param id The project ID.
#'
#' @returns Path to the rawdata directory within the project.
#'
#' @export
#' @examples
#' path_rawdata(1)
path_rawdata <- function(id) {
  fs::path("e:", "rawdata", id)
}

#' Path to workdata directory
#'
#' @param id The project ID.
#'
#' @returns Path to the workdata directory within the project.
#'
#' @export
#' @examples
#' path_workdata(1)
path_workdata <- function(id) {
  fs::path("e:", "workdata", id)
}

#' Path to subdirectory
#'
#' @param path Path to return subdirectory of.
#' @param dir Subdirectory to add to path.
#'
#' @returns Path with given subdirectory of given path.
#'
#' @export
#' @examples
#' \dontrun{
#' path_subdir("rawdata", "cleaned")
#' }
path_subdir <- function(path, dir) {
  dir <- rlang::arg_match(dir, list_dirs(path))
  fs::path(path, dir)
}

#' List directories at given path
#'
#' @param path Path to list directories of.
#'
#' @returns A character with directories at given path.
#'
#' @export
#' @examples
#' \dontrun{
#' list_dirs("raw")
#' }
list_dirs <- function(path) {
  path |>
    fs::dir_ls(type = "directory") |>
    fs::path_file()
}
