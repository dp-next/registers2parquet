# Setup ------------------------------------------------------------------------

sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
chunk_info <- convert(
  sas_file,
  output_dir = fs::path_temp("output")
)

# rbind with itself to get multiple chunks.
chunk_info <- chunk_info |> rbind(chunk_info)

# Output.
actual <- log_chunk_info(chunk_info)
combined <- paste(as.character(actual), collapse = "")

# Test log_chunk_info() --------------------------------------------------------

test_that("log_chunk_info() returns a kable object", {
  expect_s3_class(actual, "knitr_kable")
})

test_that("log_chunk_info() renders path values in output", {
  expect_match(combined, "extdata/test.sas7bdat", fixed = TRUE)
})

test_that("log_chunk_info() renders row count values in output", {
  expect_match(combined, as.character(chunk_info$row_count[[1]]), fixed = TRUE)
})

test_that("log_chunk_info() excludes register_name and columns column", {
  expect_no_match(combined, "register_name")
  expect_no_match(combined, "columns")
})
