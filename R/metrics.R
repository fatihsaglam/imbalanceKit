#' @title Performance Metrics for Imbalanced Classification
#'
#' @description Metrics that are suitable for imbalanced and multi-class
#' classification. All of them take the true classes \code{y_true} (a factor)
#' and either the predicted classes \code{y_pred} or the predicted class
#' probabilities \code{y_prob}. Use \code{\link{evaluate}} to calculate several
#' metrics at once.
#'
#' @param y_true factor of the true classes.
#' @param y_pred predicted classes. A factor or a character vector with labels
#' from the levels of \code{y_true}.
#' @param y_prob predicted class probabilities: a matrix with one column per
#' class (named after the levels of \code{y_true}, or in level order), or, for
#' two classes, a vector with the probability of \code{positive}.
#' @param average how class-wise values are combined for metrics that are
#' defined for one class: \code{"binary"} uses only the \code{positive} class,
#' \code{"macro"} is the mean over classes, \code{"micro"} pools the counts (or
#' scores) of all classes, \code{"weighted"} is the mean weighted by class sizes.
#' The default \code{"auto"} is \code{"binary"} for two classes and
#' \code{"macro"} for more.
#' @param positive the positive class of the binary versions. Default is the
#' smallest class of \code{y_true}.
#' @param n_bins number of equal width confidence bins of \code{ECE} and
#' \code{BECE}. Default is 10.
#'
#' @details
#' Metrics based on predicted classes:
#' \itemize{
#'   \item \code{ACC}: accuracy.
#'   \item \code{BACC}: balanced accuracy, the mean recall over the classes.
#'   \item \code{GMEAN}: geometric mean of the class recalls (for two classes
#'   \eqn{\sqrt{sensitivity \cdot specificity}}).
#'   \item \code{MCC}: Matthews correlation coefficient, in the multi-class form
#'   of Gorodkin (2004).
#'   \item \code{KAPPA}: Cohen's kappa.
#'   \item \code{IAM}: imbalanced accuracy measure (Mortaz, 2020), in
#'   \eqn{[-1, 1]}.
#'   \item \code{F1}, \code{PRECISION}, \code{RECALL}, \code{SPECIFICITY},
#'   \code{P4}: class-wise metrics combined with \code{average}. \code{P4} is the
#'   harmonic mean of precision, recall, specificity and negative predictive
#'   value (Sitarz, 2022). A class-wise value with an empty denominator is 0;
#'   classes that do not occur in \code{y_true} are ignored by \code{"macro"}
#'   and \code{"weighted"}. Micro averaged \code{F1}, \code{PRECISION} and
#'   \code{RECALL} equal \code{ACC}.
#' }
#' Metrics based on probabilities:
#' \itemize{
#'   \item \code{ROCAUC}: area under the ROC curve. Multi-class values are
#'   one-versus-rest and combined with \code{average}.
#'   \item \code{PRAUC}: area under the precision-recall curve, calculated as
#'   average precision. Multi-class values are one-versus-rest and combined with
#'   \code{average}.
#'   \item \code{Brier}: the Brier score, the mean over observations of the sum
#'   over classes of the squared differences between the probabilities and the
#'   one-hot true class. Lies in \eqn{[0, 2]}; for two classes it is twice
#'   the usual \eqn{(p - y)^2} form.
#'   \item \code{PBrier}: penalized Brier score (Ahmadian et al., 2024): the
#'   Brier score plus \eqn{(K-1)/K} for every misclassified observation, which
#'   keeps a wrongly classified observation from scoring better than a
#'   correctly classified one.
#'   \item \code{BBrier}: balanced Brier score, the mean of the class-wise
#'   Brier scores, so that every class counts equally.
#'   \item \code{ECE}: expected calibration error of the predicted class
#'   (confidence), \eqn{\sum_b (n_b/n) |acc_b - conf_b|} over equal width
#'   confidence bins.
#'   \item \code{BECE}: balanced expected calibration error, \code{ECE} where
#'   every observation is weighted by the inverse size of its true class.
#'   \item \code{LOGLOSS}: logarithmic loss.
#' }
#' The probabilities of \code{ECE}, \code{BECE}, \code{PBrier} use the class
#' with the highest probability as the predicted class.
#'
#' @return a number.
#'
#' @references
#' Gorodkin, J. (2004). Comparing two K-category assignments by a K-category
#' correlation coefficient. Computational Biology and Chemistry, 28(5-6),
#' 367-374.
#'
#' Mortaz, E. (2020). Imbalance accuracy metric for model selection in
#' multi-class imbalance classification problems. Knowledge-Based Systems, 210,
#' 106490.
#'
#' Sitarz, M. (2022). Extending F1 metric, probabilistic approach.
#' arXiv:2210.11997.
#'
#' Ahmadian, S. et al. (2024). Superior scoring rules for probabilistic
#' evaluation of single-label multi-class classification tasks.
#' arXiv:2407.17697.
#'
#' @examples
#' set.seed(1)
#' y_true <- factor(sample(c("a", "b", "c"), 100, replace = TRUE, prob = c(0.7, 0.2, 0.1)))
#' prob <- matrix(runif(300), 100, 3, dimnames = list(NULL, levels(y_true)))
#' prob <- prob / rowSums(prob)
#' y_pred <- factor(levels(y_true)[max.col(prob)], levels = levels(y_true))
#' BACC(y_true, y_pred)
#' F1(y_true, y_pred, average = "micro")
#' MCC(y_true, y_pred)
#' ROCAUC(y_true, prob, average = "macro")
#' Brier(y_true, prob)
#'
#' @name metrics
#' @aliases ACC BACC GMEAN MCC KAPPA IAM F1 PRECISION RECALL SPECIFICITY P4 ROCAUC PRAUC Brier PBrier BBrier ECE BECE LOGLOSS
NULL

