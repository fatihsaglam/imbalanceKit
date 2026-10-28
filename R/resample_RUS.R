#' @title  Random Undersampling (RUS)
#'
#' @description Resampling with RUS.
#'
#' @param x feature matrix.
#' @param y a factor class variable. Can have more than two classes.
#' @param n_neededToRemove vector of desired number removal for each class.
#' A vector of integers for each class. Default is NULL meaning full balance.
#' Must be equal or lower than the number of samples in each class.
#' @param ... not used.
#'
#' @details
#' Random Undersampling (RUS) is a method of removing negative
#' samples until balance is achieved.
#'
#' Can work with classes more than 2.
#'
#' @return a list with resampled dataset.
#'
#'  \item{x_new}{Resampled feature matrix.}
#'  \item{y_new}{Resampled target variable.}
#'
#' @author Fatih Saglam, saglamf89@gmail.com
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
#' m <- RUS(x = x, y = y)
#'
#' plot(m$x_new, col = m$y_new)
#'
#' @rdname RUS
#' @export

RUS <- function(x, y, n_neededToRemove = NULL, ...) {
  x <- check_xy(x, y)
  y <- droplevels(y)
  class_names <- levels(y)
  k_class <- length(class_names)
  n_classes <- as.vector(table(y))

  if (is.null(n_neededToRemove)) {
    n_neededToRemove <- n_classes - min(n_classes)
  }
  if (!is.numeric(n_neededToRemove) || length(n_neededToRemove) != k_class ||
      anyNA(n_neededToRemove) || any(n_neededToRemove < 0)) {
    stop("n_neededToRemove must be a non-negative vector with one element per class.")
  }
  if (any(n_neededToRemove > n_classes)) {
    stop("number of removal cannot be higher than the number of classes.")
  }

  # random rows of each class to drop; the original row order is kept
  i_remove <- unlist(lapply(seq_len(k_class), function(j) {
    i_class <- which(y == class_names[j])
    i_class[sample.int(length(i_class), n_neededToRemove[j])]
  }))
  i_keep <- setdiff(seq_len(nrow(x)), i_remove)

  list(
    x_new = x[i_keep, , drop = FALSE],
    y_new = y[i_keep]
  )
}
