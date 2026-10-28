# Safe-Level-SMOTE.
generate_SLSMOTE <- function(x_pos, x_neg, n_syn, k1 = 5, k2 = 5) {
  n_pos <- nrow(x_pos)
  nn_pos <- knn_self(x_pos, k1)
  if (is.null(nn_pos)) {
    return(list(x_syn = generate_fallback_ros(
      x_pos, n_syn, "The class has a single sample, no neighbour exists."),
      C = n_syn))
  }
  sl <- safe_levels(x_pos, x_neg, k2)
  i_safe <- which(sl > 0)
  if (length(i_safe) == 0) {
    warning("No sample has a same class neighbour; all samples are used.", call. = FALSE)
    i_safe <- seq_len(n_pos)
  }
  C <- integer(n_pos)
  C[i_safe] <- even_counts(n_syn, length(i_safe))

  i_center <- rep(seq_len(n_pos), C)
  i_target <- pick_neighbor(nn_pos, i_center)
  r <- safe_level_gap(sl[i_center], sl[i_target])
  x_center <- x_pos[i_center, , drop = FALSE]
  x_target <- x_pos[i_target, , drop = FALSE]
  list(x_syn = x_center + r * (x_target - x_center), C = C)
}

# number of same class samples among the k2 nearest neighbours
safe_levels <- function(x_pos, x_neg, k2) {
  x_all <- rbind(x_pos, x_neg)
  k2 <- min(k2, nrow(x_all) - 1)
  nn_all <- FNN::knnx.index(data = x_all, query = x_pos, k = k2 + 1)[, -1, drop = FALSE]
  rowSums(nn_all <= nrow(x_pos))
}

# random gap of Safe-Level-SMOTE given the safe levels of the sample and of
# its selected neighbour
safe_level_gap <- function(sl_center, sl_target) {
  hi <- ifelse(sl_target == 0, 0, ifelse(sl_target < sl_center, sl_target / sl_center, 1))
  lo <- ifelse(sl_target > sl_center, 1 - sl_center / sl_target, 0)
  lo + stats::runif(length(sl_center)) * (hi - lo)
}
