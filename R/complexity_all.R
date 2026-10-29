#' @title Calculate Several Complexity Measures
#'
#' @description Calculates the complexity measures of
#' \code{\link{complexity_measures}} in one call.
#'
#' @param x feature matrix or data.frame (numeric).
#' @param y a factor class variable.
#' @param measures character vector with the names of the measures, for example
#' \code{c("IR", "R_aug", "N3")}. The default \code{NULL} calculates all of them
#' (\code{"IR"}, \code{"C1"}, \code{"C2"}, \code{"ID"}, \code{"F1"},
#' \code{"F1v"}, \code{"F2"}, \code{"F3"}, \code{"F4"}, \code{"N1"},
#' \code{"N2"}, \code{"N3"}, \code{"N3_bal"}, \code{"N4"}, \code{"LSC"},
#' \code{"R"}, \code{"R_aug"}, \code{"SAFE"}, \code{"BORDERLINE"},
#' \code{"RARE"}, \code{"OUTLIER"}).
#' @param k_R number of neighbors of \code{R} and \code{R_aug}. Default is 7.
#' @param theta threshold of \code{R} and \code{R_aug}. Default is 3.
#' @param k_type number of neighbors of the types of minority examples. Default
#' is 5.
#' @param scale,seed see \code{\link{complexity_measures}}.
#'
#' @details The distance matrix is calculated once and shared by the measures
#' that need it, so asking for several measures at once is faster than calling
#' them one by one. The measures that use all pairwise distances (\code{N1},
#' \code{N2}, \code{LSC}) need memory of the order of \eqn{n^2}.
#'
#' @return a named numeric vector.
#'
#' @author Fatih Saglam, saglamf89@gmail.com
#'
#' @references see \code{\link{complexity_measures}}.
#'
#' @examples
#' set.seed(1)
#' x <- rbind(matrix(rnorm(400, 3, 1), ncol = 2), matrix(rnorm(40, 4, 1), ncol = 2))
#' y <- factor(rep(c("negative", "positive"), c(200, 20)))
#' complexity(x, y)
#' complexity(x, y, measures = c("IR", "R", "R_aug", "N4"), seed = 1)
#'
#' @export
complexity <- function(x, y, measures = NULL, k_R = 7, theta = 3, k_type = 5,
                       scale = "minmax", seed = NULL) {
  all_measures <- c("IR", "C1", "C2", "ID", "F1", "F1v", "F2", "F3", "F4",
                    "N1", "N2", "N3", "N3_bal", "N4", "LSC", "R", "R_aug",
                    "SAFE", "BORDERLINE", "RARE", "OUTLIER")
  if (is.null(measures)) {
    measures <- all_measures
  }
  unknown <- setdiff(measures, all_measures)
  if (length(unknown) > 0) {
    stop("unknown measures: ", paste(unknown, collapse = ", "),
         ". Available: ", paste(all_measures, collapse = ", "))
  }
  ctx <- cx_prepare(x, y, scale)
  yy <- ctx$y
  types <- NULL
  R_k <- NULL
  value <- function(m) {
    switch(m,
      IR = complexity_IR(y = yy),
      C1 = complexity_C1(y = yy),
      C2 = complexity_C2(y = yy),
      ID = complexity_ID(y = yy),
      F1 = cx_ovo(cx_f1, ctx$x, yy),
      F1v = cx_ovo(cx_f1v, ctx$x, yy),
      F2 = cx_ovo(cx_f2, ctx$x, yy),
      F3 = cx_ovo(cx_f3, ctx$x, yy),
      F4 = cx_ovo(cx_f4, ctx$x, yy),
      N1 = cx_n1(ctx),
      N2 = {
        d <- cx_nn_same_other(ctx)
        intra <- d$intra
        intra[is.infinite(intra)] <- NA
        r <- sum(intra, na.rm = TRUE) / sum(d$extra)
        r / (1 + r)
      },
      N3 = mean(yy[cx_knn(ctx, 1)[, 1]] != yy),
      N3_bal = mean(tapply(yy[cx_knn(ctx, 1)[, 1]] != yy, yy, mean)),
      N4 = complexity_N4(ctx$x, yy, scale = scale, seed = seed),
      LSC = {
        d <- cx_nn_same_other(ctx)
        Ds <- d$D
        Ds[!d$same] <- Inf
        1 - sum(rowSums(Ds < d$extra)) / ctx$n^2
      },
      R = {
        if (is.null(R_k)) R_k <<- cx_overlap_by_class(ctx, k_R, theta)
        n_k <- cx_counts(yy)
        sum(n_k * R_k) / sum(n_k)
      },
      R_aug = {
        if (is.null(R_k)) R_k <<- cx_overlap_by_class(ctx, k_R, theta)
        w <- max(cx_counts(yy)) / cx_counts(yy)
        sum(w * R_k) / sum(w)
      },
      {
        if (is.null(types)) types <<- cx_minority_types(ctx$x, yy, k_type, scale)
        unname(types[m])
      })
  }
  vapply(stats::setNames(measures, measures), value, numeric(1))
}
