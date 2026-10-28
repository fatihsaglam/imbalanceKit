# Random walk oversampling: copies of random samples plus normal noise with the
# standard error of each feature (or `se` if given).
generate_RWO <- function(x_pos, x_neg = NULL, n_syn, se = NULL) {
  n_pos <- nrow(x_pos)
  p <- ncol(x_pos)
  if (is.null(se)) {
    se <- col_sd(x_pos) / sqrt(n_pos)
  }
  i_selected <- sample.int(n_pos, n_syn, replace = TRUE)
  noise <- matrix(stats::rnorm(n_syn * p), n_syn, p) * rep(se, each = n_syn)
  list(x_syn = x_pos[i_selected, , drop = FALSE] + noise)
}
