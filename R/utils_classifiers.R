# Classifier wrappers for UGO. A classifier is a function
#   function(x_train, y_train, x_test, ...)
# returning a matrix of class probabilities for the rows of x_test with one
# column per level of y_train (in level order).

#' @noRd
classifier_rpart <- function(x_train, y_train, x_test, ...) {
  dat <- data.frame(x_train, y = y_train)
  model <- rpart::rpart(y ~ ., data = dat, method = "class", ...)
  predict(model, newdata = data.frame(x_test), type = "prob")
}

#' @noRd
classifier_randomForest <- function(x_train, y_train, x_test, ...) {
  if (!requireNamespace("randomForest", quietly = TRUE)) {
    stop("package 'randomForest' is required for classifier = \"randomForest\"")
  }
  model <- randomForest::randomForest(x = x_train, y = y_train, ...)
  predict(model, newdata = x_test, type = "prob")
}

# Turns the classifier argument of UGO into a validated function
#' @noRd
get_classifier <- function(classifier) {
  if (is.character(classifier)) {
    classifier <- match.arg(classifier, c("rpart", "randomForest"))
    return(switch(classifier,
                  rpart = classifier_rpart,
                  randomForest = classifier_randomForest))
  }
  if (!is.function(classifier)) {
    stop("classifier must be \"rpart\", \"randomForest\" or a function")
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
