# Setup ------------------------------------------------------------------------

# n = 11000 to test chunking logic.
bef_list <- simulate_registers_with_paths(
  "bef",
  years = c("", "1999_1", "1999_2", "2020")
)
sas_paths <- bef_list |>
  purrr::pwalk(write_to_sas)

# Test convert() ---------------------------------------------------------------

# Setup: Convert single file
single_file_path <- fs::path_temp("parquet_single_file")
output <- convert(
  path = sas_paths$output_path[1],
  output_dir = single_file_path
)

data_actual <- arrow::open_dataset(
  single_file_path,
  partitioning = arrow::hive_partition(year = arrow::int32())
) |>
  dplyr::as_tibble()

data_expected <- haven::read_sas(sas_paths$output_path[1]) |>
  dplyr::mutate(
    source_file = as.character(sas_paths$output_path[1]),
    year = NA_integer_
  )

test_that("convert() returns a tibble describing the written chunks", {
  expect_s3_class(output, "tbl_df")
  expect_equal(nrow(output), 1L)
  expect_equal(output$input_path, sas_paths$output_path[1])
  expect_true(fs::file_exists(output$output_path))
  expect_equal(output$row_count, nrow(data_expected))
})

test_that("convert() preserves source data and adds expected columns", {
  expect_equal(nrow(data_actual), nrow(data_expected))
  expect_identical(data_actual, data_expected)
  expect_identical(
    purrr::map(
      data_actual |> dplyr::select("year"),
      class
    ),
    list(year = "integer")
  )
})

test_that("convert() creates parts with expected naming pattern", {
  actual <- fs::path_file(fs::dir_ls(
    single_file_path,
    recurse = TRUE,
    type = "file"
  ))
  expect_true(all(stringr::str_detect(actual, "^part-[a-f0-9]{6}\\.parquet$")))
})

test_that("convert() errors with incorrect input parameters", {
  # Incorrect path type.
  expect_error(
    convert(path = 1, output_dir = single_file_path),
    regexp = "character"
  )
  # Path must exist.
  expect_error(
    convert(path = fs::file_temp(), output_dir = single_file_path),
    regexp = "does not exist"
  )
  # Incorrect output_dir type.
  expect_error(
    convert(path = sas_paths$output_path[1], output_dir = 1),
    regexp = "string"
  )
  # output_dir must be scalar.
  expect_error(
    convert(
      path = sas_paths$output_path[1],
      output_dir = rep(single_file_path, times = 2)
    ),
    regexp = "length 1"
  )
  # Incorrect chunk size (lower than allowed).
  expect_error(
    convert(
      path = sas_paths$output_path[1],
      output_dir = single_file_path,
      chunk_size = 10L
    ),
    regexp = ">= 10000"
  )
})

test_that("convert() partitions by year based on file name", {
  expected <- fs::path(
    single_file_path,
    "bef",
    "year=__HIVE_DEFAULT_PARTITION__"
  )

  expect_true(fs::dir_exists(expected))
  # Same number of created files as input files.
  expect_length(
    fs::dir_ls(expected),
    1L
  )
})

test_that("convert() creates expected n parts when chunk_size < nrow", {
  chunks_path <- fs::path_temp("chunks_path")
  chunk_size <- 10000L
  sas_file <- sas_paths$output_path[1]

  convert(
    path = sas_file,
    output_dir = chunks_path,
    chunk_size = chunk_size
  )

  n_expected <- ceiling(nrow(haven::read_sas(sas_file)) / chunk_size)
  n_actual <- length(fs::dir_ls(
    chunks_path,
    recurse = TRUE,
    type = "file"
  ))
  expect_equal(n_actual, n_expected)
})


