#' @title  VS-SMOTE (VSSMOTE, 2025)
#'
#' @description Resampling with VSSMOTE.
#'
#' @param x feature matrix or data.frame.
#' @param y a factor class variable. Can have more than two classes.
#' @param k number of nearest neighbors of the class that each sample is linked to (connecting lines) and size of the neighborhood of the middle points. Default is 5.
#' @param k1,k2 a connecting line is used if the number of samples of the class among the \code{k} nearest neighbors of its middle point is between \code{k1} and \code{k2} (high-value space). \code{k1 = 0} and \code{k2 = k} (default) give the ordinary SMOTE. Raising \code{k1} removes lines in majority dominated (noisy) spaces, lowering \code{k2} removes lines in the safest spaces. If \code{NULL}, \code{k2} is \code{k}.
#' @param ovRate Oversampling rate. Class \eqn{j} receives
#' \code{round(ovRate * (n_max - n_j))} synthetic samples, where \code{n_max} is
#' the size of the largest class (halves are rounded up). Default is 1 meaning
#' full balance. A vector with one value per class is also accepted.
#' @param ... not used.
#'
#' @details
#' \strong{Year: 2025.} Each sample is linked to its \code{k} nearest neighbors of the class. The middle point of every connecting line is used to judge the space of the line, and synthetic samples are generated uniformly along randomly chosen lines of the high-value spaces only. If no line qualifies, all lines are used with a warning.
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
#' Qiu, F., Yang, F., Xiong, Y., Chen, T., Xiao, P., Zheng, W., ... & Zhou, K.
#' (2025). VS-SMOTE: Leveraging high-value spaces to balance noise control and
#' data diversity for class imbalanced learning. Neurocomputing, 131321.
#'
#' @examples
#'
#' set.seed(1)
#' x <- rbind(matrix(rnorm(2000, 3, 1), ncol = 2, nrow = 1000),
#'            matrix(rnorm(100, 5, 1), ncol = 2, nrow = 50))
#' y <- as.factor(c(rep("negative", 1000), rep("positive", 50)))
#'
#' m <- VSSMOTE(x = x, y = y, k = 5, k1 = 2, k2 = 5)
#' table(m$y_new)
#' plot(m$x_new, col = m$y_new)
#'
#' @rdname VSSMOTE
#' @export

VSSMOTE <- function(x, y, k = 5, k1 = 0, k2 = k, ovRate = 1, ...) {
  check_positive_number(k, "k")
  if (is.null(k2)) k2 <- k
  if (!is.numeric(k1) || length(k1) != 1 || k1 < 0 || !is.numeric(k2) || length(k2) != 1 || k1 > k2) {
    stop("k1 and k2 must be numbers with 0 <= k1 <= k2")
  }
  run_oversampler(x, y, generate_VSSMOTE, ovRate, args = list(k = k, k1 = k1, k2 = k2),
                  extras = c("n_valid_lines", "n_lines"))
}
