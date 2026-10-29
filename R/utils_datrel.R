# Pure and proper class cover (PCCCD) used by DatRel. This is a direct port of
# f_cover_pcccd() of the rcccd package (Saglam), including its tie-breaking:
# the number of points each ball covers is computed once from M, covered
# points are excluded by setting their count to -1, and the first maximum is
# selected at every step.
#
# M: logical/0-1 matrix, M[i, j] = TRUE if the ball of point i covers point j.
# thresh: number of points that has to be covered.
#' @noRd
cover_pcccd <- function(M, thresh) {
  n <- nrow(M)
  M <- M == 1
  covered <- rep(FALSE, n)
  n_covers <- as.numeric(rowSums(M))
  i_dominant <- integer(0)
  while (sum(covered) < thresh) {
    n_covers[covered] <- -1
    i_selected <- which.max(n_covers)
    i_dominant <- c(i_dominant, i_selected)
    covered <- covered | M[i_selected, ]
    covered[i_selected] <- TRUE
  }
  list(i_dominant = i_dominant, cover_proportion = sum(covered) / n)
}

# Euclidean distances between the rows of a and the rows of b
#' @noRd
cross_dist <- function(a, b) {
  a <- as.matrix(a)
  b <- as.matrix(b)
  d2 <- outer(rowSums(a^2), rowSums(b^2), "+") - 2 * tcrossprod(a, b)
  sqrt(pmax(d2, 0))
}

# Dominating points of x_pos and the radii of their balls. The radius of a
# ball is the distance to the nearest sample of the other classes times
# (1 + p_of).
#' @noRd
dominant_balls <- function(x_pos, x_neg, proportion, p_of) {
  n_pos <- nrow(x_pos)
  radii <- c(FNN::get.knnx(data = x_neg, query = x_pos, k = 1)$nn.dist) * (1 + p_of)
  if (n_pos == 1) {
    return(list(i_dominant = 1L, radii = radii, cover_proportion = 1))
  }
  d_pos <- Rfast::Dist(x = x_pos)
  M <- matrix(as.numeric(d_pos < radii), n_pos)
  cover <- cover_pcccd(M, thresh = n_pos * proportion)
  list(i_dominant = cover$i_dominant, radii = radii,
       cover_proportion = cover$cover_proportion)
}

# Relocation: every synthetic sample belongs to the dominant ball with the
# smallest distance/radius ratio. If it lies outside that ball, it is moved
# onto the border of the ball along the line to the dominant point.
#' @noRd
relocate_datrel <- function(x_pos, x_neg, x_syn, proportion = 1, p_of = 0) {
  balls <- dominant_balls(x_pos, x_neg, proportion, p_of)
  i_dom <- balls$i_dominant
  x_dom <- x_pos[i_dom, , drop = FALSE]
  radii_dom <- balls$radii[i_dom]

  n_syn <- nrow(x_syn)
  x_relocated <- x_syn
  n_relocated <- 0L
  if (n_syn > 0) {
    ratio <- cross_dist(x_dom, x_syn) / radii_dom   # n_dominant x n_syn
    ratio[is.nan(ratio)] <- 0                        # zero distance, zero radius
    belong <- max.col(-t(ratio), ties.method = "first")
    ratio_b <- ratio[cbind(belong, seq_len(n_syn))]
    out <- which(ratio_b > 1)
    if (length(out) > 0) {
      anchor <- x_dom[belong[out], , drop = FALSE]
      x_relocated[out, ] <- anchor + (x_syn[out, , drop = FALSE] - anchor) / ratio_b[out]
      n_relocated <- length(out)
    }
  }
  list(x_syn = x_relocated,
       i_dominant = i_dom,
       x_dominant = x_dom,
       radii_dominant = radii_dom,
       cover_proportion = balls$cover_proportion,
       n_relocated = n_relocated)
}

# Generator of the base methods by name
#' @noRd
get_generator <- function(method) {
  generators <- list(
    ROS = generate_ROS, RWO = generate_RWO, ROSE = generate_ROSE,
    SMOTE = generate_SMOTE, ADASYN = generate_ADASYN,
    BLSMOTE = generate_BLSMOTE, SLSMOTE = generate_SLSMOTE, RadiusSMOTE = generate_RadiusSMOTE, VSSMOTE = generate_VSSMOTE,
    RSLSMOTE = generate_RSLSMOTE, GSMOTE = generate_GSMOTE,
    SMOTEWB = generate_SMOTEWB, BiSMOTE = generate_BiSMOTE,
    MCSMOTE = generate_MCSMOTE, EBSMOTE = generate_EBSMOTE,
    GQEO = generate_GQEO, LEAO = generate_LEAO, SyMProD = generate_SyMProD)
  if (!is.character(method) || length(method) != 1 || !(method %in% names(generators))) {
    stop("method must be one of ", paste0("\"", names(generators), "\"", collapse = ", "))
  }
  generators[[method]]
}

generate_DatRel <- function(x_pos, x_neg, n_syn, method = "SMOTE",
                            proportion = 1, p_of = 0, method_args = list()) {
  f_generate <- get_generator(method)
  m <- do.call(f_generate, c(list(x_pos = x_pos, x_neg = x_neg, n_syn = n_syn), method_args))
  relocate_datrel(x_pos, x_neg, m$x_syn, proportion = proportion, p_of = p_of)
}
