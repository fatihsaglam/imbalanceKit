# GQEO: samples are generated inside quadrilaterals formed by a sample and three
# of its k nearest neighbours (bilinear interpolation of the four corners).
generate_GQEO <- function(x_pos, x_neg = NULL, n_syn, k = 5, check_planarity = TRUE) {
  n_pos <- nrow(x_pos)
  k_use <- min(k, n_pos - 1)
  quads <- NULL
  if (k_use >= 3) {
    nn <- FNN::get.knn(x_pos, k = k_use)$nn.index
    triplets <- utils::combn(k_use, 3)
    # one row per (sample, triplet of its neighbours)
    quads <- do.call(rbind, lapply(seq_len(ncol(triplets)), function(j) {
      cbind(seq_len(n_pos), nn[, triplets[1, j]], nn[, triplets[2, j]], nn[, triplets[3, j]])
    }))
    quads <- t(apply(quads, 1, sort))
    quads <- quads[apply(quads, 1, function(q) length(unique(q)) == 4), , drop = FALSE]
    quads <- unique(quads)

    if (check_planarity && nrow(quads) > 0) {
      d <- function(a, b) sqrt(rowSums((x_pos[quads[, a], , drop = FALSE] -
                                          x_pos[quads[, b], , drop = FALSE])^2))
      edges <- cbind(d(1, 2), d(2, 3), d(3, 4), d(4, 1))
      # every edge must be shorter than the sum of the other three
      ok <- rowSums(edges) - edges > edges
      quads <- quads[rowSums(ok) == 4, , drop = FALSE]
    }
  }
  if (is.null(quads) || nrow(quads) == 0) {
    return(list(x_syn = generate_fallback_ros(
      x_pos, n_syn, "No quadrilateral could be formed.")))
  }

  q <- quads[sample.int(nrow(quads), n_syn, replace = TRUE), , drop = FALSE]
  eta <- stats::runif(n_syn)
  xi <- 1 - eta
  a <- cbind(0.25 * (1 - xi) * (1 - eta), 0.25 * (1 + xi) * (1 - eta),
             0.25 * (1 + xi) * (1 + eta), 0.25 * (1 - xi) * (1 + eta))
  x_syn <- a[, 1] * x_pos[q[, 1], , drop = FALSE]
  for (j in 2:4) {
    x_syn <- x_syn + a[, j] * x_pos[q[, j], , drop = FALSE]
  }
  list(x_syn = x_syn)
}
