#' @title  Randomly Over Sampling Examples
#'
#' @description Generates synthetic data for each class to balance imbalanced
#' datasets using kernel density estimations. Can be used for multiclass datasets.
#'
#' @param x feature matrix or data.frame.
#' @param y a factor class variable. Can be multiclass.
#' @param h A numeric vector of length one or number of classes in y. If one is
#' given, all classes will have same shrink factor. If a value is given for each
#' classes, it will match respectively to \code{levels(y)}. Default is 1.
#' @param ovRate Oversampling rate. Class \eqn{j} receives
#' \code{round(ovRate * (n_max - n_j))} synthetic samples, where \code{n_max} is
#' the size of the largest class (halves are rounded up). Default is 1 meaning
#' full balance. A vector with one value per class is also accepted.
#' @details
#' Randomly Over Sampling Examples (ROSE) (Menardi and Torelli, 2014) is an
#' oversampling method which uses conditional kernel densities to balance dataset.
#' There is already an R package called `ROSE` (Lunardon et al., 2014).
#' Difference is that this one is much faster and can be applied for more than two classes.
#'
#' @return a list with resampled dataset.
#'  \item{x_new}{Resampled feature matrix.}
#'  \item{y_new}{Resampled target variable.}
#'
#' @author Fatih Saglam, saglamf89@gmail.com
#'
#' @importFrom  stats rnorm
#' @importFrom  stats sd
#'
#' @references
#' Lunardon, N., Menardi, G., and Torelli, N. (2014). ROSE: a Package for Binary
#' Imbalanced Learning. R Jorunal, 6:82–92.
#'
#' Menardi, G. and Torelli, N. (2014). Training and assessing classification
#' rules with imbalanced data. Data Mining and Knowledge Discovery, 28:92–122.
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
#' m <- ROSE(x = x, y = y, h = c(0.12, 1))
#'
#' plot(m$x_new, col = m$y_new)
#'
#' @rdname ROSE
#' @export

ROSE <- function(x, y, h = 1, ovRate = 1) {
  if (!is.numeric(h) || anyNA(h)) {
    stop("h must be numeric")
  }
  if (any(h < 0)) {
    stop("h can not be negative")
  }
  if (!is.factor(y)) {
    stop("y must be a factor")
  }
  k_class <- nlevels(droplevels(y))
  if (!(length(h) %in% c(1, k_class))) {
    stop("h must be length one or number of classes, ", k_class)
  }
  run_oversampler(x, y, generate_ROSE, ovRate,
                  per_class = list(h = rep_len(h, k_class)))
}
