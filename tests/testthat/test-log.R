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
log_schema_no_diff <- log_schema(log_bef)
log_schema_diff <- log_schema(log_lmdb)

# Test log_as_table() ----------------------------------------------------------

test_that("log_as_table() returns kable", {
  expect_identical(class(log_table), "knitr_kable")
})

# Test log_schema() ------------------------------------------------------------

test_that("log_schema() returns s3 object", {
  expect_s3_class(log_schema_no_diff, "fastreg_schema")
  expect_s3_class(log_schema_diff, "fastreg_schema")
})

test_that("log_schema() description include expected wording with no diff and diff", {
  expect_match(log_schema_no_diff$description, "same schema")
  expect_match(log_schema_diff$description, "most common")
})

test_that("log_schema() description shows expected count when schemas differ", {
  expect_match(log_schema_diff$description, "4/11")
})

test_that("log_schema() diff_tables is empty when schemas match", {
  expect_length(log_schema_no_diff$diff_tables, 0)
})

test_that("log_schema() diff_tables has entries when schemas differ", {
  # Length is 2 bc there's more files with schema diffs than `max_file_cols`
  # in chunk_diff_table().
  expect_length(log_schema_diff$diff_tables, 2)
})

test_that("printing a fastreg_schema does not error", {
  expect_no_error(capture.output(print(log_schema_no_diff)))
  expect_no_error(capture.output(print(log_schema_diff)))
})
