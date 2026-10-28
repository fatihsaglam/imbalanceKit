#' @title Evaluate a Classifier with Several Metrics
#'
#' @description Calculates the performance metrics of
#' \code{\link{metrics}} in one call.
#'
#' @param y_true factor of the true classes.
#' @param y_pred predicted classes. If \code{NULL}, the class with the highest
#' probability in \code{y_prob} is used.
#' @param y_prob predicted class probabilities (matrix with one column per
#' class, or for two classes a vector with the probability of \code{positive}).
#' Needed for the probability based metrics.
#' @param metrics character vector with the names of the metrics. The default
#' \code{NULL} calculates all metrics that the inputs allow: without
#' \code{y_prob} only the metrics based on predicted classes.
#' @param average,positive,n_bins see \code{\link{metrics}}.
#'
#' @details
#' The available metrics are \code{ACC}, \code{BACC}, \code{F1}, \code{GMEAN},
#' \code{MCC}, \code{ROCAUC}, \code{PRAUC}, \code{Brier}, \code{PBrier},
#' \code{BBrier}, \code{ECE}, \code{BECE}, \code{P4}, \code{IAM},
#' \code{PRECISION}, \code{RECALL}, \code{SPECIFICITY}, \code{KAPPA} and
#' \code{LOGLOSS}. \code{average} is used by \code{F1}, \code{P4},
#' \code{PRECISION}, \code{RECALL}, \code{SPECIFICITY}, \code{ROCAUC} and
#' \code{PRAUC}; the other metrics are defined for any number of classes.
#'
#' @return a named numeric vector.
#'
#' @examples
#' set.seed(1)
#' y_true <- factor(sample(c("neg", "pos"), 200, replace = TRUE, prob = c(0.9, 0.1)))
#' p_pos <- ifelse(y_true == "pos", rbeta(200, 3, 2), rbeta(200, 2, 4))
#' evaluate(y_true, y_prob = p_pos, positive = "pos")
#' evaluate(y_true, y_prob = p_pos, positive = "pos", metrics = c("MCC", "IAM", "BECE"))
#'
#' @export
evaluate <- function(y_true, y_pred = NULL, y_prob = NULL, metrics = NULL,
                     average = "auto", positive = NULL, n_bins = 10) {
  if (!is.factor(y_true)) {
    y_true <- factor(y_true)
  }
  label_metrics <- c("ACC", "BACC", "F1", "GMEAN", "MCC", "P4", "IAM",
                     "PRECISION", "RECALL", "SPECIFICITY", "KAPPA")
  prob_metrics <- c("ROCAUC", "PRAUC", "Brier", "PBrier", "BBrier", "ECE",
                    "BECE", "LOGLOSS")
  all_metrics <- c("ACC", "BACC", "F1", "GMEAN", "MCC", "ROCAUC", "PRAUC",
                   "Brier", "PBrier", "BBrier", "ECE", "BECE", "P4", "IAM",
                   "PRECISION", "RECALL", "SPECIFICITY", "KAPPA", "LOGLOSS")

  if (!is.null(y_prob)) {
    y_prob <- prepare_probs(y_true, y_prob, positive)
    if (is.null(y_pred)) {
      y_pred <- colnames(y_prob)[max.col(y_prob, ties.method = "first")]
    }
  }
  explicit <- !is.null(metrics)
  if (!explicit) {
    metrics <- all_metrics
  }
  unknown <- setdiff(metrics, all_metrics)
  if (length(unknown) > 0) {
    stop("unknown metric: ", paste(unknown, collapse = ", "))
  }
  if (is.null(y_pred) && any(metrics %in% label_metrics)) {
    if (explicit) {
      stop("y_pred or y_prob is needed for ", paste(intersect(metrics, label_metrics), collapse = ", "))
    }
    metrics <- setdiff(metrics, label_metrics)
  }
  if (is.null(y_prob) && any(metrics %in% prob_metrics)) {
    if (explicit) {
      stop("y_prob is needed for ", paste(intersect(metrics, prob_metrics), collapse = ", "))
    }
    metrics <- setdiff(metrics, prob_metrics)
  }

  value <- function(m) {
    switch(m,
      ACC = ACC(y_true, y_pred),
      BACC = BACC(y_true, y_pred),
      GMEAN = GMEAN(y_true, y_pred),
      MCC = MCC(y_true, y_pred),
      KAPPA = KAPPA(y_true, y_pred),
      IAM = IAM(y_true, y_pred),
      F1 = F1(y_true, y_pred, average, positive),
      PRECISION = PRECISION(y_true, y_pred, average, positive),
      RECALL = RECALL(y_true, y_pred, average, positive),
      SPECIFICITY = SPECIFICITY(y_true, y_pred, average, positive),
      P4 = P4(y_true, y_pred, average, positive),
      ROCAUC = ROCAUC(y_true, y_prob, average, positive),
      PRAUC = PRAUC(y_true, y_prob, average, positive),
      Brier = Brier(y_true, y_prob),
      PBrier = PBrier(y_true, y_prob),
      BBrier = BBrier(y_true, y_prob),
      ECE = ECE(y_true, y_prob, n_bins),
      BECE = BECE(y_true, y_prob, n_bins),
      LOGLOSS = LOGLOSS(y_true, y_prob)
    )
  }
  vapply(stats::setNames(metrics, metrics), value, numeric(1))
}
