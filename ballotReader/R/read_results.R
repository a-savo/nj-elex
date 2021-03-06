#' read_results
#'
#' Imports and tidies election results from simply-formatted .pdf files.
#'
#' This function should help read and tidy election results from simple and well-
#' formatted .pdf table, where localities (county, city, voting district, etc.)
#' are listed in the first column, candidate vote totals are listed in all
#' subsequent columns, and vertical text is not used for column names or other parts
#' of the table. See read_vertical_results for well-formatted results where column
#' names are formatted vertically.
#'
#' @author Alyssa Savo
#'
#' @param file A URL or path to a .pdf file.
#' @param merged_header FALSE by default. If the table has merged headers
#' grouping the candidates (by race, etc.) in the first row, setting this to TRUE
#' will drop that row.
#'
#' @examples
#' url <- "data/hor_nj01_17.csv"
#' read_results(url)
#'
#' @export
#'

read_results <- function(file, merged_header = FALSE) {
  `%>%` <- magrittr::`%>%`

  # Extract pdf tables into a list of matrices
  pages <- tabulizer::extract_tables(file)

  # If extra header, drop the first row of each page
  if (merged_header == TRUE) {
    for (i in 1:length(pages)) {
      pages[[i]] <- pages[[i]][-1,]
    }
  }

  # Combine pages into single data.frame and use first row as colnames
  all_elex <- as.data.frame(do.call("rbind", pages), stringsAsFactors = FALSE)
  names <- as.vector(all_elex[1,])
  names(all_elex) <- names

  # Drop empty rows, rename first column, and create subheader column
  all_elex <- all_elex %>%
    fill_na() %>%
    unique() %>%
    dplyr::rename(Municipality = !!names(.[1])) %>%
    dplyr::mutate(count_na = ncol(all_elex)-apply(., 1, function(x) sum(is.na(x)))) %>%
    dplyr::mutate(Subgroup = ifelse(count_na == 1, Municipality,NA))


  if (sum(!is.na(all_elex$count_na)) > 0) {
    all_elex <- all_elex %>%
      # Fill in Subgroup with subheaders if they exist
      tidyr::fill(Subgroup) %>%
      dplyr::select(Subgroup, dplyr::everything(), -count_na) %>%
      # Drop empty subheader rows
      dplyr::filter(!(Subgroup == Municipality)) %>%
      # Gather candidate results into single column
      tidyr::gather(-Subgroup, -Municipality, key = "Candidate", value = "Votes") %>%
      dplyr::mutate(Votes = as.numeric(gsub('[,]', '', Votes)))
  } else {
    all_elex <- all_elex %>%
    # If no subheaders, drop those cols and gather candidate results
      dplyr::select(dplyr::everything(), -count_na, -Subgroup) %>%
      tidyr::gather(-Municipality, key = "Candidate", value = "Votes") %>%
      dplyr::mutate(Votes = as.numeric(gsub('[,]', '', Votes)))
  }

  all_elex
}
