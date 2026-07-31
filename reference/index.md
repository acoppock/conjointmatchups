# Package index

## Reshape

Move losslessly between the profile-long and task-wide representations.

- [`as_tasks()`](https://alexandercoppock.com/conjointmatchups/reference/as_tasks.md)
  : Reshape profile-level (long) conjoint data to task-level (wide)
- [`as_profiles()`](https://alexandercoppock.com/conjointmatchups/reference/as_profiles.md)
  : Reshape task-level (wide) conjoint data to profile-level (long)

## Extract matchups

Pull the tasks realizing a contrast between two profiles, with a clean
outcome.

- [`get_matchups()`](https://alexandercoppock.com/conjointmatchups/reference/get_matchups.md)
  : Extract matchups realizing a contrast between two profiles
- [`valid_contrast()`](https://alexandercoppock.com/conjointmatchups/reference/valid_contrast.md)
  : Is a matchup contrast well defined?
- [`contrast_message()`](https://alexandercoppock.com/conjointmatchups/reference/contrast_message.md)
  : Explain why a matchup contrast is not well defined

## Validate

- [`check_conjoint()`](https://alexandercoppock.com/conjointmatchups/reference/check_conjoint.md)
  : Check that task-wide data is a valid forced-choice conjoint
- [`check_conjoint_star()`](https://alexandercoppock.com/conjointmatchups/reference/check_conjoint_star.md)
  : Check a conjoint cleaned as a relational star

## Estimate

A thin convenience for the Average Feature Choice Probability.

- [`afcp()`](https://alexandercoppock.com/conjointmatchups/reference/afcp.md)
  : Average Feature Choice Probability from a matchup

## Data

- [`kc_yougov`](https://alexandercoppock.com/conjointmatchups/reference/kc_yougov.md)
  : Kirkland & Coppock (2018) YouGov candidate conjoint
