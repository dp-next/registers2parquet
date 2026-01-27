#' Convert register SAS file(s) and save to Parquet format
#'
#' @description
#' This function reads one or more SAS files for a given register, and saves the
#' data in Parquet format. It expects the input SAS files to come from the same
#' register, e.g., different years of the same register.
#'
#' If multiple paths are given, the function looks for a year (the first four
#' consecutive digits) in the file names to use the year as partition, see
#' `vignettes("design")` for more information about the partitioning. If a year
#' is found, the data is saved partitioned by year in the output directory,
#' e.g., `path/to/register_name/year=2020/part-ad5b.parquet` (the ending being an UUID). If no year is
#' found in the file name, the data is still partitioned with `year=NA`.
#'
#' Because this function only converts one file at a time (in chunks) to be
#' able to handle larger-than-memory SAS files, duplicate rows across files are
#' not deduplicated.
#'
#' @param paths A character vector with the absolute path to a SAS
#'    file or files for one register.
#' @param output_path A character scalar with the path to the directory to save
#'    the output Parquet file to. Should include the register name as the last
#'    part of the path. E.g., `path/to/register_name/`.
#' @param chunk_size An integer scalar indicating the number of rows to read
#'    at a time from the SAS files. Defaults to 10,000,000.
#'
#' @returns Returns a character scalar with the path to the created Parquet
#'    file(s) (`output_path`), so it can be used in a
#'    [targets](https://books.ropensci.org/targets/) pipeline.
#'
#' @export
#' @examples
#' \dontrun{
#' convert_to_parquet(
#'   list_sas_files("path/to/sas/files"),
#'   "output/path/to/register_name"
#' )
#' }
convert_to_parquet <- function(paths, output_path, chunk_size = 10000000L) {
  # Initial checks.
  checkmate::assert_character(paths)
  checkmate::assert_file_exists(paths)
  checkmate::assert_true(is_same_register(paths))
  checkmate::assert_character(output_path)
  checkmate::assert_scalar(output_path)
  checkmate::assert_int(chunk_size, lower = 10000L)

  # Convert files.
  purrr::walk(
    paths,
    \(path) convert_file_in_chunks(path, output_path, chunk_size)
  )

  # Success message.
  cli::cli_alert_success(
    "Successfully converted {.val {fs::path_file(paths)}} and saved it in {.path {output_path}}."
  )

  output_path
}


#' Convert a single register SAS file to Parquet in chunks
#'
#' @param path A character scalar with the absolute path to a single SAS file.
#' @inheritParams convert_to_parquet
#'
#' @returns Path to the partition.
#'
#' @keywords internal
convert_file_in_chunks <- function(path, output_path, chunk_size = 10000000L) {
  # Create partition path, if it doesn't exist.
  partition_path <- fs::path(
    output_path,
    glue::glue("year={get_year_from_filename(path)}")
  )
  fs::dir_create(partition_path, recurse = TRUE)

  # Prepare variables used in repeat below.
  part <- create_part_uuid()
  skip <- 0L

  # Read first chunk to establish schema.
  chunk <- haven::read_sas(path, skip = skip, n_max = chunk_size) |>
    column_names_to_lower() |>
    dplyr::mutate(source_file = as.character(path))
  schema <- create_arrow_schema(chunk)

  repeat {
    # Break when no more rows left.
    if (nrow(chunk) == 0) {
      break
    }

    chunk |>
      arrow::as_arrow_table(schema = schema) |>
      arrow::write_parquet(
        sink = fs::path(
          partition_path,
          glue::glue("part-{part}.parquet")
        )
      )

    skip <- skip + nrow(chunk)
    part <- create_part_uuid()

    chunk <- haven::read_sas(path, skip = skip, n_max = chunk_size) |>
      column_names_to_lower() |>
      dplyr::mutate(source_file = as.character(path))
  }

  invisible(partition_path)
}

#' Get year from file name
#'
#' The year is determined as the first four consecutive numbers starting with
#' 19 or 20 in the file name (i.e., years 1900-2099).
#'
#' @param file_path A character vector with file path to extract year from.
#'
#' @returns An integer vector with the extracted years, or NA if no year
#'    is found.
#'
#' @keywords internal
get_year_from_filename <- function(file_path) {
  file_path |>
    fs::path_file() |>
    stringr::str_extract("(19|20)\\d{2}") |>
    as.integer()
}

#' Create UUID for partition part
#'
#' We're using shortened UUIDs instead of integers to avoid collisions when
#' converting registers in parallel.
#'
#' @returns A character scalar with a UUID with a length of 4.
#'
#' @keywords internal
create_part_uuid <- function() {
  substr(uuid::UUIDgenerate(), 0, 4)
}

#' Create a consistent Arrow schema from a data frame
#'
#' Maps R types to specific Arrow types to ensure consistent schemas across
#' chunks and files.
#'
#' @param data A data frame to create a schema from.
#'
#' @returns An Arrow schema with consistent types.
#'
#' @keywords internal
create_arrow_schema <- function(data) {
  type_map <- function(x) {
    if (inherits(x, "POSIXt")) {
      return(arrow::timestamp(unit = "s"))
    }
    if (inherits(x, "Date")) {
      return(arrow::date32())
    }
    if (is.character(x)) {
      return(arrow::large_utf8())
    }
    if (is.integer(x)) {
      return(arrow::int32())
    }
    if (is.numeric(x)) {
      return(arrow::float64())
    }
    if (is.logical(x)) {
      return(arrow::boolean())
    }
    arrow::infer_type(x)
  }

  fields <- purrr::imap(data, \(col, name) arrow::field(name, type_map(col)))
  arrow::schema(fields)
}

#' Convert column names to lower case
#'
#' @param data A data frame type object.
#'
#' @returns The same object type given.
#' @keywords internal
column_names_to_lower <- function(data) {
  dplyr::rename_with(data, tolower)
}

#' Check that all paths are from the same register
#'
#' Removes all non-letters from the file names in paths and checks that the
#' remaining characters are identical, i.e., the registers have the same name.
#'
#' @param paths A character vector with paths to SAS registers.
#'
#' @returns A logical that's TRUE if all paths point to files from the same
#'  register, based on the file names.
#'
#' @keywords internal
is_same_register <- function(paths) {
  base_names <- paths |>
    fs::path_file() |>
    fs::path_ext_remove() |>
    # Remove everything that's not a letter.
    stringr::str_remove_all("[^[:alpha:]]")

  length(unique(base_names)) == 1L
}
