# Setup ------------------------------------------------------------------------
bef_list <- simulate_registers_with_paths("bef", c("", "2020"))
sas_paths <- bef_list |>
  purrr::pwalk(write_to_sas)
output_dir <- fs::path_temp("E/workdata/parquet-registers/")

# Convert files.
purrr::walk(sas_paths$output_path, \(path) {
  convert(path, output_dir)
})

# Test read_parquet_*() ---------------------------------------------------------

test_that("read_parquet_file() reads a single Parquet file", {
  # Read single Parquet file (2020 file).
  # Because UUID is used in the convert function, we can't know the name of the
  # file.
  year <- "2020"
  actual_data <- read_parquet_file(fs::dir_ls(fs::path(
    output_dir,
    "bef",
    glue::glue("year={year}")
  ))) |>
    dplyr::collect()

  expected_source_file <- stringr::str_subset(sas_paths$output_path, year)
  expected_data <- haven::read_sas(expected_source_file)

  expect_equal(
    # year col doesn't exist when only one file is read.
    actual_data |> dplyr::select(-"source_file"),
    expected_data,
    ignore_attr = TRUE
  )
  expect_all_equal(
    actual_data$source_file,
    expected_source_file
  )
})

test_that("read_parquet_dataset() reads a partitioned Parquet register", {
  actual <- read_parquet_dataset(output_dir) |> dplyr::collect()

  expected <- purrr::map(sas_paths$output_path, \(path) {
    haven::read_sas(path)
  }) |>
    dplyr::bind_rows()
  expected_years <- get_year_from_filename(sas_paths$output_path)

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
    # Convert sas paths to character, otherwise it's an fs_path.
    sort(as.character(sas_paths$output_path))
  )
  # year column.
  expect_equal(
    sort(unique(actual$year), na.last = TRUE),
    sort(unique(expected_years), na.last = TRUE)
  )
})

test_that("read_parquet_file() errors when path does not exist", {
  expect_error(
    read_parquet_file("/non/existing/path.parquet"),
    regexp = "not exist"
  )
  expect_error(
    read_parquet_dataset("/non/existing/directory/"),
    regexp = "not exist"
  )
})

test_that("read_parquet_file() errors with incorrect input type", {
  expect_error(read_parquet_file(123), regexp = "string")
  expect_error(
    read_parquet_file(c("path1.parquet", "path2.parquet")),
    regexp = "length 1"
  )
})

test_that("read_parquet_dataset() errors when directory has no Parquet files", {
  temp_empty_dir <- fs::path_temp("empty_dir")
  fs::dir_create(temp_empty_dir)

  expect_error(read_parquet_dataset(temp_empty_dir), temp_empty_dir)
})

test_that("read_parquet_file() errors when file is not Parquet", {
  temp_txt_file <- fs::path_temp("file.txt")
  fs::file_create(temp_txt_file)

  expect_error(read_parquet_file(temp_txt_file), temp_txt_file)
})

test_that("files with extension .parq can also be read", {
  path <- fs::path_temp("file.parq")
  arrow::write_parquet(
    simulate_registers_with_paths("bef")$data[[1]],
    sink = path
  )
  expect_no_error(read_parquet_file(path))
})


test_that("read_parquet_dataset() reads files with different columns", {
  # Faux bef with lmdb structure, saved separately and combined with sas paths
  sas_dir <- fs::path_temp("different_columns/sas")
  parquet_dir <- fs::path_temp("different_columns/parquet")
  register_diff_cols <- simulate_registers_with_paths(
    c("bef", "lmdb"),
    years = c("2021"),
    output_dir = sas_dir
  ) |>
    dplyr::mutate(
      output_path = stringr::str_replace(output_path, "lmdb2021", "bef2022")
    ) |>
    purrr::pwalk(write_to_sas)

  # Convert files.
  purrr::walk(register_diff_cols$output_path, \(path) {
    convert(path, parquet_dir)
  })

  # Define expected columns.
  expected <- register_diff_cols$data |>
    purrr::map(colnames) |>
    purrr::list_c() |>
    unique() |>
    append(c("source_file", "year"))

  expect_identical(
    sort(expected),
    sort(read_parquet_dataset(parquet_dir) |> colnames())
  )
})

test_that("read_parquet_dataset() errors with incompatible schemas", {
  # Create a bef file where numeric columns are changed to character, so
  # the schema is incompatible with the other bef files.
  incompatible_data <- bef_list$data[[1]] |>
    dplyr::mutate(dplyr::across(where(is.numeric), as.character))

  incompatible_sas_path <- fs::path_temp(
    "sas_schema_incompatible/bef2099.sas7bdat"
  )
  write_to_sas(incompatible_data, incompatible_sas_path)
  sas_incompatible <- c(
    sas_paths$output_path,
    incompatible_sas_path
  )

  incompatible_output <- fs::path_temp("incompatible")
  # Convert files.
  purrr::walk(sas_incompatible, \(path) {
    convert(path, incompatible_output)
  })

  expect_error(read_parquet_dataset(incompatible_output), "incompatible")
})

# Test read_register() ---------------------------------------------------------

test_that("read in a register", {
  withr::with_options(
    list(
      fastreg.project_rawdata_dir = fs::path_temp("E/rawdata/202020/"),
      fastreg.project_workdata_dir = fs::path_temp("E/workdata/202020/")
    ),
    {
      simulate_registers_with_paths(
        "bef",
        years = "2020",
        n = 10,
        output_dir = get_project_rawdata_dir()
      ) |>
        purrr::pwalk(write_to_sas)

      convert(
        get_project_rawdata_dir() |>
          list_sas_files(),
        get_project_workdata_dir()
      )

      expect_match(class(read_register("bef")), "duckdb", all = FALSE)
      expect_shape(dplyr::collect(read_register("bef")), nrow = 10)
      expect_error(
        # Warning about project id from internal `get_project_rawdata_dir()`.
        suppressWarnings(read_register("non_existing")),
        regexp = "`name` must be one of"
      )

      # Clean up
      fs::file_delete(list_sas_files(get_project_rawdata_dir()))
      fs::file_delete(list_parquet_files())
    }
  )
})
