

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Named capture groups
#'
#' @param string input character vector
#' @param pattern a regex using named capture groups as used in \code{glue} and
#'        \code{unglue}
#' @param delim delimiters of the named capture groups. Note: Very litte sanity
#'        checking is done here. You'll want to be able to guarantee that these
#'        delims do not appear in your actual string input otherwise things
#'        will not go as you want. Caveat Emptor!
#'
#' @return data.frame of captured groups
#'
#' @import stringr
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
str_capture <- function(string, pattern, delim = c('{', '}')) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Assert delim is sane
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  stopifnot(length(delim) == 2L)
  stopifnot(delim[1L] != delim[2L])
  stopifnot(all(nchar(delim) == 1L))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # This is how the capture patterns will be extracted e.g. "<.*?>"
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  capture_pattern <- paste0("(\\", delim[1L], ".*?\\", delim[2L], ")")

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Extract the captured names + regexs from the user-supplied patterns
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  capture_groups <- stringr::str_match_all(pattern, capture_pattern)[[1L]][,-1L]
  capture_groups <- stringr::str_sub(capture_groups, start = 2L,
                                    end = stringr::str_length(capture_groups) - 1L)

  capture_groups <- stringr::str_split_fixed(capture_groups, '=', 2)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Sanity check the names
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  capture_names <- capture_groups[,1L]
  stopifnot(length(capture_names) > 0L)
  stopifnot(!anyNA(capture_names))
  stopifnot(all(nchar(capture_names) > 0L))
  stopifnot(!anyDuplicated(capture_names))


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # massage the regexes. pay attention to backslashes
  # if no regex supplied, use ".*?"
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  capture_regex <- capture_groups[,2L]
  capture_regex[capture_regex == ''] <- '.*?'
  capture_regex <- paste0("(", capture_regex, ")")
  capture_regex <- stringr::str_replace_all(capture_regex, "\\\\", "\\\\\\\\")


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Replace the users capture pattern with just the user-supplied regex for
  # this capture group
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final_pattern <- pattern
  for (new_regex in capture_regex) {
    final_pattern <- stringr::str_replace(final_pattern, capture_pattern, new_regex)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Run the regex and create a data.frame result
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  res <- stringr::str_match(string, final_pattern)[,-1L, drop = FALSE]
  res <- as.data.frame(res)
  names(res) <- capture_names


  res
}


if (FALSE) {
  delim   <- c('<', '>')

  string <- c(
    "information: name:greg age:27 ",
    "information: name:mary age:34 "
  )

  pattern <- "name:{name} age:{age=\\d+}"

  str_capture(string, pattern)




}
