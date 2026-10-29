make_multiclass <- function(n = c(120, 40, 15), seed = 1) {
  set.seed(seed)
  x <- do.call(rbind, lapply(seq_along(n), function(j) {
    matrix(rnorm(n[j] * 3, mean = j * 0.8), n[j], 3)
  }))
  colnames(x) <- c("a", "b", "c")
  list(x = x, y = factor(rep(paste0("c", seq_along(n)), n)))
}

resamplers <- c("ROS", "RWO", "ROSE", "SMOTE", "ADASYN", "BLSMOTE", "SLSMOTE",
                "RSLSMOTE", "GSMOTE", "SMOTEWB", "BiSMOTE", "MCSMOTE", "EBSMOTE", "GQEO",
                "LEAO", "SyMProD", "RadiusSMOTE", "VSSMOTE")

test_that("all resamplers balance three classes", {
  d <- make_multiclass()
  for (nm in resamplers) {
    f <- get(nm, asNamespace("imbalanceKit"))
    set.seed(2)
    m <- suppressWarnings(f(d$x, d$y))
    expect_equal(as.vector(table(m$y_new)), c(120L, 120L, 120L), info = nm)
    expect_equal(nrow(m$x_syn), 185L, info = nm)
    expect_equal(length(m$y_syn), 185L, info = nm)
    expect_false(anyNA(m$x_syn), info = nm)
    expect_equal(colnames(m$x_new), colnames(d$x), info = nm)
  }
})

test_that("generated samples belong to the right class region (ordering of means)", {
  d <- make_multiclass(n = c(300, 100, 50))
  for (nm in c("SMOTE", "ADASYN", "MCSMOTE", "BiSMOTE", "SLSMOTE")) {
    f <- get(nm, asNamespace("imbalanceKit"))
    set.seed(3)
    m <- f(d$x, d$y)
    mu <- tapply(rowMeans(m$x_syn), m$y_syn, mean)
    expect_gt(mu[["c3"]], mu[["c2"]], label = nm)
  }
})

test_that("k = 1 works for all neighbour based resamplers", {
  d <- make_multiclass()
  expect_no_error(SMOTE(d$x, d$y, k = 1))
  expect_no_error(ADASYN(d$x, d$y, k = 1))
  expect_no_error(BiSMOTE(d$x, d$y, k = 1))
  expect_no_error(GSMOTE(d$x, d$y, k = 1))
  expect_no_error(suppressWarnings(BLSMOTE(d$x, d$y, k1 = 1, k2 = 1)))
  expect_no_error(suppressWarnings(SLSMOTE(d$x, d$y, k1 = 1, k2 = 1)))
  expect_no_error(suppressWarnings(RSLSMOTE(d$x, d$y, k1 = 1, k2 = 1)))
  expect_equal(as.vector(table(SMOTE(d$x, d$y, k = 1)$y_new)), c(120L, 120L, 120L))
  expect_equal(as.vector(table(ADASYN(d$x, d$y, k = 1)$y_new)), c(120L, 120L, 120L))
})

test_that("k larger than the class size is reduced", {
  d <- make_multiclass(n = c(60, 20, 4))
  for (nm in c("SMOTE", "ADASYN", "BiSMOTE", "GSMOTE")) {
    f <- get(nm, asNamespace("imbalanceKit"))
    expect_no_error(f(d$x, d$y, k = 10))
  }
})

test_that("single sample classes fall back to duplication with a warning", {
  d <- make_multiclass(n = c(60, 20, 1))
  for (nm in c("SMOTE", "ADASYN", "BiSMOTE", "SLSMOTE", "RSLSMOTE", "GSMOTE")) {
    f <- get(nm, asNamespace("imbalanceKit"))
    m <- suppressWarnings(f(d$x, d$y))
    expect_equal(as.vector(table(m$y_new)), c(60L, 60L, 60L), info = nm)
  }
  expect_warning(SMOTE(d$x, d$y), "single sample")
})

test_that("ovRate: rounding, scalar and per class values", {
  d <- make_multiclass()  # needs 0, 80 and 105 samples
  expect_equal(nrow(SMOTE(d$x, d$y, ovRate = 0)$x_syn), 0)
  expect_equal(nrow(SMOTE(d$x, d$y, ovRate = 0.5)$x_syn), 40 + 53)
  # half is rounded up, not to even: 0.5 * 105 = 52.5 -> 53
  expect_equal(imbalanceKit:::n_needed_rule(0.5, c(120, 40, 15)), c(0L, 40L, 53L))
  expect_equal(imbalanceKit:::n_needed_rule(0.1, c(30, 0)), c(0L, 3L))
  # one value per class
  m <- SMOTE(d$x, d$y, ovRate = c(1, 0, 0.5))
  expect_equal(as.vector(table(m$y_syn)), c(0L, 0L, 53L))
  # more than 1 oversamples beyond balance
  expect_equal(nrow(SMOTE(d$x, d$y, ovRate = 2)$x_syn), 160 + 210)
  expect_error(SMOTE(d$x, d$y, ovRate = -1), "ovRate")
  expect_error(SMOTE(d$x, d$y, ovRate = c(1, 1)), "ovRate")
})

