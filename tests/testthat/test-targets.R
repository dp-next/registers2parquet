# Tests of use_targets_template() ----------------------------------------------
output_path <- fs::path_temp("_targets.R")
use_targets_pipeline(output_path, open = FALSE)
template <- system.file("template-targets.R", package = "registers2parquet")
template_content <- readLines(template)

test_that("targets pipeline is created as expected", {
  expect_true(fs::file_exists(output_path))
})

test_that("trying to create pipeline when it already exists throws error", {
  expect_error(use_targets_pipeline(output_path, open = FALSE))
})

test_that("created file matches template content", {
  expect_equal(
    readLines(output_path),
    readLines(template)
  )
})

test_that("returns path invisibly", {
  temp_path <- fs::path_temp("test_return.R")
  result <- use_targets_pipeline(temp_path, open = FALSE)
  expect_equal(result, temp_path)
})

test_that("template is valid R code", {
  expect_no_error(parse(file = template))
})

test_that("template contains expected targets", {
  expect_true(any(grepl("all_sas_paths", template_content)))
  expect_true(any(grepl("register_path_groups", template_content)))
  expect_true(any(grepl("register_parquets", template_content)))
})

test_that("template uses correct package functions", {
  expect_true(any(grepl("registers2parquet::list_sas_files", template_content)))
  expect_true(any(grepl(
    "registers2parquet::get_register_path_groups",
    template_content
  )))
  expect_true(any(grepl(
    "registers2parquet::convert_to_parquet",
    template_content
  )))
})

# Test pipeline ----------------------------------------------------------------

test_that("pipeline converts SAS files to Parquet", {
  skip_on_cran()
  skip_if_not_installed("targets")
  skip_if_not_installed("crew")

  # Create temp directory structure
  test_path <- fs::path_temp("pipeline-test")
  input_path <- fs::path_temp(test_path, "input")
  output_path <- fs::path(test_path, "output")
  fs::dir_create(input_path)
  fs::dir_create(output_path)

  # Create test SAS files
  kontakter_list <- helper_create_simulated_kontakter(n = 1000)
  paths <- fs::path(input_path) |>
    paste0("/", names(kontakter_list), ".sas7bdat") |>
    as.character()
  temp_output <- fs::path_temp("kontakter")

  suppressWarnings(haven::write_sas(kontakter_list[[1]], paths[[1]]))
  suppressWarnings(haven::write_sas(kontakter_list[[2]], paths[[2]]))
  suppressWarnings(haven::write_sas(kontakter_list[[3]], paths[[3]]))

  # Read template and replace placeholder paths
  modified_content <- template_content |>
    stringr::str_replace("/path/to/register/sas/files/directory", input_path) |>
    stringr::str_replace("/path/to/output/directory", output_path)

  # Write and run pipeline
  withr::with_dir(test_path, {
    writeLines(modified_content, "_targets.R")
    targets::tar_make(callr_function = NULL, reporter = "silent")
  })

  # Check output
  parquet_files <- fs::dir_ls(output_path, recurse = TRUE, glob = "*.parquet")
  expect_equal(length(parquet_files), length(kontakter_list))
})
