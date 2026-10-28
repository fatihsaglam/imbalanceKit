# Classifier wrappers for UGO. A classifier is a function
#   function(x_train, y_train, x_test, ...)
# returning a matrix of class probabilities for the rows of x_test with one
# column per level of y_train (in level order).

# Built-in classifiers. Every classifier is a function with the arguments
# (x_train, y_train, x_test, ...) and returns the class probabilities of the
# rows of x_test, one column per level of y_train.

# Names accepted by `classifier` (aliases in the second vector).
classifier_names <- c("CART", "RF", "LogReg", "KNN", "NaiveBayes", "LDA", "NNET")
classifier_aliases <- c(rpart = "CART", randomForest = "RF", nnet = "NNET",
                        glm = "LogReg", lda = "LDA", knn = "KNN", nb = "NaiveBayes")

# softmax of the rows of a score matrix (numerically stable)
#' @noRd
softmax_rows <- function(score) {
  score <- score - apply(score, 1, max)
  e <- exp(score)
  e / rowSums(e)
}

# CART (package rpart)
#' @noRd
classifier_CART <- function(x_train, y_train, x_test, ...) {
  dat <- data.frame(x_train, y = y_train)
  model <- rpart::rpart(y ~ ., data = dat, method = "class", ...)
  prob <- predict(model, newdata = data.frame(x_test), type = "prob")
  prob[, levels(y_train), drop = FALSE]
}

# Random forest (package randomForest)
#' @noRd
classifier_RF <- function(x_train, y_train, x_test, ...) {
  if (!requireNamespace("randomForest", quietly = TRUE)) {
    stop("package 'randomForest' is required for classifier = \"RF\"")
  }
  model <- randomForest::randomForest(x = x_train, y = y_train, ...)
  predict(model, newdata = x_test, type = "prob")
}

# Logistic regression: glm for two classes, one-vs-rest glm (probabilities
# normalised) for more classes.
#' @noRd
classifier_LogReg <- function(x_train, y_train, x_test, ...) {
  class_names <- levels(y_train)
  dat <- data.frame(x_train)
  new <- data.frame(x_test)
  fit_one <- function(is_class) {
    d <- cbind(dat, .y = as.numeric(is_class))
    m <- suppressWarnings(stats::glm(.y ~ ., data = d, family = stats::binomial(), ...))
    suppressWarnings(as.numeric(predict(m, newdata = new, type = "response")))
  }
  if (length(class_names) == 2) {
    p1 <- fit_one(y_train == class_names[2])
    prob <- cbind(1 - p1, p1)
  } else {
    prob <- sapply(class_names, function(m) fit_one(y_train == m))
    prob <- prob / pmax(rowSums(prob), 1e-12)
  }
  prob[is.na(prob)] <- 1 / length(class_names)
  colnames(prob) <- class_names
  prob
}

# k nearest neighbours: class proportions among the k neighbours (package FNN)
#' @noRd
classifier_KNN <- function(x_train, y_train, x_test, k = 5, ...) {
  k <- min(k, nrow(x_train))
  nn <- FNN::get.knnx(data = x_train, query = x_test, k = k)$nn.index
  class_names <- levels(y_train)
  y_nn <- matrix(as.integer(y_train)[nn], nrow = nrow(x_test))
  prob <- sapply(seq_along(class_names), function(j) rowMeans(y_nn == j))
  prob <- matrix(prob, nrow = nrow(x_test))
  colnames(prob) <- class_names
  prob
}

# Gaussian naive Bayes
#' @noRd
classifier_NaiveBayes <- function(x_train, y_train, x_test, ...) {
  class_names <- levels(y_train)
  x_train <- as.matrix(x_train)
  x_test <- as.matrix(x_test)
  floor_sd <- 1e-3 * (apply(x_train, 2, stats::sd) + 1e-8)
  score <- sapply(class_names, function(m) {
    xm <- x_train[y_train == m, , drop = FALSE]
    mu <- colMeans(xm)
    s <- if (nrow(xm) > 1) apply(xm, 2, stats::sd) else rep(0, ncol(xm))
    s <- pmax(s, floor_sd)
    z <- sweep(sweep(x_test, 2, mu), 2, s, "/")
    log(nrow(xm) / nrow(x_train)) - rowSums(0.5 * z^2 + rep(log(s), each = nrow(x_test)))
  })
  score <- matrix(score, nrow = nrow(x_test))
  prob <- softmax_rows(score)
  colnames(prob) <- class_names
  prob
}

