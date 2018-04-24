#' drop_totals
#'
#' Drops rows containing totals
#'
#' Takes a data.frame and filters it to return rows that do not contain the
#' word "total" without paying attention to case.
#'
#' @author Alyssa Savo
#'
#' @param df A data.frame
#'
#' @export

drop_totals <- function(df) {
  `%>%` <- magrittr::`%>%`
  df <- df %>%
    filter_all(all_vars(!grepl('Total',., ignore.case = TRUE)))
  df
}