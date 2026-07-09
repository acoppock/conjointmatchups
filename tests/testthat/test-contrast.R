test_that("valid_contrast enforces shared, differing attribute", {
  expect_true(valid_contrast(list(party = "R"), list(party = "D")))
  expect_false(valid_contrast(list(party = "R"), list(party = "R")))
  expect_false(valid_contrast(list(party = "R"), list(gender = "F")))
})

test_that("contrast_message names the offending attribute", {
  expect_match(contrast_message(list(party = "R"), list(party = "R")), "party")
  expect_match(contrast_message(list(party = "R"), list(gender = "F")),
               "don't share")
})
