# Setup ------------------------------------------------------------------------
output_path <- fs::path_temp()
file_path <- use_targets_template(output_path, open = FALSE)
template_path <- fs::path_package("fastreg", "template-targets.R")
template_content <- readLines(template_path)

# Test use_targets_template() --------------------------------------------------

test_that("use_targets_template() creates pipeline file", {
  expect_true(fs::file_exists(output_path))
})

test_that("use_targets_template() errors when file already exists", {
  expect_error(use_targets_template(output_path, open = FALSE))
})

test_that("use_targets_template() creates file matching template content", {
  expect_equal(
    readLines(file_path),
    readLines(template_path)
  )
})

test_that("use_targets_template() creates R code", {
  expect_no_error(parse(file = template_path))
})

test_that("use_targets_template() errors with non-existing `path`", {
  expect_error(
    use_targets_template(fs::path_temp("non-existing/dir")),
    regexp = "does not exist"
  )
})

# Test pipeline ----------------------------------------------------------------

test_that("targets pipeline template converts SAS files to Parquet", {
  skip_on_cran()
  skip_if_not_installed("targets")
  skip_if_not_installed("crew")

  # Create temp directory structure.
  test_dir <- fs::path_temp("pipeline-test")
  input_dir <- fs::path(test_dir, "input")
  output_dir <- fs::path(test_dir, "output")
  fs::dir_create(input_dir)
  fs::dir_create(output_dir)

  # Create SAS files.
  bef_list <- simulate_register("bef", c("1999", "2020"))
  lmdb_list <- simulate_register("lmdb", c("2020", "2021"))
  save_as_sas(bef_list, input_dir)
  save_as_sas(lmdb_list, input_dir)

  # Read template and replace placeholder paths.
  modified_content <- template_content |>
    stringr::str_replace("/path/to/register/sas/files/directory", input_dir) |>
    stringr::str_replace("/path/to/output/directory", output_dir)

  # Write and run pipeline.
  withr::with_dir(test_dir, {
    writeLines(modified_content, "_targets.R")
    targets::tar_make(callr_function = NULL, reporter = "silent")
  })

  # Check number of created Parquet files.
  parquet_files <- fs::dir_ls(output_dir, recurse = TRUE, glob = "*.parquet")
  expect_equal(
    length(parquet_files),
    sum(length(bef_list), length(lmdb_list))
  )

  # Check nrows per register.
  n_expected_bef <- sum(purrr::map_int(bef_list, nrow))
  n_expected_lmdb <- sum(purrr::map_int(lmdb_list, nrow))

  n_actual_bef <- arrow::open_dataset(fs::path(
    output_dir,
    "bef"
  )) |>
    dplyr::collect() |>
    nrow()
  n_actual_lmdb <- arrow::open_dataset(fs::path(
    output_dir,
    "lmdb"
  )) |>
    dplyr::collect() |>
    nrow()

  expect_equal(n_actual_bef, n_expected_bef)
  expect_equal(n_actual_lmdb, n_expected_lmdb)
})
