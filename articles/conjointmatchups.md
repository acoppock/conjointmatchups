# Getting your conjoint data into shape

``` r

library(conjointmatchups)
```

The single most important thing to get right is the **shape of your
input data**. Everything else in `conjointmatchups` follows from it.
This vignette shows the required format, how to reshape into it, and the
two-step workflow it unlocks: reshape, then extract matchups.

## The required format: profile-long

`conjointmatchups` expects your data in **profile-long** form: one row
per candidate profile per choice task, with two profiles per task. Each
row needs

- columns that **key the profile**: a respondent id, a task id (unique
  within respondent), and a profile index (which of the two candidates
  in the task this row is);
- a **binary `chosen` indicator**: 1 if this profile was picked in its
  task, 0 otherwise, with exactly one chosen per task;
- one column per **randomized attribute** (party, gender, and so on).

The names are up to you. Every function takes the key column names as
arguments. The shipped `kc_yougov` dataset (the YouGov sample from
Kirkland and Coppock 2018) is in exactly this form:

``` r

head(kc_yougov, 6)
#>   respondent task profile chosen       party gender     race     age
#> 1          1    1       1      0        <NA>    man Hispanic   older
#> 2          1    1       2      1        <NA>    man    Black   older
#> 3          1    2       1      1 Independent    man    Black younger
#> 4          1    2       2      0 Independent  woman Hispanic   older
#> 5          1    3       1      1        <NA>    man Hispanic younger
#> 6          1    3       2      0        <NA>    man Hispanic younger
#>      occupation       experience resp_party
#> 1  professional prior experience   Democrat
#> 2       teacher prior experience   Democrat
#> 3      business prior experience   Democrat
#> 4      business prior experience   Democrat
#> 5          <NA> prior experience   Democrat
#> 6 working class prior experience   Democrat
```

Here `respondent`, `task`, `profile` key each row; `chosen` is the
outcome; `party` through `experience` are the randomized attributes; and
`resp_party` is a respondent-level covariate carried along for subgroup
analysis.

Attributes may be `NA` when a feature was not shown in a given
condition. In these data `party` is shown only in the partisan condition
(the substantive point of the study), so it is `NA` for the rest. That
is fine: matchups on party simply use the tasks where party was shown.

### If your data is already task-wide

If instead you have one row per task with per-profile columns
(`party_1`, `party_2`, `chosen_1`, `chosen_2`, …), use
[`as_profiles()`](https://acoppock.github.io/conjointmatchups/reference/as_profiles.md)
to get to profile-long, or skip straight to
[`get_matchups()`](https://acoppock.github.io/conjointmatchups/reference/get_matchups.md),
which operates on task-wide data directly (see below).

### Checklist for your own data

Before anything else, make sure you can point to:

| You need                           | In `kc_yougov`       |
|------------------------------------|----------------------|
| respondent id                      | `respondent`         |
| task id (unique within respondent) | `task`               |
| profile index (1/2)                | `profile`            |
| binary chosen indicator            | `chosen`             |
| one column per attribute           | `party`, `gender`, … |

If your raw export has candidate attributes spread across oddly named
columns, reshape it into the table above first (with `tidyr`), then
continue.

## Step 1: reshape to task-wide with `as_tasks()`

Matchup extraction compares the two profiles within a task, so it works
on the **task-wide** representation: one row per task, every attribute
suffixed with the profile index.

``` r

tasks <- as_tasks(
  kc_yougov,
  task_keys = c("respondent", "task"),
  profile = "profile",
  outcome = "chosen"
)
tasks[, c("respondent", "task", "party_1", "party_2", "chosen_1", "chosen_2")] |>
  head(4)
#> # A tibble: 4 × 6
#>   respondent  task party_1     party_2     chosen_1 chosen_2
#>        <int> <int> <chr>       <chr>          <dbl>    <dbl>
#> 1          1     1 NA          NA                 0        1
#> 2          1     2 Independent Independent        1        0
#> 3          1     3 NA          NA                 1        0
#> 4          1     4 Democrat    Independent        1        0
```

[`as_profiles()`](https://acoppock.github.io/conjointmatchups/reference/as_profiles.md)
is the exact inverse if you ever need to go back.

## Step 2: extract a matchup with `get_matchups()`

A **matchup** is the subset of tasks where one profile carries the
attributes you pin in `A` and the other carries those in `B`, in either
display position. The result renames the outcome to a clean binary,
`A_wins`.

``` r

dem_v_rep <- get_matchups(
  tasks,
  A = list(party = "Democrat"),
  B = list(party = "Republican"),
  outcome = "chosen"
)
head(dem_v_rep, 4)
#> # A tibble: 4 × 3
#>   respondent  task A_wins
#>        <int> <int>  <int>
#> 1          3     4      0
#> 2          6     4      0
#> 3          8     1      0
#> 4          9     4      0
mean(dem_v_rep$A_wins)  # share of Democrat wins in these head-to-heads
#> [1] 0.5893471
```

You can pin several attributes at once to hold the comparison fixed, for
example a younger woman versus an older man:

``` r

young_woman_v_old_man <- get_matchups(
  tasks,
  A = list(gender = "woman", age = "younger"),
  B = list(gender = "man",   age = "older"),
  outcome = "chosen"
)
mean(young_woman_v_old_man$A_wins)
#> [1] 0.5802708
```

### Well-defined contrasts

A and B must be **mutually exclusive**: they must differ on at least one
shared attribute. Otherwise a single profile could satisfy both sides
and the “estimate” would reflect which candidate was shown first, not
any real difference.
[`get_matchups()`](https://acoppock.github.io/conjointmatchups/reference/get_matchups.md)
refuses such a contrast, and you can check it yourself:

``` r

valid_contrast(list(party = "Democrat"), list(party = "Republican"))
#> [1] TRUE
valid_contrast(list(party = "Democrat"), list(gender = "woman"))
#> [1] FALSE
```

## Step 3 (optional): estimate the AFCP

The matchup is ready for any estimator.
[`afcp()`](https://acoppock.github.io/conjointmatchups/reference/afcp.md)
is a thin convenience that computes the Average Feature Choice
Probability, the chance the A-side wins, with respondent-clustered
standard errors:

``` r

afcp(dem_v_rep, clusters = "respondent")
#> # A tibble: 1 × 5
#>   estimate std.error conf.low conf.high     n
#>      <dbl>     <dbl>    <dbl>     <dbl> <int>
#> 1    0.589    0.0227    0.545     0.634   582
```

For richer estimands (AMCE, marginal means) hand the matchup, or the
task-wide data, to `cregg` or `cjoint`. `conjointmatchups` stops at
producing the analysis-ready dataset.
