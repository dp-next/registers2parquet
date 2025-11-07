#' List all the SAS register databases recursively in a folder.
#'
#' @param dir Directory to list (recursively) all SAS database files (e.g. in
#'   `Grunddata/`).
#'
#' @return A character vector of file paths.
#' @export
#'
#' @examples
#'
#' list_sas_files(path_grunddata_dir())
#' list_sas_files(path_eksterne_dir())
#'
list_sas_files <- function(dir) {
  fs::dir_ls(dir, glob = "*.sas7bdat", recurse = TRUE) |>
    sort()
}

#' List all the Parquet database files recursively in a folder.
#'
#' @param dir Directory to list (recursively) all Parquet files.
#'
#' @return A character vector.
#' @export
#'
#' @examples
#'
#' list_parquet_files(path_parquet_dirs()[1])
#' list_parquet_files(path_parquet_dirs()[2])
#'
list_parquet_files <- function(dir) {
  fs::dir_ls(dir, glob = "*.parquet", recurse = TRUE) |>
    sort()
}

#' Lists all the cleaned Parquet databases in the `cleaned-data` folder.
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' list_databases()
list_databases <- function(full_path = FALSE) {
  database_paths <- path_parquet_dirs("708421") |>
    purrr::map(~ fs::dir_ls(.x, type = "directory")) |>
    unlist()

  if (!full_path) {
    database_paths <- fs::path_file(database_paths)
  }

  sort(database_paths)
}

#' List all the available misc Parquet databases.
#'
#' `r lifecycle::badge("deprecated")`
#'
#' @param full_path Whether to list the full path to the database.
#'
#' @return Vector of file paths.
#' @export
#'
list_misc_db <- function(full_path = FALSE) {
  lifecycle::deprecate_warn(
    when = "0.1.0",
    what = "list_misc_db()",
    with = "list_databases()"
  )
  list_databases()
}

#' List all the available registers.
#'
#' `r lifecycle::badge("deprecated")`
#'
#' @param full_path Whether to list the full path to the register.
#'
#' @return Vector of file paths.
#' @export
#'
list_registers <- function(full_path = FALSE) {
  lifecycle::deprecate_warn(
    when = "0.1.0",
    what = "list_registers()",
    with = "list_databases()"
  )
  list_databases()
}

list_massive_files <- function() {
  path_workdata("708421") |>
    path_subdir("cleaned-data") |>
    path_subdir("temporary") |>
    fs::dir_ls(glob = "*.csv")
}

# Helpers -----------------------------------------------------------------

path_as_df <- function(path) {
  tibble::tibble(
    path = path,
    file = fs::path_file(path)
  )
}

path_duplicates_as_list <- function(path) {
  path |>
    path_as_df() |>
    dplyr::group_split(file) |>
    purrr::map(~ dplyr::pull(.x, path))
}

#' Convert file path to end as a Parquet Partition.
#'
#' @inheritParams path_set_dir
#'
#' @return A character vector.
#' @keywords internal
#'
#' @examples
#' fs::file_temp(ext = ".sas7bdat") |> path_ext_set_parquet_partition()
path_ext_set_parquet_partition <- function(path) {
  path |>
    fs::path("part-0.parquet")
}

#' Alter the path of a file to a Parquet partition in another directory.
#'
#' @param path A file path.
#' @param output_dir New directory the file should be in.
#'
#' @return A character vector.
#' @keywords internal
#'
#' @examples
#' fs::file_temp(ext = ".sas7bdat") |> path_set_dir(fs::path_temp())
path_set_dir <- function(path, output_dir) {
  checkmate::assert_character(output_dir)
  checkmate::assert_scalar(output_dir)
  fs::path(output_dir, fs::path_file(path))
}

#' Convert file name of a path to end in `/year=YYYY`.
#'
#' To follow the Parquet partitioning style (`{input_path_dir}/year=####/`).
#'
#' @inheritParams path_set_dir
#'
#' @return A character vector.
#' @keywords internal
#'
#' @examples
#' fs::file_temp(pattern = "database2020-", ext = ".sas7bdat") |>
#'   path_alter_filename_year_as_dir()
path_alter_filename_year_as_dir <- function(path) {
  database_year <- get_database_year(path)
  fs::path(
    path_alter_filename_as_dir(path),
    glue::glue("year={database_year}")
  )
}

#' Convert file name of a path to end in `filename/`.
#'
#' @inheritParams path_set_dir
#'
#' @return A character vector.
#' @keywords internal
#'
#' @examples
#' fs::file_temp(pattern = "database", ext = ".sas7bdat") |>
#'   path_alter_filename_as_dir()
path_alter_filename_as_dir <- function(path) {
  database_name <- get_database_name(path)
  fs::path(
    fs::path_dir(path),
    database_name
  )
}

#' Change the path to represent a Parquet Partition in another directory.
#'
#' Converts the file path to the pattern:
#' `{output_dir}/{file_name}/part-0.parquet`, since this is the style used to
#' tell Parquet the file is part of a partition. This includes converting to a
#' year partition as `{output_dir}/{file_name}/style={year}/part-0.parquet`.
#'
#' @inheritParams path_set_dir
#'
#' @return A character vector.
#' @keywords internal
#'
#' @examples
#' fs::path_temp("database.sas7bdat") |>
#'   path_alter_to_output_parquet_partition(fs::path_temp("new-dir"))
#' fs::file_temp(pattern = "database2020-", ext = ".sas7bdat") |>
#'   path_alter_to_output_parquet_partition(fs::path_temp("new-dir"))
path_alter_to_output_parquet_partition <- function(path, output_dir) {
  path <- path |>
    path_set_dir(output_dir)

  years <- get_database_year(path)
  path <- dplyr::if_else(
    !is.na(years) & years %in% 1969:2030,
    path_alter_filename_year_as_dir(path),
    path_alter_filename_as_dir(path)
  )

  path |>
    path_ext_set_parquet_partition()
}

path_alter_to_cleaned_dir <- function(path, dir) {
  dir <- rlang::arg_match(dir, fs::path_file(path_parquet_dirs("708421")))
  output_dir <- path_parquet_dirs("708421") |>
    stringr::str_subset(dir)
  path |>
    path_alter_to_output_parquet_partition(output_dir)
}
