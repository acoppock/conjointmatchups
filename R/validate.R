# Data-contract validation ----

#' Check that task-wide data is a valid forced-choice conjoint
#'
#' Verifies the invariants a binary forced-choice conjoint must satisfy in
#' task-wide form: the two per-profile outcome columns exist, their values are
#' 0/1, and exactly one profile is chosen in every task. Generalizes the
#' structural checks used when cleaning a conjoint study.
#'
#' @param tasks A data frame in task-wide form (see [as_tasks()]).
#' @param outcome Name (stem) of the per-profile choice-indicator columns.
#' @param profiles Length-2 character vector of profile suffixes.
#' @param sep Separator between an attribute stem and its profile suffix.
#'
#' @return Invisibly, `tasks`. Called for its side effect of erroring on a
#'   violated invariant.
#' @examples
#' tasks <- data.frame(chosen_1 = c(1, 0), chosen_2 = c(0, 1))
#' check_conjoint(tasks)
#' @export
check_conjoint <- function(tasks, outcome = "chosen", profiles = c("1", "2"),
                           sep = "_") {
  stopifnot(is.data.frame(tasks), length(profiles) == 2L)
  o1 <- paste0(outcome, sep, profiles[1])
  o2 <- paste0(outcome, sep, profiles[2])

  missing_cols <- setdiff(c(o1, o2), names(tasks))
  if (length(missing_cols)) {
    stop("Outcome columns not found: ", paste(missing_cols, collapse = ", "),
         call. = FALSE)
  }

  v1 <- tasks[[o1]]
  v2 <- tasks[[o2]]
  if (!all(v1 %in% c(0, 1, NA)) || !all(v2 %in% c(0, 1, NA))) {
    stop("Outcome columns must be 0/1.", call. = FALSE)
  }

  total <- v1 + v2
  bad <- which(total != 1)
  if (length(bad)) {
    stop(length(bad), " task(s) do not have exactly one chosen profile ",
         "(e.g. row ", bad[1], ").", call. = FALSE)
  }
  invisible(tasks)
}
