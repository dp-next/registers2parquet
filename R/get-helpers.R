#' Get the years from the external database's name of the file path.
#'
#' Only for the external raw data files.
#' Only years with four digits (e.g., 2025, 1990) are recognised as years.
#' Digits like 25 and 90 are not recognised as years and will not be included.
#'
#' @param database_name The name of the database taken from the file path.
#'
#' @returns A character vector of years.

#' @export
#' @examples
#' \dontrun{
#' get_database_year_external("path/to/external/database2025.csv")
#' }
get_database_year_external <- function(path) {
  path |>
    get_filename_no_ext() |>
    stringr::str_match_all("\\d{4}") |>
    purrr::map_chr(
      ~ {
        if (length(.x[, 1]) == 0) {
          NA
        } else if (nrow(.x) == 1) {
          .x[1, 1]
        } else if (.x[1, 1] == .x[2, 1]) {
          .x[1, 1]
        } else {
          cli::cli_warn(
            "A database has different years: {.val {.x[1, 1]}} vs {.val {.x[2, 2]}}. Using NA instead."
          )
          NA
        }
      }
    )
}

#' Get the year of database from the file name
#'
#' This function extracts the year of the database from the file name.
#'
#' @param path Path to the database file.
#'
#' @returns An integer with the year.
#'
#' @export
#' @examples
#' get_database_year("path/to/database2025.sas")
get_database_year <- function(path) {
  path |>
    get_filename_no_ext() |>
    stringr::str_extract("\\d{4,6}") |>
    stringr::str_extract("^\\d{4}") |>
    as.integer()
}

#' Get the year of the parquet file from the file name
#'
#' This function extracts the year of the database from the file name.
#'
#' @param path Path to the parquet file.
#'
#' @returns An integer with the year.
#'
#' @export
#' @examples
#' get_parquet_year("path/to/year=2025/file.parquet")
get_parquet_year <- function(path) {
  path |>
    stringr::str_extract("year=\\d{4}.*\\.parquet") |>
    stringr::str_extract("\\d{4}") |>
    as.integer()
}

#' Get the name of the database from the file name
#'
#' @param path Path to the database file.
#'
#' @returns A character with the database name.
#'
#' @export
#' @examples
#' get_database_name("path/to/database.ext")
get_database_name <- function(path) {
  path |>
    get_filename_no_ext() |>
    stringr::str_remove("\\d.*$")
}

#' Get the filename without its file extension
#'
#' @param path Path to the file.
#'
#' @returns A character with the filename without a file extension.
#'
#' @export
#' @examples
#' get_filename_no_ext("path/to/file name.ext")
get_filename_no_ext <- function(path) {
  path |>
    fs::path_file() |>
    fs::path_ext_remove()
}


# Are functions below used anywhere? Should they be removed? :fire:

#' Get paths with duplicate file names
#'
#' @param path Path to look for duplicate file names in.
#'
#' @returns A character with duplicate paths, an empty character if no duplicates.
#'
#' @export
#' @examples
#' get_path_duplicates(c("path/duplicate.parquet", "path/duplicate.parquet"))
#' get_path_duplicates(c("path/no/duplicate.parquet", "path/no/identical.parquet"))
get_path_duplicates <- function(path) {
  path_df <- path_as_df(path)

  duplicates <- path_df |>
    dplyr::count(file) |>
    dplyr::filter(n > 1)

  path_df |>
    dplyr::right_join(duplicates, by = "file") |>
    dplyr::arrange(file) |>
    dplyr::pull(path)
}

#' Get path with year in the file name
#'
#' @param path Path to to get if there's a year in the file name.
#'
#' @returns The path, if the file name contains a year.
#'
#' @export
#' @examples
#' get_path_with_year(c("path/with/year2025", "path/without/year"))
get_path_with_year <- function(path) {
  path[!is.na(get_database_year_external(path))]
}

#' Get path without year in the file name
#'
#' @param path Path to to get if there's not a year in the file name.
#'
#' @returns The path, if the file name doesn't contain a year.
#'
#' @export
#' @examples
#' get_path_with_year(c("path/with/year2025", "path/without/year"))
get_path_without_year <- function(path) {
  path[is.na(get_database_year_external(path))]
}

#' Get paths with no duplicate file names
#'
#' @param path Path to look for non-duplicate file names in.
#'
#' @returns A character with unique paths, an empty character if duplicates.
#'
#' @export
#' @examples
#' get_path_no_duplicates(c("path/duplicate.parquet", "path/duplicate.parquet"))
#' get_path_no_duplicates(c("path/no/duplicate.parquet", "path/no/identical.parquet"))
get_path_no_duplicates <- function(path) {
  path_df <- tibble::tibble(
    path = path,
    file = fs::path_file(path)
  )

  no_duplicates <- path_df |>
    dplyr::count(file) |>
    dplyr::filter(n == 1)

  path_df |>
    dplyr::right_join(no_duplicates, by = "file") |>
    dplyr::arrange(file) |>
    dplyr::pull(path) |>
    sort()
}

#' Get path with specific database file
#'
#' @param path Path to get specific database from.
#' @param name Name of the specific database to look for.
#'
#' @returns A character containing a path with the specific database.
#'
#' @export
#' @examples
#' get_path_specific_database("path/to/bef2025.sas", "bef")
#' get_path_specific_database("path/to/bef2025.sas", "lpr2")
get_path_specific_database <- function(path, name) {
  stringr::str_subset(path, name)
}
