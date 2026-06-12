#' Use a targets pipeline for converting SAS registers to Parquet
#'
#' Copies a `_targets.R` template and a conversion log Quarto Markdown file to
#' the given directory.
#'
#' @param path Path to the directory where the targets pipeline and conversion
#'   log will be created. Defaults to the current directory.
#' @param open Whether to open the file for editing.
#'
#' @returns The path to the created `_targets.R` file, invisibly.
#'
#' @export
#' @examples
#' use_template(path = fs::path_temp(""))
use_template <- function(
  path = ".",
  open = rlang::is_interactive()
) {
  checkmate::assert_directory_exists(path)
  target_file <- fs::path(path, "_targets.R")

  targets_path <- fs::path_package("fastreg", "template-targets.R")
  quarto_path <- fs::path_package("fastreg", "template-conversion-log.qmd")
  quarto_file <- fs::path(path, "conversion-log.qmd")

  if (fs::file_exists(target_file)) {
    cli::cli_abort(c(
      "{.file {target_file}} already exists.",
      "i" = "Delete it first or choose a different directory."
    ))
  }

  if (fs::file_exists(quarto_file)) {
    cli::cli_abort(c(
      "{.file {quarto_file}} already exists.",
      "i" = "Delete it first or choose a different directory."
    ))
  }

  fs::file_copy(path = targets_path, new_path = target_file)
  fs::file_copy(path = quarto_path, new_path = quarto_file)

  if (fs::file_exists(quarto_file)) {
    cli::cli_alert_success("Created {.file {target_file}}")
  }
  if (fs::file_exists(target_file)) {
    cli::cli_alert_success("Created {.file {target_file}}")
    cli::cli_alert_info("Edit the {.code config} section to set your paths.")
  }

  if (open && .Platform$GUI == "RStudio") {
    utils::file.edit(target_file)
  }

  invisible(target_file)
}
