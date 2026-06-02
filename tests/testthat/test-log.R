# Setup ------------------------------------------------------------------------

test_output_dir <- fs::path_temp()
fs::dir_create(test_output_dir)

# Create SAS files.
bef <- simulate_registers_with_paths("bef", c("1999", "2020"))
lmdb_no_atc <- simulate_registers_with_paths(
  "lmdb",
  as.character(c(2030:2033))
) |>
  dplyr::mutate(
    data = purrr::map(data, \(d) {
      d |>
        dplyr::select(-atc)
    })
  )
lmdb_edited_cols <- simulate_registers_with_paths(
  "lmdb",
  as.character(c(2040:2043))
) |>
  dplyr::mutate(
    data = purrr::map(data, \(d) {
      d |>
        dplyr::mutate(pnr = as.numeric(pnr), new_col = 3)
    })
  )
lmdb <- simulate_registers_with_paths(
  "lmdb",
  as.character(c(2020:2025, 2045))
) |>
  rbind(lmdb_no_atc, lmdb_edited_cols)


bef |> purrr::pwalk(write_to_sas)
lmdb |> purrr::pwalk(write_to_sas)

log_bef <- bef$output_path |>
  purrr::map(\(path) {
    convert(path, output_dir = test_output_dir)
  }) |>
  purrr::list_rbind()


log_lmdb <- lmdb$output_path |>
  purrr::map(\(path) {
    convert(path, output_dir = test_output_dir)
  }) |>
  purrr::list_rbind()

# Output.
log_table <- log_as_table(log_bef)

log_schema_no_diff <- capture.output(print_log_schema(log_bef))
log_schema_diff <- capture.output(print_log_schema(log_lmdb))

# Test log_as_table() ----------------------------------------------------------

test_that("log_as_table() returns kable", {
  expect_identical(class(log_table), "knitr_kable")
})

# Test print_log_schema() ------------------------------------------------------

test_that("print_log_schema() returns input invisibly", {
  actual <- expect_invisible(print_log_schema(log_bef))
  expect_equal(actual, log_bef)
})

test_that("print_log_schema() only include expected elements with no diff", {
  # Description phrasing.
  expect_true(any(stringr::str_detect(log_schema_no_diff, "same schema")))
  # No mentions of differences throughout.
  expect_false(any(grepl("differences", log_schema_no_diff)))
  # Only one table (one reference).
  n_tables <- log_schema_no_diff |>
    stringr::str_detect("^\\|[:-]") |>
    sum()
  expect_equal(n_tables, 1)
})

test_that("print_log_schema() includes expected elements with diffs", {
  # Description phrasing.
  expect_true(any(stringr::str_detect(log_schema_diff, "most common")))
  # Fraction of schemas matching most common schema/total files.
  expect_match(log_schema_diff, "7/15", all = FALSE, fixed = TRUE)
  # Differences header.
  expect_true(any(stringr::str_detect(
    log_schema_diff,
    "Schema differences"
  )))
  # Three tables (one reference, two with schema diffs).
  n_tables <- log_schema_diff |>
    stringr::str_detect("^\\|[:-]") |>
    sum()
  expect_equal(n_tables, 3)
})
