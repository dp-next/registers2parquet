# Tests with small test data --------------------------------------------------

# n = 11000 to test chunking logic.
kontakter_list <- simulate_register(
  "kontakter",
  year = c("", "1999_1", "1999_2", "2020")
)
sas_path <- fs::path_temp("sas_kontakter")
save_as_sas(kontakter_list, sas_path)
sas_kontakter <- fs::dir_ls(sas_path)
output_dir <- fs::path_temp("parquet_path")

# Convert SAS to Parquet.
actual_path <- convert_to_parquet(
  path = sas_kontakter,
  output_dir = output_dir
)

# Open Parquet dataset.
actual_data <- arrow::open_dataset(
  output_dir,
  partitioning = arrow::hive_partition(year = arrow::int32())
) |>
  dplyr::as_tibble()

# Read expected dataset from SAS files.
expected_data <- purrr::map(sas_kontakter, \(sas_file) {
  haven::read_sas(sas_file)
}) |>
  dplyr::bind_rows()

test_that("output is output_dir", {
  expect_equal(actual_path, output_dir)
})

test_that("files are partitioned as expected", {
  expected <- fs::path(
    output_dir,
    c("year=__HIVE_DEFAULT_PARTITION__", "year=1999", "year=2020")
  )

  expect_all_true(fs::dir_exists(expected))
  # Same number of created files as input files.
  expect_length(fs::dir_ls(expected), length(fs::dir_ls(sas_path)))
})

test_that("parts are named as expected", {
  actual <- fs::path_file(fs::dir_ls(output_dir, recurse = TRUE, type = "file"))
  expect_true(all(stringr::str_detect(actual, "^part-[a-f0-9]{6}\\.parquet$")))
})

test_that("column names, data types, and number of rows are as expected", {
  actual <- actual_data |> dplyr::select(-c("source_file", "year"))
  expect_identical(actual, expected_data)
  expect_identical(
    purrr::map(actual_data |> dplyr::select(c("source_file", "year")), class),
    list(source_file = "character", year = "integer")
  )
})

test_that("incorrect parameters generate errors", {
  # Incorrect path type.
  expect_error(
    convert_to_parquet(
      path = 1,
      output_dir = output_dir
    ),
    regexp = "character"
  )
  # Paths from different registers.
  temp_different_register <- fs::path_temp("other_2020.sas7bdat")
  suppressWarnings(haven::write_sas(
    kontakter_list[[1]],
    temp_different_register
  ))
  expect_error(
    convert_to_parquet(
      path = c(sas_kontakter, temp_different_register),
      output_dir = temp_output_multiple_years
    ),
    regexp = "is_same_register"
  )

  # Incorrect output_dir type.
  expect_error(
    convert_to_parquet(
      path = sas_kontakter,
      output_dir = 1
    ),
    regexp = "character"
  )
  expect_error(
    convert_to_parquet(
      path = sas_kontakter,
      output_dir = rep(output_dir, times = 2),
    ),
    regexp = "length 1"
  )
  # Incorrect chunk size type (lower than allowed).
  expect_error(
    convert_to_parquet(
      path = sas_kontakter,
      output_dir = output_dir,
      chunk_size = 10L
    ),
    regexp = ">= 10000"
  )
})

test_that("files passed in the paths parameter must exist", {
  expect_error(
    convert_to_parquet(
      path = fs::file_temp(),
      output_dir = output_dir
    ),
    regexp = "does not exist"
  )
})

test_that("n parts are as expected when chunk_size is less than nrow per file", {
  output_dir <- fs::path_temp("output_chunks")
  chunk_size <- 10000L
  convert_to_parquet(
    path = sas_kontakter,
    output_dir = output_dir,
    chunk_size = 10000L
  )

  n_expected <- sum(ceiling(purrr::map_int(kontakter_list, nrow) / chunk_size))
  n_actual <- length(fs::dir_ls(output_dir, recurse = TRUE, type = "file"))
  expect_equal(n_actual, n_expected)
})


# Tests with large internal data files ----------------------------------------

test_that("larger files with 1.1 million rows are converted as expected", {
  skip_on_cran()

  # n = 1.1 million to test chunking with chunk_size = 1 million.
  kontakter_list_large <- simulate_register(
    "kontakter",
    c("1999", "2020"),
    n = 1100000
  )
  sas_path_large <- fs::path_temp("sas_kontakter_large")
  save_as_sas(kontakter_list_large, sas_path_large)
  sas_kontakter_large <- fs::dir_ls(sas_path_large)
  output_dir_large <- fs::path_temp("parquet_path_large")
  chunk_size_large <- 1000000L

  convert_to_parquet(
    path = sas_kontakter_large,
    output_dir = output_dir_large,
    chunk_size = chunk_size_large
  )

  n_expected <- sum(ceiling(
    purrr::map_int(kontakter_list_large, nrow) / chunk_size_large
  ))
  n_actual <- length(fs::dir_ls(
    output_dir_large,
    recurse = TRUE,
    type = "file"
  ))
  expect_equal(n_actual, n_expected)
})
