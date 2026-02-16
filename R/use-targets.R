#' Use a targets pipeline template for converting SAS registers to Parquet
#'
#' Copies a `_targets.R` template to the given directory.
#'
#' @param path Path to the directory where `_targets.R` will be created.
#'   Defaults to the current directory.
#' @param open Whether to open the file for editing.
#'
#' @returns The path to the created `_targets.R` file, invisibly.
#'
#' @export
#' @examples
#' use_targets_template(path = fs::path_temp(""))
use_targets_template <- function(
  path = ".",
  open = rlang::is_interactive()
) {
  checkmate::assert_directory_exists(path)
  target_file <- fs::path(path, "_targets.R")

  template_path <- fs::path_package("fastreg", "template-targets.R")

  if (fs::file_exists(target_file)) {
    cli::cli_abort(c(
      "{.file {target_file}} already exists.",
      "i" = "Delete it first or choose a different directory."
    ))
  }

  fs::file_copy(path = template_path, new_path = target_file)

  if (fs::file_exists(target_file)) {
    cli::cli_alert_success("Created {.file {target_file}}")
    cli::cli_alert_info("Edit the {.code config} section to set your paths.")
  }

  if (open) {
    utils::file.edit(target_file)
  }

  invisible(target_file)
}
