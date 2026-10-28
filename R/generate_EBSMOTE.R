# EBSMOTE: new samples are generated from borderline samples of the class and
# the nearest borderline samples of the other classes.
generate_EBSMOTE <- function(x_pos, x_neg, n_syn, m_alpha = 5, m_beta = 5,
                             lambda = 3, v_alpha = 5, w_alpha = 5,
                             expand_alpha = 0.3) {
  n_pos <- nrow(x_pos)
  x <- rbind(x_pos, x_neg)

  # borderline samples: some, but not all, of the m nearest samples (the sample
  # itself included) come from the other side
  m_a <- min(m_alpha, nrow(x) - 1)
  n_alpha <- rowSums(FNN::knnx.index(data = x, query = x_pos, k = m_a) > n_pos)
  border_pos <- which(n_alpha >= m_a / lambda & n_alpha < m_a)

  m_b <- min(m_beta, nrow(x) - 1)
  n_beta <- rowSums(FNN::knnx.index(data = x, query = x_neg, k = m_b) <= n_pos)
  border_neg <- which(n_beta >= m_b / lambda & n_beta < m_b)

  if (length(border_pos) < 1 || length(border_neg) < 1) {
    return(list(x_syn = generate_fallback_ros(
      x_pos, n_syn, "No borderline samples were found.")))
  }
  x_bpos <- x_pos[border_pos, , drop = FALSE]
  x_bneg <- x_neg[border_neg, , drop = FALSE]

  # p_i: a borderline sample, t_j: one of its nearest borderline samples of the
  # other side, p_k: one of the nearest borderline samples of t_j
  p_i <- x_bpos[sample.int(nrow(x_bpos), n_syn, replace = TRUE), , drop = FALSE]
  nn_t <- FNN::knnx.index(data = x_bneg, query = p_i, k = min(v_alpha, nrow(x_bneg)))
  t_j <- x_bneg[pick_neighbor(nn_t, seq_len(n_syn)), , drop = FALSE]
  nn_k <- FNN::knnx.index(data = x_bpos, query = t_j, k = min(w_alpha, nrow(x_bpos)))
  p_k <- x_bpos[pick_neighbor(nn_k, seq_len(n_syn)), , drop = FALSE]

  phi <- stats::runif(n_syn)
  list(x_syn = (1 - expand_alpha) * (phi * p_i + (1 - phi) * p_k) + expand_alpha * t_j)
}
