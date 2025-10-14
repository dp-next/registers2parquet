# LPR2 --------------------------------------------------------------------

#' Read the LPR Diagnosis Parquet database.
#'
#' @param path A vector of Parquet paths for the `lpr_diag`.
#'
#' @return A DuckDB database connection.
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' path_parquet_registers() |>
#'   list_parquet_files() |>
#'   get_path_specific_database("lpr_diag") |>
#'   read_lpr_diag()
#' }
#'
read_lpr_diag <- function(path) {
  lpr_diag_dir <- path |>
    fs::path_dir() |>
    fs::path_dir() |>
    unique()

  lpr_diag_dir |>
    read_parquet_partition() |>
    # Not sure yet why to keep only A, will update this later.
    dplyr::filter(C_DIAGTYPE == "A") |>
    # No missing values
    dplyr::select(RECNUM, C_DIAG, year)
}

#' Read the LPR Admissions Parquet database.
#'
#' @param path A vector of Parquet paths for the `lpr_adm`.
#'
#' @return A DuckDB database connection.
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' path_parquet_registers() |>
#'   list_parquet_files() |>
#'   get_path_specific_database("lpr_adm") |>
#'   read_lpr_adm()
#' }
#'
read_lpr_adm <- function(path) {
  lpr_adm_dir <- path |>
    fs::path_dir() |>
    fs::path_dir() |>
    unique()

  lpr_adm_dir |>
    read_parquet_partition() |>
    # Might not have cprtjek in each subset of data
    dplyr::filter(cprtjek == 0 | is.na(cprtjek)) |>
    dplyr::select(PNR, RECNUM, D_INDDTO, year)
}

#' Reads in the LPR2 registers and combines them.
#'
#' @param path_lpr_diag Path to the LPR2 diagnosis data files.
#' @param path_lpr_adm Path to the LPR2 diagnosis data files.
#'
#' @return A DuckDB object.
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' read_lpr2(
#'   path_parquet_registers() |>
#'     list_parquet_files() |>
#'     get_path_specific_database("lpr_diag"),
#'   path_parquet_registers() |>
#'     list_parquet_files() |>
#'     get_path_specific_database("lpr_adm")
#' )
#' }
read_lpr2 <- function(path_lpr_diag, path_lpr_adm) {
  dplyr::full_join(
    read_lpr_diag(path_lpr_diag),
    read_lpr_adm(path_lpr_adm),
    by = dplyr::join_by(RECNUM, year)
  ) |>
    dplyr::mutate(
      icd_revision = dplyr::case_when(
        D_INDDTO >= as.Date("1995-01-01") ~ "ICD10",
        D_INDDTO < as.Date("1995-01-01") ~ "ICD8"
      ),
      year = as.integer(year)
    ) |>
    dplyr::select(
      PNR,
      diagnosis_date = D_INDDTO,
      icd_code = C_DIAG,
      icd_revision,
      year
    )
}


# LPR3 --------------------------------------------------------------------

#' Load in the LPR3 diagnose codes
#'
#' @param path Path to file(s) for the LPR3 diagnoser kodes
#'
#' @return A DuckDB object.
#'
#' @examples
#' \dontrun{
#' path_parquet_external() |>
#'   list_parquet_files() |>
#'   get_path_specific_database("diagnoser") |>
#'   read_diagnoser()
#' }
read_diagnoser <- function(path) {
  diagnoser_dir <- path |>
    fs::path_dir() |>
    unique()

  diagnoser_dir |>
    read_parquet_partition() |>
    dplyr::filter(
      # TODO: Not sure if only A needs to be kept or also '+'
      diagnosetype == "A",
      # TODO: Not sure if this should be dropped, but makes sense
      # Keep those who were not later dropped/removed.
      senere_afkraeftet != "Ja"
    ) |>
    dplyr::select(DW_EK_KONTAKT, diagnosekode)
}

