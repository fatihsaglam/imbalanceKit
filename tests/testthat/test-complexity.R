y_imb <- factor(rep(c("a", "b"), c(6, 2)))

test_that("imbalance measures match hand calculations", {
  expect_equal(complexity_IR(y = y_imb), 3)
  p <- c(0.75, 0.25)
  expect_equal(complexity_C1(y = y_imb), 1 + sum(p * log(p)) / log(2))
  expect_equal(complexity_C2(y = y_imb), 0.4)
  expect_equal(complexity_ID(y = y_imb), 0.5)
  bal <- factor(rep(c("a", "b", "c"), each = 4))
  expect_equal(c(complexity_IR(y = bal), complexity_C1(y = bal), complexity_C2(y = bal),
                 complexity_ID(y = bal)), c(1, 0, 0, 0), tolerance = 1e-12)
  # imbalance degree: the integer part is (number of minority classes - 1)
  y3 <- factor(rep(c("a", "b", "c"), c(10, 2, 2)))
  expect_gte(complexity_ID(y = y3), 1)
  expect_lt(complexity_ID(y = y3), 2)
})

x_line <- matrix(c(0, 1, 2, 3.1, 4.1, 5), ncol = 1)
y_line <- factor(rep(c("a", "b"), each = 3))

test_that("neighbourhood measures match hand calculations", {
  expect_equal(complexity_N1(x_line, y_line), 2 / 6)
  expect_equal(complexity_N2(x_line, y_line), (5.8 / 12.5) / (1 + 5.8 / 12.5))
  expect_equal(complexity_N3(x_line, y_line), 0)
  # local sets (self excluded): sizes 2, 2, 1, 1, 2, 2 -> LSC = 1 - 10 / 36
  expect_equal(complexity_LSC(x_line, y_line), 1 - 10 / 36)
})

test_that("R and R_aug use the class weights of Oh (2011) and Borsos et al. (2018)", {
  d <- make_imbalanced(seed = 4, n_neg = 120, n_pos = 12)
  d$x[d$y == "positive", ] <- d$x[d$y == "positive", ] - 1.5   # overlap
  err <- function(yy, xx) {
    nn <- FNN::get.knnx(apply(xx, 2, function(v) (v - min(v)) / diff(range(v))),
                        apply(xx, 2, function(v) (v - min(v)) / diff(range(v))), k = 2)$nn.index[, 2]
    tapply(yy[nn] != yy, yy, mean)
  }
  R_k <- err(d$y, d$x)
  IR <- 10
  # k = 1, theta = 0: a sample is in the overlap when its nearest neighbour is of another class
  expect_equal(complexity_R(d$x, d$y, k = 1, theta = 0),
               (IR * R_k[["negative"]] + R_k[["positive"]]) / (IR + 1))
  expect_equal(complexity_R_aug(d$x, d$y, k = 1, theta = 0),
               (R_k[["negative"]] + IR * R_k[["positive"]]) / (IR + 1))
  expect_equal(complexity_R(d$x, d$y, k = 1, theta = 0), complexity_N3(d$x, d$y))
  expect_gt(complexity_R_aug(d$x, d$y), complexity_R(d$x, d$y))
})

test_that("separated classes are easy and mixed classes are hard", {
  set.seed(1)
  y <- factor(rep(c("a", "b"), c(100, 20)))
  x_sep <- rbind(matrix(rnorm(200), ncol = 2), matrix(rnorm(40, 12), ncol = 2))
  x_mix <- matrix(rnorm(240), ncol = 2)
  easy <- complexity(x_sep, y, seed = 1)
  hard <- complexity(x_mix, y, seed = 1)
  expect_equal(unname(easy[c("N3", "R", "R_aug", "N4")]), rep(0, 4))
  expect_lt(easy[["N1"]], 0.05)
  expect_lt(easy[["F3"]], 0.1)
  expect_equal(easy[["IR"]], hard[["IR"]])
  for (m in c("F1", "F2", "F3", "F4", "N1", "N2", "N3", "N4", "R_aug", "LSC")) {
    expect_gt(hard[[m]], easy[[m]])
  }
})

test_that("types of minority examples add up to one", {
  d <- make_imbalanced(seed = 5, n_neg = 150, n_pos = 25)
  tp <- complexity(d$x, d$y, measures = c("SAFE", "BORDERLINE", "RARE", "OUTLIER"))
  expect_equal(sum(tp), 1)
  expect_equal(complexity_SAFE(d$x, d$y), tp[["SAFE"]])
  expect_equal(complexity_OUTLIER(d$x, d$y), tp[["OUTLIER"]])
})

test_that("complexity() selects measures, works with 3 classes and checks input", {
  set.seed(2)
  x <- rbind(matrix(rnorm(200), ncol = 2), matrix(rnorm(60, 2), ncol = 2), matrix(rnorm(40, 4), ncol = 2))
  y <- factor(rep(c("a", "b", "c"), c(100, 30, 20)))
  all3 <- complexity(x, y, seed = 1)
  expect_equal(length(all3), 21)
  expect_false(anyNA(all3))
  expect_true(all(all3 >= 0))
  sel <- complexity(x, y, measures = c("R_aug", "IR"))
  expect_equal(names(sel), c("R_aug", "IR"))
  expect_equal(sel[["IR"]], 5)
  expect_equal(sel[["R_aug"]], complexity_R_aug(x, y))
  expect_equal(complexity(x, y, measures = "N4", seed = 3)[[1]], complexity_N4(x, y, seed = 3))
  expect_error(complexity(x, y, measures = "foo"), "unknown")
})
