f_tree <- function(x_train, y_train, x_test, ...) {
  dat <- data.frame(x_train, y = y_train)
  m <- rpart::rpart(y ~ ., data = dat, method = "class",
                    control = rpart::rpart.control(minsplit = 5, cp = 0.005))
  predict(m, newdata = data.frame(x_test), type = "prob")
}

make_ugo <- function(seed = 1, n = c(250, 40), shift = 1.2) {
  set.seed(seed)
  x <- do.call(rbind, lapply(seq_along(n), function(i) {
    matrix(rnorm(n[i] * 2, mean = (i - 1) * shift), ncol = 2)
  }))
  list(x = x, y = factor(rep(paste0("c", seq_along(n)), n)))
}

test_that("uncertainty is the modified margin", {
  prob <- rbind(c(0.7, 0.3), c(0.2, 0.8), c(0.5, 0.5))
  y <- factor(c("a", "b", "a"))
  expect_equal(imbalanceKit:::calculate_uncertainty(prob, y), c(-0.4, -0.6, 0))
  prob3 <- rbind(c(0.1, 0.6, 0.3))
  expect_equal(imbalanceKit:::calculate_uncertainty(prob3, factor("c", levels = c("a", "b", "c"))), 0.3)
})

test_that("UGO returns the expected structure for all base methods", {
  d <- make_ugo()
  for (ty in c("RWO", "SMOTE", "ROS", "MCSMOTE")) {
    set.seed(1)
    m <- UGO(d$x, d$y, type = ty, classifier = f_tree)
    expect_true(all(c("x_new", "y_new", "x_syn", "y_syn", "i_noise", "stop_reason",
                      "n_iter") %in% names(m)), info = ty)
    expect_equal(nrow(m$x_new), nrow(d$x) + nrow(m$x_syn), info = ty)
    expect_equal(length(m$y_new), nrow(m$x_new), info = ty)
    expect_equal(length(m$y_syn), nrow(m$x_syn), info = ty)
    expect_equal(levels(m$y_new), levels(d$y), info = ty)
    # original samples are kept in their original order
    expect_equal(unname(m$x_new[seq_len(nrow(d$x)), ]), unname(d$x), info = ty)
    expect_false(anyNA(m$x_syn), info = ty)
    expect_true(m$stop_reason %in% c("no_difference", "max_size", "too_much_noise",
                                     "no_uncertainty"), info = ty)
  }
})

test_that("UGO only generates samples of the classes it selects", {
  d <- make_ugo()
  set.seed(1)
  m <- UGO(d$x, d$y, type = "ROS", classifier = f_tree)
  expect_gt(nrow(m$x_syn), 0)
  expect_true(all(m$y_syn == "c2"))
})

test_that("UGO adds prop_generate * n samples per iteration", {
  d <- make_ugo(seed = 1, shift = 1.2)
  set.seed(7)
  m <- UGO(d$x, d$y, type = "RWO", classifier = f_tree, prop_generate = 0.1)
  expect_gt(m$n_iter, 0)
  expect_equal(nrow(m$x_syn), m$n_iter * ceiling(0.1 * nrow(d$x) - 1e-8))
  expect_true(m$stop_reason %in% c("no_difference", "max_size", "no_uncertainty"))
})

test_that("UGO has no plot or feature_weights arguments", {
  expect_false("plot" %in% names(formals(UGO)))
  expect_false("feature_weights" %in% names(formals(MCSMOTE)))
})

test_that("UGO stops immediately when everything is noise", {
  set.seed(1)
  x <- matrix(rnorm(400), ncol = 2)
  y <- factor(sample(c("a", "b"), 200, replace = TRUE, prob = c(0.9, 0.1)))
  m <- UGO(x, y, classifier = f_tree, k_noise = 5, pen_noise = 4)
  expect_equal(m$stop_reason, "too_much_noise")
  expect_equal(nrow(m$x_syn), 0)
  expect_equal(nrow(m$x_new), 200)
})

