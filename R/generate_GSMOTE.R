# Geometric SMOTE: samples are generated in a deformed hyperball around a
# sample of x_pos, bounded by a surface point from the same or the other class.
generate_GSMOTE <- function(x_pos, x_neg, n_syn, k = 5, alpha_sel = "combined",
                            alpha_trunc = 0.5, alpha_def = 0.5) {
  n_pos <- nrow(x_pos)
  p <- ncol(x_pos)
  nn_pos <- knn_self(x_pos, k)
  if (is.null(nn_pos) && alpha_sel != "majority") {
    warning("The class has a single sample; the other class is used as surface.",
            call. = FALSE)
    alpha_sel <- "majority"
  }

  # nearest sample of the other classes
  m_neg <- FNN::get.knnx(data = x_neg, query = x_pos, k = 1)
  C <- even_counts(n_syn, n_pos)
  i_center <- rep(seq_len(n_pos), C)
  x_center <- x_pos[i_center, , drop = FALSE]
  x_neg_nearest <- x_neg[m_neg$nn.index[i_center, 1], , drop = FALSE]
  d_neg <- m_neg$nn.dist[i_center, 1]

  # surface point
  if (alpha_sel == "majority") {
    x_surface <- x_neg_nearest
  } else {
    i_target <- pick_neighbor(nn_pos, i_center)
    x_target <- x_pos[i_target, , drop = FALSE]
    if (alpha_sel == "minority") {
      x_surface <- x_target
    } else {
      d_pos <- sqrt(rowSums((x_target - x_center)^2))
      use_pos <- d_pos < d_neg
      x_surface <- x_neg_nearest
      x_surface[use_pos, ] <- x_target[use_pos, ]
    }
  }

  # random point in the unit hyperball
  v <- matrix(stats::rnorm(n_syn * p), n_syn, p)
  x_gen <- (stats::runif(n_syn)^(1 / p) / sqrt(rowSums(v^2))) * v

  # parallel and perpendicular components relative to the surface direction
  R <- sqrt(rowSums((x_surface - x_center)^2))
  R_safe <- ifelse(R == 0, 1, R)
  e_parallel <- (x_surface - x_center) / R_safe
  proj <- rowSums(x_gen * e_parallel)
  x_parallel <- proj * e_parallel
  x_perpendicular <- x_gen - x_parallel

  # truncate, deform and translate
  truncate <- abs(alpha_trunc - proj) > 1
  x_gen[truncate, ] <- x_gen[truncate, ] - 2 * x_parallel[truncate, ]
  x_gen <- x_gen - alpha_def * x_perpendicular
  x_syn <- x_center + R * x_gen
  list(x_syn = x_syn, C = C)
}
