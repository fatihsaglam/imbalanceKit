#' @title Complexity Measures for Imbalanced Classification Data
#'
#' @description Measures of the class imbalance, of the class overlap and of the
#' noise of a classification data set, taken from the literature. Higher values
#' mean a more imbalanced or a more complex (harder) problem. Each measure is a
#' function of its own; \code{\link{complexity}} calculates all of them or the
#' selected ones.
#'
#' @param x feature matrix or data.frame (numeric).
#' @param y a factor class variable. Can have more than two classes (see
#' Details).
#' @param scale scaling of the features before distances are calculated:
#' \code{"minmax"} (default, to [0, 1]), \code{"zscore"} or \code{"none"}.
#' Feature based measures (\code{F1}, \code{F1v}, \code{F2}, \code{F3},
#' \code{F4}) use the original features.
#' @param k number of nearest neighbors. Default is 7 for \code{R} and
#' \code{R_aug} (Oh, 2011) and 5 for the types of minority examples
#' (Napierala & Stefanowski, 2016).
#' @param theta threshold of the R-value: a sample is in the overlapping region
#' if more than \code{theta} of its \code{k} nearest neighbors are from other
#' classes. Default is 3.
#' @param seed seed of the random interpolation of \code{N4}. Default is
#' \code{NULL} (the random number stream is not touched).
#'
#' @details
#' \strong{Class imbalance} (they use \code{y} only; \code{x} may be
#' \code{NULL}):
#' \itemize{
#'   \item \code{IR}: imbalance ratio, size of the largest class divided by the
#'   size of the smallest class.
#'   \item \code{C1}: \eqn{1 + \sum_k p_k \log p_k / \log K}, one minus the
#'   normalized entropy of the class proportions \eqn{p_k} (Lorena et al.,
#'   2019). 0 means balanced, 1 means one class has all the samples.
#'   \item \code{C2}: \eqn{1 - 1 / IR_{K}} with
#'   \eqn{IR_{K} = \frac{K - 1}{K} \sum_k n_k / (n - n_k)} (Lorena et al., 2019).
#'   \item \code{ID}: imbalance degree (Ortigosa-Hernandez et al., 2017), with
#'   the Euclidean distance. 0 means balanced; the integer part is the number
#'   of minority classes minus one.
#' }
#' \strong{Overlap, feature based} (Ho & Basu, 2002; Lorena et al., 2019).
#' They are defined for two classes; with more classes the mean over all pairs
#' of classes (one-versus-one) is returned. They are transformed so that higher
#' means more overlap:
#' \itemize{
#'   \item \code{F1}: \eqn{1 / (1 + r)}, with \eqn{r} the maximum Fisher's
#'   discriminant ratio over the features. \code{F1v}: the same with the
#'   directional (vector) Fisher's ratio (Orriols-Puig et al., 2010).
#'   \item \code{F2}: volume of the overlapping region (product over the
#'   features of the relative overlap).
#'   \item \code{F3}: maximum individual feature efficiency, inverted: the
#'   smallest proportion of samples in the overlapping interval of a single
#'   feature.
#'   \item \code{F4}: collective feature efficiency: proportion of samples that
#'   remain after the features have been used one after another to separate
#'   the classes.
#' }
#' \strong{Overlap, neighborhood based} (they work with any number of classes;
#' Ho & Basu, 2002; Leyva et al., 2015):
#' \itemize{
#'   \item \code{N1}: proportion of samples that are connected to a sample of
#'   another class in the minimum spanning tree.
#'   \item \code{N2}: ratio of the intra-class to the inter-class nearest
#'   neighbor distances, \eqn{r / (1 + r)}.
#'   \item \code{N3}: error rate of the leave-one-out 1-nearest neighbor
#'   classifier. \code{N3_bal}: the mean of its class-wise error rates (a
#'   class-balanced variant, not in Ho & Basu).
#'   \item \code{N4}: error rate of the 1-nearest neighbor classifier on
#'   randomly interpolated samples (of the same class) (needs a random
#'   number stream, see \code{seed}).
#'   \item \code{LSC}: local set cardinality, \eqn{1 - \sum |LS| / n^2}.
#' }
#' \strong{Overlap and imbalance together}:
#' \itemize{
#'   \item \code{R}: R-value (Oh, 2011), the proportion of samples in the
#'   overlapping region (\eqn{> theta} of the \code{k} nearest neighbors from
#'   another class). For two classes it is
#'   \eqn{(IR \cdot R_{maj} + R_{min}) / (IR + 1)}, so it is dominated by the
#'   majority class.
#'   \item \code{R_aug}: augmented R-value (Borsos et al., 2018),
#'   \eqn{(R_{maj} + IR \cdot R_{min}) / (IR + 1)}: the weights are swapped so
#'   that the minority class, which is more affected by overlap, is dominant. For
#'   more than two classes the class weights are \eqn{n_{max} / n_k}
#'   (normalized); this generalization is ours.
#' }
#' \strong{Noise, types of minority examples} (Napierala & Stefanowski, 2016).
#' The minority samples (all classes except the largest one) are labelled by
#' the proportion \eqn{s} of their \code{k} nearest neighbors from their own
#' class: safe (\eqn{s \ge 0.8}), borderline (\eqn{0.4 \le s < 0.8}), rare
#' (\eqn{0 < s < 0.4}) and outlier (\eqn{s = 0}). With \code{k = 5} these are 4-5,
#' 2-3, 1 and 0 neighbors. The measures \code{SAFE}, \code{BORDERLINE},
#' \code{RARE} and \code{OUTLIER} are the proportions of minority samples of
#' each type. Larger \code{RARE} and \code{OUTLIER} mean a noisier minority
#' class.
#'
#' @return a number.
#'
#' @author Fatih Saglam, saglamf89@gmail.com
#'
#' @references
#' Borsos, Z., Lemnaru, C., & Potolea, R. (2018). Dealing with overlap and
#' imbalance: a new metric and approach. Pattern Analysis and Applications, 21(2),
#' 381-395.
#'
#' Ho, T. K., & Basu, M. (2002). Complexity measures of supervised
#' classification problems. IEEE Transactions on Pattern Analysis and Machine
#' Intelligence, 24(3), 289-300.
#'
#' Leyva, E., Gonzalez, A., & Perez, R. (2015). A set of complexity measures
#' designed for applying meta-learning to instance selection. IEEE Transactions
#' on Knowledge and Data Engineering, 27(2), 354-367.
#'
#' Lorena, A. C., Garcia, L. P., Lehmann, J., Souto, M. C., & Ho, T. K. (2019).
#' How complex is your classification problem? A survey on measuring
#' classification complexity. ACM Computing Surveys, 52(5), 1-34.
#'
#' Napierala, K., & Stefanowski, J. (2016). Types of minority class examples
#' and their influence on learning classifiers in imbalanced domains. Journal of
#' Intelligent Information Systems, 46(3), 563-597.
#'
#' Oh, S. (2011). A new dataset evaluation method based on category overlap.
#' Computers in Biology and Medicine, 41(2), 115-122.
#'
#' Orriols-Puig, A., Macia, N., & Ho, T. K. (2010). Documentation for the data
#' complexity library in C++. Technical report, La Salle, Universitat Ramon Llull.
#'
#' Ortigosa-Hernandez, J., Inza, I., & Lozano, J. A. (2017). Measuring the
#' class-imbalance extent of multi-class problems. Pattern Recognition Letters,
#' 98, 32-38.
#'
#' @examples
#' set.seed(1)
#' x <- rbind(matrix(rnorm(400, 3, 1), ncol = 2), matrix(rnorm(40, 4, 1), ncol = 2))
#' y <- factor(rep(c("negative", "positive"), c(200, 20)))
#'
#' complexity_IR(y = y)
#' complexity_R_aug(x, y)
#' complexity_N3(x, y)
#'
#' @name complexity_measures
NULL