test_that("UGO accepts the supported classifier forms", {
  d <- make_ugo()
  set.seed(1)
  m1 <- UGO(d$x, d$y, type = "ROS", classifier = "rpart")
  expect_s3_class(m1$y_new, "factor")
  # a function returning list(prob = ...) is also accepted
  f_list <- function(x_train, y_train, x_test, ...) list(prob = f_tree(x_train, y_train, x_test))
  set.seed(1); a <- UGO(d$x, d$y, type = "ROS", classifier = f_tree)
  set.seed(1); b <- UGO(d$x, d$y, type = "ROS", classifier = f_list)
  expect_identical(a$x_new, b$x_new)
  skip_if_not_installed("randomForest")
  set.seed(1)
  m2 <- UGO(d$x, d$y, type = "SMOTE", classifier = "randomForest")
  expect_s3_class(m2$y_new, "factor")
})

test_that("UGO validates input and classifier output", {
  d <- make_ugo()
  expect_error(UGO(d$x, as.character(d$y), classifier = f_tree), "factor")
  expect_error(UGO(d$x, d$y, classifier = 1), "classifier must be")
  expect_error(UGO(d$x, d$y, classifier = function(x_train, y_train, x_test, ...) 1),
               "matrix of class probabilities")
  expect_error(UGO(d$x, d$y, classifier = f_tree, prop_generate = 0), "prop_generate")
  expect_error(UGO(d$x, d$y, classifier = f_tree, prop_sampling = 2), "prop_sampling")
  expect_error(UGO(d$x, factor(rep("a", nrow(d$x))), classifier = f_tree), "two classes")
})

test_that("UGO respects the maximum data size", {
  d <- make_ugo(seed = 1, shift = 1.6)
  set.seed(1)
  m <- UGO(d$x, d$y, type = "ROS", classifier = f_tree, comparison = "kruskal",
           lambda_max = 1.2)
  expect_lte(nrow(m$x_new), 1.2 * 2 * nrow(d$x) + ceiling(0.1 * nrow(d$x)))
})

test_that("built-in classifiers return valid probabilities", {
  set.seed(1)
  x <- rbind(matrix(rnorm(200, 0), ncol = 2), matrix(rnorm(60, 2), ncol = 2),
             matrix(rnorm(40, 4), ncol = 2))
  y3 <- factor(rep(c("a", "b", "c"), c(100, 30, 20)))
  y2 <- droplevels(y3[y3 != "c"]); x2 <- x[y3 != "c", ]
  for (cl in c("CART", "LogReg", "KNN", "NaiveBayes", "LDA", "rpart")) {
    for (case in list(list(x2, y2), list(x, y3))) {
      f <- imbalanceKit:::get_classifier(cl)
      p <- imbalanceKit:::predict_class_probs(f, case[[1]], case[[2]], case[[1]])
      expect_equal(dim(p), c(nrow(case[[1]]), nlevels(case[[2]])), info = cl)
      expect_equal(unname(rowSums(p)), rep(1, nrow(p)), tolerance = 1e-6, info = cl)
      expect_true(all(p >= -1e-12 & p <= 1 + 1e-12), info = cl)
      acc <- mean(levels(case[[2]])[max.col(p)] == as.character(case[[2]]))
      expect_gt(acc, 0.6)
    }
  }
  skip_if_not_installed("nnet")
  p <- imbalanceKit:::predict_class_probs(imbalanceKit:::get_classifier("NNET"), x, y3, x)
  expect_equal(unname(rowSums(p)), rep(1, nrow(p)), tolerance = 1e-6)
  skip_if_not_installed("randomForest")
  p <- imbalanceKit:::predict_class_probs(imbalanceKit:::get_classifier("RF"), x, y3, x)
  expect_equal(unname(rowSums(p)), rep(1, nrow(p)), tolerance = 1e-6)
})

test_that("UGO runs with every built-in classifier, also with 3 classes", {
  d3 <- make_ugo(n = c(150, 40, 20), shift = 1.5)
  for (cl in c("CART", "LogReg", "KNN", "NaiveBayes", "LDA")) {
    set.seed(1)
    m <- UGO(d3$x, d3$y, type = "SMOTE", classifier = cl)
    expect_equal(nrow(m$x_new), nrow(d3$x) + nrow(m$x_syn), info = cl)
    expect_false(anyNA(m$x_syn), info = cl)
  }
  expect_error(UGO(d3$x, d3$y, classifier = "nope"))
})
