#' Randomly sample PNR values to create a smaller database to use to test code on.
#'
#' Inside the function we keep only rows where `cprtjek` is 0, since that means
#' that there isn't a problem with the person's data or number (as defined by DST).
#' We also drop missing PNR numbers (there aren't many, just to be sure).
#'
#' @param population_db The population database that defines the people found in our DST project.
#' @param register_db The register you want to randomly sample from to make smaller.
#' @param n Sample size to use. Default is a million (1e6).
#'
#' @return Either a tibble or duckdb connection, depending on input databases.
#' @export
#'
randomly_sample <- function(population_db, register_db, n = 1e6) {
  population_db |>
    dplyr::filter(cprtjek == 0, PNR != "") |>
    dplyr::select(PNR) |>
    dplyr::slice_sample(n = n) |>
    dplyr::left_join(register_db, by = "PNR")
}
