#' @title  Synthetic Minority Oversampling Technique (SMOTE, 2002)
#'
#' @description Resampling with SMOTE.
#'
#' @param x feature matrix.
#' @param y a factor class variable. Can have more than two classes.
#' @param k number of neighbors. Default is 5.
#' @param ovRate Oversampling rate. Class \eqn{j} receives
#' \code{round(ovRate * (n_max - n_j))} synthetic samples, where \code{n_max} is
#' the size of the largest class (halves are rounded up). Default is 1 meaning
#' full balance. A vector with one value per class is also accepted.
#' @param ... not used.
#'
#' @details
#' \strong{Year: 2002.}
#'
#' SMOTE (Chawla et al., 2002) is an oversampling method which creates links
#' between positive samples and nearest neighbors and generates synthetic
#' samples along that link.
#'
#' It is well known that SMOTE is sensitive to noisy data. It may create more
#' noise.
#'
#' Can work with classes more than 2.
#'
#' Note: Much faster than \code{smotefamily::SMOTE()}.
#'
#' @return a list with resampled dataset.
#'  \item{x_new}{Resampled feature matrix.}
#'  \item{y_new}{Resampled target variable.}
#'  \item{x_syn}{Generated synthetic feature data.}
#'  \item{y_syn}{Generated synthetic label data.}
#'
#' @author Fatih Saglam, saglamf89@gmail.com
#'
#' @importFrom  FNN get.knnx
#' @importFrom  stats runif
#' @importFrom  stats sd
#'
#' @references
#' Chawla, N. V., Bowyer, K. W., Hall, L. O., & Kegelmeyer, W. P. (2002). SMOTE:
#' synthetic minority over-sampling technique. Journal of artificial
#' intelligence research, 16, 321-357.
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
#' m <- SMOTE(x = x, y = y, k = 7)
#'
#' plot(m$x_new, col = m$y_new)
#'
#' @rdname SMOTE
#' @export

SMOTE <- function(x, y, k = 5, ovRate = 1, ...) {
  check_positive_number(k, "k")
  run_oversampler(x, y, generate_SMOTE, ovRate, args = list(k = k))
}
