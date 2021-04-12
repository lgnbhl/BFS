# source: https://github.com/r-hub/pkgsearch/blob/master/R/utils.R

check_string <- function(x) {
  if (!is.character(x) || length(x) != 1 || is.na(x)) {
    throw(new_error(x, " is not a string", call. = FALSE))
  }
}

`%+%` <- function(lhs, rhs) {
  check_string(lhs)
  check_string(rhs)
  paste0(lhs, rhs)
}

snake_case <- function(x) {
  check_string(x)
  x <- tolower(x)
  gsub(".", "_", x, fixed = TRUE)
}

pluck <- function(list, idx)
  list[[idx]][[1]]

patch_pxR <- function(tmp_loc) {
  # ADD FIX. see: https://github.com/cjgb/pxR/issues/1#issuecomment-800023341
  fix <-
    iconv(
      readLines(tmp_loc, encoding = "CP1252"),
      from = "CP1252",
      to = "Latin1",
      sub = ""
    )
  fix <- gsub('\"......\"', '\"....\"', fix, fixed = TRUE)
  fix <- gsub('\".....\"', '\"....\"', fix, fixed = TRUE)
  writeLines(fix, con = tmp_loc, useBytes = TRUE)
}