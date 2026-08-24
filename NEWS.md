# conjointmatchups 0.0.0.9000

* Initial scaffold.
* `as_tasks()` / `as_profiles()`: lossless pivot between profile-long and
  task-wide representations of a forced-choice conjoint.
* `get_matchups()`: extract the subset of tasks realizing a specified contrast
  between two profiles, with a clean binary outcome.
* `valid_contrast()` / `contrast_message()`: guard against ill-defined
  (non-mutually-exclusive) contrasts.
* `check_conjoint()`: validate the forced-choice data contract.
* `afcp()`: thin Average Feature Choice Probability estimator over a matchup.
  `se_type` now defaults to `NULL`, deferring to `lm_robust()`'s own default
  (`CR2` when clustered, `HC2` otherwise); the previous hard-coded `"stata"`
  silently changed the standard errors. New `min_clusters` argument (default 2)
  drops groups with too few clusters to estimate, matching the study-level
  behavior in the meta-analysis pipeline. Validated to reproduce the paper's
  Shiny-app estimates bit-for-bit on the full 163-study corpus.
* `afcp()` returns `n_clusters` (distinct clusters, i.e. respondents) alongside
  `n` (observations, i.e. choice tasks). `lm_robust()` was already computing the
  cluster count on the fit being summarised and the tibble discarded it, which
  left a caller no way to report respondents at all.
* Bug fix: `afcp()` now tests against a null of 0.5 rather than 0. The AFCP is
  a choice probability, so the coin-flip null is the one of interest; the
  intercept test `lm_robust()` reports is against 0, which made `p.value`
  essentially 0 for any well-powered study, including one whose estimate sat
  exactly at 0.5. New `null_value` argument (default `0.5`) sets the null; pass
  `null_value = 0` to recover the old intercept test. `estimate`, `std.error`
  and the confidence interval are unchanged.
* Bug fix: `get_matchups()` with an unconstrained side (an empty `A` or `B`
  list) no longer errors with phantom `_1`/`_2` columns (a `paste0()`
  zero-length recycling gotcha).
* Bug fix: `afcp()` now drops a degenerate study (e.g. a single cluster) whose
  fit returns unusable components, instead of erroring during coefficient
  extraction; the `tryCatch` covers extraction, not just the model fit.
* Test coverage raised to ~99% (added tests for weights, unconstrained-side
  matchups, degenerate-fit handling, and the input-validation error paths).
