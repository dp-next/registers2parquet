#' Convert a single register SAS file to Parquet
#'
#' To be able to handle larger-than-memory files, the SAS file is converted in
#' chunks. It does not check for existing files in the output directory.
#' Existing data will not be overwritten, but might be duplicated if it already
#' exists in the directory, since files are saved with UUIDs in their names.
#'
#' @param path Path to a single SAS file.
#' @param output_dir Directory to save the Parquet output to. Must not include
#'  the register name as this will be extracted from `path` to create the
#'  register folder.
#' @param chunk_size Number of rows to read and convert at a time.
#'
#' @returns A tibble with a conversion log about each written chunk.
#'
#' @export
#' @examples
#' sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
#' convert(
#'   path = sas_file,
#'   output_dir = fs::path_temp("path/to/output/file")
#' )
convert <- function(
  path,
  output_dir,
  chunk_size = 10000000L
) {
  # Initial checks.
  checkmate::assert_character(path)
  checkmate::assert_file_exists(path)
  checkmate::assert_string(output_dir)
  checkmate::assert_int(chunk_size, lower = 10000L)

  # Prepare variables used in repeat below.
  partition_path <- create_partition_path(path, output_dir)
  part <- create_part_uuid()
  skip <- 0 # Not integer (0L) since they overflow at ~2.1B rows, doubles don't.
  conversion_log <- tibble::tribble(~register_name, ~input_path, ~output_path, ~row_count, ~schema)

  # Read first chunk to establish schema.
  chunk <- read_sas_chunk(path, skip, chunk_size)
  schema <- create_arrow_schema(chunk)

  repeat {
    # Break when no more rows left.
    if (nrow(chunk) == 0) {
      break
    }

    file_path <- fs::path(
      partition_path,
      glue::glue("part-{part}.parquet")
    )
    chunk |>
      arrow::as_arrow_table(schema = schema) |>
      arrow::write_parquet(sink = file_path)

    # Add current chunk's info to list.
    conversion_log <- dplyr::bind_rows(
      conversion_log,
      tibble::tibble(
        register_name = get_register_name(path),
        input_path = path,
        output_path = fs::path(file_path),
        row_count = nrow(chunk),
        schema = list(tibble::tibble(
          column_name = colnames(chunk),
          data_type = purrr::map_chr(chunk, class)
        ))
      )
    )

    skip <- skip + nrow(chunk)
    part <- create_part_uuid()

    chunk <- read_sas_chunk(path, skip, chunk_size)
  }

  cli::cli_alert_success("Converted {.path {fs::path_file(path)}}")

  conversion_log
}

#' Read SAS chunk
#'
#' @param skip Number of rows to skip.
#' @inheritParams convert
#'
#' @returns A tibble.
#'
#' @keywords internal
#' @noRd
read_sas_chunk <- function(path, skip, chunk_size) {
  haven::read_sas(path, skip = skip, n_max = chunk_size) |>
    column_names_to_lower() |>
    dplyr::mutate(source_file = as.character(path))
}

#' Create partition path
#'
#' Gets the year and register name from the file name in `path` and creates
#' a partition path `{output_dir}/{register_name}/year={year}/`.
#'
#' @inheritParams convert
#'
#' @returns The partition path.
#'
#' @keywords internal
#' @noRd
create_partition_path <- function(path, output_dir) {
  year <- get_year_from_filename(path)
  # Following the default `null_fallback` in arrow::hive_partition()
  # https://arrow.apache.org/docs/r/reference/hive_partition.html#arg-null-fallback.
  year_partition <- dplyr::if_else(
    is.na(year),
    "__HIVE_DEFAULT_PARTITION__",
    as.character(year)
  )
  partition_path <- fs::path(
    output_dir,
    get_register_name(path),
    glue::glue("year={year_partition}")
  )
  fs::dir_create(partition_path, recurse = TRUE)
  partition_path
}

#' Get year from file name
#'
#' The year is determined as the first four consecutive numbers starting with
#' 19 or 20 in the file name (i.e., years 1900-2099).
#'
#' @param path A file path.
#'
#' @returns The year, or `NA` if no year is found.
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
#' @returns A 6-character UUID string.
#'
#' @keywords internal
#' @noRd
create_part_uuid <- function() {
  stringr::str_sub(uuid::UUIDgenerate(), start = 1, end = 6)
}

#' Create a consistent Arrow schema from a data frame
#'
#' Maps R types to specific Arrow types to ensure consistent schemas across
#' chunks and files.
#'
#' @param data A data frame to create the schema from.
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
#' @returns The data frame with lower case column names.
#'
#' @keywords internal
#' @noRd
column_names_to_lower <- function(data) {
  dplyr::rename_with(data, tolower)
}

#' Get the register names from file paths
#'
#' Removes all non-letters from the file names in `path`.
#'
#' @param path One or more file paths.
#'
#' @returns A character vector of register names.
#'
#' @keywords internal
#' @noRd
get_register_names <- function(path) {
  path |>
    fs::path_file() |>
    fs::path_ext_remove() |>
    # Remove everything that's not a letter.
    stringr::str_remove_all("[^[:alpha:]]")
}

#' Get register name from a group of file paths
#'
#' Extracts the register name from `path`.
#'
#' @param path Paths from the same register.
#'
#' @returns A single register name.
#'
#' @keywords internal
#' @noRd
get_register_name <- function(path) {
  register_name <- unique(get_register_names(path))

  if (length(register_name) > 1) {
    cli::cli_abort(c(
      "Multiple register names were found: {.val {register_name}}.",
      "i" = "Expected a single register name from {.path {path}}."
    ))
  }

  register_name
}
