# Transition matrix of MCSMOTE (Algorithm 1 of Saglam & Cengiz, 2025).
#
# x_pos: feature matrix of the class to oversample.
# Returns the doubly stochastic transition matrix M, where M[i, j] is the
# probability of moving from sample i to sample j, together with Sinkhorn
# convergence information.
#' @noRd
calculate_transition_matrix <- function(x_pos, thresh_qntl = 0.1, tol = 1e-4, max_iter = 1000) {
  n_pos <- nrow(x_pos)

  if (n_pos == 1) {
    return(list(M = matrix(1, 1, 1), converged = TRUE, n_iter = 0))
  }

  D <- Rfast::Dist(x_pos)

  # Gaussian kernel with a sample specific bandwidth: the thresh_qntl quantile
  # of the distances from sample i to all samples (row i of D)
  sigma <- apply(D, 1, stats::quantile, probs = thresh_qntl, names = FALSE)
  sigma <- pmax(sigma, 1e-100)

  # sigma has one element per row, so it is recycled down the columns of D
  K <- exp(-0.5 * D^2 / sigma^2)

  # Sinkhorn-Knopp normalization
  M <- K
  converged <- FALSE
  n_iter <- 0
  for (i in seq_len(max_iter)) {
    n_iter <- i
    M <- M / rowSums(M)
    M <- M / rep(colSums(M), each = n_pos)
    if (max(abs(rowSums(M) - 1)) < tol && max(abs(colSums(M) - 1)) < tol) {
      converged <- TRUE
      break
    }
  }

  list(M = M, converged = converged, n_iter = n_iter)
}

# Generates n_syn synthetic samples from the samples in x_pos with MCSMOTE.
generate_MCSMOTE <- function(x_pos,
                             x_neg = NULL,
                             n_syn,
                             thresh_qntl = 0.1,
                             tol = 1e-4,
                             max_iter = 1000) {
  n_pos <- nrow(x_pos)

  m_tm <- calculate_transition_matrix(
    x_pos = x_pos,
    thresh_qntl = thresh_qntl,
    tol = tol,
    max_iter = max_iter
  )
  M <- m_tm$M

  # initial state: uniformly random, target state: from the transition matrix
  i_initial <- sample.int(n_pos, size = n_syn, replace = TRUE)
  i_target <- integer(n_syn)
  for (i in unique(i_initial)) {
    i_row <- which(i_initial == i)
    i_target[i_row] <- sample.int(n_pos, size = length(i_row), replace = TRUE, prob = M[i, ])
  }

  x_initial <- x_pos[i_initial, , drop = FALSE]
  x_target <- x_pos[i_target, , drop = FALSE]
  x_syn <- x_initial + stats::runif(n_syn) * (x_target - x_initial)
  list(x_syn = x_syn, converged = m_tm$converged, n_iter = m_tm$n_iter)
}
