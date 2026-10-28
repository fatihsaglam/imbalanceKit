# Oversamplers that add synthetic samples and return the full interface
oversamplers <- c("ADASYN", "BLSMOTE", "BiSMOTE", "GSMOTE", "MCSMOTE", "ROS", "ROSE", "RSLSMOTE", "RWO",
                  "SLSMOTE", "SMOTE", "SMOTEWB", "EBSMOTE", "GQEO", "LEAO", "SyMProD")

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
