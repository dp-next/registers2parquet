#' Get the project ID from the current working directory path
#'
#' Gets a numeric project ID from the current working directory path by looking
#' for a folder name with only digits. Errors if a project ID with an unexpected
#' length was found.
#'
#' @returns A 6-digit character string, or `NA` if no project ID is found in the
#'   path.
#' @noRd
get_project_id <- function() {
  id <- fs::path_wd() |>
    stringr::str_extract("/[0-9]+/") |>
    stringr::str_remove_all("/")

  if (is.na(id) || id == "") {
    cli::cli_warn(
      c(
        "No project ID could be found in the path of the current working directory, so outputting `NA`.",
        "i" = "Your path is {fs::path_wd()}. Maybe change to a working directory within a project?"
      )
    )
  }

  if (stringr::str_length(id) != 6 && !is.na(id)) {
    cli::cli_abort(
      "Found an ID, but it was too long or too short to be a project ID.",
      c(
        "i" = "The ID found was {id}. Project IDs are expected to be 6 digits long."
      )
    )
  }
  id
}

#' Get the path to the rawdata or workdata directory for the current project
#'
#' Looks in the [options()] for `fastreg.project_rawdata_dir` and
#' `fastreg.project_workdata_dir` first, and if not found, constructs a path
#' based on the project ID using `get_project_id()`. The constructed path is
#' `E:/<project_id>/rawdata/` for raw data and `E:/<project_id>/workdata/` for n
#' work data.
#'
#' @returns A path object.
#' @noRd
get_project_rawdata_dir <- function() {
  rawdata_path <- getOption("fastreg.project_rawdata_dir")
  if (!is.null(rawdata_path)) {
    return(fs::path(rawdata_path))
  }

  id <- get_project_id()
  if (is.na(id) || id == "") {
    cli::cli_abort(
      c(
        "Can't set the {.path rawdata/} path without a project ID.",
        "i" = "Use {.code options(fastreg.project_rawdata_dir = '<path>')} or change into a directory within a project."
      )
    )
  }

  glue::glue("E:/{id}/rawdata/") |>
    fs::path()
}

#' @describeIn get_project_rawdata_dir Gets the project workdata directory.
#' @noRd
get_project_workdata_dir <- function() {
  workdata_path <- getOption("fastreg.project_workdata_dir")
  if (!is.null(workdata_path)) {
    return(fs::path(workdata_path))
  }

  id <- get_project_id()
  if (is.na(id) || id == "") {
    cli::cli_abort(
      c(
        "Can't set the {.path workdata/} path without a project ID.",
        "i" = "Use {.code options(fastreg.project_workdata_dir = '<path>')} or change into a working directory within a project."
      )
    )
  }
  glue::glue("E:/{id}/workdata/") |>
    fs::path()
}
