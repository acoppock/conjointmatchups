# conjointmatchups 0.0.0.9000

* Initial scaffold.
* `as_tasks()` / `as_profiles()`: lossless pivot between profile-long and
  task-wide representations of a forced-choice conjoint.
* `get_matchups()`: extract the subset of tasks realizing a specified contrast
  between two profiles, with a clean binary outcome.
* `valid_contrast()` / `contrast_message()`: guard against ill-defined
  (non-mutually-exclusive) contrasts.
* `check_conjoint()`: validate the forced-choice data contract.
* `afcp()`: thin Average Feature Choice Probability estimator over a matchup.
