#' @title  Geometric Synthetic Minority Oversamplnig Technique (GSMOTE)
#'
#' @description Resampling with GSMOTE.
#'
#' @param x feature matrix.
#' @param y a factor class variable. Can have more than two classes.
#' @param k number of neighbors. Default is 5.
#' @param alpha_sel selection method. Can be "minority", "majority" or "combined".
#' Default is "combined".
#' @param alpha_trunc truncation factor. A numeric value in \eqn{[-1,1]}.
#' Default is 0.5.
#' @param alpha_def deformation factor. A numeric value in \eqn{[0,1]}.
#' Default is 0.5
#' @param ovRate Oversampling rate. Class \eqn{j} receives
#' \code{round(ovRate * (n_max - n_j))} synthetic samples, where \code{n_max} is
#' the size of the largest class (halves are rounded up). Default is 1 meaning
#' full balance. A vector with one value per class is also accepted.
#' @details
#' GSMOTE (Douzas & Bacao, 2019) is an oversampling method which creates synthetic
#' samples geometrically around selected minority samples. Details are in the
#' paper (Douzas & Bacao, 2019).
#'
#' Can work with classes more than 2.
#'
#' @return a list with resampled dataset.
#'  \item{x_new}{Resampled feature matrix.}
#'  \item{y_new}{Resampled target variable.}
#'  \item{x_syn}{Generated synthetic feature data.}
#'  \item{y_syn}{Generated synthetic label data.}
#'  \item{C}{List with one element per class: the number of synthetic samples
#'  generated from each sample of that class.}
#'
#' @author Fatih Saglam, saglamf89@gmail.com
#'
#' @importFrom  FNN get.knnx
#' @importFrom  stats runif
#' @importFrom  stats sd
#'
#' @references
#' Douzas, G., & Bacao, F. (2019). Geometric SMOTE a geometrically enhanced
#' drop-in replacement for SMOTE. Information sciences, 501, 118-135.
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
#' m <- GSMOTE(x = x, y = y, k = 7)
#'
#' plot(m$x_new, col = m$y_new)
#'
#' @rdname GSMOTE
#' @export


GSMOTE <- function(x, y, k = 5, alpha_sel = c("combined", "minority", "majority"),
                   alpha_trunc = 0.5, alpha_def = 0.5, ovRate = 1) {
  alpha_sel <- match.arg(alpha_sel)
  if (!is.numeric(alpha_trunc) || alpha_trunc < -1 || alpha_trunc > 1) {
    stop("alpha_trunc must be between [-1,1].")
  }
  if (!is.numeric(alpha_def) || alpha_def < 0 || alpha_def > 1) {
    stop("alpha_def must be between [0,1].")
  }
  check_positive_number(k, "k")
  run_oversampler(x, y, generate_GSMOTE, ovRate,
                  args = list(k = k, alpha_sel = alpha_sel,
                              alpha_trunc = alpha_trunc, alpha_def = alpha_def),
                  extras = "C")
}
