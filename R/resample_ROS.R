#' @title  Random Oversampling (ROS)
#'
#' @description Resampling with ROS.
#'
#' @param x feature matrix.
#' @param y a factor class variable. Can have more than two classes.
#' @param ovRate Oversampling rate. Class \eqn{j} receives
#' \code{round(ovRate * (n_max - n_j))} synthetic samples, where \code{n_max} is
#' the size of the largest class (halves are rounded up). Default is 1 meaning
#' full balance. A vector with one value per class is also accepted.
#' @param ... not used.
#' @details
#' Random Oversampling (ROS) is a method of copying and pasting of positive
#' samples until balance is achieved.
#'
#' Can work with classes more than 2.
#'
#' @return a list with resampled dataset.
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
#' m <- ROS(x = x, y = y)
#'
#' plot(m$x_new, col = m$y_new)
#'
#' @rdname ROS
#' @export


ROS <- function(x, y, ovRate = 1, ...) {
  run_oversampler(x, y, generate_ROS, ovRate)
}