#' Load in the LPR3 diagnose codes
#'
#' @param path Path to file(s) for the LPR3 diagnoser kodes
#'
#' @return A DuckDB object.
#'
#' @examples
#' \dontrun{
#' path_parquet_external() |>
#'   list_parquet_files() |>
#'   get_path_specific_database("kontakter") |>
#'   read_kontakter()
#' }
read_kontakter <- function(path) {
  kontakter_dir <- path |>
    fs::path_dir() |>
    unique()

  kontakter_dir |>
    read_parquet_partition() |>
    dplyr::select(DW_EK_KONTAKT, CPR, hovedspeciale_ans, dato_start, dato_slut)
}

#' Read in the LPR3 registers.
#'
#' @param path_diagnoser Path to the diagnoser data file.
#' @param path_kontakter Path to the kontakter data file.
#'
#' @return A DuckDB object.
#'
#' @examples
#' \dontrun{
#' read_lpr3(
#'   path_parquet_external() |>
#'     list_parquet_files() |>
#'     get_path_specific_database("diagnoser"),
#'   path_parquet_external() |>
#'     list_parquet_files() |>
#'     get_path_specific_database("kontakter")
#' )
#' }
read_lpr3 <- function(path_diagnoser, path_kontakter) {
  dplyr::full_join(
    read_diagnoser(path_diagnoser),
    read_kontakter(path_kontakter),
    by = dplyr::join_by(DW_EK_KONTAKT)
  ) |>
    dplyr::mutate(
      icd_revision = dplyr::case_when(
        dato_start >= as.Date("1995-01-01") ~ "ICD10",
        dato_start < as.Date("1995-01-01") ~ "ICD8"
      ),
      year = as.integer(lubridate::year(dato_start))
    ) |>
    dplyr::select(
      PNR = CPR,
      diagnosis_date = dato_start,
      icd_code = diagnosekode,
      icd_revision,
      year,
      hovedspeciale_ans,
      dato_slut
    )
}


# ICD dataset -------------------------------------------------------------

