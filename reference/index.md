# Package index

## Reshape

Move losslessly between the profile-long and task-wide representations.

- [`as_tasks()`](https://acoppock.github.io/conjointmatchups/reference/as_tasks.md)
  : Reshape profile-level (long) conjoint data to task-level (wide)
- [`as_profiles()`](https://acoppock.github.io/conjointmatchups/reference/as_profiles.md)
  : Reshape task-level (wide) conjoint data to profile-level (long)

## Extract matchups

Pull the tasks realizing a contrast between two profiles, with a clean
outcome.

- [`get_matchups()`](https://acoppock.github.io/conjointmatchups/reference/get_matchups.md)
  : Extract matchups realizing a contrast between two profiles
- [`valid_contrast()`](https://acoppock.github.io/conjointmatchups/reference/valid_contrast.md)
  : Is a matchup contrast well defined?
- [`contrast_message()`](https://acoppock.github.io/conjointmatchups/reference/contrast_message.md)
  : Explain why a matchup contrast is not well defined

## Validate

- [`check_conjoint()`](https://acoppock.github.io/conjointmatchups/reference/check_conjoint.md)
  : Check that task-wide data is a valid forced-choice conjoint

## Estimate

A thin convenience for the Average Feature Choice Probability.

- [`afcp()`](https://acoppock.github.io/conjointmatchups/reference/afcp.md)
  : Average Feature Choice Probability from a matchup

## Data

- [`kc_yougov`](https://acoppock.github.io/conjointmatchups/reference/kc_yougov.md)
  : Kirkland & Coppock (2018) YouGov candidate conjoint