cx_counts <- function(y) as.numeric(table(droplevels(as.factor(y))))

# ---------------------------------------------------------------- imbalance

#' @rdname complexity_measures
#' @export
complexity_IR <- function(x = NULL, y) {
  tb <- cx_counts(y)
  max(tb) / min(tb)
}

#' @rdname complexity_measures
#' @export
complexity_C1 <- function(x = NULL, y) {
  p <- cx_counts(y) / length(y)
  1 + sum(p * log(p)) / log(length(p))
}

#' @rdname complexity_measures
#' @export
complexity_C2 <- function(x = NULL, y) {
  tb <- cx_counts(y)
  n <- sum(tb)
  K <- length(tb)
  1 - 1 / ((K - 1) / K * sum(tb / (n - tb)))
}

#' @rdname complexity_measures
#' @export
complexity_ID <- function(x = NULL, y) {
  p <- cx_counts(y) / length(y)
  K <- length(p)
  e <- rep(1 / K, K)
  m <- sum(p < 1 / K)
  if (m == 0) {
    return(0)
  }
  iota <- c(rep(0, m), rep(1 / (K - m), K - m))
  d <- function(a, b) sqrt(sum((a - b)^2))
  d(p, e) / d(iota, e) + (m - 1)
}

# ------------------------------------------------------- feature based (two classes)

