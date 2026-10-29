# Radius-SMOTE (Pradipta et al., 2021): samples of the class whose k nearest
# neighbours (all data) are mostly from the class are "safe". Around a safe
# sample, synthetic samples are placed on the line to its nearest sample of
# the other classes, towards it or in the opposite direction, never farther
# than the distance to that sample (the safe radius).
generate_RadiusSMOTE <- function(x_pos, x_neg, n_syn, k = 5) {
  n_pos <- nrow(x_pos)
  x_pool <- rbind(x_pos, x_neg)
  k_use <- min(k, nrow(x_pool) - 1)
  is_safe <- rep(TRUE, n_pos)
  if (k_use >= 1) {
    nn <- FNN::get.knnx(data = x_pool, query = x_pos, k = k_use + 1)$nn.index[, -1, drop = FALSE]
    n_same <- rowSums(matrix(nn <= n_pos, nrow = n_pos))
    is_safe <- n_same > k_use / 2
  }
  if (!any(is_safe)) {
    warning("No safe sample found, all samples of the class are used.", call. = FALSE)
    is_safe[] <- TRUE
  }
  x_safe <- x_pos[is_safe, , drop = FALSE]
  m_other <- FNN::get.knnx(data = x_neg, query = x_safe, k = 1)
  x_target <- x_neg[m_other$nn.index[, 1], , drop = FALSE]

  i_center <- sample.int(nrow(x_safe), n_syn, replace = TRUE)
  direction <- sample(c(-1, 1), n_syn, replace = TRUE)
  u <- stats::runif(n_syn)
  x_center <- x_safe[i_center, , drop = FALSE]
  list(x_syn = x_center + direction * u * (x_target[i_center, , drop = FALSE] - x_center),
       n_safe = nrow(x_safe))
}