test_that("ADASYN allocates exactly the needed number of samples", {
  d <- make_multiclass()
  m <- ADASYN(d$x, d$y)
  expect_equal(sum(m$C$c3), 105)
  expect_equal(sum(m$C$c2), 80)
  expect_null(m$C$c1)
})

test_that("RUS works with three classes and keeps the row order", {
  d <- make_multiclass()
  set.seed(1)
  m <- RUS(d$x, d$y)
  expect_equal(as.vector(table(m$y_new)), c(15L, 15L, 15L))
  expect_true(all(diff(as.integer(m$y_new)) >= 0))
  expect_error(RUS(d$x, d$y, n_neededToRemove = c(1, 2)), "one element per class")
  expect_error(RUS(d$x, d$y, n_neededToRemove = c(0, 0, 100)), "higher")
})

test_that("ROSE accepts one bandwidth per class", {
  d <- make_multiclass()
  expect_no_error(ROSE(d$x, d$y, h = c(0.5, 1, 2)))
  expect_error(ROSE(d$x, d$y, h = c(1, 2)), "number of classes")
  expect_error(ROSE(d$x, d$y, h = -1), "negative")
})

test_that("resamplers accept data frames and keep levels of empty classes out", {
  d <- make_multiclass()
  m <- SMOTE(as.data.frame(d$x), d$y)
  expect_true(is.matrix(m$x_new))
  y_extra <- factor(as.character(d$y), levels = c("c1", "c2", "c3", "unused"))
  m2 <- SMOTE(d$x, y_extra)
  expect_equal(levels(m2$y_new), c("c1", "c2", "c3"))
})

test_that("UGO works with three classes for every generator type", {
  d <- make_multiclass(n = c(100, 50, 25))
  f_tree <- function(x_train, y_train, x_test, ...) {
    fit <- rpart::rpart(y ~ ., data = data.frame(y = y_train, x_train), method = "class")
    predict(fit, data.frame(x_test), type = "prob")
  }
  for (ty in c("RWO", "SMOTE", "ROS", "MCSMOTE")) {
    set.seed(4)
    m <- UGO(d$x, d$y, type = ty, classifier = f_tree)
    expect_equal(nrow(m$x_new), nrow(d$x) + nrow(m$x_syn), info = ty)
    expect_equal(levels(m$y_syn), levels(d$y), info = ty)
    expect_false(anyNA(m$x_syn), info = ty)
  }
})

test_that("EBSMOTE, GQEO, LEAO and SyMProD handle tiny classes and options", {
  d <- make_multiclass(n = c(60, 20, 2))
  for (nm in c("EBSMOTE", "GQEO", "LEAO", "SyMProD")) {
    f <- get(nm, asNamespace("imbalanceKit"))
    m <- suppressWarnings(f(d$x, d$y))
    expect_equal(as.vector(table(m$y_new)), c(60L, 60L, 60L), info = nm)
  }
  d2 <- make_multiclass(n = c(80, 25))
  for (pt in c("bagging", "logistic", "knn", "nb")) {
    m <- LEAO(d2$x, d2$y, prob_type = pt)
    expect_equal(as.vector(table(m$y_new)), c(80L, 80L), info = pt)
    expect_false(anyNA(m$x_syn), info = pt)
  }
  expect_error(LEAO(d2$x, d2$y, step_min = 1, step_max = 0.1), "step_min")
  expect_gt(nrow(GQEO(d2$x, d2$y, check_planarity = FALSE)$x_syn), 0)
  expect_warning(GQEO(d2$x, d2$y, k = 2), "quadrilateral")
})

test_that("GQEO samples lie inside the convex hull of their class (bounding box)", {
  d <- make_multiclass(n = c(100, 30))
  set.seed(1)
  m <- GQEO(d$x, d$y)
  x_min <- d$x[d$y == "c2", ]
  for (j in 1:3) {
    expect_true(all(m$x_syn[, j] >= min(x_min[, j]) - 1e-8 & m$x_syn[, j] <= max(x_min[, j]) + 1e-8))
  }
})
