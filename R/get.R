#' Get (or guess) the project ID from the current working directory
#'
#' @returns The project ID as a character string.
#' @export
get_project_id <- function() {
  id <- fs::path_wd() |>
    stringr::str_extract("/[0-9]+/") |>
    stringr::str_remove_all("/")

  if (is.na(id)) {
    cli::cli_warn(
      "No project ID could be found in the path of the current working directory, so outputting `NA`.",
      c(
        "i" = "Your path is {fs::path_wd()}. Maybe you need to change into a directory within a project?"
      )
    )
  }

  if (stringr::str_length(id) != 7 && !is.na(id)) {
    cli::cli_abort(
      "Found an ID, but it was too long to be a project ID.",
      c(
        "i" = "The ID found was {id}. Project IDs are 7 digits long."
      )
    )
  }
  id
}
