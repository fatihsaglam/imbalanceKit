# VS-SMOTE (Qiu et al., 2025): every sample is linked to its k nearest
# neighbours of the class (connecting lines). The middle point of each line is
# judged by the number of class samples among its k nearest neighbours in all
# data; lines with a count in [k1, k2] ("high-value spaces") are used, and
# synthetic samples are drawn uniformly along randomly chosen valid lines.
generate_VSSMOTE <- function(x_pos, x_neg, n_syn, k = 5, k1 = 0, k2 = k) {
  n_pos <- nrow(x_pos)
  k_use <- min(k, n_pos - 1)
  if (k_use < 1) {
    return(list(x_syn = generate_fallback_ros(
      x_pos, n_syn, "The class has a single sample, no neighbour exists.")))
  }
  nn <- FNN::get.knnx(data = x_pos, query = x_pos, k = k_use + 1)$nn.index[, -1, drop = FALSE]
  i_center <- rep(seq_len(n_pos), times = k_use)
  i_target <- as.vector(nn)
  x_center <- x_pos[i_center, , drop = FALSE]
  x_target <- x_pos[i_target, , drop = FALSE]

  x_pool <- rbind(x_pos, x_neg)
  x_middle <- (x_center + x_target) / 2
  nn_mid <- FNN::get.knnx(data = x_pool, query = x_middle,
                          k = min(k, nrow(x_pool)))$nn.index
  n_minority <- rowSums(matrix(nn_mid <= n_pos, nrow = nrow(nn_mid)))
  i_valid <- which(n_minority >= k1 & n_minority <= k2)
  if (length(i_valid) == 0) {
    warning("No connecting line has between k1 and k2 samples of the class around its ",
            "middle point, all lines are used.", call. = FALSE)
    i_valid <- seq_along(i_center)
  }
  i_line <- i_valid[sample.int(length(i_valid), n_syn, replace = TRUE)]
  lambda <- stats::runif(n_syn)
  list(x_syn = x_center[i_line, , drop = FALSE] +
         lambda * (x_target[i_line, , drop = FALSE] - x_center[i_line, , drop = FALSE]),
       n_valid_lines = length(i_valid), n_lines = length(i_center))
}
