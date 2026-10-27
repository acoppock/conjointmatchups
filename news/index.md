# Changelog

## conjointmatchups 0.0.0.9000

- [`afcp()`](https://alexandercoppock.com/conjointmatchups/reference/afcp.md)
  no longer drops a study whose outcome has no variation (every task
  won, or every task lost). Under estimatr 2.0.1 such a fit returns an
  unnamed `NA` standard error, which made the extraction error inside
  [`tryCatch()`](https://rdrr.io/r/base/conditions.html). The row now
  keeps its estimate with an `NA` standard error.

- Initial scaffold.

- [`as_tasks()`](https://alexandercoppock.com/conjointmatchups/reference/as_tasks.md)
  /
  [`as_profiles()`](https://alexandercoppock.com/conjointmatchups/reference/as_profiles.md):
  lossless pivot between profile-long and task-wide representations of a
  forced-choice conjoint.

- [`get_matchups()`](https://alexandercoppock.com/conjointmatchups/reference/get_matchups.md):
  extract the subset of tasks realizing a specified contrast between two
  profiles, with a clean binary outcome.

- [`valid_contrast()`](https://alexandercoppock.com/conjointmatchups/reference/valid_contrast.md)
  /
  [`contrast_message()`](https://alexandercoppock.com/conjointmatchups/reference/contrast_message.md):
  guard against ill-defined (non-mutually-exclusive) contrasts.

- [`check_conjoint()`](https://alexandercoppock.com/conjointmatchups/reference/check_conjoint.md):
  validate the forced-choice data contract.

- [`afcp()`](https://alexandercoppock.com/conjointmatchups/reference/afcp.md):
  thin Average Feature Choice Probability estimator over a matchup.
  `se_type` now defaults to `NULL`, deferring to `lm_robust()`’s own
  default (`CR2` when clustered, `HC2` otherwise); the previous
  hard-coded `"stata"` silently changed the standard errors. New
  `min_clusters` argument (default 2) drops groups with too few clusters
  to estimate, matching the study-level behavior in the meta-analysis
  pipeline. Validated to reproduce the paper’s Shiny-app estimates
  bit-for-bit on the full 163-study corpus.

- [`afcp()`](https://alexandercoppock.com/conjointmatchups/reference/afcp.md)
  returns `n_clusters` (distinct clusters, i.e. respondents) alongside
  `n` (observations, i.e. choice tasks). `lm_robust()` was already
  computing the cluster count on the fit being summarised and the tibble
  discarded it, which left a caller no way to report respondents at all.

- Bug fix:
  [`afcp()`](https://alexandercoppock.com/conjointmatchups/reference/afcp.md)
  now tests against a null of 0.5 rather than 0. The AFCP is a choice
  probability, so the coin-flip null is the one of interest; the
  intercept test `lm_robust()` reports is against 0, which made
  `p.value` essentially 0 for any well-powered study, including one
  whose estimate sat exactly at 0.5. New `null_value` argument (default
  `0.5`) sets the null; pass `null_value = 0` to recover the old
  intercept test. `estimate`, `std.error` and the confidence interval
  are unchanged.

- Bug fix:
  [`get_matchups()`](https://alexandercoppock.com/conjointmatchups/reference/get_matchups.md)
  with an unconstrained side (an empty `A` or `B` list) no longer errors
  with phantom `_1`/`_2` columns (a
  [`paste0()`](https://rdrr.io/r/base/paste.html) zero-length recycling
  gotcha).

- Bug fix:
  [`afcp()`](https://alexandercoppock.com/conjointmatchups/reference/afcp.md)
  now drops a degenerate study (e.g. a single cluster) whose fit returns
  unusable components, instead of erroring during coefficient
  extraction; the `tryCatch` covers extraction, not just the model fit.

- Test coverage raised to ~99% (added tests for weights,
  unconstrained-side matchups, degenerate-fit handling, and the
  input-validation error paths).
