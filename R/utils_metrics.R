# Helpers of the performance metrics.

# y_true as a factor, y_pred as a factor with the same levels
prepare_labels <- function(y_true, y_pred) {
  if (!is.factor(y_true)) {
    y_true <- factor(y_true)
  }
  if (length(y_true) != length(y_pred)) {
    stop("y_true and y_pred must have the same length")
  }
  if (anyNA(y_true) || anyNA(y_pred)) {
    stop("y_true and y_pred must not contain missing values")
  }
  y_pred_chr <- as.character(y_pred)
  if (!all(y_pred_chr %in% levels(y_true))) {
    stop("y_pred contains labels that are not levels of y_true")
  }
  list(y_true = y_true, y_pred = factor(y_pred_chr, levels = levels(y_true)))
}

# one-versus-rest counts of every class
class_counts <- function(y_true, y_pred) {
  lab <- prepare_labels(y_true, y_pred)
  cm <- table(lab$y_true, lab$y_pred)
  TP <- diag(cm)
  FN <- rowSums(cm) - TP
  FP <- colSums(cm) - TP
  TN <- sum(cm) - TP - FN - FP
  list(cm = cm, TP = TP, FP = FP, FN = FN, TN = TN, n_true = rowSums(cm),
       classes = levels(lab$y_true))
}

# the positive class of binary metrics: the smallest class unless given
get_positive <- function(y_true, positive = NULL) {
  if (!is.factor(y_true)) {
    y_true <- factor(y_true)
  }
  if (is.null(positive)) {
    return(names(which.min(table(y_true))))
  }
  if (length(positive) != 1 || !(as.character(positive) %in% levels(y_true))) {
    stop("positive must be one of the classes of y_true")
  }
  as.character(positive)
}

# "auto" is "binary" for two classes and "macro" otherwise
resolve_average <- function(average, n_class) {
  average <- match.arg(average, c("auto", "macro", "micro", "weighted", "binary"))
  if (average == "auto") {
    average <- if (n_class == 2) "binary" else "macro"
  }
  if (average == "binary" && n_class != 2) {
    stop("average = \"binary\" needs exactly two classes")
  }
  average
}

# Combines class-wise values. `value(TP, FP, FN, TN)` is evaluated on the counts
# of one class (macro, weighted, binary) or on the pooled counts (micro).
averaged_metric <- function(cc, value, average, positive) {
  if (average == "micro") {
    return(unname(value(sum(cc$TP), sum(cc$FP), sum(cc$FN), sum(cc$TN))))
  }
  if (average == "binary") {
    j <- match(positive, cc$classes)
    return(unname(value(cc$TP[j], cc$FP[j], cc$FN[j], cc$TN[j])))
  }
  v <- value(cc$TP, cc$FP, cc$FN, cc$TN)
  # classes without samples in y_true are ignored
  present <- cc$n_true > 0
  if (average == "macro") {
    unname(mean(v[present]))
  } else {
    unname(sum(v[present] * cc$n_true[present]) / sum(cc$n_true[present]))
  }
}

# a / b with 0 for an empty denominator
safe_div <- function(a, b) ifelse(b == 0, 0, a / b)

# probability matrix with one column per level of y_true
prepare_probs <- function(y_true, y_prob, positive = NULL) {
  if (!is.factor(y_true)) {
    y_true <- factor(y_true)
  }
  classes <- levels(y_true)
  k <- length(classes)
  if (is.data.frame(y_prob)) {
    y_prob <- as.matrix(y_prob)
  }
  if (is.null(dim(y_prob))) {
    if (k != 2) {
      stop("y_prob must be a matrix with one column per class")
    }
    # probability of the positive class
    pos <- get_positive(y_true, positive)
    y_prob <- cbind(y_prob, 1 - y_prob)
    colnames(y_prob) <- c(pos, setdiff(classes, pos))
  }
  if (nrow(y_prob) != length(y_true)) {
    stop("y_prob and y_true must have the same number of observations")
  }
  if (ncol(y_prob) != k) {
    stop("y_prob must have one column per class")
  }
  if (is.null(colnames(y_prob))) {
    colnames(y_prob) <- classes
  } else if (!setequal(colnames(y_prob), classes)) {
    stop("column names of y_prob must be the classes of y_true")
  }
  y_prob <- y_prob[, classes, drop = FALSE]
  if (anyNA(y_prob) || any(y_prob < 0) || any(y_prob > 1)) {
    stop("y_prob must contain probabilities between 0 and 1")
  }
  y_prob
}

# area under the ROC curve (Mann-Whitney statistic, ties count half)
auc_roc <- function(is_pos, score) {
  n1 <- sum(is_pos)
  n0 <- length(is_pos) - n1
  if (n1 == 0 || n0 == 0) {
    return(NA_real_)
  }
  r <- rank(score)
  (sum(r[is_pos]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}

# area under the precision-recall curve as average precision
auc_pr <- function(is_pos, score) {
  n1 <- sum(is_pos)
  if (n1 == 0) {
    return(NA_real_)
  }
  o <- order(score, decreasing = TRUE)
  s <- score[o]
  tp <- cumsum(is_pos[o])
  # evaluate at the end of each group of tied scores
  last <- c(s[-length(s)] != s[-1], TRUE)
  tp <- tp[last]
  n_pred <- seq_along(is_pos)[last]
  precision <- tp / n_pred
  recall <- tp / n1
  sum(diff(c(0, recall)) * precision)
}

# class-wise (macro, weighted), pooled (micro) or positive class score of a
# ranking metric computed with one-versus-rest
ranking_metric <- function(y_true, y_prob, auc_fun, average, positive) {
  if (!is.factor(y_true)) {
    y_true <- factor(y_true)
  }
  classes <- levels(y_true)
  average <- resolve_average(average, length(classes))
  if (average != "binary" && length(classes) < 2) {
    stop("y_true needs at least two classes")
  }
  prob <- prepare_probs(y_true, y_prob, positive)
  if (average == "binary") {
    pos <- get_positive(y_true, positive)
    return(auc_fun(y_true == pos, prob[, pos]))
  }
  if (average == "micro") {
    is_pos <- as.vector(outer(as.character(y_true), classes, "=="))
    return(auc_fun(is_pos, as.vector(prob)))
  }
  v <- vapply(seq_along(classes), function(j) auc_fun(y_true == classes[j], prob[, j]),
              numeric(1))
  n_true <- as.vector(table(y_true))
  ok <- !is.na(v)
  if (average == "macro") mean(v[ok]) else sum(v[ok] * n_true[ok]) / sum(n_true[ok])
}

# Brier scores of every observation: sum over classes of (p - y)^2
brier_each <- function(y_true, prob) {
  onehot <- outer(as.character(y_true), colnames(prob), "==") * 1
  rowSums((prob - onehot)^2)
}

# weights that give every class of y_true the same total weight
balanced_weights <- function(y_true) {
  n_true <- table(y_true)
  w <- 1 / as.vector(n_true)[as.integer(y_true)]
  w / sum(w)
}
