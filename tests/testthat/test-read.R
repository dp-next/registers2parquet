# Prepare temp file without year.
temp_parquet_no_year <- fs::path_temp("test.parquet")

# Prepare temp files with year.
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
paths <- c(
  temp_parquet_no_year,
  temp_parquet_year_2019,
  temp_parquet_year_2020
)

# Prepare CO2 dataset with character columns instead of factors.
co2_df <- CO2 |>
  dplyr::mutate(dplyr::across(tidyselect::where(is.factor), as.character)) |>
  dplyr::as_tibble()

# Write as Parquet files.
fs::dir_create(fs::path_dir(paths))
purrr::map(paths, \(file_path) arrow::write_parquet(co2_df, file_path))


test_that("reading a Parquet register file works as expected", {
  actual <- read_register(temp_parquet_no_year)
  expected <- co2_df |> arrow::to_duckdb()

  expect_equal(
    dplyr::collect(actual),
    dplyr::collect(expected)
  )
})

test_that("reading a partitioned Parquet register works as expected", {
  # Go two levels up to get the register directory containing the partitioned Parquet files.
  actual <- read_register(
    temp_parquet_year_2019 |>
      fs::path_dir() |>
      fs::path_dir()
  )

  co2_df_2019 <- co2_df |> dplyr::mutate(year = 2019)
  co2_df_2020 <- co2_df |> dplyr::mutate(year = 2020)
  expected <- dplyr::bind_rows(co2_df_2019, co2_df_2020) |> arrow::to_duckdb()

  expect_equal(
    dplyr::collect(actual),
    dplyr::collect(expected)
  )
})

test_that("reading a non-existing Parquet register throws an error", {
  expect_error(read_register("/non/existing/path.parquet"))
  expect_error(read_register("/non/existing/directory/"))
})

test_that("incorrect input type throws an error", {
  expect_error(read_register(123))
  expect_error(read_register(c("path1.parquet", "path2.parquet")))
})