cx_f1 <- function(x, g) {
  r <- apply(x, 2, function(v) {
    a <- v[g]; b <- v[!g]
    den <- stats::var(a) + stats::var(b)
    if (!is.finite(den) || den == 0) 0 else (mean(a) - mean(b))^2 / den
  })
  1 / (1 + max(r))
}

cx_f1v <- function(x, g) {
  p1 <- mean(g); p0 <- 1 - p1
  x1 <- x[g, , drop = FALSE]; x0 <- x[!g, , drop = FALSE]
  m1 <- colMeans(x1); m0 <- colMeans(x0); m <- p1 * m1 + p0 * m0
  cov1 <- if (nrow(x1) > 1) stats::cov(x1) else matrix(0, ncol(x), ncol(x))
  cov0 <- if (nrow(x0) > 1) stats::cov(x0) else matrix(0, ncol(x), ncol(x))
  W <- p1 * cov1 + p0 * cov0
  W <- W + diag(1e-8 * mean(diag(W)) + 1e-12, ncol(W))
  d <- solve(W, m1 - m0)
  num <- p1 * sum(d * (m1 - m))^2 + p0 * sum(d * (m0 - m))^2
  1 / (1 + num / as.numeric(t(d) %*% W %*% d))
}

cx_interval <- function(v, g) {
  c(lo = max(min(v[g]), min(v[!g])), hi = min(max(v[g]), max(v[!g])))
}

cx_f2 <- function(x, g) {
  prod(vapply(seq_len(ncol(x)), function(j) {
    v <- x[, j]
    iv <- cx_interval(v, g)
    rg <- max(v) - min(v)
    if (rg == 0) 1 else max(0, iv[["hi"]] - iv[["lo"]]) / rg
  }, numeric(1)))
}

cx_f3 <- function(x, g) {
  min(vapply(seq_len(ncol(x)), function(j) {
    v <- x[, j]
    iv <- cx_interval(v, g)
    if (iv[["lo"]] > iv[["hi"]]) 0 else mean(v >= iv[["lo"]] & v <= iv[["hi"]])
  }, numeric(1)))
}

