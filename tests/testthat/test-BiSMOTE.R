test_that("BiSMOTE returns the common structure and balances classes", {
  d <- make_imbalanced()
  set.seed(1)
  m <- BiSMOTE(d$x, d$y)
  expect_named(m, c("x_new", "y_new", "x_syn", "y_syn"))
  expect_equal(nrow(m$x_new), nrow(d$x) + nrow(m$x_syn))
  expect_equal(unname(table(m$y_new)), unname(table(factor(rep(c("a", "b"), 200)))))
  expect_equal(colnames(m$x_syn), colnames(d$x))
  expect_equal(levels(m$y_syn), levels(d$y))
  expect_false(anyNA(m$x_syn))
})

test_that("BiSMOTE works with more than two classes", {
  set.seed(2)
  x <- rbind(matrix(rnorm(300), ncol = 2), matrix(rnorm(100, 2), ncol = 2),
             matrix(rnorm(40, 4), ncol = 2))
  y <- factor(rep(c("a", "b", "c"), c(150, 50, 20)))
  m <- BiSMOTE(x, y, k = 3)
  expect_equal(as.vector(table(m$y_new)), c(150L, 150L, 150L))
})

test_that("BiSMOTE respects ovRate and handles large k", {
  d <- make_imbalanced()
  m <- BiSMOTE(d$x, d$y, ovRate = 0.25)
  expect_equal(nrow(m$x_syn), 45)
  # k larger than the class size is reduced instead of failing
  expect_no_error(BiSMOTE(d$x, d$y, k = 100))
  m0 <- BiSMOTE(d$x, d$y, ovRate = 0)
  expect_equal(nrow(m0$x_syn), 0)
})

test_that("BiSMOTE falls back to duplication for a single-sample class", {
  x <- rbind(matrix(rnorm(40), ncol = 2), matrix(rnorm(2), ncol = 2))
  y <- factor(c(rep("a", 20), "b"))
  expect_warning(m <- BiSMOTE(x, y), "single sample")
  expect_equal(nrow(m$x_syn), 19)
  expect_true(all(m$x_syn[, 1] == x[21, 1]))
})

test_that("BiSMOTE handles duplicated samples", {
  x <- rbind(matrix(rnorm(40), ncol = 2), matrix(2, 6, 2))
  y <- factor(c(rep("a", 20), rep("b", 6)))
  m <- BiSMOTE(x, y, k = 3)
  expect_false(anyNA(m$x_syn))
  expect_true(all(is.finite(m$x_syn)))
})

test_that("BiSMOTE validates its input", {
  d <- make_imbalanced()
  expect_error(BiSMOTE(d$x, as.character(d$y)), "factor")
  expect_error(BiSMOTE("a", d$y), "matrix or dataframe")
  expect_error(BiSMOTE(d$x[-1, ], d$y), "same number")
  expect_error(BiSMOTE(d$x, d$y, k = 0), "positive")
  expect_error(BiSMOTE(d$x, d$y, ovRate = -1), "non-negative")
})

test_that("BiSMOTE is reproducible", {
  d <- make_imbalanced(seed = 1, n_neg = 120, n_pos = 15)
  set.seed(11); m1 <- BiSMOTE(d$x, d$y, k = 3, ovRate = 0.5)
  set.seed(11); m2 <- BiSMOTE(d$x, d$y, k = 3, ovRate = 0.5)
  expect_identical(m1$x_new, m2$x_new)
  expect_equal(nrow(m1$x_syn), 53)
})
