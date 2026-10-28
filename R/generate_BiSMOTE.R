# Bi-directional SMOTE: interpolation and extrapolation along the line from a
# sample to one of its k nearest neighbours of the same class. The distance
# to the closest sample of another class limits the extrapolation.
generate_BiSMOTE <- function(x_pos, x_neg, n_syn, k = 5) {
  n_pos <- nrow(x_pos)
  k_use <- min(k, n_pos - 1)
  if (k_use < 1) {
    return(list(x_syn = generate_fallback_ros(
      x_pos, n_syn, "The class has a single sample, no neighbour exists.")))
  }
  d_other <- FNN::get.knnx(data = x_neg, query = x_pos, k = 1)$nn.dist[, 1]
  m_pos <- FNN::get.knnx(data = x_pos, query = x_pos, k = k_use + 1)
  nn <- m_pos$nn.index[, -1, drop = FALSE]
  d_nn <- m_pos$nn.dist[, -1, drop = FALSE]

  i_center <- sample.int(n_pos, n_syn, replace = TRUE)
  i_neighbor <- sample.int(k_use, n_syn, replace = TRUE)
  i_target <- nn[cbind(i_center, i_neighbor)]
  d_center2target <- pmax(d_nn[cbind(i_center, i_neighbor)], 1e-100)
  bound <- d_other[i_center] / d_center2target
  lambda <- stats::runif(n_syn, -bound, bound)

  x_center <- x_pos[i_center, , drop = FALSE]
  x_target <- x_pos[i_target, , drop = FALSE]
  list(x_syn = x_center + lambda * (x_target - x_center))
}
