skip_if_not_installed("estimatr")

make_m <- function() {
  # 40 tasks in study A across 20 respondents; study B has a single respondent.
  tibble::tibble(
    study_id = c(rep("A", 40), rep("B", 3)),
    resp_id = c(rep(1:20, each = 2), rep(99, 3)),
    resp_weights = 1,
    A_wins = c(rep(c(1, 0), 20), 1, 0, 1)
  )
}

test_that("default se_type matches lm_robust's CR2 when clustered", {
  m <- make_m()[1:40, ]
  d <- afcp(m, by = "study_id", clusters = "resp_id")
  cr2 <- afcp(m, by = "study_id", clusters = "resp_id", se_type = "CR2")
  expect_equal(d$std.error, cr2$std.error)
})

test_that("min_clusters drops single-cluster groups", {
  m <- make_m()
  d <- afcp(m, by = "study_id", clusters = "resp_id")
  expect_equal(d$study_id, "A")            # B (1 respondent) dropped
  d0 <- afcp(m, by = "study_id", clusters = "resp_id", min_clusters = 1L)
  expect_setequal(d0$study_id, c("A", "B")) # guard relaxed -> B kept
})

test_that("afcp estimates the mean of the outcome", {
  m <- tibble::tibble(resp_id = 1:100, A_wins = rep(c(1, 0, 1, 1), 25))
  d <- afcp(m, clusters = "resp_id")
  expect_equal(d$estimate, 0.75)
})

test_that("weights change the estimate", {
  m <- tibble::tibble(resp_id = 1:4, w = c(1, 1, 1, 100), A_wins = c(1, 1, 1, 0))
  unw <- afcp(m, clusters = "resp_id")
  wt  <- afcp(m, clusters = "resp_id", weights = "w")
  expect_equal(unw$estimate, 0.75)
  expect_lt(wt$estimate, unw$estimate)   # the heavily weighted 0 pulls it down
})

test_that("a degenerate single-cluster fit is dropped, not fatal", {
  # study B has one respondent; with the guard relaxed the clustered fit fails,
  # and afcp() should drop it via tryCatch rather than error.
  m <- tibble::tibble(
    study_id = c("A", "A", "A", "A", "B"),
    resp_id  = c(1, 1, 2, 2, 9),
    A_wins   = c(1, 0, 1, 0, 1)
  )
  d <- afcp(m, by = "study_id", clusters = "resp_id", min_clusters = 1L)
  expect_true("A" %in% d$study_id)
  expect_false("B" %in% d$study_id)
})
