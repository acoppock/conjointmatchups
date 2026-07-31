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
`statistic`, `p.value`, `conf.low`, `conf.high`, `df`, and `n`
(observations). This is the tidy-tibble form, not a fit object, so that
many per-group AFCPs compose directly into a meta-analysis; call
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
#> # A tibble: 1 × 9
#>   study_id estimate std.error statistic p.value conf.low conf.high    df     n
#>   <chr>       <dbl>     <dbl>     <dbl>   <dbl>    <dbl>     <dbl> <dbl> <int>
#> 1 s1              1         0       Inf       0        1         1    19    40
# }
```
