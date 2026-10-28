# SyMProD: z-score noise removal, closeness factors, probabilistic selection of
# base samples and convex combinations of a base sample and its neighbours.
generate_SyMProD <- function(x_pos, x_neg, n_syn, NT = 3, CT = 0, K = 5, M = 5) {
  z_clean <- function(x) {
    z <- if (nrow(x) > 1) scale(x) else matrix(0, nrow(x), ncol(x))
    z[is.na(z)] <- 0
    x[apply(abs(z) <= NT, 1, all), , drop = FALSE]
  }
  x_p <- z_clean(x_pos)
  x_n <- z_clean(x_neg)
  fallback <- function(reason) {
    list(x_syn = generate_fallback_ros(x_pos, n_syn, reason))
  }
  if (nrow(x_p) < 2 || nrow(x_n) < 2) {
    return(fallback("Too few samples remain after noise removal."))
  }

  # closeness factor of every sample of the class, rescaled to [0, 1]
  total_dist <- rowSums(as.matrix(stats::dist(x_p)))
  closeness <- 1 / total_dist
  r <- range(closeness)
  closeness <- if (all(is.finite(r)) && r[2] > r[1]) (closeness - r[1]) / (r[2] - r[1]) else rep(0.5, nrow(x_p))

  KK <- min(K, nrow(x_p) - 1, nrow(x_n) - 1)
  nn_p <- FNN::knnx.index(data = x_p, query = x_p, k = KK + 1)[, -1, drop = FALSE]
  nn_n <- FNN::knnx.index(data = x_n, query = x_p, k = KK)

  tau_p <- tau_n <- numeric(nrow(x_p))
  for (j in seq_len(KK)) {
    d_p <- sqrt(rowSums((x_p[nn_p[, j], , drop = FALSE] - x_p)^2) + 1e-10)
    tau_p <- tau_p + closeness[nn_p[, j]] / d_p
    tau_n <- tau_n + 1 / sqrt(rowSums((x_n[nn_n[, j], , drop = FALSE] - x_p)^2))
  }
  tau_n[is.infinite(tau_n)] <- 1e100

  keep <- tau_p > CT * tau_n
  if (!any(keep)) {
    return(fallback("No sample passed the selection."))
  }
  score <- ((tau_p + 1) / (tau_n + 1))[keep]
  x_f <- x_p[keep, , drop = FALSE]

  # convex combination of a base sample and its MM nearest neighbours
  MM <- min(M, nrow(x_f) - 1)
  base <- sample.int(nrow(x_f), n_syn, replace = TRUE, prob = score / sum(score))
  nn_f <- FNN::knnx.index(data = x_f, query = x_f, k = MM + 1)
  beta <- matrix(stats::runif(n_syn * (MM + 1)), n_syn, MM + 1)
  beta <- beta / rowSums(beta)
  x_syn <- beta[, 1] * x_f[nn_f[base, 1], , drop = FALSE]
  for (j in seq_len(MM) + 1) {
    x_syn <- x_syn + beta[, j] * x_f[nn_f[base, j], , drop = FALSE]
  }
  list(x_syn = x_syn)
}
