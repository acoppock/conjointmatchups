# Average Feature Choice Probability from a matchup

A convenience wrapper that closes the loop on the matchup workflow:
given the output of
[`get_matchups()`](https://alexandercoppock.com/conjointmatchups/reference/get_matchups.md),
it estimates the probability that the A-side profile is chosen (the
AFCP), optionally within respondent-clustered, weighted groups. The
estimation itself is a one-liner over
[`estimatr::lm_robust()`](https://declaredesign.org/r/estimatr/reference/lm_robust.html);
this function exists only to make
`as_profiles() |> as_tasks() |> get_matchups() |> afcp()` a complete
workflow. For richer estimands (AMCE, marginal means) use 'cregg' or
'cjoint'.

## Usage

``` r
afcp(
  matchups,
  outcome = "A_wins",
  null_value = 0.5,
  by = NULL,
  clusters = NULL,
  weights = NULL,
  se_type = NULL,
  min_clusters = 2L
)
```

## Arguments

- matchups:

  A data frame from
  [`get_matchups()`](https://alexandercoppock.com/conjointmatchups/reference/get_matchups.md).

- outcome:

  Name of the binary outcome column. Defaults to `"A_wins"`.

- null_value:

  The value of the AFCP under the null hypothesis, against which
  `statistic` and `p.value` are computed. Defaults to `0.5`, the
  coin-flip null: an AFCP of 0.5 means the A-side profile is chosen half
  the time, so a test against 0 is almost never the test of interest.
  Set to `0` to recover the usual intercept test, or to any other value
  to test a different null.

- by:

  Optional character vector of grouping columns (e.g. `"study_id"`); one
  AFCP is returned per group.

- clusters:

  Optional name of the cluster column (e.g. `"resp_id"`) for
  cluster-robust standard errors.

- weights:

  Optional name of a survey-weight column.

- se_type:

  Standard-error type passed to
  [`estimatr::lm_robust()`](https://declaredesign.org/r/estimatr/reference/lm_robust.html).
  The default `NULL` lets `lm_robust()` choose its own default: `"CR2"`
  when `clusters` is supplied, `"HC2"` otherwise. Set explicitly (e.g.
  `"stata"`) only to override that.

- min_clusters:

  When `clusters` is supplied, groups with fewer than this many distinct
  clusters are dropped rather than estimated (a single-cluster AFCP has
  no usable sampling variance). Ignored without `clusters`.

## Value

A tidy tibble, one row per group (or a single row when `by` is `NULL`):
the grouping columns (if any) plus `estimate` (the AFCP), `std.error`,
`statistic`, `p.value`, `conf.low`, `conf.high`, `df`, `n` and
`n_clusters`. `statistic` is `(estimate - null_value) / std.error` and
`p.value` is its two-sided t-test; `estimate`, `std.error` and the
confidence interval do not depend on `null_value`. `n` counts
observations, which for a matchup means choice tasks, and `n_clusters`
counts distinct clusters, which means respondents when `clusters` is a
respondent id and is `NA_integer_` when `clusters` is not supplied. Both
are returned because `n` alone leaves a caller no way to report
respondents, even though `lm_robust()` has already counted them. This is
the tidy-tibble form, not a fit object, so that many per-group AFCPs
compose directly into a meta-analysis; call
[`estimatr::lm_robust()`](https://declaredesign.org/r/estimatr/reference/lm_robust.html)
yourself if you need the fit.

## Examples

``` r
# \donttest{
tasks <- data.frame(
  study_id = "s1", resp_id = rep(1:20, each = 2),
  party_1  = rep(c("R", "D"), 20), party_2 = rep(c("D", "R"), 20),
  chosen_1 = rep(c(1, 0), 20),      chosen_2 = rep(c(0, 1), 20)
)
m <- get_matchups(tasks, list(party = "R"), list(party = "D"),
                  outcome = "chosen")
if (requireNamespace("estimatr", quietly = TRUE)) {
  afcp(m, by = "study_id", clusters = "resp_id")
}
#> The model reproduces the outcome exactly, so there is no residual variation left to estimate a variance from and every standard error for it is NA. What the variance calculation returns here is zero or rounding error, not precision.
#> # A tibble: 1 × 10
#>   study_id estimate std.error statistic p.value conf.low conf.high    df     n
#>   <chr>       <dbl>     <dbl>     <dbl>   <dbl>    <dbl>     <dbl> <dbl> <int>
#> 1 s1              1        NA        NA      NA       NA        NA    19    40
#> # ℹ 1 more variable: n_clusters <int>
# }
```
