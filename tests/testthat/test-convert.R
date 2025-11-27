# Prepare temp file without year.
temp_sas_file_no_year <- fs::path_temp("test.sas7bdat")
temp_parquet_file_no_year <- fs::path_temp("test.parquet")
temp_output_no_year <- fs::path_temp("test")

# Prepare temp files with year.
temp_sas_file_year_2019 <- fs::path_temp("test_year2019.sas7bdat")
temp_sas_file_year_2020 <- fs::path_temp("test_year2020.sas7bdat")
temp_parquet_year_2019 <- fs::path_temp(
  "test_year",
  "year=2019",
  "part-0.parquet"
)
temp_parquet_year_2020 <- fs::path_temp(
  "test_year",
  "year=2020",
  "part-0.parquet"
)
temp_output_year <- fs::path_temp("test_year")

# Prepare CO2 dataset with character columns instead of factors.
co2_df <- CO2 |>
  # Add duplicate rows to test de-duplication.
  dplyr::bind_rows(CO2) |>
  dplyr::mutate(dplyr::across(tidyselect::where(is.factor), as.character)) |>
  dplyr::as_tibble()
co2_df_with_distinct_row <- co2_df |>
  tibble::add_row(
    Plant = "Unknown",
    Type = "Quebec",
    Treatment = "chilled",
    conc = 99,
    uptake = 99.9
  )

# Write temporary SAS files.
# Suppress warnings needed since write_sas() is deprecated.
suppressWarnings(haven::write_sas(co2_df, temp_sas_file_no_year))
suppressWarnings(haven::write_sas(co2_df, temp_sas_file_year_2019))
suppressWarnings(haven::write_sas(
  co2_df_with_distinct_row,
  temp_sas_file_year_2020
))

# Convert SAS to Parquet. Used throughout the tests below.
parquet_no_year <- convert_to_parquet(
  path = temp_sas_file_no_year,
  output_path = temp_output_no_year
)
parquet_year_partitioned <- convert_to_parquet(
  path = c(temp_sas_file_year_2019, temp_sas_file_year_2020),
  output_path = temp_output_year
)
parquet_year_not_partitioned <- convert_to_parquet(
  path = c(temp_sas_file_year_2019),
  output_path = temp_output_year
)

test_that("expected Parquet file without year in file name exists after conversion", {
  expect_true(fs::file_exists(parquet_no_year))
})

test_that("expected Parquet file with year exists after conversion when only one path is given", {
  expect_true(fs::file_exists(parquet_year_not_partitioned))
})

test_that("expected Parquet files with year partition exists after conversion", {
  expect_true(fs::dir_exists(temp_output_year))
  expect_true(fs::file_exists(temp_parquet_year_2019))
  expect_true(fs::file_exists(temp_parquet_year_2020))
})

test_that("column names and data types are properly converted without year partition", {
  actual <- arrow::read_parquet(parquet_no_year) |>
    purrr::map_chr(class)

  expected <- co2_df |>
    dplyr::mutate(
      source_file = as.character(parquet_no_year),
    ) |>
    purrr::map_chr(class)

  # Same column names with same data types.
  expect_identical(actual, expected)
})

test_that("column names and data types are properly converted with year partition", {
  actual <- arrow::open_dataset(
    temp_output_year,
    unify_schemas = TRUE
  ) |>
    dplyr::as_tibble() |>
    purrr::map_chr(class)

  expected <- co2_df |>
    dplyr::mutate(
      source_file = as.character(temp_output_year),
      year = 2019L
    ) |>
    purrr::map_chr(class)

  # Same column names with same data types.
  expect_identical(actual, expected)
})

test_that("duplicates are removed without year partition", {
  actual <- arrow::read_parquet(
    temp_parquet_file_no_year
  ) |>
    dplyr::as_tibble()

  expected <- co2_df |>
    dplyr::distinct()

  expect_true(nrow(actual) == nrow(expected))
})

test_that("duplicates are removed with year partition", {
  actual <- arrow::open_dataset(
    temp_output_year,
    unify_schemas = TRUE
  ) |>
    dplyr::as_tibble()

  expected_2019 <- co2_df |>
    dplyr::distinct()

  expect_true(
    nrow(actual |> dplyr::filter(year == 2019)) == nrow(expected_2019)
  )
  # Only one distinct row in 2020 file based on co2_df_with_distinct_row.
  expect_true(nrow(actual |> dplyr::filter(year == 2020)) == 1)
})

test_that("incorrect argument types generates errors", {
  # Non-character arguments.
  expect_error(convert_to_parquet(1, temp_parquet_file_no_year))
  expect_error(convert_to_parquet(temp_sas_file_no_year, 1))
  # Non-scalar output_path.
  expect_error(convert_to_parquet(
    temp_sas_file_no_year,
    rep(temp_parquet_file_no_year, times = 2)
  ))
})

test_that("input_path must exist", {
  expect_error(convert_to_parquet(fs::file_temp(), temp_parquet_file_no_year))
})
