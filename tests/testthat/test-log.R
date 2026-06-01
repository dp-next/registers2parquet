# Setup ------------------------------------------------------------------------

# TODO: Update setup when save_as_sas() is deprecated.
test_dir <- fs::path_temp("log_dir")
test_input_dir <- fs::path(test_dir, "input")
test_output_dir <- fs::path(test_dir, "output")
fs::dir_create(test_input_dir)
fs::dir_create(test_output_dir)

# Create SAS files.
bef_list <- simulate_register("bef", c("1999", "2020"))
lmdb_list <- simulate_register(
  "lmdb",
  as.character(c(2020:2025, 2031, 2035, 2041, 2045, 2051))
)

for (yr in c("2021", "2031", "2041", "2051")) {
  lmdb_list[[paste0("lmdb", yr)]] <- lmdb_list[[paste0("lmdb", yr)]] |>
    dplyr::mutate(pnr = as.numeric(pnr), new_col = 3) |>
    dplyr::select(-atc)
}

for (yr in c("2025", "2035", "2045")) {
  lmdb_list[[paste0("lmdb", yr)]] <- lmdb_list[[paste0("lmdb", yr)]] |>
    dplyr::mutate(apk = as.numeric(apk), new_col = 3, another_new_col = "new")
}

purrr::walk(list(bef_list, lmdb_list), \(register) {
  save_as_sas(register, test_input_dir)
})

all_files <- fastreg::list_sas_files(test_input_dir)

log_bef <- all_files |>
  stringr::str_subset("bef") |>
  purrr::map(\(path) {
    convert(path, output_dir = test_output_dir)
  }) |>
  purrr::list_rbind()

log_lmdb <- all_files |>
  stringr::str_subset("lmdb") |>
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
  # Only one table (found by looking for the separator ":-").
  n_tables <- log_schema_no_diff |>
    stringr::str_detect("^\\|[:-]") |>
    sum()
  expect_equal(n_tables, 1)
})

test_that("print_log_schema() includes expected elements with diffs", {
  # Description phrasing.
  expect_true(any(stringr::str_detect(log_schema_diff, "most common")))
  # Fraction of schemas matching most common schema/total files.
  expect_match(log_schema_diff, "4/11", all = FALSE, fixed = TRUE)
  # Differences header.
  expect_true(any(stringr::str_detect(
    log_schema_diff,
    "Schema differences"
  )))
  # Three tables (found by looking for the separator ":-").
  n_tables <- log_schema_diff |>
    stringr::str_detect("^\\|[:-]") |>
    sum()
  expect_equal(n_tables, 3)
})
