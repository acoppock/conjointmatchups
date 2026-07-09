# Reshape profile-level (long) conjoint data to task-level (wide)

Each choice task appears as two profile rows in the input. `as_tasks()`
pivots those rows into a single wide row per task, suffixing every
non-key column with the profile index (e.g. `party` becomes `party_1`
and `party_2`). This is the representation used for modeling the binary
choice and for
[`get_matchups()`](https://acoppock.github.io/conjointmatchups/reference/get_matchups.md).

## Usage

``` r
as_tasks(profiles, task_keys, profile, outcome = NULL, sep = "_")
```

## Arguments

- profiles:

  A data frame in profile-long form: one row per candidate profile per
  task.

- task_keys:

  Character vector of column names that jointly identify a choice task
  (e.g. `c("study_id", "resp_id", "task_id")`). These are carried
  through unchanged.

- profile:

  Name of the column indexing the profile within a task (values such as
  `1`/`2`). Its values become the column-name suffixes.

- outcome:

  Optional name of the choice-indicator column. If supplied, the
  resulting per-profile outcome columns are coerced to numeric (they are
  character after pivoting, like every attribute).

- sep:

  Separator between an attribute name and the profile suffix. Defaults
  to `"_"`.

## Value

A tibble with one row per task: `task_keys` plus, for every other input
column `x` and every profile value `p`, a column `x{sep}p`.

## See also

[`as_profiles()`](https://acoppock.github.io/conjointmatchups/reference/as_profiles.md)
for the inverse.

## Examples

``` r
profiles <- data.frame(
  task_id = c(1, 1, 2, 2),
  profile = c(1, 2, 1, 2),
  party   = c("R", "D", "D", "R"),
  chosen  = c(1, 0, 0, 1)
)
as_tasks(profiles, task_keys = "task_id", profile = "profile",
         outcome = "chosen")
#> # A tibble: 2 × 5
#>   task_id party_1 chosen_1 party_2 chosen_2
#>     <dbl> <chr>      <dbl> <chr>      <dbl>
#> 1       1 R              1 D              0
#> 2       2 D              0 R              1
```
