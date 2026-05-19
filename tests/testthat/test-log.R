# Setup ------------------------------------------------------------------------

sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
log <- convert(
  sas_file,
  output_dir = fs::path_temp("output")
)

# rbind with itself to get multiple logs.
log <- log |> rbind(log)

# Output.
actual <- log_as_table(log)
combined <- paste(as.character(actual), collapse = "")

# Test log_chunk_info() --------------------------------------------------------

test_that("log_as_table() returns a kable object", {
  expect_s3_class(actual, "knitr_kable")
})

test_that("log_as_table() renders path values in output", {
  expect_match(combined, "extdata/test.sas7bdat", fixed = TRUE)
})

test_that("log_as_table() renders row count values in output", {
  expect_match(combined, as.character(log$row_count[[1]]), fixed = TRUE)
})

test_that("log_as_table() excludes register_name and columns column", {
  expect_no_match(combined, "register_name")
  expect_no_match(combined, "columns")
})
