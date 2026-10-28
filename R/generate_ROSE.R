# Smoothed bootstrap (ROSE): random samples plus Gaussian kernel noise.
generate_ROSE <- function(x_pos, x_neg = NULL, n_syn, h = 1) {
  n_pos <- nrow(x_pos)
  p <- ncol(x_pos)
  bandwidth <- h * (4 / ((p + 2) * n_pos))^(1 / (p + 4)) * (col_sd(x_pos) + 1e-7)
  i_selected <- sample.int(n_pos, n_syn, replace = TRUE)
  noise <- matrix(stats::rnorm(n_syn * p), n_syn, p) * rep(bandwidth, each = n_syn)
  list(x_syn = x_pos[i_selected, , drop = FALSE] + noise)
}
