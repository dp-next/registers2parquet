# kontakter register: One without year in filename, two with the same year
kontakter <- osdc::simulate_registers("kontakter", n = 2000000)[[1]]
kontakter_1999_1 <- osdc::simulate_registers("kontakter", n = 2000000)[[1]]
kontakter_1999_2 <- osdc::simulate_registers("kontakter", n = 1000000)[[1]]

usethis::use_data(
  kontakter,
  kontakter_1999_1,
  kontakter_1999_2,
  internal = TRUE,
  overwrite = TRUE
)
