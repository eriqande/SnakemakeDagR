
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



#' @importFrom dplyr  case_when count filter group_by left_join mutate n pull rename select ungroup
#' @importFrom purrr  map_chr
#' @importFrom stats setNames
#' @importFrom stringr  str_c str_detect str_replace str_replace_all str_split
#' @importFrom tibble tibble
#' @importFrom tidyr  extract replace_na
NULL


if(getRversion() >= "2.15.1")  {
  utils::globalVariables(
    c(
      ".",
      "add_to_label",
      "canonical",
      "decorations",
      "dest_canonical",
      "dest_id",
      "dest_idx",
      "dest_status",
      "id",
      "node_n",
      "origin_canonical",
      "origin_dest",
      "origin_idx",
      "origin_status",
      "status",
      "wildcards",
      "wildlabel",
      "wildlist"
    )
  )
}
