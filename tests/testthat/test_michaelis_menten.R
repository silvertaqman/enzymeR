library(testthat)
source("../../R/michaelis_menten.R")
test_that("michaelis_menten works correctly with rate model", {
  data <- data.frame(Substrate=c(.05,.1,.25,.5,1),Rate=c(4,7,20,35,56))
  result <- michaelis_menten(data, model = "rate", method="lb")
  expected <- list(Km=2.24, Vmax=179.5)
  expect_equal(result, expected)
})
