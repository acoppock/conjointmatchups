# Matchup extraction ----

#' Extract matchups realizing a contrast between two profiles
#'
#' A *matchup* is the subset of choice tasks in which one profile carries the
#' attributes pinned in `A` and the other carries the attributes pinned in `B`
#' (in either display position). `get_matchups()` filters `tasks` to those rows
#' and returns them with a single binary outcome, `winner`, equal to 1 when the
#' A-side profile was chosen. This turns an arbitrary conjoint into a clean
#' pairwise sub-experiment ready for estimation (see [afcp()]).
#'
#' `A` and `B` are named lists mapping attribute names (the stems, without the
#' profile suffix) to the level each side is pinned to. An empty list leaves that
#' side unconstrained.
#'
#' For the contrast to be well defined, A and B must be **mutually exclusive**:
#' they must pin at least one shared attribute to different levels. Otherwise a
#' single profile can satisfy both sides and the "estimate" reflects display
#' position (primacy), not a real difference. When `check_contrast = TRUE` (the
#' default) an invalid contrast raises an error explaining why; see
#' [valid_contrast()].
#'
#' @param tasks A data frame in task-wide form (see [as_tasks()]).
#' @param A,B Named lists mapping attribute stems to pinned levels for each side.
#' @param outcome Name (stem) of the per-profile choice-indicator columns
#'   (e.g. `"chosen"` for columns `chosen_1`, `chosen_2`). Values must be 0/1.
#' @param profiles Length-2 character vector of the profile suffixes. Defaults to
#'   `c("1", "2")`.
#' @param sep Separator between an attribute stem and its profile suffix.
#' @param winner Name for the returned binary outcome column. Defaults to
#'   `"A_wins"`.
#' @param keep Character vector of columns to carry through to the result. If
#'   `NULL` (default), every column that is *not* profile-specific (i.e. does not
#'   end in `sep` + a profile suffix) is kept: task keys, respondent covariates,
#'   weights, and so on.
#' @param check_contrast If `TRUE`, error on a contrast that is not mutually
#'   exclusive.
#'
#' @return A tibble of the matched tasks: the `keep` columns plus the `winner`
#'   column (0/1).
#'
#' @examples
#' tasks <- data.frame(
#'   study_id = "s1", resp_id = c(1, 1, 2, 2),
#'   party_1  = c("R", "D", "R", "R"), party_2 = c("D", "R", "R", "D"),
#'   chosen_1 = c(1, 0, 1, 1),          chosen_2 = c(0, 1, 0, 0)
#' )
#' get_matchups(tasks, A = list(party = "R"), B = list(party = "D"),
#'              outcome = "chosen")
#' @export
get_matchups <- function(tasks, A, B, outcome, profiles = c("1", "2"),
                         sep = "_", winner = "A_wins", keep = NULL,
                         check_contrast = TRUE) {
  stopifnot(is.data.frame(tasks), length(profiles) == 2L)
  if (check_contrast && !valid_contrast(A, B)) {
    stop(contrast_message(A, B), call. = FALSE)
  }
  s1 <- profiles[1]
  s2 <- profiles[2]

  needed <- c(
    paste0(names(A), sep, s1), paste0(names(A), sep, s2),
    paste0(names(B), sep, s1), paste0(names(B), sep, s2),
    paste0(outcome, sep, s1), paste0(outcome, sep, s2)
  )
  missing_cols <- setdiff(unique(needed), names(tasks))
  if (length(missing_cols)) {
    stop("Columns not found in `tasks`: ",
         paste(missing_cols, collapse = ", "), call. = FALSE)
  }

  match_side <- function(d, attr_list, suffix) {
    if (length(attr_list) == 0) return(rep(TRUE, nrow(d)))
    keepv <- rep(TRUE, nrow(d))
    for (a in names(attr_list)) {
      col <- paste0(a, sep, suffix)
      keepv <- keepv & (as.character(d[[col]]) == as.character(attr_list[[a]]))
    }
    keepv & !is.na(keepv)
  }

  A_in_1 <- match_side(tasks, A, s1) & match_side(tasks, B, s2)
  A_in_2 <- match_side(tasks, A, s2) & match_side(tasks, B, s1)
  A_in_1[is.na(A_in_1)] <- FALSE
  A_in_2[is.na(A_in_2)] <- FALSE

  rows <- A_in_1 | A_in_2
  out <- tasks[rows, , drop = FALSE]
  a1 <- A_in_1[rows]
  sel1 <- out[[paste0(outcome, sep, s1)]]
  sel2 <- out[[paste0(outcome, sep, s2)]]
  a_winner <- as.integer((a1 & sel1 == 1) | (!a1 & sel2 == 1))

  if (is.null(keep)) {
    suffix_pat <- paste0(sep, "(", paste(profiles, collapse = "|"), ")$")
    keep <- names(out)[!grepl(suffix_pat, names(out))]
  } else {
    keep <- intersect(keep, names(out))
  }

  res <- tibble::as_tibble(out[, keep, drop = FALSE])
  res[[winner]] <- a_winner
  res
}

#' Is a matchup contrast well defined?
#'
#' A forced-choice contrast requires candidates A and B to be mutually
#' exclusive: they must pin at least one shared attribute to different levels.
#' Otherwise a single profile can satisfy both sides, the matchup includes tasks
#' where the two candidates are identical on the pinned attributes, and the
#' outcome reflects display position rather than any real difference.
#'
#' @param A,B Named lists mapping attribute stems to pinned levels.
#' @return `TRUE` if the contrast is well defined, `FALSE` otherwise.
#' @seealso [contrast_message()], [get_matchups()]
#' @examples
#' valid_contrast(list(party = "R"), list(party = "D"))   # TRUE
#' valid_contrast(list(party = "R"), list(gender = "F"))  # FALSE (no shared attr)
#' valid_contrast(list(party = "R"), list(party = "R"))   # FALSE (identical)
#' @export
valid_contrast <- function(A, B) {
  shared <- intersect(names(A), names(B))
  if (length(shared) == 0) return(FALSE)
  any(vapply(shared, function(a) !identical(A[[a]], B[[a]]), logical(1)))
}

#' Explain why a matchup contrast is not well defined
#'
#' Produces a human-readable message for a contrast rejected by
#' [valid_contrast()], for use in error messages or interactive UIs.
#'
#' @inheritParams valid_contrast
#' @return A length-1 character string.
#' @seealso [valid_contrast()]
#' @examples
#' contrast_message(list(party = "R"), list(party = "R"))
#' @export
contrast_message <- function(A, B) {
  shared <- intersect(names(A), names(B))
  same <- shared[vapply(shared, function(a) identical(A[[a]], B[[a]]), logical(1))]
  if (length(shared) == 0) {
    base <- "Candidates A and B don't share an attribute to contrast on."
  } else {
    base <- sprintf("Candidates A and B are identical on: %s.",
                    paste(same, collapse = ", "))
  }
  paste(base,
        "A clean comparison needs them to differ on a shared attribute,",
        "e.g. A: party = Republican vs B: party = Democrat.",
        "As specified, the matchup compares identical profiles and reflects",
        "which position was shown first, not a real difference.")
}
