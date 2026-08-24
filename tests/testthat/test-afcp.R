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
  # With the guard relaxed the single-cluster group is handed to lm_robust,
  # and what comes back is version-dependent: estimatr >= 2.0.0 refuses it
  # (no between-cluster variation to estimate) so afcp() drops it anyway,
  # while 1.0.6 returns it with a degenerate near-zero standard error. What
  # afcp() must guarantee either way is that the group loop does not abort.
  d0 <- afcp(m, by = "study_id", clusters = "resp_id", min_clusters = 1L)
  expect_true("A" %in% d0$study_id)
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

test_that("the default test is against 0.5, not 0", {
  # 60/100 wins: far from 0.5 but nowhere near far enough to make p ~ 0.
  m <- tibble::tibble(resp_id = 1:100, A_wins = rep(c(1, 1, 1, 0, 0), 20))
  d <- afcp(m, clusters = "resp_id")
  expect_equal(d$estimate, 0.6)
  expect_equal(d$statistic, (0.6 - 0.5) / d$std.error)
  expect_equal(d$p.value, 2 * stats::pt(abs(d$statistic), d$df, lower.tail = FALSE))
  expect_gt(d$p.value, 0.01)
})

test_that("null_value moves only the test, not the estimate or the interval", {
  m <- tibble::tibble(resp_id = 1:100, A_wins = rep(c(1, 1, 1, 0, 0), 20))
  half <- afcp(m, clusters = "resp_id")
  zero <- afcp(m, clusters = "resp_id", null_value = 0)
  expect_equal(half$estimate, zero$estimate)
  expect_equal(half$std.error, zero$std.error)
  expect_equal(half$conf.low, zero$conf.low)
  expect_equal(half$conf.high, zero$conf.high)
  expect_equal(half$df, zero$df)
  expect_lt(zero$p.value, half$p.value)      # 0.6 is much further from 0
  expect_equal(zero$statistic, zero$estimate / zero$std.error)
})

test_that("null_value at the estimate gives p = 1", {
  m <- tibble::tibble(resp_id = 1:100, A_wins = rep(c(1, 1, 1, 0, 0), 20))
  d <- afcp(m, clusters = "resp_id", null_value = 0.6)
  expect_equal(d$statistic, 0)
  expect_equal(d$p.value, 1)
})

test_that("null_value applies within each `by` group", {
  # Study A wins 60% of the time, study B 40%: symmetric about the 0.5 null, so
  # the two groups must come back with the same statistic up to sign.
  m <- tibble::tibble(
    study_id = rep(c("A", "B"), each = 100),
    resp_id = 1:200,
    A_wins = c(rep(c(1, 1, 1, 0, 0), 20), rep(c(1, 1, 0, 0, 0), 20))
  )
  d <- afcp(m, by = "study_id", clusters = "resp_id")
  expect_equal(d$estimate, c(0.6, 0.4))
  expect_equal(d$statistic, c(1, -1) * (0.1 / d$std.error))
  expect_equal(d$p.value[1], d$p.value[2])
})

test_that("null_value must be a finite scalar", {
  m <- tibble::tibble(resp_id = 1:10, A_wins = rep(c(1, 0), 5))
  expect_error(afcp(m, null_value = c(0.5, 0.6)))
  expect_error(afcp(m, null_value = NA_real_))
  expect_error(afcp(m, null_value = "0.5"))
})
