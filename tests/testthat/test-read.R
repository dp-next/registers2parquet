# Prepare data to be read.
kontakter_list <- helper_create_simulated_kontakter(n = 1000)
file_paths <- paste0(names(kontakter_list), ".sas7bdat") |>
  fs::path_temp() |>
  as.character()
temp_output <- fs::path_temp("kontakter")

# Clean up any existing files from previous test runs.
if (fs::dir_exists(temp_output)) {
  fs::dir_delete(temp_output)
}

suppressWarnings(haven::write_sas(kontakter_list[[1]], file_paths[[1]]))
suppressWarnings(haven::write_sas(kontakter_list[[2]], file_paths[[2]]))
suppressWarnings(haven::write_sas(kontakter_list[[3]], file_paths[[3]]))

# Use convert_to_parquet() for conversion
convert_to_parquet(file_paths = file_paths, output_dir = temp_output)

test_that("reading a single Parquet file works as expected", {
  # Read single Parquet file (from SAS file without year in filename).
  # Because UUID is used in the convert function, we can't know the name of the
  # file.
  actual <- read_register(fs::dir_ls(fs::path(
    temp_output,
    "year=__HIVE_DEFAULT_PARTITION__"
  ))) |>
    dplyr::collect()

  expected <- haven::read_sas(file_paths[[1]])

  expect_equal(
    actual |> dplyr::select(-"source_file"),
    expected
  )
  expect_all_equal(actual$source_file, file_paths[[1]])
})

test_that("reading a partitioned Parquet register works as expected", {
  actual <- read_register(temp_output) |> dplyr::collect()

  expected <- purrr::map(file_paths, \(file_path) haven::read_sas(file_path)) |>
    dplyr::bind_rows()

  # Sort both dataframes by cpr and dw_ek_kontakt to ensure consistent ordering,
  # and use ignore_attr = TRUE to ignore row.names differences.
  expect_equal(
    actual |>
      dplyr::select(-c("source_file", "year")) |>
      dplyr::arrange(cpr, dw_ek_kontakt),
    expected |>
      dplyr::arrange(cpr, dw_ek_kontakt),
    ignore_attr = TRUE
  )

  expect_equal(sort(unique(actual$source_file)), sort(file_paths))
  expect_equal(sort(unique(actual$year), na.last = TRUE), c(1999, NA))
})

test_that("reading a non-existing Parquet register throws an error", {
  expect_error(read_register("/non/existing/path.parquet"))
  expect_error(read_register("/non/existing/directory/"))
})

test_that("incorrect input type throws an error", {
  expect_error(read_register(123))
  expect_error(read_register(c("path1.parquet", "path2.parquet")))
})

test_that("directory with no Parquet files returns error", {
  temp_empty_dir <- fs::path_temp("empty_dir")
  fs::dir_create(temp_empty_dir)

  # Error message includes the path to the empty directory.
  expect_error(read_register(temp_empty_dir), temp_empty_dir)
})

test_that("non-Parquet file returns error", {
  temp_txt_file <- fs::path_temp("file.txt")
  fs::file_create(temp_txt_file)

  # Error message includes the path to the non-Parquet file.
  expect_error(read_register(temp_txt_file), temp_txt_file)
})