#' @rdname metrics
#' @export
ACC <- function(y_true, y_pred) {
  cc <- class_counts(y_true, y_pred)
  sum(cc$TP) / sum(cc$cm)
}

#' @rdname metrics
#' @export
BACC <- function(y_true, y_pred) {
  cc <- class_counts(y_true, y_pred)
  present <- cc$n_true > 0
  mean(cc$TP[present] / cc$n_true[present])
}

#' @rdname metrics
#' @export
GMEAN <- function(y_true, y_pred) {
  cc <- class_counts(y_true, y_pred)
  present <- cc$n_true > 0
  recall <- cc$TP[present] / cc$n_true[present]
  exp(mean(log(recall)))
}

#' @rdname metrics
#' @export
MCC <- function(y_true, y_pred) {
  cc <- class_counts(y_true, y_pred)
  s <- sum(cc$cm)
  t_k <- rowSums(cc$cm)
  p_k <- colSums(cc$cm)
  den <- sqrt((s^2 - sum(p_k^2)) * (s^2 - sum(t_k^2)))
  if (den == 0) {
    return(0)
  }
  (sum(cc$TP) * s - sum(p_k * t_k)) / den
}

#' @rdname metrics
#' @export
KAPPA <- function(y_true, y_pred) {
  cc <- class_counts(y_true, y_pred)
  s <- sum(cc$cm)
  po <- sum(cc$TP) / s
  pe <- sum(rowSums(cc$cm) * colSums(cc$cm)) / s^2
  if (pe == 1) {
    return(0)
  }
  (po - pe) / (1 - pe)
}

#' @rdname metrics
#' @export
IAM <- function(y_true, y_pred) {
  cc <- class_counts(y_true, y_pred)
  cm <- cc$cm
  k <- nrow(cm)
  if (k < 2) {
    stop("y_true needs at least two classes")
  }
  v <- vapply(seq_len(k), function(i) {
    worst <- max(cm[i, -i], cm[-i, i])
    den <- max(sum(cm[, i]), sum(cm[i, ]))
    if (den == 0) NA_real_ else (cm[i, i] - worst) / den
  }, numeric(1))
  mean(v, na.rm = TRUE)
}

# class-wise metrics --------------------------------------------------------

classwise_metric <- function(y_true, y_pred, value, average, positive) {
  cc <- class_counts(y_true, y_pred)
  average <- resolve_average(average, length(cc$classes))
  positive <- if (average == "binary") get_positive(y_true, positive) else NULL
  averaged_metric(cc, value, average, positive)
}

#' @rdname metrics
#' @export
F1 <- function(y_true, y_pred, average = "auto", positive = NULL) {
  classwise_metric(y_true, y_pred, function(TP, FP, FN, TN) {
    safe_div(2 * TP, 2 * TP + FP + FN)
  }, average, positive)
}

