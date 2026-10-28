# Building blocks shared by the generate_* functions.

empty_syn <- function(p) matrix(NA_real_, nrow = 0, ncol = p)

# sample standard deviations of the columns (0 for a single row)
col_sd <- function(x) {
  n <- nrow(x)
  if (n < 2) {
    return(rep(0, ncol(x)))
  }
  sqrt(colSums((x - rep(colMeans(x), each = n))^2) / (n - 1))
}

# indices of the k nearest neighbours of every row of x inside x (itself
# excluded). k is capped at nrow(x) - 1; NULL when no neighbour exists.
knn_self <- function(x, k) {
  k <- min(k, nrow(x) - 1)
  if (k < 1) {
    return(NULL)
  }
  FNN::knnx.index(data = x, query = x, k = k + 1)[, -1, drop = FALSE]
}

# Random oversampling, the fallback of neighbour based generators when a
# class has too few samples.
generate_fallback_ros <- function(x_pos, n_syn, reason) {
  warning(reason, " Random oversampling is used instead.", call. = FALSE)
  x_pos[sample.int(nrow(x_pos), n_syn, replace = TRUE), , drop = FALSE]
}

# n_syn spread as evenly as possible over m candidates; the remainder goes to
# randomly selected candidates. Always sums to n_syn.
even_counts <- function(n_syn, m) {
  C <- rep(n_syn %/% m, m)
  n_rest <- n_syn %% m
  if (n_rest > 0) {
    ii <- sample.int(m, n_rest)
    C[ii] <- C[ii] + 1L
  }
  C
}

# n_syn spread proportionally to w (largest remainder method). Sums to n_syn.
proportional_counts <- function(n_syn, w) {
  w <- w / sum(w)
  C <- floor(n_syn * w)
  n_rest <- n_syn - sum(C)
  if (n_rest > 0) {
    ii <- order(n_syn * w - C, decreasing = TRUE)[seq_len(n_rest)]
    C[ii] <- C[ii] + 1
  }
  as.integer(C)
}

# a random neighbour (column) for each of the rows in `rows`
pick_neighbor <- function(nn, rows) {
  nn[cbind(rows, sample.int(ncol(nn), length(rows), replace = TRUE))]
}
