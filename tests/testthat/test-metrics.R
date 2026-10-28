# small binary example: positive = "p" (the smaller class)
y_true <- factor(c(rep("n", 6), rep("p", 4)), levels = c("n", "p"))
y_pred <- factor(c("n", "n", "n", "n", "p", "p", "p", "p", "n", "n"), levels = c("n", "p"))
# TP = 2, FN = 2, FP = 2, TN = 4

test_that("binary label metrics match hand calculations", {
  expect_equal(ACC(y_true, y_pred), 0.6)
  expect_equal(BACC(y_true, y_pred), (0.5 + 4 / 6) / 2)
  expect_equal(GMEAN(y_true, y_pred), sqrt(0.5 * 4 / 6))
  expect_equal(F1(y_true, y_pred), 0.5)
  expect_equal(PRECISION(y_true, y_pred), 0.5)
  expect_equal(RECALL(y_true, y_pred), 0.5)
  expect_equal(SPECIFICITY(y_true, y_pred), 4 / 6)
  expect_equal(MCC(y_true, y_pred), (2 * 4 - 2 * 2) / sqrt(4 * 4 * 6 * 6))
  expect_equal(P4(y_true, y_pred), 4 / (1 / 0.5 + 1 / 0.5 + 1 / (4 / 6) + 1 / (4 / 6)))
  po <- 0.6; pe <- (6 * 6 + 4 * 4) / 100
  expect_equal(KAPPA(y_true, y_pred), (po - pe) / (1 - pe))
  # IAM for two classes: mean of (c_ii - max off diagonal) / max(row, column total)
  expect_equal(IAM(y_true, y_pred), mean(c((4 - 2) / 6, (2 - 2) / 4)))
  expect_equal(F1(y_true, y_pred, positive = "n"), 2 * 4 / (2 * 4 + 2 + 2))
})

test_that("multi-class averaging", {
  yt <- factor(c("a", "a", "a", "a", "b", "b", "c", "c", "c", "c"))
  yp <- factor(c("a", "a", "a", "b", "b", "a", "c", "c", "b", "c"), levels = levels(yt))
  rec <- c(3 / 4, 1 / 2, 3 / 4)
  f1_k <- c(2 * 3 / (6 + 1 + 1), 2 * 1 / (2 + 1 + 1), 2 * 3 / (6 + 1 + 1))
  # class-wise F1: a: TP 3, FP 1 (b->a), FN 1; b: TP 1, FP 2, FN 1; c: TP 3, FP 0, FN 1
  f1_k <- c(2 * 3 / (6 + 1 + 1), 2 * 1 / (2 + 2 + 1), 2 * 3 / (6 + 0 + 1))
  expect_equal(F1(yt, yp), mean(f1_k))
  expect_equal(F1(yt, yp, average = "macro"), mean(f1_k))
  expect_equal(F1(yt, yp, average = "weighted"), sum(f1_k * c(4, 2, 4)) / 10)
  expect_equal(F1(yt, yp, average = "micro"), ACC(yt, yp))
  expect_equal(RECALL(yt, yp, average = "micro"), ACC(yt, yp))
  expect_equal(BACC(yt, yp), mean(rec))
  expect_equal(GMEAN(yt, yp), prod(rec)^(1 / 3))
  expect_error(F1(yt, yp, average = "binary"), "two classes")
  # Gorodkin MCC equals the Pearson correlation of the one-hot encodings
  oh <- function(f) sapply(levels(yt), function(l) as.numeric(f == l))
  num <- sum(oh(yt) * oh(yp)) / 10 - sum(colMeans(oh(yt)) * colMeans(oh(yp)))
  den <- sqrt((1 - sum(colMeans(oh(yp))^2)) * (1 - sum(colMeans(oh(yt))^2)))
  expect_equal(MCC(yt, yp), num / den)
  expect_gte(IAM(yt, yp), -1)
  expect_lte(IAM(yt, yp), 1)
})

