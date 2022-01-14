
#### Import the pipe operator from magrittr ####
#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
#' @noRd
NULL



#' @importFrom dplyr  case_when count filter left_join mutate n pull rename select
#' @importFrom stats setNames
#' @importFrom stringr  str_c str_detect str_replace
#' @importFrom tibble tibble
#' @importFrom tidyr  extract replace_na
NULL


if(getRversion() >= "2.15.1")  {
  utils::globalVariables(
    c(
      ".",
      "canonical",
      "decorations",
      "dest_canonical",
      "dest_id",
      "dest_idx",
      "dest_status",
      "id",
      "origin_canonical",
      "origin_dest",
      "origin_idx",
      "origin_status",
      "status",
      "wildcards"
    )
  )
}
