#' List important paths for projects on DST
#'
#' @rdname paths
#' @name paths
#'
#' @param id The Project ID.
#' @param dir The directory name to get the path for.
#'
#' @examples
#' path_rawdata("708421")
#' path_population_file("708421")
#' path_grunddata_dir()
#' path_eksterne_dir()
#' path_parquet_dirs()
#' path_sas_formats()
NULL

path_sas_formats <- function() {
  fs::path(
    "e:",
    "Formatter",
    "SAS formatter i Danmarks Statistik",
    "TXT_filer",
    "Times_Personstatistik"
  )
}

path_parquet_external <- function(id = "708421") {
  path_parquet_dirs(id = id) |>
    stringr::str_subset("parquet-external")
}

path_parquet_registers <- function(id = "708421") {
  path_parquet_dirs(id = id) |>
    stringr::str_subset("parquet-registers")
}

path_parquet_dirs <- function(id = "708421") {
  path_workdata(id) |>
    path_subdir("cleaned-data") |>
    fs::dir_ls(regexp = "parquet-", type = "directory")
}

path_eksterne_dir <- function(id = "708421") {
  path_rawdata(id) |>
    path_subdir("Eksterne data")
}

path_grunddata_dir <- function(id = "708421") {
  path_rawdata(id) |>
    path_subdir("Grunddata")
}

path_population_file <- function(id = "708421") {
  path_rawdata(id) |>
    path_subdir("Population") |>
    fs::dir_ls(type = "file", recurse = TRUE) |>
    fs::file_info() |>
    dplyr::filter(modification_time == max(modification_time)) |>
    dplyr::pull(path)
}

path_rawdata <- function(id) {
  fs::path("e:", "rawdata", id)
}

path_workdata <- function(id) {
  fs::path("e:", "workdata", id)
}

path_subdir <- function(path, dir) {
  dir <- rlang::arg_match(dir, list_dirs(path))
  fs::path(path, dir)
}

list_dirs <- function(path) {
  path |>
    fs::dir_ls(type = "directory") |>
    fs::path_file()
}
