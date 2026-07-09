make_tasks <- function() {
  tibble::tibble(
    study_id = "s1", resp_id = c(1, 1, 2, 2),
    party_1  = c("R", "D", "R", "R"),
    party_2  = c("D", "R", "R", "D"),
    chosen_1 = c(1, 0, 1, 1),
    chosen_2 = c(0, 1, 0, 0)
  )
}

test_that("get_matchups scores A_wins from either display position", {
  m <- get_matchups(make_tasks(), A = list(party = "R"), B = list(party = "D"),
                    outcome = "chosen")
  # rows 1, 2, 4 are R-vs-D matchups; row 3 is R-vs-R (excluded)
  expect_equal(nrow(m), 3)
  # row1: R in slot1 chosen -> A wins; row2: R in slot2 chosen -> A wins;
  # row4: R in slot1 chosen -> A wins
  expect_equal(m$A_wins, c(1, 1, 1))
  # profile-specific columns dropped, keys/covariates kept
  expect_true(all(c("study_id", "resp_id") %in% names(m)))
  expect_false(any(grepl("_1$|_2$", names(m))))
})

test_that("get_matchups rejects an ill-defined contrast", {
  expect_error(
    get_matchups(make_tasks(), list(party = "R"), list(party = "R"),
                 outcome = "chosen"),
    "identical"
  )
})

test_that("keep argument restricts carried columns", {
  m <- get_matchups(make_tasks(), list(party = "R"), list(party = "D"),
                    outcome = "chosen", keep = "resp_id")
  expect_equal(names(m), c("resp_id", "A_wins"))
})
