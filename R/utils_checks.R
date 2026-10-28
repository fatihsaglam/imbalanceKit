# Input validation shared by all resamplers. Returns x as a numeric matrix.
check_xy <- function(x, y) {
  if (!is.data.frame(x) && !is.matrix(x)) {
    stop("x must be a matrix or dataframe")
  }
  if (!is.factor(y)) {
    stop("y must be a factor")
  }
  x <- as.matrix(x)
  if (!is.numeric(x)) {
    stop("x must be numeric")
  }
  if (nrow(x) != length(y)) {
    stop("x and y must have the same number of observations")
  }
  if (anyNA(x) || anyNA(y)) {
    stop("x and y must not contain missing values")
  }
  x
}

check_positive_number <- function(value, name) {
  if (!is.numeric(value) || length(value) != 1 || is.na(value) || value < 1) {
    stop(name, " must be a positive number")
  }
  invisible(TRUE)
}

# ovRate: one non-negative number or one per class
check_ovRate <- function(ovRate, k_class) {
  if (!is.numeric(ovRate) || anyNA(ovRate) || any(ovRate < 0) ||
      !(length(ovRate) %in% c(1, k_class))) {
    stop("ovRate must be a non-negative number (or one per class)")
  }
  invisible(TRUE)
}

# Number of synthetic samples per class: ovRate * (n_max - n_j), rounded half
# up (base::round rounds half to even) with tolerance to floating point noise
# such as 0.1 * 30 = 3.0000000000000004.
n_needed_rule <- function(ovRate, n_classes) {
  as.integer(floor(ovRate * (max(n_classes) - n_classes) + 0.5 + 1e-8))
}