test_that("perfect and worst predictions", {
  yt <- factor(rep(c("a", "b", "c"), c(5, 3, 2)))
  for (f in list(ACC, BACC, GMEAN, MCC, KAPPA, IAM, F1, P4)) {
    expect_equal(f(yt, yt), 1)
  }
  yw <- factor(c(rep("b", 5), rep("c", 3), rep("a", 2)), levels = levels(yt))
  expect_equal(ACC(yt, yw), 0)
  expect_equal(GMEAN(yt, yw), 0)
  expect_equal(F1(yt, yw), 0)
  expect_lt(MCC(yt, yw), 0)
})

test_that("ROC AUC and PR AUC agree with brute force", {
  set.seed(2)
  yt <- factor(sample(c("a", "b"), 60, replace = TRUE, prob = c(0.7, 0.3)))
  score <- round(runif(60), 1)  # ties on purpose
  pos <- get_pos <- names(which.min(table(yt)))
  s1 <- score[yt == pos]; s0 <- score[yt != pos]
  brute <- mean(outer(s1, s0, function(a, b) (a > b) + 0.5 * (a == b)))
  expect_equal(ROCAUC(yt, score, positive = pos), brute)
  # perfect and inverted rankings
  expect_equal(ROCAUC(yt, as.numeric(yt == pos), positive = pos), 1)
  expect_equal(ROCAUC(yt, 1 - as.numeric(yt == pos), positive = pos), 0)
  expect_equal(PRAUC(yt, as.numeric(yt == pos), positive = pos), 1)
  # average precision by definition without ties
  sc <- runif(60)
  o <- order(sc, decreasing = TRUE)
  hit <- (yt == pos)[o]
  ap <- sum(cumsum(hit)[hit] / seq_along(hit)[hit]) / sum(hit)
  expect_equal(PRAUC(yt, sc, positive = pos), ap)
})

test_that("multi-class AUC is one-versus-rest and consistent for two classes", {
  set.seed(3)
  yt <- factor(sample(c("a", "b", "c"), 90, replace = TRUE))
  prob <- matrix(runif(270), 90, 3, dimnames = list(NULL, levels(yt)))
  prob <- prob / rowSums(prob)
  auc_k <- sapply(levels(yt), function(l) ROCAUC(factor(yt == l, labels = c("o", l)), prob[, l], positive = l))
  expect_equal(ROCAUC(yt, prob), mean(auc_k))
  expect_equal(ROCAUC(yt, prob, average = "weighted"), sum(auc_k * table(yt)) / 90, ignore_attr = TRUE)
  expect_true(is.finite(ROCAUC(yt, prob, average = "micro")))
  expect_true(is.finite(PRAUC(yt, prob, average = "micro")))
  # binary matrix input equals vector input
  yb <- factor(sample(c("n", "p"), 50, replace = TRUE, prob = c(0.8, 0.2)))
  p <- runif(50)
  pm <- cbind(n = 1 - p, p = p)
  expect_equal(ROCAUC(yb, pm), ROCAUC(yb, p, positive = "p"))
})

test_that("Brier family", {
  yt <- factor(c("a", "a", "b", "b", "b", "b"))
  prob <- cbind(a = c(0.9, 0.2, 0.1, 0.4, 0.3, 0.2), b = c(0.1, 0.8, 0.9, 0.6, 0.7, 0.8))
  each <- c(2 * 0.1^2, 2 * 0.8^2, 2 * 0.1^2, 2 * 0.4^2, 2 * 0.3^2, 2 * 0.2^2)
  expect_equal(Brier(yt, prob), mean(each))
  # observation 2 is misclassified: penalty (K - 1) / K = 0.5
  expect_equal(PBrier(yt, prob), mean(each) + 0.5 / 6)
  expect_equal(BBrier(yt, prob), mean(c(mean(each[1:2]), mean(each[3:6]))))
  expect_equal(LOGLOSS(yt, prob), -mean(log(c(0.9, 0.2, 0.9, 0.6, 0.7, 0.8))))
  # perfect probabilities
  perfect <- cbind(a = c(1, 1, 0, 0, 0, 0), b = c(0, 0, 1, 1, 1, 1))
  expect_equal(Brier(yt, perfect), 0)
  expect_equal(PBrier(yt, perfect), 0)
  # the penalty makes a wrong confident prediction worse than a correct unsure one
  expect_gt(PBrier(factor(c("a", "b")), cbind(a = c(0.4, 0.6), b = c(0.6, 0.4))),
            PBrier(factor(c("a", "b")), cbind(a = c(0.6, 0.4), b = c(0.4, 0.6))))
})

