#' Convert register SAS file(s) and save to Parquet format
#'
#' @description
#' If multiple paths are given, the function looks for a year (4 digits) in the
#' file names to use the year as partition, see `vignettes("design")` for more
#' information about the partitioning. If a year is found, the data is saved
#' partitioned by year in the output directory, e.g.,
#' `path/to/register_name/year=2020/part-0.parquet`.
#'
#' If no year can be found or only one path is given, the data is converted
#' without partitioning and saved as a Parquet file with the name specified in
#' the output path. E.g., if output_path is `path/to/register`, the Parquet file
#' will be saved as `path/to/register.parquet`.
#'
#' If any duplicate rows are found from the same file, they are de-duplicated
#' before saving to Parquet. Rows that are almost identical across different files (e.g. different years) but that have a difference in values are kept,
#' as determining which is the correct value requires domain knowledge.
#'
#' @param path A character vector with the absolute path to the register SAS
#'    file(s).
#' @param output_path A character scalar with the path to the directory to save
#'    the output Parquet file to. Should include the register name as the last
#'    part of the path. E.g., `path/to/register_name/`.
#'
#' @returns Returns a character scalar with the path to the created Parquet
#'    file(s) (`output_path`), so it can be used in a [targets](https://books.ropensci.org/targets/) pipeline.
#'
#' @export
#' @examples
#' \dontrun{
#' convert_to_parquet(
#'   list_sas_registers(project_id="202020")),
#'   "output/path/to/register_name")
#' }
convert_to_parquet <- function(path, output_path) {
  # Initial checks.
  checkmate::assert_file_exists(path)
  checkmate::assert_character(path)
  checkmate::assert_character(output_path)
  checkmate::assert_scalar(output_path)

  # Read SAS files.
  data <- read_sas_files(path) |>
    # Remove duplicate rows, ignoring the source_file column.
    dplyr::distinct(dplyr::across(-"source_file"), .keep_all = TRUE) |>
    # Add year column if possible.
    add_year_col()
  # TODO: Might have to do some processing of the dates. If so, create a helper
  # function for this.
  # mutate(across(where(~inherits(.x, what = "date")), as.character))
  # mutate(across(where(lubridate::is.Date), as.character))

  # Write to Parquet, partitioned by year if year column exists.
  if (length(path) > 1 & any(colnames(data) == "year")) {
    fs::dir_create(fs::path(output_path))
    arrow::write_dataset(
      dataset = data,
      path = output_path,
      format = "parquet",
      partitioning = "year"
    )
  } else {
    output_path <- paste0(output_path, ".parquet")
    arrow::write_parquet(
      x = data,
      sink = output_path,
    )
  }

  # Success message.
  cli::cli_alert_success(
    "Successfully converted {.val {fs::path_file(path)}} to Parquet format and saved it in {.path {output_path}}."
  )

  output_path
}

#' Read SAS files
#'
#' This function reads one or more SAS files and adds a `source_file` column
#' indicating the file each row came from. This column is useful for tracking
#' the origin of the row when combining multiple files. It also ensures that
#' duplicate rows across different files are not removed during the
#' de-duplication step in `convert_to_parquet()`.
#'
#' @param path A character vector with the absolute path to the SAS file(s).
#'
#' @returns A data frame with the contents of the SAS file(s) plus a
#'    `source_file` column.
#' @keywords internal
read_sas_files <- function(path) {
  purrr::map(path, \(file_path) {
    haven::read_sas(file_path) |>
      dplyr::mutate(source_file = as.character(file_path))
  }) |>
    purrr::reduce(dplyr::full_join)
}

#' Add year column to data if possible
#'
#' @param data A data frame with a `source_file` column to extract year from.
#'
#' @returns A data frame with a year column added if the year could be
#'    determined.
#' @keywords internal
add_year_col <- function(data) {
  year <- get_year_from_col(data$source_file)

  next_year <- as.integer(format(Sys.Date(), "%Y")) + 1L
  if (all(!is.na(year) & year %in% 1969:next_year)) {
    data <- data |> dplyr::mutate(year = year)
  } else {
    cli::cli_alert_info(
      "Could not determine year from file name(s) {.path {unique(fs::path_file(data$source_file))}}. Will not partition by year."
    )
  }
  data
}

#' Get year from column values
#'
#' @param data_col A character vector with file paths to extract year from.
#'
#' @returns An integer vector with the extracted years, or `NA` if no year
#'    found.
#' @keywords internal
get_year_from_col <- function(data_col) {
  data_col |>
    get_filename_no_ext() |>
    stringr::str_extract("\\d{4,6}") |>
    stringr::str_extract("^\\d{4}") |>
    as.integer()
}
