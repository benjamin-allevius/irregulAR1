context("Matrix functions")

library(Matrix)

ar1_cov_xy <- function(obs_idx, pred_idx = obs_idx, rho, sigma) {
  sigma^2 / (1 - rho^2) * rho^outer(pred_idx, obs_idx,
                                    function(x, y) abs(x-y))
}

test_that("ar1_cov_consecutive", {
  n <- 5
  s <- 3
  r <- 0.5
  x <- ar1_cov_consecutive(n, r, s)
  y <- matrix(0, n, n)
  for (i in 1:n) {
    for (j in 1:n) {
      y[i, j] <- r^abs(i - j)
    }
  }
  y <- s^2 / (1 - r^2) * y
  expect_equal(x, y)
})

test_that("ar1_cov_irregular", {
  s <- 3
  r <- 0.5
  t <- c(1, 3, 6:7, 19)
  S1 <- ar1_cov_xy(t, t, r, s)
  S2 <- ar1_cov_irregular(t, r, s)
  expect_equal(S2, S1)
})

test_that("ar1_cross_cov", {
  s <- 3
  r <- 0.5
  t1 <- c(1, 3, 6:7, 19)
  t2 <- c(2, 5, 11:14)
  S1 <- ar1_cov_xy(t1, t2, r, s)
  S2 <- ar1_cross_cov(t1, t2, r, s)
  expect_equal(S2, S1)
})

test_that("ar1_cov_chol_irregular", {
  s <- 3
  r <- 0.5
  t1 <- c(1, 3, 6:7, 19)
  t2 <- c(2, 5, 11:14)
  U1 <- chol(ar1_cov_xy(t1, t1, r, s))
  U2 <- ar1_cov_chol_irregular(t1, r, s)
  expect_equal(U2, U1)
})


test_that("ar1_prec_consecutive", {
  n <- 5
  s <- 3
  r <- 0.5
  Q1 <- solve(ar1_cov_consecutive(n, r, s))
  Q2 <- ar1_prec_consecutive(n, r, s)
  expect_equal(Matrix::diag(Q2), diag(Q1))
  expect_equal(Matrix::diag(Q2[-nrow(Q2),-1]), diag(Q1[-nrow(Q1),-1]))
  expect_equal(Matrix::diag(Q2[-1,-ncol(Q2)]), diag(Q1[-1,-ncol(Q1)]))
})

test_that("ar1_prec_irregular", {
  s <- 3
  r <- 0.5
  t1 <- c(1, 3, 6:7, 19)
  Q1 <- solve(ar1_cov_xy(t1, t1, r, s))
  Q2 <- ar1_prec_irregular(t1, r, s)
  expect_equal(Matrix::diag(Q2), diag(Q1))
  expect_equal(Matrix::diag(Q2[-nrow(Q2),-1]), diag(Q1[-nrow(Q1),-1]))
  expect_equal(Matrix::diag(Q2[-1,-ncol(Q2)]), diag(Q1[-1,-ncol(Q1)]))
})


test_that("chol_tridiag_upper", {
  s <- 3
  r <- 0.5
  t <- c(1, 3, 6:7, 19)
  U1 <- chol(ar1_prec_irregular(t, r, s))
  U2 <- chol_tridiag_upper(ar1_prec_irregular(t, r, s))
  expect_equal(Matrix::diag(U2), diag(U1))
  expect_equal(Matrix::diag(U2[-nrow(U2),-1]), diag(U1[-nrow(U1),-1]))
})

test_that("band1_backsolve", {
  s <- 3
  r <- 0.5
  t <- c(1, 3, 6:7, 19)
  z <- 1:length(t)
  U <- chol_tridiag_upper(ar1_prec_irregular(t, r, s))
  x1 <- irregulAR1::band1_backsolve(U, z)
  x2 <- solve(U, z)
  expect_equal(as.vector(x1), as.vector(x2))
})