selected_birth_or_adoption_categories <- c(21:23, 31:33, 35)

# # 0- No parent-remove
#     When one of the parents is present then keep the arent if they do not have adoption code
# 1 & 2 has no documentation on DST webpage. remove
# 11- adoptive relationship according to adoption register-- remove
# 12- child in adoption register but adoption relationship can be with
#     another parents-- remove
# 14- parent has opposite sex-- remove
#     if MOR_ID!= MOR_ID_ADOP, then use MOR_ID. MOR_ID_ADOP usually match MOR1.
#     check fathers
# 15- adoption marking in cpr-- remove
# 16- only mother, only after child is 30 days old
# 17- only mothers, adoption marker in former ftdb-- remove
# 18- only mothers of children born after Jan 1991

# 21- parent register shortly after birth-- keep
# 22- parent register shortly after birth, subsequently adopted
#     FAR_ID==FAR_ID_ADOP, then keep FAR_ID, this match FAR1
#     FAR_ID!=FAR_ID_ADOP, then use FAR_ID_ADOP, this match FAR1
#     Do the same with mother ids
# 23- parent register shortly after birth, subsequently adopted, adoption revoked
# 31- child is an immigrant-- keep for the moment, discuss what to do
#     about them
#
# 32- child is registered to be born abroad-- keep, here we assume that the
#     parents are the biological
# 33- children born before 1973// keep
# 35- child born abroad or before 1973 and subsequently adopted-- keep, same as
#     in 22.
#     FAR_ID==FAR_ID_ADOP, then keep FAR_ID, this match FAR1
#     FAR_ID!=FAR_ID_ADOP, then use FAR_ID_ADOP, this match FAR1
#     Do the same with  mother ids
# 39- other parental relationships-- remove because with do not know what this
#     category means
list_birth_or_adoption_categories <- function() {
  # Could be either MOR_ or FER_ for father or mother since they are the same.
  readr::read_delim(
    fs::path(dst_path()$sas_formats, "C_FER_FOED_ADOP_T.txt"),
    delim = ";",
    show_col_types = FALSE,
    locale = readr::locale(encoding = "latin1")
  ) |>
    dplyr::rename(FOED_ADOP_TEXT = FER_FOED_ADOP_T, FOED_ADOP_NUMBER = START)
}
