# ADASYN: the number of synthetic samples of a sample is proportional to the
# number of other class samples among its k nearest neighbours.
generate_ADASYN <- function(x_pos, x_neg, n_syn, k = 5) {
  n_pos <- nrow(x_pos)
  nn_pos <- knn_self(x_pos, k)
  if (is.null(nn_pos)) {
    return(list(x_syn = generate_fallback_ros(
      x_pos, n_syn, "The class has a single sample, no neighbour exists."),
      C = n_syn))
  }
  x_all <- rbind(x_pos, x_neg)
  k_all <- min(k, nrow(x_all) - 1)
  nn_all <- FNN::knnx.index(data = x_all, query = x_pos, k = k_all + 1)[, -1, drop = FALSE]
  # x_pos comes first in x_all: an index above n_pos is a sample of another class
  count_other <- rowSums(nn_all > n_pos)
  w <- if (sum(count_other) == 0) rep(1, n_pos) else count_other
  C <- proportional_counts(n_syn, w)

  i_center <- rep(seq_len(n_pos), C)
  i_target <- pick_neighbor(nn_pos, i_center)
  x_center <- x_pos[i_center, , drop = FALSE]
  x_target <- x_pos[i_target, , drop = FALSE]
  list(x_syn = x_center + stats::runif(n_syn) * (x_target - x_center), C = C)
}
