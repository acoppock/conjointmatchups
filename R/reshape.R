# Profile <-> task reshaping ----

#' Reshape profile-level (long) conjoint data to task-level (wide)
#'
#' Each choice task appears as two profile rows in the input. `as_tasks()`
#' pivots those rows into a single wide row per task, suffixing every
#' non-key column with the profile index (e.g. `party` becomes `party_1` and
#' `party_2`). This is the representation used for modeling the binary choice
#' and for [get_matchups()].
#'
#' @param profiles A data frame in profile-long form: one row per candidate
#'   profile per task.
#' @param task_keys Character vector of column names that jointly identify a
#'   choice task (e.g. `c("study_id", "resp_id", "task_id")`). These are carried
#'   through unchanged.
#' @param profile Name of the column indexing the profile within a task (values
#'   such as `1`/`2`). Its values become the column-name suffixes.
#' @param outcome Optional name of the choice-indicator column. If supplied, the
#'   resulting per-profile outcome columns are coerced to numeric (they are
#'   character after pivoting, like every attribute).
#' @param sep Separator between an attribute name and the profile suffix.
#'   Defaults to `"_"`.
#'
#' @return A tibble with one row per task: `task_keys` plus, for every other
#'   input column `x` and every profile value `p`, a column `x{sep}p`.
#'
#' @seealso [as_profiles()] for the inverse.
#' @examples
#' profiles <- data.frame(
#'   task_id = c(1, 1, 2, 2),
#'   profile = c(1, 2, 1, 2),
#'   party   = c("R", "D", "D", "R"),
#'   chosen  = c(1, 0, 0, 1)
#' )
#' as_tasks(profiles, task_keys = "task_id", profile = "profile",
#'          outcome = "chosen")
#' @export
as_tasks <- function(profiles, task_keys, profile, outcome = NULL, sep = "_") {
  stopifnot(is.data.frame(profiles))
  missing_cols <- setdiff(c(task_keys, profile), names(profiles))
  if (length(missing_cols)) {
    stop("Columns not found in `profiles`: ",
         paste(missing_cols, collapse = ", "), call. = FALSE)
  }

  value_cols <- setdiff(names(profiles), c(task_keys, profile))
  prof_vals <- unique(as.character(profiles[[profile]]))

  wide <- profiles |>
    dplyr::mutate(dplyr::across(dplyr::all_of(value_cols), as.character)) |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(value_cols),
      names_to = ".attribute", values_to = ".value"
    ) |>
    tidyr::pivot_wider(
      names_from = dplyr::all_of(c(".attribute", profile)),
      values_from = ".value", names_sep = sep
    )

  if (!is.null(outcome)) {
    out_cols <- paste0(outcome, sep, prof_vals)
    out_cols <- intersect(out_cols, names(wide))
    wide <- wide |>
      dplyr::mutate(dplyr::across(dplyr::all_of(out_cols), as.numeric))
  }
  wide
}

#' Reshape task-level (wide) conjoint data to profile-level (long)
#'
#' The inverse of [as_tasks()]. Columns matching `x{sep}{profile value}` are
#' pivoted back into one row per profile per task; columns that do not match
#' (task-level or respondent-level covariates) are recycled across the profiles.
#'
#' @param tasks A data frame in task-wide form.
#' @param task_keys Character vector of column names identifying a task. Together
#'   with `profile_to` these key the output.
#' @param profiles Character vector of the profile values to unstack. Defaults to
#'   `c("1", "2")`.
#' @param sep Separator between an attribute name and the profile suffix.
#' @param profile_to Name for the new profile-index column in the output.
#'
#' @return A tibble in profile-long form.
#' @seealso [as_tasks()] for the inverse.
#' @examples
#' tasks <- data.frame(
#'   task_id  = c(1, 2),
#'   party_1  = c("R", "D"), party_2 = c("D", "R"),
#'   chosen_1 = c(1, 0),      chosen_2 = c(0, 1)
#' )
#' as_profiles(tasks, task_keys = "task_id")
#' @export
as_profiles <- function(tasks, task_keys, profiles = c("1", "2"),
                        sep = "_", profile_to = "profile") {
  stopifnot(is.data.frame(tasks))
  pat <- paste0("^(.*)", sep, "(", paste(profiles, collapse = "|"), ")$")
  value_cols <- grep(pat, names(tasks), value = TRUE)
  if (length(value_cols) == 0) {
    stop("No columns match the pattern `attribute", sep,
         "{profile}`. Check `profiles` and `sep`.", call. = FALSE)
  }

  tasks |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(value_cols),
      names_pattern = pat,
      names_to = c(".attribute", profile_to),
      values_transform = list(value = as.character)
    ) |>
    tidyr::pivot_wider(names_from = ".attribute", values_from = "value")
}
