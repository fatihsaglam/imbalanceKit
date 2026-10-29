#' @title  Radius-SMOTE (RadiusSMOTE, 2021)
#'
#' @description Resampling with RadiusSMOTE.
#'
#' @param x feature matrix or data.frame.
#' @param y a factor class variable. Can have more than two classes.
#' @param k number of neighbors used to decide whether a sample is safe (a sample is safe when more than \code{k / 2} of its \code{k} nearest neighbors in the whole data are from its own class). Default is 5.
#' @param ovRate Oversampling rate. Class \eqn{j} receives
#' \code{round(ovRate * (n_max - n_j))} synthetic samples, where \code{n_max} is
#' the size of the largest class (halves are rounded up). Default is 1 meaning
#' full balance. A vector with one value per class is also accepted.
#' @param ... not used.
#'
#' @details
#' \strong{Year: 2021.} Samples of the class that are safe are used as centers. Synthetic samples are generated on the line between a center and its nearest sample of the other classes, either towards it or in the opposite direction, at a random distance of at most the distance to that sample (the safe radius), so they do not reach the other classes. If no sample is safe, all samples are used with a warning.
#'
#' Can work with classes more than 2: every class is oversampled against the
#' union of the other classes (one-versus-rest).
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
#'
#' @references
#' Pradipta, G. A., Wardoyo, R., Musdholifah, A., & Sanjaya, I. N. H. (2021).
#' Radius-SMOTE: a new oversampling technique of minority samples based on
#' radius distance for learning from imbalanced data. IEEE Access, 9,
#' 74763-74777.
#'
#' @examples
#'
#' set.seed(1)
#' x <- rbind(matrix(rnorm(2000, 3, 1), ncol = 2, nrow = 1000),
#'            matrix(rnorm(100, 5, 1), ncol = 2, nrow = 50))
#' y <- as.factor(c(rep("negative", 1000), rep("positive", 50)))
#'
#' m <- RadiusSMOTE(x = x, y = y, k = 5)
#' table(m$y_new)
#' plot(m$x_new, col = m$y_new)
#'
#' @rdname RadiusSMOTE
#' @export

RadiusSMOTE <- function(x, y, k = 5, ovRate = 1, ...) {
  check_positive_number(k, "k")
  run_oversampler(x, y, generate_RadiusSMOTE, ovRate, args = list(k = k),
                  extras = "n_safe")
}
