# Shared pieces of the complexity measures. A "context" is an environment
# holding the prepared data; the distance matrix is computed only when a
# measure needs it, and only once.

cx_prepare <- function(x, y, scale = "minmax") {
  if (is.null(x)) {
    stop("x is needed for this measure")
  }
  x <- check_xy(x, y)
  y <- droplevels(as.factor(y))
  if (nlevels(y) < 2) {
    stop("y must have at least two classes")
  }
  scale <- match.arg(scale, c("minmax", "zscore", "none"))
  xs <- switch(scale,
    minmax = apply(x, 2, function(v) {
      r <- diff(range(v))
      if (r == 0) rep(0, length(v)) else (v - min(v)) / r
    }),
    zscore = apply(x, 2, function(v) {
      s <- stats::sd(v)
      if (!is.finite(s) || s == 0) rep(0, length(v)) else (v - mean(v)) / s
    }),
    none = x)
  xs <- matrix(xs, nrow = nrow(x))
  ctx <- new.env(parent = emptyenv())
  ctx$x <- x          # original features (feature based measures)
  ctx$xs <- xs        # scaled features (distance based measures)
  ctx$y <- y
  ctx$n <- nrow(x)
  ctx
}

# n x n distance matrix with Inf on the diagonal (computed once)
cx_dist <- function(ctx) {
  if (is.null(ctx$D)) {
    D <- as.matrix(stats::dist(ctx$xs))
    diag(D) <- Inf
    ctx$D <- D
  }
  ctx$D
}

# nearest neighbours (self excluded) of every sample, computed once for the
# largest k requested so far
cx_knn <- function(ctx, k) {
  k <- min(k, ctx$n - 1)
  if (is.null(ctx$knn) || ncol(ctx$knn) < k) {
    ctx$knn <- FNN::get.knnx(data = ctx$xs, query = ctx$xs, k = k + 1)$nn.index[, -1, drop = FALSE]
  }
  ctx$knn[, seq_len(k), drop = FALSE]
}

# measure of two classes -> mean over all pairs of classes (one-versus-one)
cx_ovo <- function(f, x, y) {
  lev <- levels(y)
  if (length(lev) == 2) {
    return(f(x, y == lev[1]))
  }
  pairs <- utils::combn(lev, 2, simplify = FALSE)
  mean(vapply(pairs, function(p) {
    keep <- y %in% p
    f(x[keep, , drop = FALSE], y[keep] == p[1])
  }, numeric(1)))
}