test_that("ECE and balanced ECE", {
  yt <- factor(c("a", "a", "a", "a", "b", "b"))
  # all predictions are "a" with confidence 0.8: accuracy 4/6
  prob <- cbind(a = rep(0.8, 6), b = rep(0.2, 6))
  expect_equal(ECE(yt, prob), abs(4 / 6 - 0.8))
  # balanced: every class counts 1/2, accuracy is the balanced accuracy 0.5
  expect_equal(BECE(yt, prob), abs(0.5 - 0.8))
  # perfectly calibrated
  yc <- factor(rep(c("a", "b"), each = 5))
  pc <- cbind(a = rep(c(1, 0), each = 5), b = rep(c(0, 1), each = 5))
  expect_equal(ECE(yc, pc), 0)
  expect_error(ECE(yt, prob, n_bins = 0), "n_bins")
})

test_that("evaluate returns all metrics by default and the selected ones", {
  set.seed(4)
  yt <- factor(sample(c("n", "p"), 100, replace = TRUE, prob = c(0.85, 0.15)))
  p <- ifelse(yt == "p", rbeta(100, 3, 2), rbeta(100, 2, 4))
  e <- evaluate(yt, y_prob = p, positive = "p")
  expect_named(e, c("ACC", "BACC", "F1", "GMEAN", "MCC", "ROCAUC", "PRAUC",
                    "Brier", "PBrier", "BBrier", "ECE", "BECE", "P4", "IAM",
                    "PRECISION", "RECALL", "SPECIFICITY", "KAPPA", "LOGLOSS"))
  expect_true(all(is.finite(e)))
  s <- evaluate(yt, y_prob = p, positive = "p", metrics = c("MCC", "BECE"))
  expect_named(s, c("MCC", "BECE"))
  expect_equal(s[["MCC"]], e[["MCC"]])
  # only predicted classes: probability metrics are skipped
  expect_named(evaluate(yt, y_pred = ifelse(p > 0.5, "p", "n")),
               c("ACC", "BACC", "F1", "GMEAN", "MCC", "P4", "IAM", "PRECISION",
                 "RECALL", "SPECIFICITY", "KAPPA"))
  expect_error(evaluate(yt, y_pred = ifelse(p > 0.5, "p", "n"), metrics = "ROCAUC"), "y_prob")
  expect_error(evaluate(yt, y_prob = p, metrics = "foo"), "unknown")
})

test_that("evaluate works for multi-class with average options", {
  set.seed(5)
  yt <- factor(sample(c("a", "b", "c"), 120, replace = TRUE, prob = c(0.7, 0.2, 0.1)))
  prob <- matrix(runif(360), 120, 3, dimnames = list(NULL, levels(yt)))
  prob <- prob / rowSums(prob)
  for (avg in c("macro", "micro", "weighted")) {
    e <- evaluate(yt, y_prob = prob, average = avg)
    expect_true(all(is.finite(e)), info = avg)
  }
  expect_equal(evaluate(yt, y_prob = prob, average = "micro")[["F1"]],
               evaluate(yt, y_prob = prob)[["ACC"]])
})

test_that("metrics validate their input", {
  expect_error(ACC(y_true, y_pred[-1]), "same length")
  expect_error(ACC(y_true, factor(rep("z", 10))), "labels")
  expect_error(Brier(y_true, matrix(0.5, 10, 3)), "one column per class")
  expect_error(Brier(y_true, matrix(2, 10, 2)), "probabilities")
  expect_error(F1(y_true, y_pred, positive = "zzz"), "positive")
})
