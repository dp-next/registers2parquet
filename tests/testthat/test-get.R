test_that("`get_project_id()` extracts correct project ID", {
  temp_dir <- fs::path_temp("701010/test/project/")
  fs::dir_create(temp_dir, recurse = TRUE)
  project_id <- withr::with_dir(
    temp_dir,
    {
      get_project_id()
    }
  )
  expect_identical(project_id, "701010")
})

test_that("`get_project_id()` errors for IDs not of length 6", {
  temp_dir <- fs::path_temp("70101/test/project/")
  fs::dir_create(temp_dir, recurse = TRUE)
  project_id <- withr::with_dir(
    temp_dir,
    {
      expect_error(get_project_id(), regexp = "project ID")
    }
  )

  temp_dir <- fs::path_temp("7010101/test/project/")
  fs::dir_create(temp_dir, recurse = TRUE)
  project_id <- withr::with_dir(
    temp_dir,
    {
      expect_error(get_project_id(), regexp = "project ID")
    }
  )
})

test_that("`get_project_id()` warns for not finding a project ID", {
  temp_dir <- fs::path_temp("non-number/test/project/")
  fs::dir_create(temp_dir, recurse = TRUE)
  withr::with_dir(
    temp_dir,
    {
      expect_warning(get_project_id(), regexp = "`NA`")
      expect_identical(
        suppressWarnings(get_project_id()),
        NA_character_
      )
    }
  )
})

test_that("should fail if no `E:` drive exists", {
  temp_path <- fs::path_temp("701010/")
  fs::dir_create(temp_path)
  withr::with_dir(
    temp_path,
    {
      expect_error(suppressWarnings(get_project_rawdata_dir()))
      expect_error(suppressWarnings(get_project_workdata_dir()))
    }
  )
})

test_that("takes project directory from options", {
  withr::with_options(
    list(
      fastreg.project_rawdata_dir = fs::path("E/rawdata/701010/"),
      fastreg.project_workdata_dir = fs::path("E/workdata/701010/")
    ),
    {
      expect_identical(
        get_project_rawdata_dir(),
        fs::path("E/rawdata/701010/")
      )
      expect_identical(
        get_project_workdata_dir(),
        fs::path("E/workdata/701010/")
      )
    }
  )
})
