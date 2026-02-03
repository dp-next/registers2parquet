#' Get the register names from file paths
#'
#' Removes all non-letters from the file names in `paths`.
#'
#' @param paths Character vector with file paths.
#'
#' @returns The file names from `paths` with only letters (all non-letter
#'  removed).
#'
#' @keywords internal
get_register_names <- function(paths) {
  paths |>
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
#' @param paths A character vector of file paths.
#'
#' @returns A list of character vectors, where each element contains paths
#'   belonging to the same register.
#'
#' @export
#' @examples
#' paths <- c("data/bef2020.sas7bdat", "data/bef2021.sas7bdat", "data/ind2020.sas7bdat")
#' split_paths_by_register(paths)
split_paths_by_register <- function(paths) {
  register_names <- get_register_names(paths)
  split(paths, register_names) |> unname()
}

#' Get register name from a group of file paths
#'
#' Extracts the register name from the path in a group. Intended for use
#' with groups created by [split_paths_by_register()] in the targets template.
#'
#' @param file_paths A character vector of file file_paths from the same
#'  register.
#'
#' @returns A character scalar with the register name.
#'
#' @export
#' @examples
#' file_paths <- c("data/bef2020.sas7bdat", "data/bef2021.sas7bdat")
#' get_register_name(file_paths)
get_register_name <- function(file_paths) {
  register_name <- unique(get_register_names(file_paths))

  if (length(register_name) > 1) {
    cli::cli_abort(c(
      "Multiple register names were found: {.val {register_name}}.",
      "i" = "Expected a single register name from {.path {file_paths}}."
    ))
  }

  register_name
}
