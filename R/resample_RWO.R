#' @title  Random Walk Oversampling (RWO, 2014)
#'
#' @description Resampling with RWO
#'
#' @param x feature matrix.
#' @param y a factor class variable. Can have more than two classes.
#' @param ovRate Oversampling rate. Class \eqn{j} receives
#' \code{round(ovRate * (n_max - n_j))} synthetic samples, where \code{n_max} is
#' the size of the largest class (halves are rounded up). Default is 1 meaning
#' full balance. A vector with one value per class is also accepted.
#' @details
#' \strong{Year: 2014.}
#'
#' RWO (Zhang and Li, 2014) is an oversampling method which generates data using
#' variable standard error in a way that it preserves the variances of all variables.
#'
#' Can work with classes more than 2.
#'
#' @return a list with resampled dataset.
#'  \item{x_new}{Resampled feature matrix.}
#'  \item{y_new}{Resampled target variable.}
#'  \item{x_syn}{Generated synthetic feature data.}
#'  \item{y_syn}{Generated synthetic label data.}
#'
#' @author Fatih Saglam, saglamf89@gmail.com
#'
#' @importFrom  stats rnorm
#' @importFrom  stats sd
#'
#' @references
#' Zhang, H., & Li, M. (2014). RWO-Sampling: A random walk over-sampling
#' approach to imbalanced data classification. Information Fusion, 20, 99-116.
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
#' m <- RWO(x = x, y = y)
#'
#' plot(m$x_new, col = m$y_new)
#'
#' @rdname RWO
#' @export

RWO <- function(x, y, ovRate = 1) {
  run_oversampler(x, y, generate_RWO, ovRate)
}
