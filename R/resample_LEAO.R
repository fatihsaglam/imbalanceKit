#' @title  Local Entropy-Adversarial Oversampling (LEAO, 2025)
#'
#' @description Resampling with LEAO.
#'
#' @param x feature matrix or dataframe.
#' @param y a factor class variable. Can have more than two classes.
#' @param iters maximum number of gradient steps per synthetic sample. Default is 50.
#' @param alpha decay of the potential. Default is 1.
#' @param prob_type how the class probabilities, which give the entropies, are estimated: \code{"bagging"} (classification trees, default), \code{"logistic"}, \code{"knn"} or \code{"nb"} (Gaussian naive Bayes).
#' @param k number of nearest samples of the other classes (Mahalanobis distance) from which one is chosen. Default is 3.
#' @param stop_prob probability to stop at each step. Default is 0.3.
#' @param step_max,step_min range of the random step size. \code{step_min} is \code{step_max / 10} if \code{NULL}.
#' @param eps numerical constant of the entropy. Default is 1e-6.
#' @param cov_ridge value added to the diagonal of the covariance matrix. Default is 1e-8.
#' @param ovRate Oversampling rate. Class \eqn{j} receives
#' \code{round(ovRate * (n_max - n_j))} synthetic samples, where \code{n_max} is
#' the size of the largest class (halves are rounded up). Default is 1 meaning
#' full balance. A vector with one value per class is also accepted.
#' @param ... not used.
#'
#' @details
#' \strong{Year: 2025.}
#'
#' Seeds are drawn with probabilities proportional to the entropy of their class
#' probability. Each synthetic sample starts at its seed and moves by gradient
#' descent on a potential that is high near the seed and low near a nearby
#' sample of the other classes, until it is not positive, the maximum number of
#' steps is reached or the random stop happens.
#'
#' The method is defined for two classes. With more than two classes every class
#' is oversampled against the union of the other classes (one-versus-rest).
#'
#' @return a list with resampled dataset.
#'  \item{x_new}{Resampled feature matrix.}
#'  \item{y_new}{Resampled target variable.}
#'  \item{x_syn}{Generated synthetic feature data.}
#'  \item{y_syn}{Generated synthetic label data.}
#'
#' @author Fatih Saglam, saglamf89@gmail.com
#'
#' @references
#' Tao, L. (2025). Local entropy-adversarial oversampling for imbalanced
#' datasets. Neurocomputing, 131959.
#'
#' @examples
#'
#' set.seed(1)
#' x <- rbind(matrix(rnorm(600, 3, 1), ncol = 2),
#'            matrix(rnorm(60, 5, 1), ncol = 2))
#' y <- as.factor(c(rep("negative", 300), rep("positive", 30)))
#'
#' m <- LEAO(x = x, y = y)
#' table(m$y_new)
#'
#' @rdname LEAO
#' @export

LEAO <- function(x, y, iters = 50, alpha = 1, prob_type = c("bagging", "logistic", "knn", "nb"),
                 k = 3, stop_prob = 0.3, step_max = 0.10, step_min = NULL,
                 eps = 1e-6, cov_ridge = 1e-8, ovRate = 1, ...) {
  prob_type <- match.arg(prob_type)
  if (!is.null(step_min) && (step_min <= 0 || step_min >= step_max)) {
    stop("step_min must be in (0, step_max)")
  }
  check_positive_number(k, "k")
  run_oversampler(x, y, generate_LEAO, ovRate,
                  args = list(iters = iters, alpha = alpha, prob_type = prob_type,
                              k = k, stop_prob = stop_prob, step_max = step_max,
                              step_min = step_min, eps = eps, cov_ridge = cov_ridge))
}
