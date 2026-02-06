#' Get the register names from file paths
#'
#' Removes all non-letters from the file names in `path`.
#'
#' @param path A character vector of one or more file paths.
#'
#' @returns The file names from `path` with only letters (all non-letters
#'  removed).
#'
#' @keywords internal
#' @noRd
get_register_names <- function(path) {
  path |>
    fs::path_file() |>
    fs::path_ext_remove() |>
    # Remove everything that's not a letter.
    stringr::str_remove_all("[^[:alpha:]]")
}

#' Group file paths by register name
#'
#' Groups a vector of file paths by their register name, where the register
#' name is derived from the file name with all non-letter characters removed.
#'
#' @param path A character vector of one or more file paths.
#'
#' @returns A list of character vectors, where each element contains paths
#'   belonging to the same register.
#'
#' @export
#' @examples
#' path <- c("data/bef2020.sas7bdat", "data/bef2021.sas7bdat", "data/ind2020.sas7bdat")
#' split_paths_by_register(path)
split_paths_by_register <- function(path) {
  register_names <- get_register_names(path)
  split(path, register_names) |> unname()
}

#' Get register name from a group of file paths
#'
#' Extracts the register name from the path in a group. Intended for use
#' with groups created by [split_paths_by_register()] in the targets template.
#'
#' @param path A character vector of one or more paths from the same register.
#'
#' @returns A character scalar with the register name.
#'
#' @export
#' @examples
#' path <- c("data/bef2020.sas7bdat", "data/bef2021.sas7bdat")
#' get_register_name(path)
get_register_name <- function(path) {
  register_name <- unique(get_register_names(path))

  if (length(register_name) > 1) {
    cli::cli_abort(c(
      "Multiple register names were found: {.val {register_name}}.",
      "i" = "Expected a single register name from {.path {path}}."
    ))
  }

  register_name
}
