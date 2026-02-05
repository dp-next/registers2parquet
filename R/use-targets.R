#' Use a targets pipeline template for converting SAS registers to Parquet
#'
#' Copies a template to your project root.
#'
#' @param path Path to the file to create. Defaults to `_targets.R`.
#' @param open Whether to open the file for editing. Defaults to `TRUE` in
#'   interactive sessions.
#'
#' @returns The path to the created file (invisibly).
#'
#' @export
use_targets <- function(
  path = "_targets.R",
  open = rlang::is_interactive()
) {
  checkmate::assert_string(fs::path_file(path), "_targets.R")

  template_path <- fs::path_package("fastreg", "template-targets.R")

  if (fs::file_exists(path)) {
    cli::cli_abort(c(
      "{.file {path}} already exists.",
      "i" = "Delete it first or choose a different path."
    ))
  }

  fs::file_copy(path = template_path, new_path = path)

  if (fs::file_exists(path)) {
    cli::cli_alert_success("Created {.file {path}}")
    cli::cli_alert_info("Edit the {.code config} section to set your paths.")
  }

  if (open) {
    utils::file.edit(path)
  }

  invisible(path)
}
