library(dplyr)
# Prepare paths to temporary files.
temp_sas_file <- fs::path_temp("test.sas7bdat")
temp_sas_file_year <- fs::path_temp("test2019.sas7bdat")
temp_parquet_file <- fs::path_temp("test.parquet")
temp_parquet_partition <- fs::path_temp("test", "year=2019", "part-0.parquet")

co2_df <- CO2 |>
  mutate(across(where(is.factor), as.character)) |>
  as_tibble()

# Write temporary SAS files.
# Suppress warnings needed since write_sas() is deprecated.
suppressWarnings(haven::write_sas(co2_df, temp_sas_file))
suppressWarnings(haven::write_sas(co2_df, temp_sas_file_year))

# Convert SAS to Parquet. Used throughout the tests below.
sas_to_parquet(temp_sas_file, temp_parquet_file)
sas_to_parquet(temp_sas_file_year, temp_parquet_partition)

test_that("expected Parquet without year partition file exists after conversion", {
  expect_true(fs::file_exists(temp_parquet_file))
})

test_that("expected Parquet file with year partition exists after conversion", {
  expect_true(fs::file_exists(temp_parquet_partition))
})

test_that("column names and data types are properly converted without year partition", {
  actual <- arrow::read_parquet(temp_parquet_file) |>
    purrr::map_chr(class) |>
    sort()

  expected <- purrr::map_chr(co2_df, class) |>
    sort()

  # Same column names with same data types.
  expect_identical(actual, expected)
})

test_that("column names and data types are properly converted with year partition", {
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

  expected <- co2_df |>
    mutate(year = 2019L) |>
    purrr::map_chr(class) |>
    sort()

  # Same column names with same data types.
  expect_identical(actual, expected)
})

test_that("incorrect argument types generates errors", {
  # Non-character arguments.
  expect_error(sas_to_parquet(1, temp_parquet_file))
  expect_error(sas_to_parquet(temp_sas_file, 1))
  # Non-scalar output_path.
  expect_error(sas_to_parquet(
    temp_sas_file,
    rep(temp_parquet_file, times = 2)
  ))
})

test_that("input_path must exist", {
  expect_error(sas_to_parquet(fs::file_temp(), temp_parquet_file))
})
