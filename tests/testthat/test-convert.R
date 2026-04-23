# Setup ------------------------------------------------------------------------

# n = 11000 to test chunking logic.
register_name <- "bef"
bef_list <- simulate_register(
  register_name,
  year = c("", "1999_1", "1999_2", "2020")
)
sas_path <- fs::path_temp("sas_bef")
save_as_sas(bef_list, sas_path)
sas_bef <- fs::dir_ls(sas_path)

# Test convert_file() ----------------------------------------------------------

# Setup: Convert single file
single_file_path <- fs::path_temp("parquet_single_file")
single_file_output <- convert_file(
  path = sas_bef[[1]],
  output_dir = single_file_path
)
data_actual <- arrow::open_dataset(
  single_file_path,
  partitioning = arrow::hive_partition(year = arrow::int32())
) |>
  dplyr::as_tibble()
data_expected <- haven::read_sas(sas_bef[[1]])

test_that("convert_file() returns output_dir", {
  expect_equal(single_file_output, single_file_path)
})

test_that("convert_file() preserves source data and adds expected columns", {
  expect_equal(nrow(data_actual), nrow(data_expected))
  expect_identical(
    data_actual |> dplyr::select(-c("source_file", "year")),
    data_expected
  )
  expect_all_equal(
    data_actual$source_file,
    as.character(sas_bef[[1]])
  )
  expect_identical(
    purrr::map(
      data_actual |> dplyr::select(c("source_file", "year")),
      class
    ),
    list(source_file = "character", year = "integer")
  )
})

test_that("convert_file() creates parts with expected naming pattern", {
  actual <- fs::path_file(fs::dir_ls(
    single_file_path,
    recurse = TRUE,
    type = "file"
  ))
  expect_true(all(stringr::str_detect(actual, "^part-[a-f0-9]{6}\\.parquet$")))
})

test_that("convert_file() errors with incorrect input parameters", {
  # Incorrect path type.
  expect_error(
    convert_file(path = 1, output_dir = single_file_output),
    regexp = "character"
  )
  # Path must exist.
  expect_error(
    convert_file(path = fs::file_temp(), output_dir = single_file_output),
    regexp = "does not exist"
  )
  # Incorrect output_dir type.
  expect_error(
    convert_file(path = sas_bef[[1]], output_dir = 1),
    regexp = "string"
  )
  # output_dir must be scalar.
  expect_error(
    convert_file(
      path = sas_bef[[1]],
      output_dir = rep(single_file_output, times = 2)
    ),
    regexp = "length 1"
  )
  # Incorrect chunk size (lower than allowed).
  expect_error(
    convert_file(
      path = sas_bef[[1]],
      output_dir = single_file_output,
      chunk_size = 10L
    ),
    regexp = ">= 10000"
  )
})

test_that("convert_file() partitions by year based on file name", {
  expected <- fs::path(
    single_file_output,
    register_name,
    "year=__HIVE_DEFAULT_PARTITION__"
  )

  expect_true(fs::dir_exists(expected))
  # Same number of created files as input files.
  expect_length(
    fs::dir_ls(expected),
    1L
  )
})

test_that("convert_file() creates expected n parts when chunk_size < nrow", {
  chunks_path <- fs::path_temp("chunks_path")
  chunk_size <- 10000L
  sas_file <- sas_bef[[1]]

  convert_file(
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
