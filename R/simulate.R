#' Simulate an example register
#'
#' This is a helper function that simulates data using
#' `osdc::simulate_registers()`. It's used in vignettes and tests.
#'
#' @param register Name of the register. Must be accepted by
#'  `osdc::simulate_registers()`.
#' @param year Year suffixes for list element names (e.g., `"2020"`,
#'  `"1999_1"`, or `""` for no suffix).
#' @param n Number of rows per year.
#'
#' @returns A named list of tibbles following the naming scheme
#'  `{register}{year}` or just `{register}` when year = "".
#'
#' @export
#' @examples
#' simulate_register(register = "bef", year = c("1999", "2000"))
simulate_register <- function(register, year = "", n = 1000) {
  checkmate::assert_string(register)
  checkmate::assert_character(year)
  checkmate::assert_number(n)

  names <- dplyr::if_else(
    year == "",
    register,
    paste(register, year, sep = "")
  )

  purrr::map(names, \(name) {
    osdc::simulate_registers(registers = register, n = n)[[1]]
  }) |>
    purrr::set_names(names)
}

#' Save a list of data frames as SAS files
#'
#' This helper function is used for testing fastreg code and in the docs.
#' It will write each element of a named list as a SAS file to the given
#' directory. The file names are determined from the list names.
#'
#' @param data_list A named list of data frames.
#' @param path Directory to save the SAS files to.
#'
#' @returns `path`, invisibly.
#'
#' @export
#' @examples
#' save_as_sas(
#'   data_list = simulate_register("bef", "2020"),
#'   path = fs::path_temp()
#' )
save_as_sas <- function(data_list, path) {
  checkmate::assert_list(data_list, names = "named")

  fs::dir_create(path, recurse = TRUE)

  purrr::iwalk(data_list, \(df, name) {
    # Suppress warning bc `write_sas()` is deprecated, but good enough for our
    # use case.
    suppressWarnings(haven::write_sas(
      df,
      fs::path(path, glue::glue("{name}.sas7bdat"))
    ))
  })

  invisible(path)
}
