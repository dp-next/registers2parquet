# Setup ------------------------------------------------------------------------

sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
log <- convert(
  sas_file,
  output_dir = fs::path_temp("output")
)

# rbind with itself to get multiple logs.
log <- log |> rbind(log)

# Output.
log_row_count <- capture.output(print_log_row_count(log))

# Test print_log_row_count() --------------------------------------------------------

test_that("print_log_row_count() returns input invisibly", {
  actual <- expect_invisible(print_log_row_count(log))
  expect_equal(actual, log)
})

test_that("print_log_row_count() renders path values in output", {
  expect_match(
    log_row_count,
    "extdata/test.sas7bdat",
    all = FALSE,
    fixed = TRUE
  )
})

test_that("print_log_row_count() renders row count values in output", {
  expect_match(
    log_row_count,
    "1000",
    all = FALSE,
    fixed = TRUE
  )
})

test_that("print_log_row_count() excludes register_name and columns column", {
  expect_no_match(log_row_count, "register_name")
  expect_no_match(log_row_count, "columns")
})
