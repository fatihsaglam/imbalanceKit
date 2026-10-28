# Borderline-SMOTE (type1 and type2). Samples with 0 < same class fraction <= 0.5
# among their k2 nearest neighbours are "in danger" and are used for generation.
generate_BLSMOTE <- function(x_pos, x_neg, n_syn, k1 = 5, k2 = 5, type = "type1") {
  n_pos <- nrow(x_pos)
  x_all <- rbind(x_pos, x_neg)
  k2_max <- nrow(x_all) - 1

  k2_use <- min(k2, k2_max)
  repeat {
    nn_all <- FNN::knnx.index(data = x_all, query = x_pos, k = k2_use + 1)[, -1, drop = FALSE]
    safe_level <- rowSums(nn_all <= n_pos) / k2_use
    i_danger <- which(safe_level <= 0.5 & safe_level > 0)
    # fewer than two dangerous samples: look at a larger neighbourhood
    if (length(i_danger) >= 2 || k2_use >= k2_max) {
      break
    }
    k2_use <- k2_use + 1
  }
  if (length(i_danger) < 2) {
    warning("Fewer than two borderline samples were found; all samples of the ",
            "class are used.", call. = FALSE)
    i_danger <- seq_len(n_pos)
    nn_all <- FNN::knnx.index(data = x_all, query = x_pos, k = min(k1, k2_max) + 1)[, -1, drop = FALSE]
  }
  n_danger <- length(i_danger)
  x_danger <- x_pos[i_danger, , drop = FALSE]
  i_center <- sample.int(n_danger, n_syn, replace = TRUE)
  x_center <- x_danger[i_center, , drop = FALSE]

  if (type == "type1") {
    nn <- knn_self(x_danger, k1)
    if (is.null(nn)) {
      return(list(x_syn = generate_fallback_ros(
        x_danger, n_syn, "A single dangerous sample was found.")))
    }
    x_target <- x_danger[pick_neighbor(nn, i_center), , drop = FALSE]
    r <- stats::runif(n_syn)
  } else {
    # neighbours are searched in the whole data
    k1_use <- min(k1, k2_max)
    nn <- FNN::knnx.index(data = x_all, query = x_danger, k = k1_use + 1)[, -1, drop = FALSE]
    i_target <- pick_neighbor(nn, i_center)
    x_target <- x_all[i_target, , drop = FALSE]
    # towards a sample of another class only up to half of the way
    r <- stats::runif(n_syn) * ifelse(i_target <= n_pos, 1, 0.5)
  }
  list(x_syn = x_center + r * (x_target - x_center))
}
