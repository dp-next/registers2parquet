#' Create simulated kontakter registers to be used in tests
#'
#' @param n Number of rows to simulate per simulated kontakter tibble.
#'
#' @returns A named list with three tibbles containing simulated kontakter
#'  registers.
#'
#' @keywords internal
helper_create_simulated_kontakter <- function(n = 1000000) {
  list(
    kontakter = osdc::simulate_registers("kontakter", n = n)[[1]],
    kontakter_1999_1 = osdc::simulate_registers("kontakter", n = n)[[1]],
    kontakter_1999_2 = osdc::simulate_registers("kontakter", n = n)[[1]]
  )
}
