# Is a matchup contrast well defined?

A forced-choice contrast requires candidates A and B to be mutually
exclusive: they must pin at least one shared attribute to different
levels. Otherwise a single profile can satisfy both sides, the matchup
includes tasks where the two candidates are identical on the pinned
attributes, and the outcome reflects display position rather than any
real difference.

## Usage

``` r
valid_contrast(A, B)
```

## Arguments

- A, B:

  Named lists mapping attribute stems to pinned levels.

## Value

`TRUE` if the contrast is well defined, `FALSE` otherwise.

## See also

[`contrast_message()`](https://acoppock.github.io/conjointmatchups/reference/contrast_message.md),
[`get_matchups()`](https://acoppock.github.io/conjointmatchups/reference/get_matchups.md)

## Examples

``` r
valid_contrast(list(party = "R"), list(party = "D"))   # TRUE
#> [1] TRUE
valid_contrast(list(party = "R"), list(gender = "F"))  # FALSE (no shared attr)
#> [1] FALSE
valid_contrast(list(party = "R"), list(party = "R"))   # FALSE (identical)
#> [1] FALSE
```
