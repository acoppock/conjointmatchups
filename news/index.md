# Changelog

## conjointmatchups 0.0.0.9000

- Initial scaffold.
- [`as_tasks()`](https://acoppock.github.io/conjointmatchups/reference/as_tasks.md)
  /
  [`as_profiles()`](https://acoppock.github.io/conjointmatchups/reference/as_profiles.md):
  lossless pivot between profile-long and task-wide representations of a
  forced-choice conjoint.
- [`get_matchups()`](https://acoppock.github.io/conjointmatchups/reference/get_matchups.md):
  extract the subset of tasks realizing a specified contrast between two
  profiles, with a clean binary outcome.
- [`valid_contrast()`](https://acoppock.github.io/conjointmatchups/reference/valid_contrast.md)
  /
  [`contrast_message()`](https://acoppock.github.io/conjointmatchups/reference/contrast_message.md):
  guard against ill-defined (non-mutually-exclusive) contrasts.
- [`check_conjoint()`](https://acoppock.github.io/conjointmatchups/reference/check_conjoint.md):
  validate the forced-choice data contract.
- [`afcp()`](https://acoppock.github.io/conjointmatchups/reference/afcp.md):
  thin Average Feature Choice Probability estimator over a matchup.
