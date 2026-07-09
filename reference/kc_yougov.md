# Kirkland & Coppock (2018) YouGov candidate conjoint

The YouGov sample (Study 2) from Kirkland and Coppock's study of
candidate choice, in the **profile-long** form this package expects as
input: one row per candidate profile per choice task, two profiles per
task. Respondents made repeated binary forced choices between pairs of
hypothetical candidates described by randomized attributes.

## Usage

``` r
kc_yougov
```

## Format

A tibble with 11,432 rows (5,716 tasks x 2 profiles) and 11 columns:

- respondent:

  Integer respondent id.

- task:

  Integer task number within respondent (1-5).

- profile:

  Profile index within task, 1 or 2.

- chosen:

  1 if this profile was chosen in its task, else 0. Exactly one profile
  is chosen per task.

- party:

  Candidate party: "Democrat", "Republican", "Independent", or `NA` in
  the nonpartisan condition.

- gender:

  Candidate gender: "man" or "woman".

- race:

  Candidate race: "White", "Black", "Hispanic", or "Asian".

- age:

  Candidate age: "younger" or "older".

- occupation:

  Candidate occupation: "business", "professional", "teacher", "working
  class", or `NA` when not shown.

- experience:

  Political experience: "prior experience" or "no experience".

- resp_party:

  Respondent's party identification (a respondent-level covariate,
  constant within respondent): "Democrat", "Republican", or
  "Independent". Useful for subgroup analyses.

## Source

Kirkland, P. A., & Coppock, A. (2018). Candidate Choice without Party
Labels: New Insights from Conjoint Survey Experiments. *Political
Behavior*, 40(3), 571-591.
[doi:10.1007/s11109-017-9414-8](https://doi.org/10.1007/s11109-017-9414-8)

## Details

This is the shape your own data should be in before calling
[`as_tasks()`](https://acoppock.github.io/conjointmatchups/reference/as_tasks.md):
a set of columns that key the profile (respondent, task, profile index),
a binary `chosen` indicator, and one column per randomized attribute.
Attribute columns may be `NA` when a feature was not shown in a given
condition (here `party` and `occupation` are shown only to some
respondents, which is the substantive point of the study).

## Examples

``` r
head(kc_yougov)
#> # A tibble: 6 × 11
#>   respondent  task profile chosen party gender race  age   occupation experience
#>        <int> <int>   <int>  <int> <chr> <chr>  <chr> <chr> <chr>      <chr>     
#> 1          1     1       1      0 NA    man    Hisp… older professio… prior exp…
#> 2          1     1       2      1 NA    man    Black older teacher    prior exp…
#> 3          1     2       1      1 Inde… man    Black youn… business   prior exp…
#> 4          1     2       2      0 Inde… woman  Hisp… older business   prior exp…
#> 5          1     3       1      1 NA    man    Hisp… youn… NA         prior exp…
#> 6          1     3       2      0 NA    man    Hisp… youn… working c… prior exp…
#> # ℹ 1 more variable: resp_party <chr>
# reshape to task-wide, then extract a partisan matchup
tasks <- as_tasks(kc_yougov,
                  task_keys = c("respondent", "task"),
                  profile = "profile", outcome = "chosen")
get_matchups(tasks, A = list(party = "Democrat"),
             B = list(party = "Republican"), outcome = "chosen")
#> # A tibble: 582 × 3
#>    respondent  task A_wins
#>         <int> <int>  <int>
#>  1          3     4      0
#>  2          6     4      0
#>  3          8     1      0
#>  4          9     4      0
#>  5         10     2      0
#>  6         12     5      0
#>  7         14     1      0
#>  8         14     4      0
#>  9         16     2      1
#> 10         16     3      1
#> # ℹ 572 more rows
```
