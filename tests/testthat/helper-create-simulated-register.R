#' Create simulated register data for testing
#'
#' Generates a named list containing simulated register data using
#' [osdc::simulate_registers()].
#'
#' @param register A character string specifying the type of register to
#'  simulate. Passed to [osdc::simulate_registers()] so it must be one of the
#'  registers that it can simulate.
#' @param name A character string specifying the name of the list element.
#'  Used for creating file names in tests.
#' @param n Number of rows to simulate. Defaults to `1000000`.
#'
#' @returns A named list with one element (named by `name`) containing a
#'   tibble with `n` rows of simulated register data.
#'
#' @keywords internal
helper_create_simulated_register <- function(
  register,
  name,
  n = 1000000
) {
  setNames(list(osdc::simulate_registers(register, n = n)[[1]]), name)
}
