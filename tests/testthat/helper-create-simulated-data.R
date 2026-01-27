helper_create_simulated_kontakter <- function() {
  list(
    kontakter = osdc::simulate_registers("kontakter", n = 1000000)[[1]],
    kontakter_1999_1 = osdc::simulate_registers("kontakter", n = 1000000)[[1]],
    kontakter_1999_2 = osdc::simulate_registers("kontakter", n = 1000000)[[1]]
  )
}
