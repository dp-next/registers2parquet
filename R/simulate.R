#' Simulate example registers
#'
#' The data is simulated using `osdc::simulate_registers()`. It's used
#' in vignettes and tests.
#'
#' @param register Name of the register. Has to be a register accepted by
#'  osdc::simulate_registers().
#' @param year A character vector of year suffixes appended to the register
#'  name to form the list element names (e.g., `"2020"`, `"1999_1"`, or
#'  `""` for no suffix).
#' @param n Number of rows to simulate per year.
#'
#' @returns A named list of tibble(s) with names in the format
#'  `{register}_{year}`.
#'
#' @export
#' @examples
#' simulate_register(register = "kontakter", year = c("1999", "2000"))
simulate_register <- function(register, year = "", n = 1000) {
  names <- ifelse(year == "", register, paste(register, year, sep = "_"))
  purrr::map(names, \(name) {
    osdc::simulate_registers(registers = register, n = n)[[1]]
  }) |>
    stats::setNames(names)
}

#' Save a list of data frames as SAS files
#'
#' Writes each element of a named list as a SAS file to the given directory.
#' The file names are derived from the list names.
#'
#' @param data_list A named list of data frames.
#' @param path A character scalar with the directory to save the SAS files to.
#'
#' @returns The path invisibly.
#'
#' @export
#' @examples
#' save_as_sas(data_list = simulate_register("kontakter", "2020"), path = fs::path_temp())
save_as_sas <- function(data_list, path) {
  fs::dir_create(path, recurse = TRUE)
  purrr::iwalk(data_list, \(df, name) {
    suppressWarnings(haven::write_sas(
      df,
      fs::path(path, paste0(name, ".sas7bdat"))
    ))
  })
  invisible(path)
}
