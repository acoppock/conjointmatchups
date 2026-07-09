test_that("check_conjoint passes a clean forced choice", {
  tasks <- data.frame(chosen_1 = c(1, 0), chosen_2 = c(0, 1))
  expect_invisible(check_conjoint(tasks))
})

test_that("check_conjoint catches ties and double-picks", {
  expect_error(check_conjoint(data.frame(chosen_1 = 1, chosen_2 = 1)),
               "exactly one")
  expect_error(check_conjoint(data.frame(chosen_1 = 0, chosen_2 = 0)),
               "exactly one")
  expect_error(check_conjoint(data.frame(chosen_1 = 2, chosen_2 = 0)),
               "0/1")
})
