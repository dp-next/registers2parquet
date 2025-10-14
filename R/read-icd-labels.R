#' Reads one individual ICD label file from DST's documentation.
#'
#' This imports *either* the ICD8 or ICD10 "L1L2_KT" files in DST's variable
#' format folder. L1L2 stands for DST's "99 disease groupings". There's another
#' one for "23 disease groupings", but we'll use this one to have a bit more
#' resolution at the disease level.
#'
#' @param icd_revision Either ICD8 or ICD10.
#' @keywords internal
#'
#' @return A tibble.
#'
#' @examples
#'
#' read_specific_icd_disease_labels("ICD8")
#' read_specific_icd_disease_labels("ICD10")
#'
read_specific_icd_disease_labels <- function(icd_revision = c("ICD8", "ICD10")) {
  icd_revision <- rlang::arg_match(icd_revision)
  icd_file_path <- fs::path(
    "e:",
    "Formater",
    "SAS formater i Danmarks Statistik",
    "TXT_filer",
    "Sundhed",
    # L1L2 = 99 groups of diseases
    # KT = Codes and Text for the groups
    glue::glue("C_{icd_revision}_L1L2_KT.txt")
  )

  readr::read_delim(
    icd_file_path,
    delim = ";",
    col_types = "c",
    locale = readr::locale(encoding = "latin1")
  ) |>
    dplyr::rename(
      icd_code = START,
      dst_diagnosis_group = glue::glue("{icd_revision}_L1L2_KT")
    ) |>
    dplyr::mutate(icd_revision = icd_revision) |>
    tidyr::extract(
      col = dst_diagnosis_group,
      into = c("diagnosis_group_code", "dst_diagnosis_group"),
      regex = "^([[:digit:]]{3}) +(.*)$"
    ) |>
    dplyr::filter(diagnosis_group_code != "000")
}

#' Read both ICD8 and ICD10 labeling data as a tibble.
#'
#' Calls [read_specific_icd_labels()] for both ICD8 and ICD10, then joins both.
#'
#' @export
#' @return A tibble.
#'
#' @examples
#'
#' read_icd_disease_labels()
#'
read_icd_disease_labels <- function() {
  dplyr::bind_rows(
    read_specific_icd_disease_labels("ICD8"),
    read_specific_icd_disease_labels("ICD10")
  )
}
