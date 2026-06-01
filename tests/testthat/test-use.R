# Setup ------------------------------------------------------------------------
output_path <- fs::path_temp()
file_path <- use_template(output_path, open = FALSE)
template_path <- fs::path_package("fastreg", "template-targets.R")
template_content <- readLines(template_path)

# Test use_template() --------------------------------------------------

test_that("use_template() creates pipeline file", {
  expect_true(fs::file_exists(output_path))
})

test_that("use_template() errors when file already exists", {
  expect_error(use_template(output_path, open = FALSE))
})

test_that("use_template() creates file matching template content", {
  expect_equal(
    readLines(file_path),
    readLines(template_path)
  )
})

test_that("use_template() creates R code", {
  expect_no_error(parse(file = template_path))
})

test_that("use_template() errors with non-existing `path`", {
  expect_error(
    use_template(fs::path_temp("non-existing/dir")),
    regexp = "does not exist"
  )
})

# Test pipeline ----------------------------------------------------------------

test_that("targets pipeline template converts SAS files to Parquet", {
  skip_on_cran()
  skip_on_ci()
  skip_if(
    Sys.info()[["sysname"]] == "Windows" &&
      # Copied directly from `testthat:::on_ci()`.
      isTRUE(as.logical(Sys.getenv("CI", "false"))),
    "Running parallel workers on Windows can leave files around. Skipping on Windows GitHub workflows."
  )
  skip_if_not_installed("targets")
  skip_if_not_installed("crew")

  # Create temp directory structure.
  test_dir <- fs::path_temp("pipeline-test")
  test_input_dir <- fs::path(test_dir, "input")
  test_output_dir <- fs::path(test_dir, "output")

  # Create SAS files.
  registers_sas <- simulate_registers_with_paths(
    c("bef", "lmdb"),
    c("1999", "2020", "2021"),
    output_dir = test_input_dir
  ) |>
    purrr::pwalk(write_to_sas)

  # Create template files in test directory.
  fastreg::use_template(test_dir)

  # Replace placeholder paths in targets template content.
  modified_content <- template_content |>
    stringr::str_replace("/path/to/sas/directory", test_input_dir) |>
    stringr::str_replace("/path/to/output/directory", test_output_dir)

  # Write and run pipeline.
  withr::with_dir(test_dir, {
    writeLines(modified_content, "_targets.R")
    targets::tar_make(callr_function = NULL, reporter = "silent")
  })

  # Check number of created Parquet files.
  parquet_files <- fs::dir_ls(
    test_output_dir,
    recurse = TRUE,
    glob = "*.parquet"
  )

  expect_equal(
    length(parquet_files),
    nrow(registers_sas)
  )

  # Check rows of registers.
  n_expected <- registers_sas$data |>
    purrr::map(nrow) |>
    purrr::list_c() |>
    sum()

  n_actual_bef <- arrow::open_dataset(fs::path(
    test_output_dir,
    "bef"
  )) |>
    dplyr::collect() |>
    nrow()

  n_actual_lmdb <- arrow::open_dataset(fs::path(
    test_output_dir,
    "lmdb"
  )) |>
    dplyr::collect() |>
    nrow()

  expect_equal(n_actual_bef + n_actual_bef, n_expected)

  # Conversion log Quarto file and PDF were created.
  expect_true(fs::file_exists(fs::path(test_dir, "conversion-log.qmd")))
  expect_true(length(fs::dir_ls(test_dir, glob = "*.pdf")) == 1)
})