#' Convert ICD disease classification data from LPR2 to a partitioned Parquet database.
#'
#' @param path_lpr_diag The path to the LPR2 Diagnosis Parquet dataset.
#' @param path_lpr_adm The path to the LPR2 Admissions Parquet dataset.
#' @param output_path The new path to save the ICD data as a Parquet dataset.
#' @param dst_icd_disease_labels The disease labels given by DST for specific
#'   ICD categories.
#'
#' @return A character vector.
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' lpr_adm_paths <- path_parquet_registers("708421") |>
#'   list_parquet_files() |>
#'   get_path_specific_database("lpr_adm")
#' lpr_diag_paths <- path_parquet_registers("708421") |>
#'   list_parquet_files() |>
#'   get_path_specific_database("lpr_diag")
#'
#' create_lpr2_icd_parquet(
#'   path_lpr_adm = lpr_adm_paths,
#'   path_lpr_diag = lpr_diag_paths,
#'   path_alter_for_icd(lpr_diag_paths[1]),
#'   targets::tar_read(dst_icd_disease_labels)
#' )
#' }
#'
create_lpr2_icd_parquet <- function(
    path_lpr_diag, path_lpr_adm,
    output_path, dst_icd_disease_groups) {
  checkmate::assert_file_exists(path_lpr_diag)
  checkmate::assert_file_exists(path_lpr_adm)
  checkmate::assert_scalar(path_lpr_diag)
  checkmate::assert_scalar(path_lpr_adm)
  checkmate::assert_scalar(output_path)
  checkmate::assert_set_equal(
    get_parquet_year(path_lpr_diag),
    get_parquet_year(path_lpr_adm)
  )
  fs::dir_create(fs::path_dir(output_path))

  dst_icd_disease_groups <- dst_icd_disease_groups |>
    arrow::to_duckdb()

  lpr <- read_lpr2(
    path_lpr_diag = path_lpr_diag,
    path_lpr_adm = path_lpr_adm
  )

  icd_labels_with_admissions <- lpr |>
    dplyr::left_join(dst_icd_disease_groups, by = c("icd_code", "icd_revision")) |>
    add_column_specific_diseases()

  icd_labels_with_admissions |>
    dplyr::filter(!is.na(diagnosis_group_code)) |>
    arrow::to_arrow() |>
    arrow::write_parquet(output_path)

  cli::cli_alert_success("Created {.val {output_path}}.")
  output_path
}
#' Convert ICD disease classification data to a partitioned Parquet database.
#'
#' @param path_diagnoser The path to the LPR3 Diagnosis Parquet dataset.
#' @param path_kontakter The path to the LPR3 Admissions Parquet dataset.
#' @param output_dir The new path to save the ICD data as a Parquet dataset.
#' @param dst_icd_disease_labels The disease labels given by DST for specific
#'   ICD categories.
#'
#' @return A character vector.
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' diagnoser_path <- path_parquet_external() |>
#'   list_parquet_files() |>
#'   get_path_specific_database("diagnoser")
#' kontakter_path <- path_parquet_external() |>
#'   list_parquet_files() |>
#'   get_path_specific_database("kontakter")
#'
#' create_lpr3_icd_parquet(
#'   path_kontakter = kontakter_path,
#'   path_diagnoser = diagnoser_path,
#'   output_dir = as.character(fs::path(
#'     path_parquet_external("708421"),
#'     "icd"
#'   )),
#'   targets::tar_read(dst_icd_disease_labels)
#' )
#' }
#'
create_lpr3_icd_parquet <- function(
    path_diagnoser, path_kontakter,
    output_dir, dst_icd_disease_groups) {
  checkmate::assert_file_exists(path_diagnoser)
  checkmate::assert_file_exists(path_kontakter)
  checkmate::assert_scalar(path_diagnoser)
  checkmate::assert_scalar(path_kontakter)
  checkmate::assert_scalar(output_dir)
  fs::dir_create(output_dir)

  dst_icd_disease_groups <- dst_icd_disease_groups |>
    arrow::to_duckdb()

  lpr <- read_lpr3(
    path_diagnoser = path_diagnoser,
    path_kontakter = path_kontakter
  )

  icd_labels_with_admissions <- lpr |>
    dplyr::left_join(dst_icd_disease_groups, by = c("icd_code", "icd_revision")) |>
    add_column_specific_diseases()

  icd_labels_with_admissions |>
    dplyr::filter(!is.na(diagnosis_group_code)) |>
    arrow::to_arrow() |>
    dplyr::group_by(year) |>
    # Ideally this should use write_parquet, but the overlap with
    # LPR2 makes it tricky, plus that LPR3 has all the years in one
    # data file.
    arrow::write_dataset(
      output_dir,
      # Using 'b' since there is some overlap with LPR2.
      basename_template = "part-{i}b.parquet"
    )

  output_paths <- fs::dir_ls(output_dir, regexp = "part-[0-9]+?b\\.parquet", recurse = TRUE)
  cli::cli_alert_success("Created {.val {output_paths}}.")
  output_paths
}

# Helpers -----------------------------------------------------------------

#' Determine whether ICD is 8 or 10 based on date.
#'
#' @param date The date of diagnosis, when the code was used.
#' @keywords internal
#' @return A vector.
#'
get_icd_revision <- function(date) {

}

#' Project specific diseases defined from ICD.
#'
#' Not all diseases we need for our projects are in DST's 99 overall classified
#' diseases.
#'
#' @param data A `data.frame` type object (DuckDB, tibble, data.table). Assumes
#'   DuckDB SQL connection.
#'
#' @return Same output as input.
#' @keywords internal
#'
add_column_specific_diseases <- function(data) {
  data |>
    dplyr::mutate(
      specific_diseases = dplyr::case_when(
        icd_code %similar to% "^(DI2[0-5][0-9]?|41[0-4][0-9][0-9])$" ~ "Ischaemic Heart Disease",
        icd_code %similar to% "^(DI6[13-6][0-9]?|DI69[34]?|43[0-8][09][0-9]?)$" ~ "Stroke",
        icd_code %similar to% "^(DI50[0-9]?|DI1[13][02]?|42[689][0-9][0-9]?)$" ~ "Heart Failure",
        icd_code %similar to% "^(DI7[04][0-9]?|DI739?|44[0-24][0-9][0-9]?)$" ~ "Peripheral Artery Disease"
      )
    )
}
