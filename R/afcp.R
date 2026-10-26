# Thin AFCP estimator ----

#' Average Feature Choice Probability from a matchup
#'
#' A convenience wrapper that closes the loop on the matchup workflow: given the
#' output of [get_matchups()], it estimates the probability that the A-side
#' profile is chosen (the AFCP), optionally within respondent-clustered,
#' weighted groups. The estimation itself is a one-liner over
#' `estimatr::lm_robust()`; this function exists only to make
#' `as_profiles() |> as_tasks() |> get_matchups() |> afcp()` a complete
#' workflow. For richer estimands (AMCE, marginal means) use 'cregg' or 'cjoint'.
#'
#' @param matchups A data frame from [get_matchups()].
#' @param outcome Name of the binary outcome column. Defaults to `"A_wins"`.
#' @param null_value The value of the AFCP under the null hypothesis, against
#'   which `statistic` and `p.value` are computed. Defaults to `0.5`, the
#'   coin-flip null: an AFCP of 0.5 means the A-side profile is chosen half the
#'   time, so a test against 0 is almost never the test of interest. Set to `0`
#'   to recover the usual intercept test, or to any other value to test a
#'   different null.
#' @param by Optional character vector of grouping columns (e.g. `"study_id"`);
#'   one AFCP is returned per group.
#' @param clusters Optional name of the cluster column (e.g. `"resp_id"`) for
#'   cluster-robust standard errors.
#' @param weights Optional name of a survey-weight column.
#' @param se_type Standard-error type passed to `estimatr::lm_robust()`. The
#'   default `NULL` lets `lm_robust()` choose its own default: `"CR2"` when
#'   `clusters` is supplied, `"HC2"` otherwise. Set explicitly (e.g. `"stata"`)
#'   only to override that.
#' @param min_clusters When `clusters` is supplied, groups with fewer than this
#'   many distinct clusters are dropped rather than estimated (a single-cluster
#'   AFCP has no usable sampling variance). Ignored without `clusters`.
#'
#' @return A tidy tibble, one row per group (or a single row when `by` is
#'   `NULL`): the grouping columns (if any) plus `estimate` (the AFCP),
#'   `std.error`, `statistic`, `p.value`, `conf.low`, `conf.high`, `df`,
#'   `n` and `n_clusters`. `statistic` is `(estimate - null_value) /
#'   std.error` and `p.value` is its two-sided t-test; `estimate`,
#'   `std.error` and the confidence interval do not depend on `null_value`.
#'   `n` counts observations, which for a matchup means choice tasks, and
#'   `n_clusters` counts distinct clusters, which means respondents when
#'   `clusters` is a respondent id and is `NA_integer_` when `clusters` is not
#'   supplied. Both are returned because `n` alone leaves a caller no way to
#'   report respondents, even though `lm_robust()` has already counted them.
#'   This is the tidy-tibble form, not a fit object, so that many per-group
#'   AFCPs compose directly into a meta-analysis; call
#'   `estimatr::lm_robust()` yourself if you need the fit.
#'
#' @examples
#' \donttest{
#' tasks <- data.frame(
#'   study_id = "s1", resp_id = rep(1:20, each = 2),
#'   party_1  = rep(c("R", "D"), 20), party_2 = rep(c("D", "R"), 20),
#'   chosen_1 = rep(c(1, 0), 20),      chosen_2 = rep(c(0, 1), 20)
#' )
#' m <- get_matchups(tasks, list(party = "R"), list(party = "D"),
#'                   outcome = "chosen")
#' if (requireNamespace("estimatr", quietly = TRUE)) {
#'   afcp(m, by = "study_id", clusters = "resp_id")
#' }
#' }
#' @export
afcp <- function(matchups, outcome = "A_wins", null_value = 0.5, by = NULL,
                 clusters = NULL, weights = NULL, se_type = NULL,
                 min_clusters = 2L) {
  if (!requireNamespace("estimatr", quietly = TRUE)) {
    stop("`afcp()` requires the 'estimatr' package. Install it, or estimate ",
         "directly from the output of `get_matchups()`.", call. = FALSE)
  }
  stopifnot(is.data.frame(matchups), outcome %in% names(matchups),
            is.numeric(null_value), length(null_value) == 1L,
            is.finite(null_value))

  fit_one <- function(d) {
    if (!is.null(clusters) &&
        dplyr::n_distinct(d[[clusters]]) < min_clusters) {
      return(tibble::tibble())
    }
    # The test is against `null_value`, not 0. Recentering the outcome and
    # shifting the estimate back afterwards leaves the standard error, the
    # degrees of freedom and the interval width untouched, and lets
    # `lm_robust()` compute the statistic and p-value for the null we want with
    # its own machinery (CR2 Satterthwaite degrees of freedom included) rather
    # than a hand-rolled t-test here.
    d[[outcome]] <- d[[outcome]] - null_value
    args <- list(
      formula = stats::reformulate("1", response = outcome),
      data = d
    )
    if (!is.null(se_type)) args$se_type <- se_type
    if (!is.null(clusters)) args$clusters <- d[[clusters]]
    if (!is.null(weights)) args$weights <- d[[weights]]
    # Wrap both the fit and the extraction: a degenerate study (e.g. a single
    # cluster) can return a fit whose components are missing, which would error
    # on extraction. Such a study is dropped rather than aborting the group loop.
    # Single brackets: estimatr 2.0.1 returns an unnamed NA standard error when
    # the outcome has no variation (every task won, or every task lost), and
    # `[[i]]` would error on it and silently drop a cell that has an estimate.
    tryCatch({
      fit <- do.call(estimatr::lm_robust, args)
      i <- "(Intercept)"
      tibble::tibble(
        estimate = unname(fit$coefficients[i]) + null_value,
        std.error = unname(fit$std.error[i]),
        statistic = unname(fit$statistic[i]),
        p.value = unname(fit$p.value[i]),
        conf.low = unname(fit$conf.low[i]) + null_value,
        conf.high = unname(fit$conf.high[i]) + null_value,
        df = unname(fit$df[i]),
        n = fit$nobs,
        n_clusters = if (is.null(clusters)) NA_integer_ else fit$nclusters
      )
    }, error = function(e) tibble::tibble())
  }

  if (is.null(by)) {
    return(fit_one(matchups))
  }
  matchups |>
    dplyr::group_by(dplyr::across(dplyr::all_of(by))) |>
    dplyr::group_modify(~ fit_one(.x)) |>
    dplyr::ungroup()
}
