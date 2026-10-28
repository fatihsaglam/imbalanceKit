#' @title  SMOTE with boosting (SMOTEWB)
#'
#' @description Resampling with SMOTE with boosting.
#'
#' @param x feature matrix.
#' @param y a factor class variable. Can have more than two classes.
#' @param n_weak_classifier number of weak classifiers for boosting.
#' @param class_weights numeric vector of length two. First number is for
#' positive class, and second is for negative. Higher the relative weight,
#' lesser noises for that class. By default,  \eqn{2\times n_{neg}/n} for
#' positive and \eqn{2\times n_{pos}/n} for negative class.
#' @param k_max to increase maximum number of neighbors. Default is
#' \code{ceiling(n_neg/n_pos)}.
#' @param ovRate Oversampling rate. Class \eqn{j} receives
#' \code{round(ovRate * (n_max - n_j))} synthetic samples, where \code{n_max} is
#' the size of the largest class (halves are rounded up). Default is 1 meaning
#' full balance. A vector with one value per class is also accepted.
#' @param ... not used.
#'
#' @details
#' SMOTEWB (Saglam & Cengiz, 2022) is a SMOTE-based oversampling method which
#' can handle noisy data and adaptively decides the appropriate number of neighbors
#' to link during resampling with SMOTE.
#'
#' Trained model based on this method gives significantly better Matthew
#' Correlation Coefficient scores compared to others.
#'
#' Can work with classes more than 2.
#'
#' @return a list with resampled dataset.
#'  \item{x_new}{Resampled feature matrix.}
#'  \item{y_new}{Resampled target variable.}
#'  \item{x_syn}{Generated synthetic data.}
#'  \item{y_syn}{Generated synthetic data labels.}
#'  \item{w}{Boosting weights for original dataset.}
#'  \item{k}{Number of nearest neighbors for positive class samples.}
#'  \item{C}{Number of synthetic samples for each positive class samples.}
#'  \item{fl}{"good", "bad" and "lonely" sample labels}
#'
#' @author Fatih Saglam, saglamf89@gmail.com
#'
#' @importFrom  FNN knnx.index
#' @importFrom  stats runif
#' @importFrom  stats sd
#'
#' @references
#' Sağlam, F., & Cengiz, M. A. (2022). A novel SMOTE-based resampling technique
#' trough noise detection and the boosting procedure. Expert Systems with
#' Applications, 200, 117023.
#'
#' @examples
#'
#' set.seed(1)
#' x <- rbind(matrix(rnorm(2000, 3, 1), ncol = 2, nrow = 1000),
#'            matrix(rnorm(100, 5, 1), ncol = 2, nrow = 50))
#' y <- as.factor(c(rep("negative", 1000), rep("positive", 50)))
#'
#' plot(x, col = y)
#'
#' # resampling
#' m <- SMOTEWB(x = x, y = y, n_weak_classifier = 150)
#'
#' plot(m$x_new, col = m$y_new)
#'
#' @rdname SMOTEWB
#' @export

SMOTEWB <- function(x,
                    y,
                    n_weak_classifier = 100,
                    class_weights = NULL,
                    k_max = NULL,
                    ovRate = 1,
                    ...) {
  run_oversampler(x, y, generate_SMOTEWB, ovRate,
                  args = list(k_max = k_max,
                              n_weak_classifier = n_weak_classifier,
                              class_weights = class_weights),
                  extras = c("w", "k", "C", "fl"))
}
