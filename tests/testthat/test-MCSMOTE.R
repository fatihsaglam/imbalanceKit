# Straightforward implementation of Algorithm 1 of the paper, used as reference
reference_tm <- function(x, q) {
  n <- nrow(x)
  D <- as.matrix(stats::dist(x))
  K <- matrix(0, n, n)
  for (i in 1:n) {
    s <- stats::quantile(D[i, ], q, names = FALSE)
    K[i, ] <- exp(-0.5 * D[i, ]^2 / s^2)
  }
  M <- K
  for (it in 1:20000) {
    M <- M / rowSums(M)
    M <- t(t(M) / colSums(M))
    if (max(abs(rowSums(M) - 1)) < 1e-9 && max(abs(colSums(M) - 1)) < 1e-9) break
  }
  M
}

test_that("transition matrix is doubly stochastic and follows the paper", {
  set.seed(3)
  x <- matrix(rnorm(80), ncol = 2)
  for (q in c(0.3, 0.5, 1)) {
    m <- imbalanceKit:::calculate_transition_matrix(x, thresh_qntl = q, tol = 1e-8, max_iter = 20000)
    expect_true(m$converged)
    expect_true(all(m$M >= 0))
    expect_equal(rowSums(m$M), rep(1, 40), tolerance = 1e-6)
    expect_equal(colSums(m$M), rep(1, 40), tolerance = 1e-6)
    # orientation matters: M[i, ] is the distribution of the next state from i
    expect_equal(m$M, reference_tm(x, q), tolerance = 1e-5)
  }
})

test_that("MCSMOTE returns the common structure and balances classes", {
  d <- make_imbalanced()
  set.seed(1)
  m <- MCSMOTE(d$x, d$y, thresh_qntl = 0.2)
  expect_true(all(c("x_new", "y_new", "x_syn", "y_syn", "converged") %in% names(m)))
  expect_equal(as.vector(table(m$y_new)), c(200L, 200L))
  expect_equal(nrow(m$x_new), nrow(d$x) + nrow(m$x_syn))
  expect_equal(colnames(m$x_syn), colnames(d$x))
  expect_false(anyNA(m$x_syn))
})

test_that("MCSMOTE synthetic samples lie on segments between class samples", {
  d <- make_imbalanced()
  x_pos <- d$x[d$y == "positive", ]
  set.seed(1)
  m <- MCSMOTE(d$x, d$y)
  # convex combinations of two samples stay inside the bounding box
  expect_true(all(m$x_syn[, 1] >= min(x_pos[, 1]) - 1e-8 & m$x_syn[, 1] <= max(x_pos[, 1]) + 1e-8))
  expect_true(all(m$x_syn[, 2] >= min(x_pos[, 2]) - 1e-8 & m$x_syn[, 2] <= max(x_pos[, 2]) + 1e-8))
})

test_that("small quantiles keep generation local", {
  set.seed(4)
  x <- rbind(matrix(rnorm(200, 0, 0.2), ncol = 2),
             matrix(rnorm(40, 10, 0.2), ncol = 2),  # two distant minority clusters
             matrix(rnorm(40, -10, 0.2), ncol = 2))
  y <- factor(c(rep("neg", 100), rep("pos", 40)), levels = c("neg", "pos"))
  m <- MCSMOTE(x, y, thresh_qntl = 0.01)
  # almost no sample is generated between the clusters
  between <- abs(m$x_syn[, 1]) < 5
  expect_lt(mean(between), 0.05)
})

test_that("MCSMOTE works with more than two classes and ovRate", {
  set.seed(5)
  x <- rbind(matrix(rnorm(300), ncol = 2), matrix(rnorm(100, 2), ncol = 2),
             matrix(rnorm(40, 4), ncol = 2))
  y <- factor(rep(c("a", "b", "c"), c(150, 50, 20)))
  m <- MCSMOTE(x, y)
  expect_equal(as.vector(table(m$y_new)), c(150L, 150L, 150L))
  m <- MCSMOTE(x, y, ovRate = 0.5)
  expect_equal(nrow(m$x_syn), round(0.5 * 100) + round(0.5 * 130))
  expect_equal(nrow(MCSMOTE(x, y, ovRate = 0)$x_syn), 0)
})

test_that("MCSMOTE handles duplicates and a single-sample class", {
  x <- rbind(matrix(rnorm(40), ncol = 2), matrix(1, 5, 2))
  y <- factor(c(rep("a", 20), rep("b", 5)))
  m <- MCSMOTE(x, y, thresh_qntl = 0.001)
  expect_false(anyNA(m$x_syn))
  x2 <- rbind(matrix(rnorm(40), ncol = 2), matrix(0, 1, 2))
  y2 <- factor(c(rep("a", 20), "b"))
  m2 <- MCSMOTE(x2, y2)
  expect_equal(nrow(m2$x_syn), 19)
  expect_true(all(m2$x_syn == 0))
})

test_that("MCSMOTE validates its input", {
  d <- make_imbalanced()
  expect_error(MCSMOTE(d$x, as.character(d$y)), "factor")
  expect_error(MCSMOTE(d$x, d$y, thresh_qntl = 0), "thresh_qntl")
  expect_error(MCSMOTE(d$x, d$y, thresh_qntl = 2), "thresh_qntl")
  expect_error(MCSMOTE(d$x, d$y, ovRate = -1), "non-negative")
})

test_that("MCSMOTE is reproducible", {
  d <- make_imbalanced()
  set.seed(8); m1 <- MCSMOTE(d$x, d$y)
  set.seed(8); m2 <- MCSMOTE(d$x, d$y)
  expect_identical(m1$x_new, m2$x_new)
})
