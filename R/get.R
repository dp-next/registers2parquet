#' Get the project ID from the current working directory path
#'
#' Gets a numeric project ID from the current working directory path by looking
#' for a folder name with only digits. Errors if a project ID with an unexpected
#' length was found.
#'
#' @returns A 6-digit character string, or `NA` if no project ID is found in the
#'   path.
#' @export
get_project_id <- function() {
  id <- fs::path_wd() |>
    stringr::str_extract("/[0-9]+/") |>
    stringr::str_remove_all("/")

  if (is.na(id) || id == "") {
    cli::cli_warn(
      c(
        "No project ID could be found in the path of the current working directory, so outputting `NA`.",
        "i" = "Your path is {fs::path_wd()}. Maybe you need to change into a directory within a project?"
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
