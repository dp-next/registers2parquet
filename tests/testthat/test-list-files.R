test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("extension changes to a Parquet partition format", {
  actual <- fs::file_temp(ext = ".sas7bdat") |>
    path_ext_set_parquet_partition() |>
    fs::path_file()

  expect_identical(actual, "part-0.parquet")
})

test_that("directory of path changes", {
  expected <- fs::path_temp() |>
    as.character()

  actual <- fs::file_temp(ext = ".sas7bdat") |>
    path_set_dir(expected) |>
    fs::path_dir()

  expect_identical(actual, expected)
})

test_that("year from file name gets appended as a directory", {
  expected <- "year=2020"

  actual <- fs::file_temp(pattern = "database2020-", ext = ".sas7bdat") |>
    path_alter_filename_year_as_dir() |>
    fs::path_file()

  expect_identical(actual, expected)
})

test_that("file name gets converted as a directory instead", {
  actual <- fs::file_temp(pattern = "database", ext = ".sas7bdat") |>
    path_alter_filename_as_dir()

  expect_identical(fs::path_file(actual), "database")
})

test_that("path is converted to a Parquet Partition in another directory", {
  expected_dir <- fs::path_temp("new-dir") |>
    as.character()

  actual_path <- fs::path_temp("database.sas7bdat") |>
    path_alter_to_output_parquet_partition(expected_dir)
  actual_root_dir <- actual_path |>
    fs::path_dir() |>
    fs::path_dir()
  actual_parent_dir <- actual_path |>
    fs::path_dir()

  expect_identical(fs::path_file(actual_path), "part-0.parquet")
  expect_identical(fs::path_file(actual_parent_dir), "database")
  expect_identical(actual_root_dir, expected_dir)
})

test_that("path with year is converted to a Parquet Partition in another directory", {
  expected_dir <- fs::path_temp("new-dir") |>
    as.character()

  actual_path <- fs::file_temp(pattern = "database2020-", ext = ".sas7bdat") |>
    path_alter_to_output_parquet_partition(expected_dir)
  actual_root_dir <- actual_path |>
    fs::path_dir() |>
    fs::path_dir() |>
    fs::path_dir()
  actual_parent_dir <- actual_path |>
    fs::path_dir() |>
    fs::path_dir()
  actual_year_dir <- actual_path |>
    fs::path_dir()

  expect_identical(fs::path_file(actual_path), "part-0.parquet")
  expect_identical(fs::path_file(actual_year_dir), "year=2020")
  expect_identical(fs::path_file(actual_parent_dir), "database")
  expect_identical(actual_root_dir, expected_dir)
})

test_that("multiple paths with or without years are converted as well", {
  expected_dir <- fs::path_temp("new-dir") |>
    as.character()

  actual_path <- fs::path_temp(c("database2020", "database-no-year")) |>
    fs::path_ext_set(".sas7bdat") |>
    path_alter_to_output_parquet_partition(expected_dir)
  actual_root_dir <- actual_path |>
    fs::path_dir() |>
    fs::path_dir() |>
    fs::path_dir()
  actual_parent_dir <- actual_path |>
    fs::path_dir() |>
    fs::path_dir()
  actual_year_dir <- actual_path |>
    fs::path_dir()

  expect_identical(fs::path_file(actual_path), c("part-0.parquet", "part-0.parquet"))
  expect_identical(fs::path_file(actual_year_dir), c("year=2020", "database-no-year"))
  expect_identical(fs::path_file(actual_parent_dir), c("database", "new-dir"))
  expect_identical(actual_root_dir, c(expected_dir, fs::path_dir(expected_dir)))
})
