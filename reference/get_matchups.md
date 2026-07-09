# Extract matchups realizing a contrast between two profiles

A *matchup* is the subset of choice tasks in which one profile carries
the attributes pinned in `A` and the other carries the attributes pinned
in `B` (in either display position). `get_matchups()` filters `tasks` to
those rows and returns them with a single binary outcome, `winner`,
equal to 1 when the A-side profile was chosen. This turns an arbitrary
conjoint into a clean pairwise sub-experiment ready for estimation (see
[`afcp()`](https://acoppock.github.io/conjointmatchups/reference/afcp.md)).

## Usage

``` r
get_matchups(
  tasks,
  A,
  B,
  outcome,
  profiles = c("1", "2"),
  sep = "_",
  winner = "A_wins",
  keep = NULL,
  check_contrast = TRUE
)
```

## Arguments

- tasks:

  A data frame in task-wide form (see
  [`as_tasks()`](https://acoppock.github.io/conjointmatchups/reference/as_tasks.md)).

- A, B:

  Named lists mapping attribute stems to pinned levels for each side.

- outcome:

  Name (stem) of the per-profile choice-indicator columns (e.g.
  `"chosen"` for columns `chosen_1`, `chosen_2`). Values must be 0/1.

- profiles:

  Length-2 character vector of the profile suffixes. Defaults to
  `c("1", "2")`.

- sep:

  Separator between an attribute stem and its profile suffix.

- winner:

  Name for the returned binary outcome column. Defaults to `"A_wins"`.

- keep:

  Character vector of columns to carry through to the result. If `NULL`
  (default), every column that is *not* profile-specific (i.e. does not
  end in `sep` + a profile suffix) is kept: task keys, respondent
  covariates, weights, and so on.

- check_contrast:

  If `TRUE`, error on a contrast that is not mutually exclusive.

## Value

A tibble of the matched tasks: the `keep` columns plus the `winner`
column (0/1).

## Details

`A` and `B` are named lists mapping attribute names (the stems, without
the profile suffix) to the level each side is pinned to. An empty list
leaves that side unconstrained.

For the contrast to be well defined, A and B must be **mutually
exclusive**: they must pin at least one shared attribute to different
levels. Otherwise a single profile can satisfy both sides and the
"estimate" reflects display position (primacy), not a real difference.
When `check_contrast = TRUE` (the default) an invalid contrast raises an
error explaining why; see
[`valid_contrast()`](https://acoppock.github.io/conjointmatchups/reference/valid_contrast.md).

## Examples

``` r
tasks <- data.frame(
  study_id = "s1", resp_id = c(1, 1, 2, 2),
  party_1  = c("R", "D", "R", "R"), party_2 = c("D", "R", "R", "D"),
  chosen_1 = c(1, 0, 1, 1),          chosen_2 = c(0, 1, 0, 0)
)
get_matchups(tasks, A = list(party = "R"), B = list(party = "D"),
             outcome = "chosen")
#> # A tibble: 3 × 3
#>   study_id resp_id A_wins
#>   <chr>      <dbl>  <int>
#> 1 s1             1      1
#> 2 s1             1      1
#> 3 s1             2      1
```
