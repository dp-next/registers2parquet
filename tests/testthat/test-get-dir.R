# Setup ------------------------------------------------------------------------
temp_dir <- withr::local_tempdir()
project_dir <- fs::path(temp_dir, 123456)
project_sub_dir <- fs::path(project_dir, "Grunddata", "raw")
fs::dir_create(project_sub_dir)

# Resolve symlinks.
project_dir <- fs::path_real(project_dir)
project_sub_dir <- fs::path_real(project_sub_dir)
grunddata_dir <- fs::path(project_dir, "Grunddata")

# Test get_project_dir() -------------------------------------------------------

test_that("get_project_dir() finds project id by walking up the dir tree", {
  expect_equal(
    get_project_dir(project_id = 123456, path = project_sub_dir),
    project_dir
  )
})

test_that("get_project_dir() matches starting directory itself", {
  expect_equal(
    get_project_dir(project_id = 123456, path = project_dir),
    project_dir
  )
})

test_that("get_project_dir() uses cwd when path is not given", {
  withr::with_dir(project_sub_dir, {
    expect_equal(get_project_dir(project_id = 123456), project_dir)
  })
})

test_that("get_project_dir() errors when project id is not in the dir tree", {
  expect_error(
    get_project_dir(project_id = 321, path = project_sub_dir),
    regexp = "321"
  )
})
