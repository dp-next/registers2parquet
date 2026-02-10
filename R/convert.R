#' Convert register SAS file(s) and save to Parquet format
#'
#' @description
#' This function reads one or more SAS files for a given register, and saves the
#' data in Parquet format. It expects the input SAS files to come from the same
#' register, e.g., different years of the same register. The function checks
#' that all files belong to the same register by comparing the alphabetic
#' characters in the file name(s).
#'
#' The function looks for a year (1900-2099) in the file
#' names in `path` to use the year as partition, see `vignette("design")`
#' for more information about the partitioning.
#'
#' If a year is found, the data is saved as a partition by year in the output
#' directory, e.g., `output_dir/year=2020/part-ad5b.parquet` (the ending being
#' a UUID). If no year is found in the file name, the data is saved in a
#' `year=__HIVE_DEFAULT_PARTITION__` partition, which is the standard Hive
#' convention for missing partition values.
#'
#' Because this function only converts one file at a time (in chunks) to be
#' able to handle larger-than-memory SAS files, duplicate rows across files are
#' not deduplicated.
#'
#' @param path A character vector of one or more paths to SAS file(s) for one
#'    register. See [list_sas_files()], which is a helper for this parameter.
#' @param output_dir A character scalar with the path to the directory to save
#'    the output Parquet file to. Should not include the register name as this
#'    will be extracted from `path`.
#' @param chunk_size An integer scalar indicating the number of rows to read
#'    at a time from the SAS files. Defaults to 10,000,000.
#'
#' @returns Returns a character scalar with the path to the created Parquet
#'    file(s) (`output_dir`) invisibly, so it can be used in a
#'    [targets](https://books.ropensci.org/targets/) pipeline.
#'
#' @export
#' @examples
#' sas_file_directory <- fs::path_package("fastreg", "extdata")
#' convert_to_parquet(
#'   path = list_sas_files(sas_file_directory),
#'   output_dir = fs::path_temp("path/to/output/")
#' )
convert_to_parquet <- function(
  path,
  output_dir,
  chunk_size = 10000000L
) {
  # Initial checks.
  checkmate::assert_character(path)
  checkmate::assert_file_exists(path)
  checkmate::assert_true(is_same_register(path))
  checkmate::assert_character(output_dir)
  checkmate::assert_scalar(output_dir)
  checkmate::assert_int(chunk_size, lower = 10000L)

  # Convert files.
  purrr::walk(
    path,
    \(p) convert_file_in_chunks(p, output_dir, chunk_size)
  )

  # Success message.
  cli::cli_alert_success(
    "Successfully converted {.val {fs::path_file(path)}} and saved it in {.path {output_dir}}."
  )

  invisible(output_dir)
}

#' Convert a single register SAS file to Parquet in chunks
#'
#' @param path A character scalar with the absolute path to a single SAS file.
#' @inheritParams convert_to_parquet
#'
#' @returns The input `path` (SAS file path) invisibly.
#'
#' @keywords internal
#' @noRd
convert_file_in_chunks <- function(
  path,
  output_dir,
  chunk_size = 10000000L
) {
  # Create partition path, if it doesn't exist.
  year <- get_year_from_filename(path)
  # Following the default `null_fallback` in arrow::hive_partition()
  # https://arrow.apache.org/docs/r/reference/hive_partition.html#arg-null-fallback.
  year_partition <- if (is.na(year)) "__HIVE_DEFAULT_PARTITION__" else year
  partition_path <- fs::path(
    output_dir,
    get_register_name(path),
    glue::glue("year={year_partition}")
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

  invisible(path)
}

#' Get year from file name
#'
#' The year is determined as the first four consecutive numbers starting with
#' 19 or 20 in the file name (i.e., years 1900-2099).
#'
#' @param path A character vector with file path to extract year from.
#'
#' @returns An integer vector with the extracted years, or NA if no year
#'    is found.
#'
#' @keywords internal
#' @noRd
get_year_from_filename <- function(path) {
  path |>
    fs::path_file() |>
    stringr::str_extract("(19|20)\\d{2}") |>
    as.integer()
}

#' Create UUID for partition part
#'
#' We're using shortened UUIDs instead of integers to avoid collisions when
#' converting registers in parallel.
#'
#' @returns A character scalar with a UUID with a length of 6.
#'
#' @keywords internal
#' @noRd
create_part_uuid <- function() {
  substr(uuid::UUIDgenerate(), 0, 6)
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
#' @noRd
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
#' @param data A data frame.
#'
#' @returns A data frame with column names converted to lower case.
#'
#' @keywords internal
#' @noRd
column_names_to_lower <- function(data) {
  dplyr::rename_with(data, tolower)
}

#' Check that all file paths are from the same register
#'
#' Checks that all register names (file names without any non-letters) in
#' `path` are identical, i.e., the registers have the same name.
#'
#' @param path A character vector of one or more paths to SAS register files.
#'
#' @returns A logical that's TRUE if all paths point to files from the
#'  same register, based on the file names.
#'
#' @keywords internal
#' @noRd
is_same_register <- function(path) {
  register_names <- get_register_names(path)

  length(unique(register_names)) == 1L
}
