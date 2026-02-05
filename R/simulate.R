#' Create example kontakter registers
#'
#' The data is simulated using `osdc::simulate_registers()`. It's used
#' in vignettes and tests.
#'
#' @param n Number of rows to simulate per simulated kontakter tibble.
#'
#' @returns A named list with four tibbles containing simulated kontakter
#'  registers.
#'
#' @keywords internal
#' @noRd
simulate_kontakter_register <- function(
  n = 1000
) {
  data_list <- list(
    kontakter = osdc::simulate_registers("kontakter", n = n)[[1]],
    kontakter_1999_1 = osdc::simulate_registers("kontakter", n = n)[[1]],
    kontakter_1999_2 = osdc::simulate_registers("kontakter", n = n)[[1]],
    kontakter_2020 = osdc::simulate_registers("kontakter", n = n)[[1]]
  )
}

#' Create example diagnoser registers
#'
#' The data is simulated using `osdc::simulate_registers()`. It's used
#' in vignettes and tests.
#'
#' @param n Number of rows to simulate per simulated diagnoser tibble.
#'
#' @returns A named list with two tibbles containing simulated diagnoser
#'  registers.
#'
#' @keywords internal
#' @noRd
simulate_diagnoser_register <- function(
  n = 1000
) {
  data_list <- list(
    diagnoser_2020 = osdc::simulate_registers("diagnoser", n = n)[[1]],
    diagnoser_2021 = osdc::simulate_registers("diagnoser", n = n)[[1]]
  )
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
#' @keywords internal
#' @noRd
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
