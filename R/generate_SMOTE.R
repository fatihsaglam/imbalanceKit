# SMOTE: interpolation between a random sample and one of its k nearest
# neighbours in the same class.
generate_SMOTE <- function(x_pos, x_neg = NULL, n_syn, k = 5) {
  n_pos <- nrow(x_pos)
  nn <- knn_self(x_pos, k)
  if (is.null(nn)) {
    return(list(x_syn = generate_fallback_ros(
      x_pos, n_syn, "The class has a single sample, no neighbour exists.")))
  }
  i_center <- sample.int(n_pos, n_syn, replace = TRUE)
  i_target <- pick_neighbor(nn, i_center)
  x_center <- x_pos[i_center, , drop = FALSE]
  x_target <- x_pos[i_target, , drop = FALSE]
  list(x_syn = x_center + stats::runif(n_syn) * (x_target - x_center))
}
