#' Create the PDF files of the documentation.
#'
#' @return Nothing, builds the PDF based on the Quarto book format.
#' @keywords internal
#'
build_docs <- function() {
  withr::with_dir(
    here::here("vignettes"),
    {
      quarto::quarto_render(output_format = "pdf")
    }
  )
  return(invisible(NULL))
}
