#' Log chunk information as a table
#'
#' Turns the chunk information returned by [convert()] into a pretty
#' table, showing relative input/output paths and row counts.
#'
#' @param chunk_info A tibble returned by [convert()], with columns
#'   `input_path`, `output_path`, and `row_count`.
#'
#' @returns A `knitr_kable` table.
#'
#' @export
#' @examples
#' sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
#' chunk_info <- convert(sas_file, output_dir = fs::path_temp("output"))
#' log_chunk_info(chunk_info)
log_chunk_info <- function(chunk_info) {
  chunk_info |>
    dplyr::mutate(
      dplyr::across(c("input_path", "output_path"), fs::path_rel)
    ) |>
    dplyr::select("input_path", "output_path", "row_count") |>
    knitr::kable()
}
