# Build the shipped example dataset `kc_yougov`.
#
# Source: the YouGov sample (Study 2) from
#   Kirkland, P. A., & Coppock, A. (2018). Candidate Choice without Party
#   Labels: New Insights from Conjoint Survey Experiments. Political Behavior.
#
# The raw replication archive lives in the meta_conjoint project. This script
# reads the already-cleaned profile-level file and pares it down to a small,
# self-explanatory profile-long tibble with generic column names, to demonstrate
# the shape a forced-choice conjoint should be in before calling as_tasks().
#
# Re-run manually when the source changes; not part of the package build.

suppressMessages(library(tidyverse))

src <- "~/Library/CloudStorage/Dropbox/meta_conjoint/clean_data/kirkland_coppock_2018_study_2_cand.rds"

# party is NA in the nonpartisan condition: Kirkland & Coppock's design shows
# party labels only to some respondents, which is the whole point of the paper.
# This is kept as-is; it is a realistic example of a conditionally shown feature.
kc_yougov <- read_rds(src) |>
  transmute(
    respondent = as.integer(str_extract(resp_id, "\\d+")),
    task = as.integer(str_extract(task_id, "(?<=task_)\\d+")),
    profile = as.integer(cand_profile),
    chosen = as.integer(cand_selected),
    party = as.character(cand_party),
    gender = as.character(cand_gender),
    race = as.character(cand_race),
    age = as.character(cand_age_2),
    occupation = str_replace_all(as.character(cand_occupation_std), "_", " "),
    experience = as.character(cand_experience_type),
    resp_party = as.character(resp_pid_3)
  ) |>
  arrange(respondent, task, profile) |>
  as_tibble()

usethis::use_data(kc_yougov, overwrite = TRUE, compress = "bzip2")
