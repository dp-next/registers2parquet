#' Get the years from the external database's name of the file path.
#'
#' Only for the external raw data files.
#'
#' @param database_name The name of the database taken from the file path.
#'
#' @return A character vector of years.
#' @keywords internal
#'
get_database_year_external <- function(path) {
  path |>
    get_filename_no_ext() |>
    stringr::str_match_all("\\d{4}") |>
    purrr::map_chr(~ {
      if (length(.x[, 1]) == 0) {
        NA
      } else if (nrow(.x) == 1) {
        .x[1, 1]
      } else if (.x[1, 1] == .x[2, 1]) {
        .x[1, 1]
      } else {
        cli::cli_warn("A database has different years: {.val {.x[1, 1]}} vs {.val {.x[2, 2]}}. Using NA instead.")
        NA
      }
    })
}

get_database_year <- function(path) {
  path |>
    get_filename_no_ext() |>
    stringr::str_extract("\\d{4,6}") |>
    stringr::str_extract("^\\d{4}") |>
    as.integer()
}

get_parquet_year <- function(path) {
  path |>
    stringr::str_extract("year=\\d{4}.*\\.parquet") |>
    stringr::str_extract("\\d{4}") |>
    as.integer()
}

get_database_name <- function(path) {
  path |>
    get_filename_no_ext() |>
    stringr::str_remove("\\d.*$")
}

get_filename_no_ext <- function(path) {
  path |>
    fs::path_file() |>
    fs::path_ext_remove()
}

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

get_path_with_year <- function(path) {
  path[!is.na(get_database_year_external(path))]
}

get_path_without_year <- function(path) {
  path[is.na(get_database_year_external(path))]
}

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

get_path_specific_database <- function(path, name) {
  stringr::str_subset(path, name)
}
