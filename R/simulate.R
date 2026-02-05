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
