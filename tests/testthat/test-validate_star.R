make_star <- function(n_resp = 2, selected = NULL) {
  rid <- paste0("r", seq_len(n_resp))
  resp <- data.frame(study_id = "s1", resp_id = rid, resp_weights = 1)
  task <- data.frame(study_id = "s1", resp_id = rid, task_id = paste0(rid, "_t1"))
  cand <- data.frame(
    study_id = "s1",
    resp_id = rep(rid, each = 2),
    task_id = rep(paste0(rid, "_t1"), each = 2),
    cand_profile = rep(1:2, n_resp),
    cand_selected = if (is.null(selected)) rep(c(1, 0), n_resp) else selected,
    resp_weights = 1
  )
  list(cand = cand, task = task, resp = resp)
}

test_that("a clean star passes silently", {
  s <- make_star()
  expect_silent(check_conjoint_star(s$cand, s$task, s$resp))
  expect_true(check_conjoint_star(s$cand, s$task, s$resp))
})

test_that("missing required cand columns error", {
  s <- make_star()
  s$cand$cand_profile <- NULL
  expect_error(check_conjoint_star(s$cand, s$task, s$resp), "missing column")
})

test_that("more than one study_id errors", {
  s <- make_star()
  s$cand$study_id[1] <- "s2"
  expect_error(check_conjoint_star(s$cand, s$task, s$resp), "distinct study_id")
})

test_that("a duplicated resp key errors", {
  s <- make_star()
  s$resp <- rbind(s$resp, s$resp[1, ])
  expect_error(check_conjoint_star(s$cand, s$task, s$resp), "not uniquely keyed")
})

test_that("duplicate profile rows error", {
  s <- make_star()
  s$cand <- rbind(s$cand, s$cand[1, ])
  expect_error(check_conjoint_star(s$cand, s$task, s$resp), "duplicate rows")
})

test_that("an out-of-range profile slot errors", {
  s <- make_star()
  s$cand$cand_profile[1] <- 3
  expect_error(check_conjoint_star(s$cand, s$task, s$resp), "must be one of")
})

test_that("a task without exactly two profiles errors", {
  s <- make_star()
  s$cand <- s$cand[-1, ]
  expect_error(check_conjoint_star(s$cand, s$task, s$resp),
               "do not have exactly 2 profiles")
})

test_that("cand/task row-count disagreement errors", {
  s <- make_star()
  s$task <- rbind(s$task, s$task[1, ])
  expect_error(check_conjoint_star(s$cand, s$task, s$resp), "nrow\\(task\\)")
})

test_that("selecting both profiles warns rather than errors", {
  # This fixture legitimately trips two checks: the multi-select warning and,
  # because one of its two tasks is broken, the one-winner-share warning.
  s <- make_star(selected = c(1, 1, 1, 0))
  w <- testthat::capture_warnings(check_conjoint_star(s$cand, s$task, s$resp))
  expect_match(w, "select >1 profile", all = FALSE)
  expect_length(w, 2)
})

test_that("a low one-winner share warns", {
  s <- make_star(n_resp = 10)
  s$cand$cand_selected <- rep(c(0, 0), 10)  # nobody wins anywhere
  expect_warning(check_conjoint_star(s$cand, s$task, s$resp),
                 "exactly one selected profile")
})

test_that("all-NA tasks are excluded from the one-winner share", {
  # one clean task, one entirely unanswered: the answered task is perfect, so
  # nonresponse must not drag the share below the threshold.
  s <- make_star(n_resp = 2, selected = c(1, 0, NA, NA))
  expect_silent(check_conjoint_star(s$cand, s$task, s$resp))
})

test_that("orphaned respondents warn", {
  s <- make_star()
  s$resp <- s$resp[1, , drop = FALSE]
  expect_warning(check_conjoint_star(s$cand, s$task, s$resp), "not in resp")
})

test_that("missing and NA weights warn", {
  s <- make_star()
  s$cand$resp_weights <- NULL
  expect_warning(check_conjoint_star(s$cand, s$task, s$resp), "resp_weights missing")

  s2 <- make_star()
  s2$cand$resp_weights[1] <- NA
  expect_warning(check_conjoint_star(s2$cand, s2$task, s2$resp), "NA resp_weights")
})

test_that("the weights check can be switched off", {
  s <- make_star()
  s$cand$resp_weights <- NULL
  expect_silent(check_conjoint_star(s$cand, s$task, s$resp, weights = NULL))
})

test_that("warnings carry the study id", {
  s <- make_star(selected = c(1, 1, 1, 0))
  w <- testthat::capture_warnings(check_conjoint_star(s$cand, s$task, s$resp))
  expect_true(all(grepl("^s1: ", w)))
})

test_that("study_id = NULL skips the label and the single-study check", {
  s <- make_star()
  s$cand$study_id[1] <- "s2"
  expect_silent(check_conjoint_star(s$cand, s$task, s$resp, study_id = NULL))
})

test_that("alternative column names are honoured", {
  s <- make_star()
  names(s$cand)[names(s$cand) == "cand_profile"] <- "slot"
  names(s$cand)[names(s$cand) == "cand_selected"] <- "won"
  expect_silent(check_conjoint_star(
    s$cand, s$task, s$resp,
    keys = c("resp_id", "task_id", "slot"),
    profile = "slot", outcome = "won"
  ))
})

test_that("a haven_labelled column warns", {
  skip_if_not_installed("haven")
  s <- make_star()
  s$cand$cand_age <- haven::labelled(c(1, 2, 1, 2), c(young = 1, old = 2))
  expect_warning(check_conjoint_star(s$cand, s$task, s$resp), "haven_labelled")
})
