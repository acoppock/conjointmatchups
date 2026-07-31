# Check a conjoint cleaned as a relational star

Validates the three-frame ("relational star") representation of a
cleaned conjoint study: one row per respondent (`resp`), one row per
candidate profile shown (`cand`), and one row per task (`task`). This is
the shape a meta-analysis cleaning pipeline persists, and it carries
invariants that
[`check_conjoint()`](https://alexandercoppock.com/conjointmatchups/reference/check_conjoint.md)
cannot see, because that function validates a single task-wide frame.

## Usage

``` r
check_conjoint_star(
  cand,
  task,
  resp,
  keys = c("resp_id", "task_id", "cand_profile"),
  profile = "cand_profile",
  profiles = c(1, 2),
  outcome = "cand_selected",
  resp_key = c("study_id", "resp_id"),
  weights = "resp_weights",
  study_id = "study_id",
  min_one_winner = 0.9
)
```

## Arguments

- cand:

  One row per candidate profile shown. Must contain the columns named by
  `keys` and `profile`, and normally the `outcome` column.

- task:

  One row per task. Used for the row-count invariant
  `nrow(cand) == nrow(task) * 2`.

- resp:

  One row per respondent. Must be uniquely keyed by `resp_key`.

- keys:

  Character vector identifying a profile row within the study.

- profile:

  Column holding the profile slot within a task; its values must be the
  two levels in `profiles`.

- profiles:

  Length-2 vector of valid profile slots.

- outcome:

  Column holding the per-profile choice indicator. Checked only when
  present.

- resp_key:

  Column(s) uniquely keying `resp`.

- weights:

  Column expected to carry respondent weights, or `NULL` to skip the
  weights check.

- study_id:

  Column holding a single study identifier, or `NULL` to skip. Used to
  prefix warnings so a corpus-wide run says which study complained.

- min_one_winner:

  Warn when the share of answered tasks with exactly one selected
  profile falls below this.

## Value

Invisibly, `TRUE`. Called for its errors and warnings.

## Details

The two functions divide as follows.
[`check_conjoint()`](https://alexandercoppock.com/conjointmatchups/reference/check_conjoint.md)
is a contract check on the task-wide shape
[`as_tasks()`](https://alexandercoppock.com/conjointmatchups/reference/as_tasks.md)
produces: the outcome columns exist, are 0/1, and exactly one profile
wins. `check_conjoint_star()` additionally checks relational integrity
*across* frames (unique keys, profile cardinality, row-count agreement,
orphaned respondents), plus the data-quality problems a cleaning
pipeline needs to surface.

Severity is deliberately split. Structural invariants that hold for
every standard paired design are **errors**. Data-quality problems that
can legitimately vary between studies are **warnings**, so a study that
needs attention still saves and surfaces loudly rather than halting a
whole-corpus run on the first offender.

The one-winner check is computed over *answered* tasks only, i.e. those
with at least one non-`NA` outcome. All-`NA` tasks are item nonresponse
or by-design abstention, and counting them would make benign nonresponse
indistinguishable from a broken outcome mapping.

## See also

[`check_conjoint()`](https://alexandercoppock.com/conjointmatchups/reference/check_conjoint.md)
for the task-wide contract check.

## Examples

``` r
resp <- data.frame(study_id = "s1", resp_id = c("r1", "r2"), resp_weights = 1)
cand <- data.frame(
  study_id = "s1",
  resp_id = rep(c("r1", "r2"), each = 2),
  task_id = rep(c("r1_t1", "r2_t1"), each = 2),
  cand_profile = rep(1:2, 2),
  cand_selected = c(1, 0, 0, 1),
  resp_weights = 1
)
task <- data.frame(
  study_id = "s1", resp_id = c("r1", "r2"), task_id = c("r1_t1", "r2_t1")
)
check_conjoint_star(cand, task, resp)
```
