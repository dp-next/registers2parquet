# Setup ------------------------------------------------------------------------

test_that("`get_project_id()` extracts correct ID", {
  temp_dir <- fs::path_temp("7010101/test/project/")
  fs::dir_create(temp_dir, recurse = TRUE)
  project_id <- withr::with_dir(
    temp_dir,
    {
      get_project_id()
    }
  )
  expect_identical(project_id, "7010101")
})

test_that("`get_project_id()` errors for IDs not of length 7", {
  temp_dir <- fs::path_temp("701010/test/project/")
  fs::dir_create(temp_dir, recurse = TRUE)
  project_id <- withr::with_dir(
    temp_dir,
    {
      expect_error(get_project_id())
    }
  )

  temp_dir <- fs::path_temp("70101010/test/project/")
  fs::dir_create(temp_dir, recurse = TRUE)
  project_id <- withr::with_dir(
    temp_dir,
    {
      expect_error(get_project_id())
    }
  )
})

test_that("`get_project_id()` warns for not finding a project ID", {
  temp_dir <- fs::path_temp("non-number/test/project/")
  fs::dir_create(temp_dir, recurse = TRUE)
  project_id <- withr::with_dir(
    temp_dir,
    {
      expect_warning(get_project_id())
      expect_identical(get_project_id(), NA_character_)
    }
  )
})
