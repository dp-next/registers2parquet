#' Log chunk information as a table
#'
#' Turns the log information returned by [convert()] into a pretty
#' table, showing relative input/output paths and row counts.
#'
#' @param log A tibble returned by [convert()], with columns
#'   `input_path`, `output_path`, and `row_count`.
#'
#' @returns A `knitr_kable` table.
#'
#' @export
#' @examples
#' sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
#' conversion_log <- convert(sas_file, output_dir = fs::path_temp("output"))
#' log_as_table(conversion_log)
log_as_table <- function(log) {
  log |>
    dplyr::mutate(
      dplyr::across(c("input_path", "output_path"), fs::path_rel)
    ) |>
    dplyr::select("input_path", "output_path", "row_count") |>
    knitr::kable()
}