# Linear discriminant analysis with pooled covariance (ridge for stability)
#' @noRd
classifier_LDA <- function(x_train, y_train, x_test, ridge = 1e-6, ...) {
  class_names <- levels(y_train)
  x_train <- as.matrix(x_train)
  x_test <- as.matrix(x_test)
  p <- ncol(x_train)
  n <- nrow(x_train)
  mu <- t(sapply(class_names, function(m) colMeans(x_train[y_train == m, , drop = FALSE])))
  mu <- matrix(mu, nrow = length(class_names))
  centered <- x_train - mu[as.integer(y_train), , drop = FALSE]
  S <- crossprod(centered) / max(n - length(class_names), 1)
  S <- S + diag(ridge * mean(diag(S)) + 1e-10, p)
  S_inv <- solve(S)
  prior <- log(as.vector(table(y_train)) / n)
  score <- sapply(seq_along(class_names), function(j) {
    drop(x_test %*% S_inv %*% mu[j, ]) - 0.5 * drop(mu[j, ] %*% S_inv %*% mu[j, ]) + prior[j]
  })
  score <- matrix(score, nrow = nrow(x_test))
  prob <- softmax_rows(score)
  colnames(prob) <- class_names
  prob
}

# Single hidden layer neural network (package nnet), standardised inputs
#' @noRd
classifier_NNET <- function(x_train, y_train, x_test, size = 5, decay = 1e-3,
                            maxit = 200, ...) {
  if (!requireNamespace("nnet", quietly = TRUE)) {
    stop("package 'nnet' is required for classifier = \"NNET\"")
  }
  x_train <- as.matrix(x_train)
  x_test <- as.matrix(x_test)
  mu <- colMeans(x_train)
  s <- apply(x_train, 2, stats::sd) + 1e-8
  z_train <- sweep(sweep(x_train, 2, mu), 2, s, "/")
  z_test <- sweep(sweep(x_test, 2, mu), 2, s, "/")
  model <- nnet::nnet(x = z_train, y = nnet::class.ind(y_train), size = size,
                      decay = decay, maxit = maxit, softmax = TRUE, trace = FALSE, ...)
  prob <- predict(model, newdata = z_test, type = "raw")
  prob <- matrix(prob, nrow = nrow(x_test))
  colnames(prob) <- levels(y_train)
  prob
}

# Turns the classifier argument of UGO into a validated function
#' @noRd
get_classifier <- function(classifier) {
  if (is.character(classifier) && length(classifier) == 1) {
    if (classifier %in% names(classifier_aliases)) {
      classifier <- classifier_aliases[[classifier]]
    }
    classifier <- match.arg(classifier, classifier_names)
    return(switch(classifier,
                  CART = classifier_CART,
                  RF = classifier_RF,
                  LogReg = classifier_LogReg,
                  KNN = classifier_KNN,
                  NaiveBayes = classifier_NaiveBayes,
                  LDA = classifier_LDA,
                  NNET = classifier_NNET))
  }
  if (!is.function(classifier)) {
    stop("classifier must be one of ", paste0("\"", classifier_names, "\"", collapse = ", "),
         " or a function")
  }
  classifier
}

# Class probabilities of x_test from a trained-on-the-fly classifier, checked
# and ordered to follow the levels of y_train.
#' @noRd
predict_class_probs <- function(f_classifier, x_train, y_train, x_test, ...) {
  prob <- f_classifier(x_train = x_train, y_train = y_train, x_test = x_test, ...)
  if (is.list(prob) && !is.null(prob$prob)) {
    prob <- prob$prob
  }
  prob <- as.matrix(prob)
  class_names <- levels(y_train)
  if (nrow(prob) != nrow(x_test) || ncol(prob) != length(class_names)) {
    stop("classifier must return a matrix of class probabilities with one row ",
         "per test sample and one column per class")
  }
  if (!is.null(colnames(prob)) && all(class_names %in% colnames(prob))) {
    prob <- prob[, class_names, drop = FALSE]
  }
  prob
}

# UGO uncertainty (modified margin): highest probability among the other
# classes minus the probability of the true class.
#' @noRd
calculate_uncertainty <- function(prob, y) {
  y_num <- as.integer(y)
  p_true <- prob[cbind(seq_along(y_num), y_num)]
  prob_other <- prob
  prob_other[cbind(seq_along(y_num), y_num)] <- -Inf
  apply(prob_other, 1, max) - p_true
}
