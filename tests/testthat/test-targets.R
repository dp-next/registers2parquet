# Tests of use_targets_template() ----------------------------------------------
output_path <- fs::path_temp("_targets.R")
use_targets_template(output_path, open = FALSE)
template_path <- fs::path_package("fastreg", "template-targets.R")
template_content <- readLines(template_path)

test_that("targets pipeline is created as expected", {
  expect_true(fs::file_exists(output_path))
})

test_that("trying to create pipeline when it already exists throws error", {
  expect_error(use_targets_template(output_path, open = FALSE))
})

test_that("created file matches template content", {
  expect_equal(
    readLines(output_path),
    readLines(template_path)
  )
})

test_that("template is valid R code", {
  expect_no_error(parse(file = template_path))
})

test_that("use_targets_template() errors with incorrect `path`", {
  expect_error(
    use_targets_template(fs::path_temp("not-targets.R")),
    regexp = "_targets.R"
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
  kontakter_list <- simulate_register("kontakter", c("1999", "2020"))
  diagnoser_list <- simulate_register("diagnoser", c("2020", "2021"))
  save_as_sas(kontakter_list, input_dir)
  save_as_sas(diagnoser_list, input_dir)

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
    sum(length(kontakter_list), length(diagnoser_list))
  )
})