cx_f4 <- function(x, g) {
  n <- nrow(x)
  keep <- rep(TRUE, n)
  feats <- seq_len(ncol(x))
  while (length(feats) > 0 && any(keep)) {
    if (length(unique(g[keep])) < 2) {
      keep[] <- FALSE
      break
    }
    cnt <- vapply(feats, function(j) {
      iv <- cx_interval(x[keep, j], g[keep])
      if (iv[["lo"]] > iv[["hi"]]) 0 else sum(x[keep, j] >= iv[["lo"]] & x[keep, j] <= iv[["hi"]])
    }, numeric(1))
    jb <- feats[which.min(cnt)]
    iv <- cx_interval(x[keep, jb], g[keep])
    if (iv[["lo"]] > iv[["hi"]]) {
      keep[] <- FALSE
      break
    }
    keep <- keep & x[, jb] >= iv[["lo"]] & x[, jb] <= iv[["hi"]]
    feats <- setdiff(feats, jb)
  }
  sum(keep) / n
}

cx_feature_measure <- function(f, x, y) {
  ctx <- cx_prepare(x, y, "none")
  cx_ovo(f, ctx$x, ctx$y)
}

#' @rdname complexity_measures
#' @export
complexity_F1 <- function(x, y) cx_feature_measure(cx_f1, x, y)

#' @rdname complexity_measures
#' @export
complexity_F1v <- function(x, y) cx_feature_measure(cx_f1v, x, y)

#' @rdname complexity_measures
#' @export
complexity_F2 <- function(x, y) cx_feature_measure(cx_f2, x, y)

#' @rdname complexity_measures
#' @export
complexity_F3 <- function(x, y) cx_feature_measure(cx_f3, x, y)

#' @rdname complexity_measures
#' @export
complexity_F4 <- function(x, y) cx_feature_measure(cx_f4, x, y)

# ------------------------------------------------------------ neighbourhood based

cx_mst_edges <- function(D) {
  n <- nrow(D)
  in_tree <- rep(FALSE, n)
  in_tree[1] <- TRUE
  best <- D[1, ]
  from <- rep(1L, n)
  edges <- matrix(0L, n - 1, 2)
  for (s in seq_len(n - 1)) {
    cand <- best
    cand[in_tree] <- Inf
    j <- which.min(cand)
    edges[s, ] <- c(from[j], j)
    in_tree[j] <- TRUE
    upd <- D[j, ] < best & !in_tree
    best[upd] <- D[j, upd]
    from[upd] <- j
  }
  edges
}

cx_n1 <- function(ctx) {
  E <- cx_mst_edges(cx_dist(ctx))
  diff_class <- ctx$y[E[, 1]] != ctx$y[E[, 2]]
  length(unique(c(E[diff_class, 1], E[diff_class, 2]))) / ctx$n
}

cx_nn_same_other <- function(ctx) {
  D <- cx_dist(ctx)
  same <- outer(ctx$y, ctx$y, "==")
  Ds <- D; Ds[!same] <- Inf
  De <- D; De[same] <- Inf
  list(D = D, same = same, intra = apply(Ds, 1, min), extra = apply(De, 1, min))
}

#' @rdname complexity_measures
#' @export
complexity_N1 <- function(x, y, scale = "minmax") cx_n1(cx_prepare(x, y, scale))

#' @rdname complexity_measures
#' @export
complexity_N2 <- function(x, y, scale = "minmax") {
  d <- cx_nn_same_other(cx_prepare(x, y, scale))
  intra <- d$intra
  intra[is.infinite(intra)] <- NA     # classes with a single sample
  r <- sum(intra, na.rm = TRUE) / sum(d$extra)
  r / (1 + r)
}

#' @rdname complexity_measures
#' @export
complexity_N3 <- function(x, y, scale = "minmax") {
  ctx <- cx_prepare(x, y, scale)
  nn1 <- cx_knn(ctx, 1)[, 1]
  mean(ctx$y[nn1] != ctx$y)
}

#' @rdname complexity_measures
#' @export
complexity_N3_bal <- function(x, y, scale = "minmax") {
  ctx <- cx_prepare(x, y, scale)
  nn1 <- cx_knn(ctx, 1)[, 1]
  err <- ctx$y[nn1] != ctx$y
  mean(tapply(err, ctx$y, mean))
}

