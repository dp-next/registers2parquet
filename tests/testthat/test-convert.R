# Prepare temp file without year in filename.
temp_sas_no_years <- c(
  fs::path_temp("test.sas7bdat"),
  fs::path_temp("test1.sas7bdat")
)
temp_output_no_year_one_file <- fs::path_temp("test_no_year_one_file")
temp_output_no_year <- fs::path_temp("test_no_year")

# Prepare temp files with year in filename.
temp_sas_years <- c(
  fs::path_temp("test_1999.sas7bdat"),
  fs::path_temp("test_2020.sas7bdat")
)
temp_output_multiple_years <- fs::path_temp("test_multiple_years")

# Prepare CO2 dataset with character columns instead of factors.
co2_df <- CO2 |>
  dplyr::mutate(dplyr::across(tidyselect::where(is.factor), as.character)) |>
  dplyr::as_tibble()

# Write temporary SAS files.
# Suppress warnings needed since write_sas() is deprecated.
suppressWarnings(haven::write_sas(co2_df, temp_sas_no_years[1]))
suppressWarnings(haven::write_sas(co2_df, temp_sas_no_years[2]))
suppressWarnings(haven::write_sas(co2_df, temp_sas_years[1]))
suppressWarnings(haven::write_sas(co2_df, temp_sas_years[2]))

# Convert SAS to Parquet.
output_no_years_one_file <- convert_to_parquet(
  paths = temp_sas_no_years[1],
  output_path = temp_output_no_year_one_file
)
output_no_years <- convert_to_parquet(
  paths = temp_sas_no_years,
  output_path = temp_output_no_year
)
output_multiple_years <- convert_to_parquet(
  paths = temp_sas_years,
  output_path = temp_output_multiple_years
)

# Open datasets.
actual_no_years_one_file <- arrow::open_dataset(
  output_no_years_one_file
) |>
  dplyr::as_tibble()

actual_no_years <- arrow::open_dataset(
  output_no_years
) |>
  dplyr::as_tibble()

actual_multiple_years <- arrow::open_dataset(
  output_multiple_years
) |>
  dplyr::as_tibble()

test_that("output is output_path", {
  expect_equal(output_no_years_one_file, temp_output_no_year_one_file)
  expect_equal(output_no_years, temp_output_no_year)
  expect_equal(output_multiple_years, temp_output_multiple_years)
})

test_that("files without year in filename are partitioned as expected", {
  # One input file.
  expected_path <- fs::path(temp_output_no_year_one_file, "year=NA")
  expect_true(fs::dir_exists(expected_path))
  expect_length(list.files(expected_path), 1)

  # Multiple input files.
  expected_path <- fs::path(temp_output_no_year, "year=NA")
  expect_true(fs::dir_exists(expected_path))
  expect_length(list.files(expected_path), 2) # One Parquet per input file.
})

test_that("files with year in filename are partitioned as expected", {
  expected_path_1999 <- fs::path(temp_output_multiple_years, "year=1999")
  expected_path_2020 <- fs::path(temp_output_multiple_years, "year=2020")

  expect_true(fs::dir_exists(expected_path_1999))
  expect_length(list.files(expected_path_1999), 1)
  expect_true(fs::dir_exists(expected_path_2020))
  expect_length(list.files(expected_path_2020), 1)
})

test_that("column names and data types are as expected", {
  actual_multi <- arrow::open_dataset(temp_output_multiple_years) |>
    dplyr::as_tibble() |>
    purrr::map_chr(class)

  expected <- co2_df |>
    dplyr::mutate(
      source_file = as.character(temp_sas_years[[1]]),
      year = 1999L
    ) |>
    dplyr::rename_with(tolower) |>
    purrr::map_chr(class)

  expect_identical(actual_multi, expected)
})

test_that("number of rows are as expected", {
  actual_no_years_one_file <- arrow::open_dataset(
    output_no_years_one_file
  ) |>
    dplyr::as_tibble() |>
    nrow()

  expected_nrow_one_file <- nrow(co2_df)
  expected_nrow_two_files <- expected_nrow_one_file * 2

  expect_equal(actual_no_years_one_file, expected_nrow_one_file)
  expect_equal(nrow(actual_no_years), expected_nrow_two_files)
  expect_equal(nrow(actual_multiple_years), expected_nrow_two_files)
})

test_that("incorrect parameters generate errors", {
  # Incorrect paths type.
  expect_error(convert_to_parquet(1, temp_output_multiple_years))
  # Incorrect output_path type.
  expect_error(convert_to_parquet(temp_sas_years[[1]], 1))
  expect_error(convert_to_parquet(
    temp_sas_years[[1]],
    rep(temp_output_multiple_years, times = 2)
  ))
  # Incorrect chunk size type (lower than allowed).
  expect_error(convert_to_parquet(
    temp_sas_no_years,
    temp_output_no_year_one_file,
    10L
  ))
  # Paths are not from the same register.
  temp_different_register <- fs::path_temp("other_2020.sas7bdat")
  suppressWarnings(haven::write_sas(co2_df, temp_different_register))
  expect_error(convert_to_parquet(
    c(temp_sas_years[[1]], temp_different_register),
    temp_output_multiple_years
  ))
})

test_that("files passed in the paths parameter must exist", {
  expect_error(convert_to_parquet(fs::file_temp(), temp_output_multiple_years))
})

test_that("parts are named correctly with chunked files", {
  temp_paths <- c(
    fs::path_temp(
      "test_chunks_1999.sas7bdat"
    ),
    fs::path_temp("test_chunks_2000.sas7bdat")
  )
  output_path <- fs::path_temp("output_chunks")
  df <- dplyr::bind_rows(
    co2_df,
    dplyr::slice_sample(co2_df, n = 10000, replace = TRUE)
  )
  suppressWarnings(haven::write_sas(df, temp_paths[[1]]))
  suppressWarnings(haven::write_sas(df, temp_paths[[2]]))

  convert_to_parquet(
    temp_paths,
    output_path,
    chunk_size = 10000L
  )

  files <- list.files(output_path, recursive = TRUE)

  # Check correct number of files per partition
  expect_length(files[grepl("^year=1999/", files)], 2)
  expect_length(files[grepl("^year=2000/", files)], 2)
})

test_that("mixed files with and without years are partitioned correctly", {
  output_path_mixed <- fs::path_temp("output_mixed")

  convert_to_parquet(
    c(temp_sas_no_years[[1]], temp_sas_years[[1]]),
    output_path_mixed
  )

  files <- list.files(output_path_mixed, recursive = TRUE)

  # Check correct number of files per partition
  expect_length(files[grepl("^year=1999/", files)], 1)
  expect_length(files[grepl("^year=NA/", files)], 1)

  # Verify data can be read and has correct row count
  result <- arrow::open_dataset(output_path_mixed) |>
    dplyr::as_tibble()
  expect_equal(nrow(result), nrow(co2_df) * 2)
})
