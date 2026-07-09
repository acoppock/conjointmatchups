test_that("as_tasks and as_profiles round-trip", {
  profiles <- tibble::tibble(
    task_id = c(1, 1, 2, 2),
    profile = c(1, 2, 1, 2),
    party   = c("R", "D", "D", "R"),
    chosen  = c(1, 0, 0, 1)
  )
  tasks <- as_tasks(profiles, task_keys = "task_id", profile = "profile",
                    outcome = "chosen")
  expect_true(all(c("party_1", "party_2", "chosen_1", "chosen_2") %in% names(tasks)))
  expect_equal(nrow(tasks), 2)
  expect_type(tasks$chosen_1, "double")

  back <- as_profiles(tasks, task_keys = "task_id")
  expect_equal(nrow(back), 4)
  # same (task, profile, party) content after round-trip
  key <- function(d) paste(d$task_id, d$profile, d$party)
  expect_setequal(key(back), key(profiles))
})

test_that("as_tasks errors on missing keys", {
  expect_error(
    as_tasks(data.frame(a = 1), task_keys = "nope", profile = "p"),
    "not found"
  )
})

test_that("as_profiles errors when no columns match the suffix pattern", {
  expect_error(as_profiles(data.frame(a = 1, b = 2), task_keys = "a"),
               "No columns match")
})
