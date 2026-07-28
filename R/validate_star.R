#' Check a conjoint cleaned as a relational star
#'
#' Validates the three-frame ("relational star") representation of a cleaned
#' conjoint study: one row per respondent (`resp`), one row per candidate
#' profile shown (`cand`), and one row per task (`task`). This is the shape a
#' meta-analysis cleaning pipeline persists, and it carries invariants that
#' [check_conjoint()] cannot see, because that function validates a single
#' task-wide frame.
#'
#' The two functions divide as follows. [check_conjoint()] is a contract check
#' on the task-wide shape [as_tasks()] produces: the outcome columns exist, are
#' 0/1, and exactly one profile wins. `check_conjoint_star()` additionally
#' checks relational integrity *across* frames (unique keys, profile
#' cardinality, row-count agreement, orphaned respondents), plus the
#' data-quality problems a cleaning pipeline needs to surface.
#'
#' Severity is deliberately split. Structural invariants that hold for every
#' standard paired design are **errors**. Data-quality problems that can
#' legitimately vary between studies are **warnings**, so a study that needs
#' attention still saves and surfaces loudly rather than halting a whole-corpus
#' run on the first offender.
#'
#' The one-winner check is computed over *answered* tasks only, i.e. those with
#' at least one non-`NA` outcome. All-`NA` tasks are item nonresponse or
#' by-design abstention, and counting them would make benign nonresponse
#' indistinguishable from a broken outcome mapping.
#'
#' @param cand One row per candidate profile shown. Must contain the columns
#'   named by `keys` and `profile`, and normally the `outcome` column.
#' @param task One row per task. Used for the row-count invariant
#'   `nrow(cand) == nrow(task) * 2`.
#' @param resp One row per respondent. Must be uniquely keyed by `resp_key`.
#' @param keys Character vector identifying a profile row within the study.
#' @param profile Column holding the profile slot within a task; its values must
#'   be the two levels in `profiles`.
#' @param profiles Length-2 vector of valid profile slots.
#' @param outcome Column holding the per-profile choice indicator. Checked only
#'   when present.
#' @param resp_key Column(s) uniquely keying `resp`.
#' @param weights Column expected to carry respondent weights, or `NULL` to skip
#'   the weights check.
#' @param study_id Column holding a single study identifier, or `NULL` to skip.
#'   Used to prefix warnings so a corpus-wide run says which study complained.
#' @param min_one_winner Warn when the share of answered tasks with exactly one
#'   selected profile falls below this.
#'
#' @return Invisibly, `TRUE`. Called for its errors and warnings.
#' @examples
#' resp <- data.frame(study_id = "s1", resp_id = c("r1", "r2"), resp_weights = 1)
#' cand <- data.frame(
#'   study_id = "s1",
#'   resp_id = rep(c("r1", "r2"), each = 2),
#'   task_id = rep(c("r1_t1", "r2_t1"), each = 2),
#'   cand_profile = rep(1:2, 2),
#'   cand_selected = c(1, 0, 0, 1),
#'   resp_weights = 1
#' )
#' task <- data.frame(
#'   study_id = "s1", resp_id = c("r1", "r2"), task_id = c("r1_t1", "r2_t1")
#' )
#' check_conjoint_star(cand, task, resp)
#' @seealso [check_conjoint()] for the task-wide contract check.
#' @export
check_conjoint_star <- function(cand, task, resp,
                                keys = c("resp_id", "task_id", "cand_profile"),
                                profile = "cand_profile",
                                profiles = c(1, 2),
                                outcome = "cand_selected",
                                resp_key = c("study_id", "resp_id"),
                                weights = "resp_weights",
                                study_id = "study_id",
                                min_one_winner = 0.9) {
  stopifnot(is.data.frame(cand), is.data.frame(task), is.data.frame(resp))
  stopifnot(length(profiles) == 2L)

  missing_cols <- setdiff(c(keys, profile), names(cand))
  if (length(missing_cols)) {
    stop("cand is missing column(s): ", paste(missing_cols, collapse = ", "),
         call. = FALSE)
  }

  # A label for messages, so a corpus run says which study complained.
  sid <- NULL
  if (!is.null(study_id) && study_id %in% names(cand)) {
    sid <- unique(cand[[study_id]])
    if (length(sid) != 1L) {
      stop("cand holds ", length(sid), " distinct ", study_id,
           " values; expected exactly 1.", call. = FALSE)
    }
  }
  tag <- function(...) paste0(if (is.null(sid)) "" else paste0(sid, ": "), ...)

  # structural invariants (errors) -----------------------------------------
  resp_key_present <- intersect(resp_key, names(resp))
  if (length(resp_key_present) && any(duplicated(resp[resp_key_present]))) {
    stop(tag("resp is not uniquely keyed by ",
             paste(resp_key_present, collapse = ", ")), call. = FALSE)
  }
  if (any(duplicated(cand[keys]))) {
    stop(tag("cand has duplicate rows on ", paste(keys, collapse = ", ")),
         call. = FALSE)
  }
  if (!all(cand[[profile]] %in% profiles)) {
    stop(tag(profile, " must be one of ", paste(profiles, collapse = "/")),
         call. = FALSE)
  }

  task_key <- setdiff(keys, profile)
  n_per_task <- table(interaction(cand[task_key], drop = TRUE))
  if (!all(n_per_task == 2L)) {
    stop(tag(sum(n_per_task != 2L), " task(s) do not have exactly 2 profiles"),
         call. = FALSE)
  }
  if (nrow(cand) != nrow(task) * 2L) {
    stop(tag("nrow(cand) is ", nrow(cand), " but nrow(task) * 2 is ",
             nrow(task) * 2L), call. = FALSE)
  }

  # data-quality checks (warnings) -----------------------------------------
  if (!is.null(outcome) && outcome %in% names(cand)) {
    v <- suppressWarnings(as.numeric(cand[[outcome]]))
    key <- interaction(cand[task_key], drop = TRUE)
    per_task_sum <- tapply(v, key, sum, na.rm = TRUE)
    answered <- tapply(v, key, function(x) any(!is.na(x)))

    n_multi <- sum(per_task_sum > 1)
    if (n_multi > 0) {
      warning(tag(n_multi, " task(s) select >1 profile; not a binary choice"),
              call. = FALSE)
    }
    if (any(answered)) {
      frac <- mean(per_task_sum[answered] == 1)
      if (frac < min_one_winner) {
        warning(tag("only ", round(100 * frac),
                    "% of answered tasks have exactly one selected profile"),
                call. = FALSE)
      }
    }
  }

  resp_id_col <- utils::tail(setdiff(resp_key, study_id), 1)
  if (length(resp_id_col) && all(resp_id_col %in% c(names(cand), names(resp)))) {
    orphans <- setdiff(cand[[resp_id_col]], resp[[resp_id_col]])
    if (length(orphans) > 0) {
      warning(tag(length(orphans), " cand ", resp_id_col,
                  "(s) not in resp (NA covariates)"), call. = FALSE)
    }
  }

  if (!is.null(weights)) {
    if (!weights %in% names(cand)) {
      warning(tag(weights, " missing"), call. = FALSE)
    } else if (any(is.na(cand[[weights]]))) {
      warning(tag(sum(is.na(cand[[weights]])), " NA ", weights), call. = FALSE)
    }
  }

  labelled <- names(cand)[vapply(cand, function(x) inherits(x, "haven_labelled"),
                                 logical(1))]
  if (length(labelled) > 0) {
    warning(tag("haven_labelled columns present: ",
                paste(labelled, collapse = ", ")), call. = FALSE)
  }

  invisible(TRUE)
}
