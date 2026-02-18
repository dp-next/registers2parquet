# Setup ------------------------------------------------------------------------
register_name <- "bef"
bef_list <- simulate_register(register_name, c("", "2020"))
sas_path <- fs::path_temp("sas_bef")
save_as_sas(bef_list, sas_path)
sas_bef <- fs::dir_ls(sas_path)
output_dir <- fs::path_temp("output_dir")

# Use convert_register() for conversion
convert_register(path = sas_bef, output_dir = output_dir)

# Test read_register() ---------------------------------------------------------

test_that("read_register() reads a single Parquet file", {
  # Read single Parquet file (2020 file).
  # Because UUID is used in the convert function, we can't know the name of the
  # file.
  year <- "2020"
  actual_data <- read_register(fs::dir_ls(fs::path(
    output_dir,
    register_name,
    glue::glue("year={year}")
  ))) |>
    dplyr::collect()

  expected_source_file <- stringr::str_subset(sas_bef, year)
  expected_data <- haven::read_sas(expected_source_file)

  expect_equal(
    # year col doesn't exist when only one file is read.
    actual_data |> dplyr::select(-"source_file"),
    expected_data
  )
  expect_all_equal(actual_data$source_file, expected_source_file)
})

test_that("read_register() reads a partitioned Parquet register", {
  actual <- read_register(output_dir) |> dplyr::collect()

  expected <- purrr::map(sas_bef, \(path) haven::read_sas(path)) |>
    dplyr::bind_rows()
  expected_years <- get_year_from_filename(sas_bef)

  # Data is as expected (column names, data types, nrows)
  # Sort dataframes by koen and pnr to ensure consistent ordering,
  # and use ignore_attr = TRUE to ignore row.names differences.
  expect_equal(
    actual |>
      dplyr::select(-c("source_file", "year")) |>
      dplyr::arrange(koen, pnr),
    expected |>
      dplyr::arrange(koen, pnr),
    ignore_attr = TRUE
  )

  # source_file column.
  expect_equal(
    sort(unique(actual$source_file)),
    # Convert sas_bef to character, otherwise it's an fs_path.
    sort(as.character(sas_bef))
  )
  # year column.
  expect_equal(
    sort(unique(actual$year), na.last = TRUE),
    sort(unique(expected_years), na.last = TRUE)
  )
})

test_that("read_register() errors when path does not exist", {
  expect_error(
    read_register("/non/existing/path.parquet"),
    regexp = "not exist"
  )
  expect_error(read_register("/non/existing/directory/"), regexp = "not exist")
})

test_that("read_register() errors with incorrect input type", {
  expect_error(read_register(123), regexp = "string")
  expect_error(
    read_register(c("path1.parquet", "path2.parquet")),
    regexp = "length 1"
  )
})

test_that("read_register() errors when directory has no Parquet files", {
  temp_empty_dir <- fs::path_temp("empty_dir")
  fs::dir_create(temp_empty_dir)

  expect_error(read_register(temp_empty_dir), temp_empty_dir)
})

test_that("read_register() errors when file is not Parquet", {
  temp_txt_file <- fs::path_temp("file.txt")
  fs::file_create(temp_txt_file)

  expect_error(read_register(temp_txt_file), temp_txt_file)
})

test_that("files with extension .parq can also be read", {
  path <- fs::path_temp("file.parq")
  arrow::write_parquet(simulate_register("bef")[[1]], sink = path)
  expect_no_error(read_register(path))
})
