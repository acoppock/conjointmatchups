# Reshape task-level (wide) conjoint data to profile-level (long)

The inverse of
[`as_tasks()`](https://acoppock.github.io/conjointmatchups/reference/as_tasks.md).
Columns matching `x{sep}{profile value}` are pivoted back into one row
per profile per task; columns that do not match (task-level or
respondent-level covariates) are recycled across the profiles.

## Usage

``` r
as_profiles(
  tasks,
  task_keys,
  profiles = c("1", "2"),
  sep = "_",
  profile_to = "profile"
)
```

## Arguments

- tasks:

  A data frame in task-wide form.

- task_keys:

  Character vector of column names identifying a task. Together with
  `profile_to` these key the output.

- profiles:

  Character vector of the profile values to unstack. Defaults to
  `c("1", "2")`.

- sep:

  Separator between an attribute name and the profile suffix.

- profile_to:

  Name for the new profile-index column in the output.

## Value

A tibble in profile-long form.

## See also

[`as_tasks()`](https://acoppock.github.io/conjointmatchups/reference/as_tasks.md)
for the inverse.

## Examples

``` r
tasks <- data.frame(
  task_id  = c(1, 2),
  party_1  = c("R", "D"), party_2 = c("D", "R"),
  chosen_1 = c(1, 0),      chosen_2 = c(0, 1)
)
as_profiles(tasks, task_keys = "task_id")
#> # A tibble: 4 × 4
#>   task_id profile party chosen
#>     <dbl> <chr>   <chr> <chr> 
#> 1       1 1       R     1     
#> 2       1 2       D     0     
#> 3       2 1       D     0     
#> 4       2 2       R     1     
```
