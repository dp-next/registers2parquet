#' Get a project directory by going up the directory tree
#'
#' Starting from `path`, this function walks up the directory tree to get the
#' first ancestor directory whose name matches `project_id`.
#'
#' @param project_id The project id to get the directory of.
#' @param path The starting directory for the search. Defaults to the current
#'   working directory.
#'
#' @returns The absolute path to the matched directory.
#'
#' @export
#' @examples
#' temp_path <- fs::path_temp(123456, "subdir")
#' fs::dir_create(temp_path)
#' get_project_dir(project_id = 123456, path = temp_path)
get_project_dir <- function(project_id, path = ".") {
  checkmate::assert_number(project_id)
  checkmate::assert_directory_exists(path)

  current_path <- fs::path_real(path)

  while (fs::path_file(current_path) != project_id) {
    parent_path <- fs::path_dir(current_path)

    if (parent_path == current_path) {
      cli::cli_abort(
        "No directory named {.val {project_id}} found in the directory tree above {.path {path}}."
      )
    }

    current_path <- parent_path
  }

  # Ensure a path is returned as `path_dir()` converts to a character.
  fs::path(current_path)
}
