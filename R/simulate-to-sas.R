#' Simulate example registers along with output paths for SAS files
#'
#' A helper function that simulates data using
#' [osdc::simulate_registers()]. It's used in vignettes and tests.
#' It simulates data for one or more registers and years.
#'
#' @param registers Name of one or more registers. Must be a register that
#'   [osdc::simulate_registers()] can simulate. See [osdc::registers()] for
#'   a list of available registers.
#' @param years One or more years to save the simulated data under. The year is
#'   used as a suffix in the file name. For example for register "bef" and year
#'   "1999", the file will be named `bef1999.sas7bdat`. Can also take no year.
#' @param n Number of rows of data to simulate per year.
#' @param output_dir The root directory appended to the created SAS paths.
#'   By default, the output_dir is a temp path that mimics the paths on DST,
#'   `E/rawdata/701010`. The default should
#'   technically be `E:` on Windows, but the default temporary directory on
#'   Windows for R doesn't allow using `:`, so we use `E` instead.
#'
#' @returns A nested tibble with a column `data` containing the simulated data
#'   and a column `output_path` containing the path where the SAS file should
#'   be saved to. Pipe to `purrr::pwalk(write_to_sas)` or `purrr::pmap(write_to_sas)`
#'   to write each simulated dataset to a SAS file.
#'
#' @export
#' @examples
#' sim_regs <- simulate_registers_with_paths(
#'   registers = c("bef", "lmdb"),
#'   years = c("1999", "2000"),
#'   n = 10,
#' )
#' sim_regs
#'
#' sim_regs |>
#'   purrr::pwalk(write_to_sas)
simulate_registers_with_paths <- function(
  registers,
  years = "",
  n = 1000,
  output_dir = fs::path_temp("E/rawdata/701010/")
) {
  checkmate::assert_character(registers)
  checkmate::assert_character(years)
  checkmate::assert_number(n)
  checkmate::assert_string(output_dir)

  tidyr::expand_grid(
    registers = registers,
    years = years
  ) |>
    dplyr::mutate(
      output_path = fs::path(output_dir, as_sas_path(registers, years)),
      data = purrr::map(registers, \(register) {
        osdc::simulate_registers(registers = register, n = n)[[1]]
      })
    ) |>
    dplyr::select("output_path", "data")
}

#' Write simulated data to a SAS file
#'
#' A helper function that writes a data frame to a SAS file. It's used
#' mainly in fastreg's vignettes and tests. Pipe the output of
#' [simulate_registers_with_paths()] with [purrr::pwalk()] followed by this function
#' to write each simulated dataset to a SAS file.
#'
#' @param data A tibble containing the simulated data.
#' @param output_path A string of the path to where the SAS file should be saved.
#'
#' @returns Invisibly gives the path to the saved SAS file.
#'
#' @export
write_to_sas <- function(data, output_path) {
  checkmate::assert_tibble(data)
  checkmate::assert_string(output_path)
  fs::dir_create(fs::path_dir(output_path))
  # Suppress warning bc `write_sas()` is deprecated, but good enough for our
  # use case.
  suppressWarnings(haven::write_sas(
    data,
    output_path
  ))
  invisible(output_path)
}

as_sas_path <- function(register, year) {
  fs::path(
    glue::glue("{register}{year}")
  ) |>
    fs::path_ext_set("sas7bdat")
}
