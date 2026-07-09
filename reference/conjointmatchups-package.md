# conjointmatchups: the data grammar of forced-choice conjoint experiments

Forced-choice (paired) conjoint data has a fundamental duality. Each
choice task is at once two *profile* rows (long form, natural for
describing attributes) and one *task* row with per-profile columns (wide
form, natural for modeling the binary choice). conjointmatchups provides
a lossless pivot between these two representations
([`as_tasks()`](https://acoppock.github.io/conjointmatchups/reference/as_tasks.md),
[`as_profiles()`](https://acoppock.github.io/conjointmatchups/reference/as_profiles.md))
and a way to extract *matchups*
([`get_matchups()`](https://acoppock.github.io/conjointmatchups/reference/get_matchups.md)):
the subset of tasks realizing a specified contrast between the two
profiles, returned with a clean binary outcome that is ready to hand to
any estimator.

## Details

The package deliberately does not re-implement AMCE or marginal-means
estimation (see 'cregg', 'cjoint', 'projoint', 'factorEx'). It produces
the analysis-ready datasets those tools consume, and underlies the
Average Feature Choice Probability (AFCP) estimand. A thin
[`afcp()`](https://acoppock.github.io/conjointmatchups/reference/afcp.md)
convenience closes the loop for the AFCP workflow.

## See also

Useful links:

- <https://github.com/acoppock/conjointmatchups>

- <https://acoppock.github.io/conjointmatchups/>

- Report bugs at <https://github.com/acoppock/conjointmatchups/issues>

## Author

**Maintainer**: Alexander Coppock <acoppock@gmail.com>

Authors:

- Alexander Coppock <acoppock@gmail.com>

Other contributors:

- Matthew Blyth \[contributor\]
