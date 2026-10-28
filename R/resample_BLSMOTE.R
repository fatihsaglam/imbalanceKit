#' @title  Borderline-SMOTE (BLSMOTE, 2005)
#'
#' @description \code{BLSMOTE()} applies BLSMOTE (Borderline-SMOTE) which is a
#' variation of the SMOTE algorithm that generates synthetic samples only in the
#' vicinity of the borderline instances in imbalanced datasets.
#'
#' @param x feature matrix or data.frame.
#' @param y a factor class variable. Can have more than two classes.
#' @param k1 number of neighbors to link. Default is 5.
#' @param k2 number of neighbors to determine safe levels. Default is 5.
#' @param type "type1" or "type2". Default is "type1".
#' @param ovRate Oversampling rate. Class \eqn{j} receives
#' \code{round(ovRate * (n_max - n_j))} synthetic samples, where \code{n_max} is
#' the size of the largest class (halves are rounded up). Default is 1 meaning
#' full balance. A vector with one value per class is also accepted.
#' @details
#' \strong{Year: 2005.}
#'
#' BLSMOTE works by focusing on the instances that are near the decision
#' boundary between the minority and majority classes, known as borderline
#' instances. These instances are more informative and potentially more
#' challenging for classification, and thus generating synthetic samples in
#' their vicinity can be more effective than generating them randomly.
#'
#' Can work with classes more than 2.
#'
#' @return a list with resampled dataset.
#'  \item{x_new}{Resampled feature matrix.}
#'  \item{y_new}{Resampled target variable.}
#'  \item{x_syn}{Generated synthetic data.}
#'
#' @author Fatih Saglam, saglamf89@gmail.com
#'
#' @importFrom  FNN knnx.index
#' @importFrom  stats rnorm
#' @importFrom  stats sd
#'
#' @references
#' Han, H., Wang, W. Y., & Mao, B. H. (2005). Borderline-SMOTE: a new
#' over-sampling method in imbalanced data sets learning. In Advances in
#' Intelligent Computing: International Conference on Intelligent Computing,
#' ICIC 2005, Hefei, China, August 23-26, 2005, Proceedings, Part I 1
#' (pp. 878-887). Springer Berlin Heidelberg.
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
#' m <- BLSMOTE(x = x, y = y, k1 = 5, k2 = 5)
#'
#' plot(m$x_new, col = m$y_new)
#'
#' @rdname BLSMOTE
#' @export

BLSMOTE <- function(x, y, k1 = 5, k2 = 5, type = c("type1", "type2"), ovRate = 1) {
  type <- match.arg(type)
  check_positive_number(k1, "k1")
  check_positive_number(k2, "k2")
  run_oversampler(x, y, generate_BLSMOTE, ovRate,
                  args = list(k1 = k1, k2 = k2, type = type))
}
