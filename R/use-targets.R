#' Set up a targets pipeline for converting SAS registers to Parquet
#'
#' Copies the targets pipeline template to your project root.
#'
#' @param path Path to the file to create. Defaults to `_targets.R`.
#' @param open Whether to open the file for editing. Defaults to `TRUE` in
#'   interactive sessions.
#'
#' @returns The path to the created file (invisibly).
#'
#' @export
#' @examples
#' \dontrun{
#' use_targets_pipeline()
#' }
use_targets_pipeline <- function(
  path = "_targets.R",
  open = rlang::is_interactive()
) {
  template <- system.file(
    "template-targets.R",
    package = "registers2parquet",
    mustWork = TRUE
  )

  if (fs::file_exists(path)) {
    cli::cli_abort(c(
      "{.file {path}} already exists.",
      "i" = "Delete it first or choose a different path."
    ))
  }

  fs::file_copy(template, path)
  cli::cli_alert_success("Created {.file {path}}")
  cli::cli_alert_info("Edit the {.code config} section to set your paths.")

  if (open) {
    utils::file.edit(path)
  }

  invisible(path)
}
