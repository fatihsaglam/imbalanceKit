# LEAO: local entropy-adversarial oversampling. A seed sample of the class is
# moved by gradient descent on a potential that is high near the class sample
# and low near a nearby sample of the other classes; the number of samples per
# seed is proportional to its entropy.
generate_LEAO <- function(x_pos, x_neg, n_syn, iters = 50, alpha = 1,
                          prob_type = "bagging", k = 3, stop_prob = 0.3,
                          step_max = 0.10, step_min = NULL, eps = 1e-6,
                          cov_ridge = 1e-8) {
  n_pos <- nrow(x_pos)
  n_neg <- nrow(x_neg)
  p <- ncol(x_pos)
  x <- rbind(x_pos, x_neg)
  is_pos <- c(rep(TRUE, n_pos), rep(FALSE, n_neg))
  if (is.null(step_min)) {
    step_min <- step_max / 10
  }
  k <- min(k, n_neg)

  # Mahalanobis distance with the covariance of all samples
  S <- stats::cov(x) + diag(cov_ridge, p)
  eg <- eigen(S, symmetric = TRUE)
  # (pseudo) inverse through the eigen decomposition
  inv_values <- ifelse(eg$values > max(eg$values) * 1e-12, 1 / eg$values, 0)
  Sinv <- eg$vectors %*% (inv_values * t(eg$vectors))
  dM <- function(v) sqrt(pmax(rowSums((v %*% Sinv) * v), 0))
  # Euclidean coordinates in which distances are Mahalanobis distances
  W <- eg$vectors %*% diag(sqrt(inv_values), p)

  # entropy of the class probability of every sample
  p_hat <- estimate_class_prob(x, is_pos, prob_type)
  entropy <- function(pv) {
    pv <- pmin(pmax(pv, 0), 1)
    -((pv + eps) * log(pv + eps) + (1 - pv + eps) * log(1 - pv + eps))
  }
  H <- entropy(p_hat)
  H_pos <- H[is_pos]
  H_neg <- H[!is_pos]

  w <- if (all(H_pos <= 1e-12)) rep(1, n_pos) else H_pos
  counts <- as.vector(stats::rmultinom(1, size = n_syn, prob = w / sum(w)))
  seed <- rep(seq_len(n_pos), counts)

  nn <- FNN::knnx.index(data = x_neg %*% W, query = x_pos %*% W, k = k)
  i_neg <- nn[cbind(seed, sample.int(k, n_syn, replace = TRUE))]

  x_seed <- x_pos[seed, , drop = FALSE]
  x_opp <- x_neg[i_neg, , drop = FALSE]
  H_s <- H_pos[seed]
  H_o <- H_neg[i_neg]
  eta <- stats::runif(n_syn, step_min, step_max)

  x_cur <- x_seed
  active <- rep(TRUE, n_syn)
  for (t in seq_len(iters)) {
    idx <- which(active)
    if (length(idx) == 0) {
      break
    }
    # probabilistic termination
    stop_now <- stats::runif(length(idx)) < stop_prob
    active[idx[stop_now]] <- FALSE
    idx <- idx[!stop_now]
    if (length(idx) == 0) {
      break
    }
    d_s <- x_cur[idx, , drop = FALSE] - x_seed[idx, , drop = FALSE]
    d_o <- x_cur[idx, , drop = FALSE] - x_opp[idx, , drop = FALSE]
    dm_s <- pmax(dM(d_s), 1e-12)
    dm_o <- pmax(dM(d_o), 1e-12)
    g <- (-alpha * H_s[idx] * exp(-alpha * dm_s) / dm_s) * (d_s %*% Sinv) +
      (alpha * H_o[idx] * exp(-alpha * dm_o) / dm_o) * (d_o %*% Sinv)
    x_cur[idx, ] <- x_cur[idx, , drop = FALSE] - eta[idx] * g
    # stop when the adversarial potential is not positive any more
    L <- H_s[idx] * exp(-alpha * dM(x_cur[idx, , drop = FALSE] - x_seed[idx, , drop = FALSE])) -
      H_o[idx] * exp(-alpha * dM(x_cur[idx, , drop = FALSE] - x_opp[idx, , drop = FALSE]))
    active[idx[L <= 0]] <- FALSE
  }
  list(x_syn = x_cur)
}

# probability of the class of interest for every sample (resubstitution)
estimate_class_prob <- function(x, is_pos, type) {
  type <- match.arg(type, c("bagging", "logistic", "knn", "nb"))
  dat <- data.frame(x)
  colnames(dat) <- paste0("v", seq_len(ncol(x)))
  if (type == "logistic") {
    fit <- suppressWarnings(stats::glm(is_pos ~ ., data = cbind(dat, is_pos = as.integer(is_pos)),
                                       family = stats::binomial()))
    return(suppressWarnings(stats::predict(fit, newdata = dat, type = "response")))
  }
  if (type == "knn") {
    nn <- FNN::get.knn(x, k = min(11, nrow(x) - 1))$nn.index
    return(rowMeans(matrix(is_pos[nn], nrow = nrow(x))))
  }
  if (type == "nb") {
    # Gaussian naive Bayes
    log_post <- vapply(c(TRUE, FALSE), function(cl) {
      xc <- x[is_pos == cl, , drop = FALSE]
      mu <- colMeans(xc)
      s <- col_sd(xc) + 1e-6
      log(nrow(xc) / nrow(x)) +
        rowSums(stats::dnorm(x, rep(mu, each = nrow(x)), rep(s, each = nrow(x)), log = TRUE))
    }, numeric(nrow(x)))
    return(1 / (1 + exp(log_post[, 2] - log_post[, 1])))
  }
  # bagging of classification trees
  y <- factor(as.integer(is_pos), levels = c(0, 1))
  prob <- rowMeans(vapply(seq_len(50), function(b) {
    i_b <- sample.int(nrow(x), replace = TRUE)
    # a bootstrap sample with a single class gives a constant probability
    if (length(unique(y[i_b])) < 2) {
      return(rep(as.numeric(as.character(y[i_b[1]])), nrow(x)))
    }
    fit <- rpart::rpart(y ~ ., data = cbind(dat[i_b, , drop = FALSE], y = y[i_b]), method = "class")
    pr <- stats::predict(fit, newdata = dat, type = "prob")
    if ("1" %in% colnames(pr)) pr[, "1"] else rep(0, nrow(dat))
  }, numeric(nrow(x))))
  prob
}