#' @rdname complexity_measures
#' @export
complexity_N4 <- function(x, y, scale = "minmax", seed = NULL) {
  ctx <- cx_prepare(x, y, scale)
  if (!is.null(seed)) set.seed(seed)
  Z <- NULL
  zy <- character(0)
  for (cl in levels(ctx$y)) {
    i <- which(ctx$y == cl)
    m <- length(i)
    a <- i[sample.int(m, m, replace = TRUE)]
    b <- i[sample.int(m, m, replace = TRUE)]
    t <- stats::runif(m)
    Z <- rbind(Z, ctx$xs[a, , drop = FALSE] * (1 - t) + ctx$xs[b, , drop = FALSE] * t)
    zy <- c(zy, rep(cl, m))
  }
  nn <- FNN::get.knnx(data = ctx$xs, query = Z, k = 1)$nn.index[, 1]
  mean(as.character(ctx$y)[nn] != zy)
}

#' @rdname complexity_measures
#' @export
complexity_LSC <- function(x, y, scale = "minmax") {
  d <- cx_nn_same_other(cx_prepare(x, y, scale))
  Ds <- d$D
  Ds[!d$same] <- Inf
  1 - sum(rowSums(Ds < d$extra)) / nrow(Ds)^2
}

# ---------------------------------------------------------------- R-value

cx_overlap_by_class <- function(ctx, k, theta) {
  nn <- cx_knn(ctx, k)
  n_other <- rowSums(matrix(as.integer(ctx$y)[nn] != as.integer(ctx$y), nrow = ctx$n))
  tapply(n_other > theta, ctx$y, mean)
}

#' @rdname complexity_measures
#' @export
complexity_R <- function(x, y, k = 7, theta = 3, scale = "minmax") {
  ctx <- cx_prepare(x, y, scale)
  R_k <- cx_overlap_by_class(ctx, k, theta)
  n_k <- cx_counts(ctx$y)
  sum(n_k * R_k) / sum(n_k)
}

#' @rdname complexity_measures
#' @export
complexity_R_aug <- function(x, y, k = 7, theta = 3, scale = "minmax") {
  ctx <- cx_prepare(x, y, scale)
  R_k <- cx_overlap_by_class(ctx, k, theta)
  w <- max(cx_counts(ctx$y)) / cx_counts(ctx$y)
  sum(w * R_k) / sum(w)
}

# -------------------------------------------------- types of minority examples

cx_minority_types <- function(x, y, k, scale) {
  ctx <- cx_prepare(x, y, scale)
  n_k <- table(ctx$y)
  is_min <- ctx$y != names(n_k)[which.max(n_k)]
  nn <- cx_knn(ctx, k)
  s <- rowMeans(matrix(as.integer(ctx$y)[nn] == as.integer(ctx$y), nrow = ctx$n))[is_min]
  c(SAFE = mean(s >= 0.8), BORDERLINE = mean(s >= 0.4 & s < 0.8),
    RARE = mean(s > 0 & s < 0.4), OUTLIER = mean(s == 0))
}

#' @rdname complexity_measures
#' @export
complexity_SAFE <- function(x, y, k = 5, scale = "minmax") {
  unname(cx_minority_types(x, y, k, scale)["SAFE"])
}

#' @rdname complexity_measures
#' @export
complexity_BORDERLINE <- function(x, y, k = 5, scale = "minmax") {
  unname(cx_minority_types(x, y, k, scale)["BORDERLINE"])
}

#' @rdname complexity_measures
#' @export
complexity_RARE <- function(x, y, k = 5, scale = "minmax") {
  unname(cx_minority_types(x, y, k, scale)["RARE"])
}

#' @rdname complexity_measures
#' @export
complexity_OUTLIER <- function(x, y, k = 5, scale = "minmax") {
  unname(cx_minority_types(x, y, k, scale)["OUTLIER"])
}
