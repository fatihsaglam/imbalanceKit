#' @title  Quadrilateral Element Oversampling (GQEO, 2025)
#'
#' @description Resampling with GQEO.
#'
#' @param x feature matrix or dataframe.
#' @param y a factor class variable. Can have more than two classes.
#' @param k number of nearest neighbours from which the corners of the quadrilaterals are chosen (at least 3). Default is 5.
#' @param check_planarity if \code{TRUE}, quadrilaterals whose edges violate the polygon inequality are removed. Default is \code{TRUE}.
#' @param ovRate Oversampling rate. Class \eqn{j} receives
#' \code{round(ovRate * (n_max - n_j))} synthetic samples, where \code{n_max} is
#' the size of the largest class (halves are rounded up). Default is 1 meaning
#' full balance. A vector with one value per class is also accepted.
#' @param ... not used.
#'
#' @details
#' \strong{Year: 2025.}
#'
#' Synthetic samples are generated inside quadrilaterals made of a sample and three of
#' its \code{k} nearest neighbours of the same class, by bilinear
#' interpolation of the four corners. Classes that are too small to form a
#' quadrilateral are oversampled randomly with a warning.
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
#' Dai, Q., Wang, L., Zhang, J., Ding, W., & Chen, L. (2025). GQEO: Nearest
#' neighbor graph-based generalized quadrilateral element oversampling for
#' class-imbalance problem. Neural Networks, 184, 107107.
#'
#' @examples
#'
#' set.seed(1)
#' x <- rbind(matrix(rnorm(600, 3, 1), ncol = 2),
#'            matrix(rnorm(60, 5, 1), ncol = 2))
#' y <- as.factor(c(rep("negative", 300), rep("positive", 30)))
#'
#' m <- GQEO(x = x, y = y)
#' table(m$y_new)
#'
#' @rdname GQEO
#' @export

GQEO <- function(x, y, k = 5, check_planarity = TRUE, ovRate = 1, ...) {
  run_oversampler(x, y, generate_GQEO, ovRate,
                  args = list(k = k, check_planarity = check_planarity))
}