test_that("convert()'s skip doesn't become NA when passing the 32-bit integer limit", {
  chunk_size <- 1073741824L # Two chunks exceed 32 bit integer max (2,147,483,647).
  total_rows <- 2500000000

  # Replace read_sas_chunk so it returns an empty tibble that "reports" the
  # right number of rows.
  local_mocked_bindings(
    read_sas_chunk = function(path, skip, chunk_size) {
      # Return 0 rows if `skip` becomes NA to catch the expected integer
      # overflow with int32.
      rows_remaining <- if (is.na(skip)) 0 else total_rows - skip
      tibble::new_tibble(
        list(),
        nrow = as.integer(min(chunk_size, rows_remaining))
      )
    },
    .package = "fastreg"
  )

  result <- expect_no_warning(
    convert(
      path = sas_paths$output_path[1],
      output_dir = fs::path_temp("large_overflow_test"),
      chunk_size = chunk_size
    )
  )

  expect_equal(sum(result$row_count), total_rows)
})

test_that("read_sas_chunk() returns 0 rows when skip exceeds 32-bit limit", {
  # Passes on all operating systems now. Without the fix in read_sas_chunk() to
  # handle this, readstat overflows and starts to read from row 0 instead when
  # run on Windows (as observed on DST).
  path <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
  max_32_bit <- 2147483647
  chunk <- read_sas_chunk(
    path,
    skip = max_32_bit + 1,
    chunk_size = 1000L
  )
  expect_equal(nrow(chunk), 0L)
})

test_that("read_sas_chunk() returns 0 rows when skip is exactly the 32-bit limit", {
  # Was created to test that the overflow observed on Windows only happened when
  # skip exceeds the 32-bit limit.
  # The fix uses `>`, not `>=`, so skip = max_32_bit does not trigger it.
  # This returns 0 rows because the test file has fewer rows than max_32_bit.
  path <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
  max_32_bit <- 2147483647
  chunk <- read_sas_chunk(
    path,
    skip = 2147483647,
    chunk_size = 1000L
  )
  expect_equal(nrow(chunk), 0L)
})

test_that("read_sas_chunk() returns first chunk when skip is NA and empty tibble when skip exceeds the 32-bit limit", {
  # Should be the same on all operating systems now that we explicitly return an
  # empty tibble when skip exceeds 32-bit limit in read_sas_chunk().
  path <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
  max_32_bit <- 2147483647
  chunk_skip_na <- read_sas_chunk(
    path,
    skip = NA,
    chunk_size = 100L
  )
  chunk_skip_over_32_bit <- read_sas_chunk(
    path,
    skip = max_32_bit + 1,
    chunk_size = 100L
  )

  expect_equal(
    chunk_skip_na |> dplyr::select(-"source_file"),
    haven::read_sas(path, n_max = 100L)
  )
  expect_equal(nrow(chunk_skip_over_32_bit), 0L)
})

test_that("convert()'s conversion log handles data types with class vectors of length > 1", {
  df <- simulate_registers_with_paths("bef", n = 1000)

  # Change `foed_dato` to POSIXct (so class vector has len > 1, "POSIXct" *and* "POSIXt")
  df$data[[1]] <- df$data[[1]] |>
    dplyr::mutate(foed_dato = as.POSIXct(foed_dato))

  sas_path <- df |>
    purrr::pwalk(write_to_sas)

  result <- expect_no_error(convert(
    path = sas_path$output_path,
    output_dir = fs::path_temp("class-vector")
  ))

  foed_dato_type <- result$schema[[1]] |>
    dplyr::filter(column_name == "foed_dato") |>
    dplyr::pull(data_type) |>
    unname()

  expect_equal(foed_dato_type, "POSIXct")
})

test_that("convert() only keep lowercased letters and underscores in register names", {
  df <- simulate_registers_with_paths("bef", n = 10)
  df$output_path <- df$output_path |>
    fs::path_dir() |>
    fs::path("r€EGI-s$ ter_NAME.sas7bdat")

  sas_path <- df |>
    purrr::pwalk(write_to_sas)

  result <- expect_no_error(convert(
    path = sas_path$output_path,
    output_dir = fs::path_temp("register-name")
  ))

  expect_equal(result$register_name, "register_name")
})
