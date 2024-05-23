library(testthat)
source("../../R/fit_params.R")
test_that("fit_params works correctly with rate model", {
  data <- data.frame(Substrate=c(.05,.1,.25,.5,1),Rate=c(4,7,20,35,56))
  result <- fit_params(data, model = "rate", method="lb")
  expected <- list(Km=2.24, Vmax=179.5)
  expect_equal(result, expected)
})
