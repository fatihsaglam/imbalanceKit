# SMOTE with boosting: boosting weights separate noisy samples; the number of
# nearest neighbours used for a sample stops at the first other class sample.
generate_SMOTEWB <- function(x_pos, x_neg, n_syn, k_max = NULL,
                             n_weak_classifier = 100, class_weights = NULL) {
  n_pos <- nrow(x_pos)
  n_neg <- nrow(x_neg)
  n <- n_pos + n_neg
  x <- rbind(x_pos, x_neg)
  y <- factor(c(rep("pos", n_pos), rep("neg", n_neg)), levels = c("pos", "neg"))
  imb_ratio <- n_neg / n_pos

  w <- boosted_weights(x = x, y = y, n_iter = n_weak_classifier)
  w_pos <- w[y == "pos"]
  w_neg <- w[y == "neg"]

  if (is.null(class_weights)) {
    wclass_pos <- n / n_pos * 0.5
    wclass_neg <- n / n_neg * 0.5
  } else {
    wclass_pos <- class_weights[1]
    wclass_neg <- class_weights[2]
  }
  T_pos <- wclass_pos / n
  T_neg <- wclass_neg / n
  scl <- T_pos * n_pos + T_neg * n_neg
  T_pos <- T_pos / scl
  T_neg <- T_neg / scl

  is_noise_pos <- w_pos > T_pos
  is_noise_neg <- w_neg > T_neg

  x_notnoise <- rbind(x_pos[!is_noise_pos, , drop = FALSE],
                      x_neg[!is_noise_neg, , drop = FALSE])
  is_pos_notnoise <- c(rep(TRUE, sum(!is_noise_pos)), rep(FALSE, sum(!is_noise_neg)))

  if (is.null(k_max)) {
    k_max <- ceiling(imb_ratio)
  }
  k_max <- min(k_max, nrow(x_notnoise) - 1)
  if (k_max < 1) {
    return(list(x_syn = generate_fallback_ros(
      x_pos, n_syn, "Too few samples remain after noise removal."),
      w = w, k = rep(0, n_pos), C = rep(NA_integer_, n_pos),
      fl = rep("lonely", n_pos)))
  }

  # neighbours among the non-noise samples; a non-noise query finds itself first
  NN_all <- FNN::knnx.index(data = x_notnoise, query = x_pos, k = k_max + 1)
  NN <- NN_all[, -1, drop = FALSE]
  if (any(is_noise_pos)) {
    NN[is_noise_pos, ] <- NN_all[is_noise_pos, -(k_max + 1), drop = FALSE]
  }

  # number of neighbours before the first other class sample
  is_other <- !matrix(is_pos_notnoise[NN], nrow = n_pos)
  has_other <- rowSums(is_other) > 0
  k <- ifelse(has_other, max.col(is_other, ties.method = "first") - 1, k_max)
  fl <- ifelse(k > 0, "good", ifelse(is_noise_pos, "bad", "lonely"))

  i_candidate <- which(fl != "bad")
  if (length(i_candidate) == 0) {
    warning("All samples of the class are noise; all samples are used.", call. = FALSE)
    fl[] <- "lonely"
    i_candidate <- seq_len(n_pos)
  }
  C <- integer(n_pos)
  C[i_candidate] <- even_counts(n_syn, length(i_candidate))

  i_center <- rep(seq_len(n_pos), C)
  x_center <- x_pos[i_center, , drop = FALSE]
  is_good <- fl[i_center] == "good"
  x_syn <- x_center
  if (any(is_good)) {
    ig <- which(is_good)
    # random one of the first k[i] neighbours
    i_pick <- floor(stats::runif(length(ig)) * k[i_center[ig]]) + 1
    x_target <- x_notnoise[NN[cbind(i_center[ig], i_pick)], , drop = FALSE]
    x_syn[ig, ] <- x_center[ig, , drop = FALSE] +
      stats::runif(length(ig)) * (x_target - x_center[ig, , drop = FALSE])
  }
  list(x_syn = x_syn, w = w, k = k, C = C, fl = fl)
}
