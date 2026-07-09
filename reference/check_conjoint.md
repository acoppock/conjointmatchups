# Check that task-wide data is a valid forced-choice conjoint

Verifies the invariants a binary forced-choice conjoint must satisfy in
task-wide form: the two per-profile outcome columns exist, their values
are 0/1, and exactly one profile is chosen in every task. Generalizes
the structural checks used when cleaning a conjoint study.

## Usage

``` r
check_conjoint(tasks, outcome = "chosen", profiles = c("1", "2"), sep = "_")
```

## Arguments

- tasks:

  A data frame in task-wide form (see
  [`as_tasks()`](https://acoppock.github.io/conjointmatchups/reference/as_tasks.md)).

- outcome:

  Name (stem) of the per-profile choice-indicator columns.

- profiles:

  Length-2 character vector of profile suffixes.

- sep:

  Separator between an attribute stem and its profile suffix.

## Value

Invisibly, `tasks`. Called for its side effect of erroring on a violated
invariant.

## Examples

``` r
tasks <- data.frame(chosen_1 = c(1, 0), chosen_2 = c(0, 1))
check_conjoint(tasks)
```
