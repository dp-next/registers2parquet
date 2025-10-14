library(dplyr)

temp_sas_file <- fs::path_temp("test.sas7bdat")
temp_sas_file_year <- fs::path_temp("test2019.sas7bdat")
temp_parquet_file <- fs::path_temp("test.parquet")
temp_parquet_partition <- fs::path_temp("test", "year=2019", "part-0.parquet")


co2_prep <- CO2 |>
  mutate(across(where(is.factor), as.character)) |>
  as_tibble()

suppressWarnings(haven::write_sas(co2_prep, temp_sas_file))
suppressWarnings(haven::write_sas(co2_prep, temp_sas_file_year))
suppressMessages(sas_to_parquet(temp_sas_file, temp_parquet_file))
suppressMessages(sas_to_parquet(temp_sas_file_year, temp_parquet_partition))

test_that("conversion from SAS to Parquet happens correctly", {
  expect_true(fs::file_exists(temp_parquet_file))
  expect_true(fs::file_exists(temp_parquet_partition))
})

test_that("data types are properly converted (no years)", {
  actual <- arrow::read_parquet(temp_parquet_file) |>
    purrr::map_chr(class) |>
    sort()

  expected_columns <- purrr::map_chr(co2_prep, class) |>
    sort()

  # Same data types for columns
  expect_setequal(unname(actual), unname(expected_columns))

  # Same names
  expect_setequal(
    names(actual),
    names(expected_columns)
  )
})

test_that("data types are properly converted (with years)", {
  partition_dir <- temp_parquet_partition |>
    # Twice to go two levels up.
    fs::path_dir() |>
    fs::path_dir()

  actual <- arrow::open_dataset(
    partition_dir,
    unify_schemas = TRUE
  ) |>
    as_tibble() |>
    purrr::map_chr(class) |>
    sort()

  expected_columns <- co2_prep |>
    mutate(year = 2019L) |>
    purrr::map_chr(class) |>
    sort()

  # Same data types for columns
  expect_setequal(unname(actual), unname(expected_columns))

  # Same names
  expect_setequal(
    names(actual),
    names(expected_columns)
  )
})

test_that("argument types are correct", {
  expect_error(sas_to_parquet(
    rep(temp_sas_file, times = 2),
    rep(temp_parquet_file, times = 2)
  ))
  expect_error(sas_to_parquet(1, 1))
  expect_error(sas_to_parquet(fs::file_temp(), temp_parquet_file))

  expect_error(sas_to_parquet_with_year(fs::file_temp(), temp_parquet_file))
  expect_error(sas_to_parquet_year(1, 1))
  expect_error(sas_to_parquet_year(
    rep(temp_sas_file_year, times = 2),
    rep(temp_parquet_file, times = 2)
  ))
})
