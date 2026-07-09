# Explain why a matchup contrast is not well defined

Produces a human-readable message for a contrast rejected by
[`valid_contrast()`](https://acoppock.github.io/conjointmatchups/reference/valid_contrast.md),
for use in error messages or interactive UIs.

## Usage

``` r
contrast_message(A, B)
```

## Arguments

- A, B:

  Named lists mapping attribute stems to pinned levels.

## Value

A length-1 character string.

## See also

[`valid_contrast()`](https://acoppock.github.io/conjointmatchups/reference/valid_contrast.md)

## Examples

``` r
contrast_message(list(party = "R"), list(party = "R"))
#> [1] "Candidates A and B are identical on: party. A clean comparison needs them to differ on a shared attribute, e.g. A: party = Republican vs B: party = Democrat. As specified, the matchup compares identical profiles and reflects which position was shown first, not a real difference."
```
