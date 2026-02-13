# Prepare data to be read.
register_name <- "kontakter"
kontakter_list <- simulate_register(register_name, c("", "2020"))
sas_path <- fs::path_temp("sas_kontakter")
save_as_sas(kontakter_list, sas_path)
sas_kontakter <- fs::dir_ls(sas_path)
output_dir <- fs::path_temp("output_dir")

# Use convert_register() for conversion
convert_register(path = sas_kontakter, output_dir = output_dir)

test_that("reading a single Parquet file works as expected", {
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

  expected_source_file <- stringr::str_subset(sas_kontakter, year)
  expected_data <- haven::read_sas(expected_source_file)

  expect_equal(
    # year col doesn't exist when only one file is read.
    actual_data |> dplyr::select(-"source_file"),
    expected_data
  )
  expect_all_equal(actual_data$source_file, expected_source_file)
})

test_that("reading partitioned Parquet register works as expected", {
  actual <- read_register(output_dir) |> dplyr::collect()

  expected <- purrr::map(sas_kontakter, \(path) haven::read_sas(path)) |>
    dplyr::bind_rows()
  expected_years <- get_year_from_filename(sas_kontakter)

  # Data is as expected (column names, data types, nrows)
  # Sort dataframes by cpr and dw_ek_kontakt to ensure consistent ordering,
  # and use ignore_attr = TRUE to ignore row.names differences.
  expect_equal(
    actual |>
      dplyr::select(-c("source_file", "year")) |>
      dplyr::arrange(cpr, dw_ek_kontakt),
    expected |>
      dplyr::arrange(cpr, dw_ek_kontakt),
    ignore_attr = TRUE
  )

  # source_file column.
  expect_equal(
    sort(unique(actual$source_file)),
    # Convert sas_kontakter to character, otherwise it's an fs_path.
    sort(as.character(sas_kontakter))
  )
  # year column.
  expect_equal(
    sort(unique(actual$year), na.last = TRUE),
    sort(unique(expected_years), na.last = TRUE)
  )
})

test_that("reading a non-existing Parquet register throws an error", {
  expect_error(
    read_register("/non/existing/path.parquet"),
    regexp = "not exist"
  )
  expect_error(read_register("/non/existing/directory/"), regexp = "not exist")
})

test_that("incorrect input type throws an error", {
  expect_error(read_register(123), regexp = "character")
  expect_error(
    read_register(c("path1.parquet", "path2.parquet")),
    regexp = "length 1"
  )
})

test_that("directory with no Parquet files returns error", {
  temp_empty_dir <- fs::path_temp("empty_dir")
  fs::dir_create(temp_empty_dir)

  expect_error(read_register(temp_empty_dir), temp_empty_dir)
})

test_that("non-Parquet file returns error", {
  temp_txt_file <- fs::path_temp("file.txt")
  fs::file_create(temp_txt_file)

  expect_error(read_register(temp_txt_file), temp_txt_file)
})
