# Oversamplers that add synthetic samples and return the full interface
oversamplers <- c("ADASYN", "BLSMOTE", "BiSMOTE", "GSMOTE", "MCSMOTE", "ROS", "ROSE", "RSLSMOTE", "RWO",
                  "SLSMOTE", "SMOTE", "SMOTEWB", "EBSMOTE", "GQEO", "LEAO", "SyMProD", "RadiusSMOTE", "VSSMOTE")

test_that("oversamplers return the common structure", {
  d <- make_imbalanced()
  for (nm in oversamplers) {
    f <- get(nm, asNamespace("imbalanceKit"))
    set.seed(10)
    m <- f(x = d$x, y = d$y)
    expect_true(all(c("x_new", "y_new", "x_syn", "y_syn") %in% names(m)), info = nm)
    expect_equal(nrow(m$x_new), length(m$y_new), info = nm)
    expect_equal(nrow(m$x_new), nrow(d$x) + nrow(m$x_syn), info = nm)
    expect_equal(ncol(m$x_new), ncol(d$x), info = nm)
    expect_true(is.factor(m$y_new), info = nm)
    expect_equal(levels(m$y_new), levels(d$y), info = nm)
    # original samples are kept untouched at the top
    expect_equal(unname(m$x_new[seq_len(nrow(d$x)), ]), unname(d$x), info = nm)
  }
})

test_that("oversamplers do not remove majority samples and increase minority", {
  d <- make_imbalanced()
  for (nm in oversamplers) {
    f <- get(nm, asNamespace("imbalanceKit"))
    set.seed(10)
    m <- f(x = d$x, y = d$y)
    tab <- table(m$y_new)
    expect_equal(unname(tab["negative"]), 200L, info = nm)
    expect_gt(unname(tab["positive"]), 20L)
  }
})

test_that("results are reproducible with the same seed", {
  d <- make_imbalanced()
  for (nm in oversamplers) {
    f <- get(nm, asNamespace("imbalanceKit"))
    set.seed(5); m1 <- f(x = d$x, y = d$y)
    set.seed(5); m2 <- f(x = d$x, y = d$y)
    expect_identical(m1$x_new, m2$x_new, info = nm)
  }
})

test_that("SMOTEWB validates its input", {
  d <- make_imbalanced()
  expect_error(SMOTEWB(x = d$x, y = as.character(d$y)), "factor")
  expect_error(SMOTEWB(x = "a", y = d$y), "matrix or dataframe")
})

test_that("ovRate = 0 leaves the data unchanged for SMOTE", {
  d <- make_imbalanced()
  set.seed(1)
  m <- SMOTE(x = d$x, y = d$y, ovRate = 0)
  expect_equal(nrow(m$x_new), nrow(d$x))
})

test_that("RadiusSMOTE stays within the safe radius", {
  d <- make_imbalanced()
  set.seed(2)
  m <- RadiusSMOTE(d$x, d$y, k = 5)
  x_pos <- d$x[d$y == "positive", ]; x_neg <- d$x[d$y == "negative", ]
  # every synthetic sample lies in the ball (nearest other-class distance) of a positive sample
  r <- FNN::get.knnx(x_neg, x_pos, k = 1)$nn.dist[, 1]
  ratio <- sweep(imbalanceKit:::cross_dist(x_pos, m$x_syn), 1, r, "/")
  expect_true(all(apply(ratio, 2, min) <= 1 + 1e-8))
  expect_true(m$n_safe$positive <= sum(d$y == "positive"))
})

test_that("VSSMOTE with k1 = 0, k2 = k uses all lines and the window removes lines", {
  d <- make_imbalanced()
  set.seed(3)
  m_all <- VSSMOTE(d$x, d$y, k = 5)
  expect_equal(m_all$n_valid_lines$positive, m_all$n_lines$positive)
  m_win <- VSSMOTE(d$x, d$y, k = 5, k1 = 4, k2 = 5)
  expect_lt(m_win$n_valid_lines$positive, m_win$n_lines$positive)
  expect_equal(nrow(m_win$x_syn), sum(d$y == "negative") - sum(d$y == "positive"))
  expect_error(VSSMOTE(d$x, d$y, k1 = 4, k2 = 2))
  expect_warning(VSSMOTE(d$x, d$y, k = 5, k1 = 6, k2 = 6), "all lines")
})
