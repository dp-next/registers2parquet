# Setup ------------------------------------------------------------------------
temp_dir <- fs::path_temp("temp_dir")
fs::dir_create(temp_dir)

sas_file1 <- fs::path(temp_dir, "file1.sas7bdat")
sas_file2 <- fs::path(temp_dir, "subdir", "file2.sas7bdat")
sas_file3 <- fs::path(temp_dir, "file3.SAS7BDAT")
parquet_file1 <- fs::path(temp_dir, "file1.parquet")
parquet_file2 <- fs::path(temp_dir, "subdir", "file2.parq")
parquet_file3 <- fs::path(temp_dir, "file3.PARQUET")

fs::file_create(sas_file1)
fs::dir_create(fs::path_dir(sas_file2))
fs::file_create(sas_file2)
fs::file_create(sas_file3)
fs::file_create(parquet_file1)
fs::file_create(parquet_file2)
fs::file_create(parquet_file3)

# Test list_sas_files() --------------------------------------------------------

test_that("list_sas_files() lists expected SAS files", {
  expected <- sort(c(sas_file1, sas_file2, sas_file3))
  actual <- list_sas_files(temp_dir)

  expect_equal(as.character(actual), as.character(expected))
})

test_that("list_sas_files() errors when no relevant files are found", {
  no_relevant_files_dir <- fs::path_temp("no_relevant_files")
  fs::dir_create(no_relevant_files_dir)
  fs::file_create(fs::path(no_relevant_files_dir, "unrelated.txt"))

  expect_error(list_sas_files(no_relevant_files_dir))
})

test_that("list_sas_files() errors when path does not exist", {
  non_existent_dir <- fs::path_temp("non_existent")

  expect_error(
    list_sas_files(non_existent_dir),
    regexp = "does not exist"
  )
})
