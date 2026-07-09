# End-to-end integration on a tiny synthetic corpus with hand-computed AFCPs.
# Guards the full reshape -> matchup -> estimate path inside the package,
# independent of any private data.

# Two studies, two respondents each, two tasks each: every task pits a
# Republican against a Democrat, so a party matchup uses all 8 tasks. `chosen`
# is laid out so the per-study Republican win rates are exactly 3/4 and 1/4.
fixture_profiles <- function() {
  tibble::tribble(
    ~study, ~resp, ~task, ~profile, ~party, ~gender, ~chosen,
    "s1",   1L,    1L,    1L,       "R",    "woman", 1,   # R (slot 1) wins
    "s1",   1L,    1L,    2L,       "D",    "man",   0,
    "s1",   1L,    2L,    1L,       "D",    "woman", 1,   # R (slot 2) loses
    "s1",   1L,    2L,    2L,       "R",    "man",   0,
    "s1",   2L,    1L,    1L,       "R",    "man",   1,   # R wins
    "s1",   2L,    1L,    2L,       "D",    "woman", 0,
    "s1",   2L,    2L,    1L,       "R",    "man",   1,   # R wins
    "s1",   2L,    2L,    2L,       "D",    "woman", 0,   # -> s1: R wins 3/4
    "s2",   3L,    1L,    1L,       "R",    "woman", 0,   # R loses
    "s2",   3L,    1L,    2L,       "D",    "man",   1,
    "s2",   3L,    2L,    1L,       "R",    "man",   1,   # R wins
    "s2",   3L,    2L,    2L,       "D",    "woman", 0,
    "s2",   4L,    1L,    1L,       "D",    "woman", 1,   # R (slot 2) loses
    "s2",   4L,    1L,    2L,       "R",    "man",   0,
    "s2",   4L,    2L,    1L,       "D",    "man",   1,   # R (slot 2) loses
    "s2",   4L,    2L,    2L,       "R",    "woman", 0    # -> s2: R wins 1/4
  )
}

keys <- c("study", "resp", "task")

test_that("as_tasks -> as_profiles round-trips the synthetic corpus", {
  prof <- fixture_profiles()
  tasks <- as_tasks(prof, task_keys = keys, profile = "profile", outcome = "chosen")
  expect_equal(nrow(tasks), 8)
  expect_true(all(c("party_1", "party_2", "gender_1", "gender_2",
                    "chosen_1", "chosen_2") %in% names(tasks)))

  back <- as_profiles(tasks, task_keys = keys)
  k <- function(d) sort(paste(d$study, d$resp, d$task, d$profile, d$party, d$gender))
  expect_setequal(k(back), k(prof))
})

test_that("check_conjoint accepts the synthetic tasks", {
  tasks <- as_tasks(fixture_profiles(), task_keys = keys, profile = "profile",
                    outcome = "chosen")
  expect_invisible(check_conjoint(tasks))
})

test_that("get_matchups scores the party contrast as hand-computed", {
  tasks <- as_tasks(fixture_profiles(), task_keys = keys, profile = "profile",
                    outcome = "chosen")
  m <- get_matchups(tasks, A = list(party = "R"), B = list(party = "D"),
                    outcome = "chosen")
  expect_equal(nrow(m), 8)                       # every task is R vs D
  m <- m[order(m$study, m$resp, m$task), ]
  expect_equal(m$A_wins, c(1, 0, 1, 1,           # s1
                           0, 1, 0, 0))          # s2
})

test_that("afcp recovers the hand-computed AFCPs", {
  tasks <- as_tasks(fixture_profiles(), task_keys = keys, profile = "profile",
                    outcome = "chosen")
  m <- get_matchups(tasks, A = list(party = "R"), B = list(party = "D"),
                    outcome = "chosen")

  by_study <- afcp(m, by = "study", clusters = "resp")
  by_study <- by_study[order(by_study$study), ]
  expect_equal(by_study$study, c("s1", "s2"))
  expect_equal(by_study$estimate, c(0.75, 0.25))
  expect_true(all(by_study$std.error > 0))

  pooled <- afcp(m, clusters = "resp")           # ungrouped: 4 of 8 -> 0.5
  expect_equal(pooled$estimate, 0.5)
})
