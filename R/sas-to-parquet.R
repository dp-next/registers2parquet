#' Read the raw SAS database file and save to a Parquet format.
#'
#' Parquet is a format for saving data in an efficient way and that allows you
#' to easily import it either with `arrow::read_arrow()` function or with
#' any SQL-based language. In this case, I'm recommending using DuckDB
#' via `arrow::to_duckdb()` since it is a SQL language that is fast and is
#' designed for data analysis tasks.
#'
#' @param input_path The path to the raw SAS file.
#' @param output_path The path to save the Parquet file.
#'
#' @return Returns a character vector of the created Parquet files (from
#'   `output_path`), so as to be designed to work with targets.
#' @export
#'
sas_to_parquet <- function(input_path, output_path) {
  if (is.list(input_path)) {
    input_path <- unlist(input_path)
  }
  fs::file_exists(input_path)
  checkmate::assert_character(input_path)
  checkmate::assert_character(output_path)
  checkmate::assert_scalar(output_path)

  fs::dir_create(fs::path_dir(output_path))

  merged_data <- input_path |>
    purrr::map(haven::read_sas) |>
    purrr::reduce(dplyr::full_join)

  # When given a vector with duplicate files
  year <- get_database_year(input_path) |>
    unique()
  if (!is.na(year) & year %in% 1969:2030) {
    merged_data <- merged_data |>
      dplyr::mutate(year = year)
  }

  merged_data |>
    # TODO: Might have to do some processing of the dates.
    # mutate(across(where(~inherits(.x, what = "date")), as.character))
    # mutate(across(where(lubridate::is.Date), as.character))
    arrow::write_parquet(output_path)

  if (length(input_path) > 1) {
    cli::cli_alert_success("Finished merging and saving the duplicate {.val {fs::path_file(input_path)[1]}} files as a Parquet file.")
  } else {
    cli::cli_alert_success("Finished saving {.val {fs::path_file(input_path)}} as a Parquet file.")
  }

  output_path
}
