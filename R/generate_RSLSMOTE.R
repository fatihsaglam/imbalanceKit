# Relocating-Safe-Level-SMOTE: Safe-Level-SMOTE, then synthetic samples that
# are closer to a nearby other class sample than to the samples they were made
# from are moved towards the safer of the two parent samples.
generate_RSLSMOTE <- function(x_pos, x_neg, n_syn, k1 = 5, k2 = 5, max_relocation = 1000) {
  n_pos <- nrow(x_pos)
  nn_pos <- knn_self(x_pos, k1)
  if (is.null(nn_pos)) {
    return(list(x_syn = generate_fallback_ros(
      x_pos, n_syn, "The class has a single sample, no neighbour exists."),
      C = n_syn))
  }
  x_all <- rbind(x_pos, x_neg)
  k2_use <- min(k2, nrow(x_all) - 1)
  nn_all <- FNN::knnx.index(data = x_all, query = x_pos, k = k2_use + 1)[, -1, drop = FALSE]
  sl <- rowSums(nn_all <= n_pos)
  i_safe <- which(sl > 0)
  if (length(i_safe) == 0) {
    warning("No sample has a same class neighbour; all samples are used.", call. = FALSE)
    i_safe <- seq_len(n_pos)
  }
  C <- integer(n_pos)
  C[i_safe] <- even_counts(n_syn, length(i_safe))

  i_center <- rep(seq_len(n_pos), C)
  i_target <- pick_neighbor(nn_pos, i_center)
  sl_center <- sl[i_center]
  sl_target <- sl[i_target]
  x_center <- x_pos[i_center, , drop = FALSE]
  x_target <- x_pos[i_target, , drop = FALSE]
  r <- safe_level_gap(sl_center, sl_target)
  x_syn <- x_center + r * (x_target - x_center)

  # other class neighbours of the two parent samples (column j: j-th neighbour)
  i_nn_both <- cbind(nn_all[i_center, , drop = FALSE], nn_all[i_target, , drop = FALSE])
  is_neg <- i_nn_both > n_pos

  # smallest distance between the synthetic samples (rows) and their other
  # class neighbours
  min_dist_neg <- function(x_s, rows) {
    d <- matrix(vapply(seq_len(ncol(i_nn_both)), function(j) {
      d_j <- sqrt(rowSums((x_s - x_all[i_nn_both[rows, j], , drop = FALSE])^2))
      ifelse(is_neg[rows, j], d_j, Inf)
    }, numeric(length(rows))), nrow = length(rows))
    apply(d, 1, min)
  }

  # Relocation: a synthetic sample is moved randomly towards the safer parent
  # while an other class neighbour is closer than the closest parent distance.
  todo <- which(rowSums(is_neg) > 0)
  to_center <- sl_center >= sl_target
  for (it in seq_len(max_relocation)) {
    if (length(todo) == 0) {
      break
    }
    x_s <- x_syn[todo, , drop = FALSE]
    x_c <- x_center[todo, , drop = FALSE]
    x_t <- x_target[todo, , drop = FALSE]
    todo <- todo[min_dist_neg(x_s, todo) < dist_to_parents_rows(x_s, x_c, x_t)]
    if (length(todo) == 0) {
      break
    }
    x_s <- x_syn[todo, , drop = FALSE]
    x_c <- x_center[todo, , drop = FALSE]
    x_t <- x_target[todo, , drop = FALSE]
    towards_center <- to_center[todo]
    x_start <- x_s
    x_end <- x_t
    x_start[towards_center, ] <- x_c[towards_center, ]
    x_end[towards_center, ] <- x_s[towards_center, ]
    x_syn[todo, ] <- x_start + stats::runif(length(todo)) * (x_end - x_start)
  }
  list(x_syn = x_syn, C = C)
}

# smallest of the distances between a synthetic sample and its two parents
# and between the two parents
dist_to_parents_rows <- function(x_s, x_c, x_t) {
  pmin(sqrt(rowSums((x_s - x_c)^2)),
       sqrt(rowSums((x_s - x_t)^2)),
       sqrt(rowSums((x_c - x_t)^2)))
}