#' @rdname metrics
#' @export
PRECISION <- function(y_true, y_pred, average = "auto", positive = NULL) {
  classwise_metric(y_true, y_pred, function(TP, FP, FN, TN) safe_div(TP, TP + FP),
                   average, positive)
}

#' @rdname metrics
#' @export
RECALL <- function(y_true, y_pred, average = "auto", positive = NULL) {
  classwise_metric(y_true, y_pred, function(TP, FP, FN, TN) safe_div(TP, TP + FN),
                   average, positive)
}

#' @rdname metrics
#' @export
SPECIFICITY <- function(y_true, y_pred, average = "auto", positive = NULL) {
  classwise_metric(y_true, y_pred, function(TP, FP, FN, TN) safe_div(TN, TN + FP),
                   average, positive)
}

#' @rdname metrics
#' @export
P4 <- function(y_true, y_pred, average = "auto", positive = NULL) {
  classwise_metric(y_true, y_pred, function(TP, FP, FN, TN) {
    p <- safe_div(TP, TP + FP)
    r <- safe_div(TP, TP + FN)
    s <- safe_div(TN, TN + FP)
    npv <- safe_div(TN, TN + FN)
    ifelse(p * r * s * npv == 0, 0, 4 / (1 / p + 1 / r + 1 / s + 1 / npv))
  }, average, positive)
}

# probability based metrics ---------------------------------------------------

#' @rdname metrics
#' @export
ROCAUC <- function(y_true, y_prob, average = "auto", positive = NULL) {
  ranking_metric(y_true, y_prob, auc_roc, average, positive)
}

#' @rdname metrics
#' @export
PRAUC <- function(y_true, y_prob, average = "auto", positive = NULL) {
  ranking_metric(y_true, y_prob, auc_pr, average, positive)
}

#' @rdname metrics
#' @export
Brier <- function(y_true, y_prob, positive = NULL) {
  if (!is.factor(y_true)) y_true <- factor(y_true)
  prob <- prepare_probs(y_true, y_prob, positive)
  mean(brier_each(y_true, prob))
}

#' @rdname metrics
#' @export
PBrier <- function(y_true, y_prob, positive = NULL) {
  if (!is.factor(y_true)) y_true <- factor(y_true)
  prob <- prepare_probs(y_true, y_prob, positive)
  k <- ncol(prob)
  wrong <- colnames(prob)[max.col(prob, ties.method = "first")] != as.character(y_true)
  mean(brier_each(y_true, prob) + wrong * (k - 1) / k)
}

#' @rdname metrics
#' @export
BBrier <- function(y_true, y_prob, positive = NULL) {
  if (!is.factor(y_true)) y_true <- factor(y_true)
  prob <- prepare_probs(y_true, y_prob, positive)
  sum(balanced_weights(y_true) * brier_each(y_true, prob))
}

weighted_ece <- function(y_true, prob, w, n_bins) {
  if (!is.numeric(n_bins) || length(n_bins) != 1 || n_bins < 1) {
    stop("n_bins must be a positive number")
  }
  confidence <- apply(prob, 1, max)
  correct <- colnames(prob)[max.col(prob, ties.method = "first")] == as.character(y_true)
  bin <- pmin(pmax(ceiling(confidence * n_bins), 1), n_bins)
  sum(abs(tapply(w * (correct - confidence), factor(bin, levels = seq_len(n_bins)), sum)),
      na.rm = TRUE) / sum(w)
}

#' @rdname metrics
#' @export
ECE <- function(y_true, y_prob, n_bins = 10, positive = NULL) {
  if (!is.factor(y_true)) y_true <- factor(y_true)
  prob <- prepare_probs(y_true, y_prob, positive)
  weighted_ece(y_true, prob, rep(1, length(y_true)), n_bins)
}

#' @rdname metrics
#' @export
BECE <- function(y_true, y_prob, n_bins = 10, positive = NULL) {
  if (!is.factor(y_true)) y_true <- factor(y_true)
  prob <- prepare_probs(y_true, y_prob, positive)
  weighted_ece(y_true, prob, balanced_weights(y_true), n_bins)
}

#' @rdname metrics
#' @export
LOGLOSS <- function(y_true, y_prob, positive = NULL) {
  if (!is.factor(y_true)) y_true <- factor(y_true)
  prob <- prepare_probs(y_true, y_prob, positive)
  p_true <- prob[cbind(seq_along(y_true), match(as.character(y_true), colnames(prob)))]
  -mean(log(pmax(p_true, 1e-15)))
}
