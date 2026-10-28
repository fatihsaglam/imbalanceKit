#' @title  Uncertainty Guided Oversampling (UGO, 2026)
#'
#' @description UGO (Saglam & Cengiz, 2026) is not a resampling method on its
#' own. It is a classifier-guided procedure that \emph{uses} a base oversampling
#' method (\code{type}) and a classifier: the classifier decides which
#' samples are informative, which class needs more samples and when to stop.
#'
#' @param x feature matrix or dataframe.
#' @param y a factor class variable. Can have more than two classes.
#' @param type base oversampling method used to generate synthetic samples
#' around the selected informative samples. One of \code{"RWO"}, \code{"SMOTE"},
#' \code{"ROS"} or \code{"MCSMOTE"}. Default is \code{"RWO"}.
#' @param classifier classifier used to calculate the uncertainty. One of the
#' built-in classifiers \code{"CART"} (\pkg{rpart}), \code{"RF"}
#' (\pkg{randomForest}), \code{"LogReg"} (logistic regression, one-vs-rest for
#' more than two classes), \code{"KNN"} (\pkg{FNN}), \code{"NaiveBayes"}
#' (Gaussian), \code{"LDA"} or \code{"NNET"} (\pkg{nnet}), or a function
#' \code{function(x_train, y_train, x_test, ...)} that returns a matrix of class
#' probabilities for the rows of \code{x_test}, with one column per level of
#' \code{y_train}. The old names \code{"rpart"} and \code{"randomForest"} are
#' still accepted. UGO is classifier specific, so the classifier that will be
#' used for the final model should be used here. Default is \code{"RF"}.
#' @param comparison test used to compare the average uncertainty of the
#' classes: \code{"anova"} (Welch's one-way test) or \code{"kruskal"}
#' (Kruskal-Wallis). Generation stops when classes are not significantly
#' different.
#' @param prop_generate proportion of the sample size generated at each
#' iteration (\eqn{\lambda_{step}} in the paper). Default is 0.10.
#' @param prop_sampling proportion of the samples of the selected class that
#' are chosen as the most uncertain samples to generate data from
#' (\eqn{\lambda_{select}} in the paper). Default is 0.5.
#' @param k_max number of nearest neighbors for \code{type = "SMOTE"}. Default
#' is 5. If \code{NULL}, \code{ceiling(n / number of selected samples)}.
#' @param k_noise number of neighbors for the initial noise detection
#' (\eqn{k_{g-Pre}} in the paper). Default is 5. If 0, no sample is
#' treated as noise.
#' @param pen_noise multiplier of the threshold of the noise detection. A sample
#' is noise when fewer than \code{k_noise / K * pen_noise} of its neighbors
#' share its class, where \eqn{K} is the number of classes. Default is 1.
#' @param k_after number of neighbors for the detection of noise among the
#' generated samples (\eqn{k_{g-After}} in the paper). Default is 1.
#' @param lambda_max the algorithm stops when the data size exceeds
#' \code{lambda_max * K * n} (\eqn{\phi} in the paper). Default is 2.5.
#' @param alpha significance level of the comparison test used as the stopping
#' criterion. Default is 0.05.
#' @param classifier_args list of additional arguments for the classifier
#' (e.g. \code{list(k = 7)} for \code{"KNN"}).
#' @param generator_args list of additional arguments for the base method
#' \code{type}. Only \code{thresh_qntl}, \code{tol} and \code{max_iter} of
#' \code{\link{MCSMOTE}} are used.
#' @param verbose print the progress. Default is FALSE.
#' @param ... not used.
#'
#' @details
#' \strong{Year: 2026.} UGO (Saglam & Cengiz, 2026) is an iterative oversampling method which uses
#' the uncertainty of a classifier as in active learning. At each iteration,
#' a classifier is trained on the current data and the modified margin
#' uncertainty (the highest probability of the other classes minus the
#' probability of the true class) is calculated for the original samples that
#' are not noise. The class with the highest average uncertainty is selected
#' and \code{prop_generate * n} synthetic samples are generated around its
#' \code{prop_sampling} most uncertain samples with the base method
#' \code{type}. Generated samples that fall in the region of another class are
#' relocated to the nearest selected sample. The algorithm stops when the
#' average uncertainties of the classes are not significantly different, so the
#' number of synthetic samples does not need to be specified. Samples in class
#' overlap regions (noise) are excluded from generation.
#'
#' @return a list with resampled dataset.
#'  \item{x_new}{Resampled feature matrix.}
#'  \item{y_new}{Resampled target variable.}
#'  \item{x_syn}{Generated synthetic feature data.}
#'  \item{y_syn}{Generated synthetic label data.}
#'  \item{i_noise}{Logical vector of samples detected as noise.}
#'  \item{stop_reason}{Why the algorithm stopped: \code{"no_difference"} (the
#'  uncertainties of the classes are not significantly different),
#'  \code{"max_size"}, \code{"too_much_noise"} or \code{"no_uncertainty"}.}
#'  \item{n_iter}{Number of completed generation iterations.}
#'  \item{unc_mean_initial, unc_mean_final}{Average uncertainty of each class
#'  (noise excluded) before the first and at the last iteration.}
#'  \item{unc_rank_mean_initial, unc_rank_mean_final}{Average rank of the
#'  uncertainty of each class before the first and at the last iteration.}
#'
#' @author Fatih Saglam, saglamf89@gmail.com
#'
#' @importFrom  FNN get.knnx
#' @importFrom  stats runif rnorm sd oneway.test kruskal.test
#'
#' @references
#' Saglam, F., & Cengiz, M. A. (2026). Uncertainty guided oversampling: A
#' classifier-specific approach for effective handling of class imbalance in
#' machine learning. Knowledge-Based Systems, 342, 115886.
#'
#' @examples
#'
#' set.seed(1)
#' x <- rbind(matrix(rnorm(600, 3, 1), ncol = 2, nrow = 300),
#'            matrix(rnorm(60, 5, 1), ncol = 2, nrow = 30))
#' y <- as.factor(c(rep("negative", 300), rep("positive", 30)))
#'
#' plot(x, col = y)
#'
#' # resampling
#' if (requireNamespace("randomForest", quietly = TRUE)) {
#'   m <- UGO(x = x, y = y, type = "SMOTE", classifier = "RF")
#'   m$stop_reason
#'
#'   plot(m$x_new, col = m$y_new)
#' }
#'
#' # built-in classifiers that need no extra package
#' m <- UGO(x = x, y = y, type = "SMOTE", classifier = "LDA")
#' m$stop_reason
#'
#' # any classifier that returns class probabilities can be used
#' f_logistic <- function(x_train, y_train, x_test, ...) {
#'   dat <- data.frame(x_train, y = y_train)
#'   model <- glm(y ~ ., data = dat, family = binomial())
#'   p1 <- predict(model, newdata = data.frame(x_test), type = "response")
#'   cbind(1 - p1, p1)
#' }
#' m <- UGO(x = x, y = y, type = "ROS", classifier = f_logistic)
#' table(m$y_new)
#'
#' @rdname UGO
#' @export

UGO <- function(x,
                y,
                type = c("RWO", "SMOTE", "ROS", "MCSMOTE"),
                classifier = "RF",
                comparison = c("anova", "kruskal"),
                prop_generate = 0.10,
                prop_sampling = 0.5,
                k_max = 5,
                k_noise = 5,
                pen_noise = 1,
                k_after = 1,
                lambda_max = 2.5,
                alpha = 0.05,
                classifier_args = list(),
                generator_args = list(),
                verbose = FALSE,
                ...) {
  x <- check_xy(x, y)
  type <- match.arg(type)
  comparison <- match.arg(comparison)
  f_classifier <- get_classifier(classifier)

  if (!is.numeric(prop_generate) || prop_generate <= 0) {
    stop("prop_generate must be positive")
  }
  if (!is.numeric(prop_sampling) || prop_sampling <= 0 || prop_sampling > 1) {
    stop("prop_sampling must be in (0, 1]")
  }
  if (!is.numeric(k_noise) || k_noise < 0) {
    stop("k_noise must be a non-negative number")
  }
  if (!is.numeric(k_after) || k_after < 1) {
    stop("k_after must be a positive number")
  }

  var_names <- colnames(x)
  n <- nrow(x)
  p <- ncol(x)

  class_names <- levels(y)
  k_class <- length(class_names)
  n_classes <- sapply(class_names, function(m) sum(y == m))
  x_classes <- lapply(class_names, function(m) x[y == m, , drop = FALSE])

  if (k_class < 2 || any(n_classes < 2)) {
    stop("y must have at least two classes with at least two samples each")
  }

  # initial noise detection
  if (k_noise == 0) {
    i_noise <- rep(FALSE, n)
  } else {
    NN_all2all <- FNN::get.knnx(data = x,
                                query = x,
                                k = k_noise + 1)$nn.index[, -1, drop = FALSE]
    i_noise <- sapply(1:n, function(m) {
      sum(y[NN_all2all[m, ]] == y[m])
    }) < k_noise / k_class * pen_noise
  }

  i_noise_classes <- lapply(class_names, function(m) i_noise[y == m])
  isAllNoise_classes <- sapply(1:k_class, function(m) {
    sum(i_noise_classes[[m]]) >= (n_classes[m] - 1)
  })
  se_classes <- lapply(1:k_class, function(m) {
    apply(x_classes[[m]], 2, function(v) (sd(v) + 1e-8) / sqrt(n_classes[m]))
  })

  # results are assembled in this function
  finish <- function(x_syn, y_syn, stop_reason, n_iter, unc = NULL) {
    x_new <- rbind(x, x_syn)
    colnames(x_new) <- var_names
    colnames(x_syn) <- var_names
    list(
      x_new = x_new,
      y_new = c(y, y_syn),
      x_syn = x_syn,
      y_syn = y_syn,
      i_noise = i_noise,
      stop_reason = stop_reason,
      n_iter = n_iter,
      unc_mean_initial = unc$means_initial,
      unc_mean_final = unc$means_final,
      unc_rank_mean_initial = unc$rank_means_initial,
      unc_rank_mean_final = unc$rank_means_final
    )
  }

  x_syn <- matrix(NA_real_, nrow = 0, ncol = p)
  y_syn <- factor(c(), levels = class_names, labels = class_names)

  if (any(isAllNoise_classes)) {
    if (verbose) {
      message("too much noise, no samples generated")
    }
    return(finish(x_syn, y_syn, "too_much_noise", 0))
  }

  n_synPerSampling <- ceiling(n * prop_generate - sqrt(.Machine$double.eps))
  n_sampling_classes <- ceiling(n_classes * prop_sampling - sqrt(.Machine$double.eps))

  x_new <- x
  y_new <- y

  counter <- 0
  stop_reason <- "no_difference"
  unc <- list()

  repeat {
    # uncertainty of the original samples under the current classifier
    prob <- do.call(predict_class_probs,
                    c(list(f_classifier = f_classifier,
                           x_train = x_new,
                           y_train = y_new,
                           x_test = x),
                      classifier_args))
    uncTotal <- calculate_uncertainty(prob, y)

    uncTotalClasses <- lapply(class_names, function(m) uncTotal[y == m])
    uncGoodClasses <- lapply(1:k_class, function(m) uncTotalClasses[[m]][!i_noise_classes[[m]]])
    unc_means <- sapply(uncGoodClasses, mean)
    names(unc_means) <- class_names

    tbl <- data.frame(unc = unlist(uncGoodClasses),
                      class = factor(rep(class_names, sapply(uncGoodClasses, length)),
                                     levels = class_names))
    unc_ranks <- rank(tbl$unc)
    unc_rank_means <- sapply(class_names, function(m) mean(unc_ranks[tbl$class == m]))

    if (counter == 0) {
      unc$means_initial <- unc_means
      unc$rank_means_initial <- unc_rank_means
    }
    unc$means_final <- unc_means
    unc$rank_means_final <- unc_rank_means

    # stopping criterion: uncertainties of the classes are not different
    if (comparison == "kruskal") {
      m_comparison <- try(kruskal.test(unc ~ class, tbl), silent = TRUE)
    } else {
      m_comparison <- try(oneway.test(unc ~ class, tbl), silent = TRUE)
    }
    if (!inherits(m_comparison, "try-error")) {
      if (!is.nan(m_comparison$p.value)) {
        if (m_comparison$p.value > alpha) {
          break
        }
      } else if (sum(tbl$unc) == 0) {
        stop_reason <- "no_uncertainty"
        break
      }
    }

    if (comparison == "kruskal") {
      i_classToGenerate <- which.max(unc_rank_means)
    } else {
      i_classToGenerate <- which.max(unc_means)
    }
    class_c <- class_names[i_classToGenerate]

    # most uncertain non-noise samples of the selected class
    i_allGood <- !i_noise_classes[[i_classToGenerate]]
    x_mainGood <- x_classes[[i_classToGenerate]][i_allGood, , drop = FALSE]
    uncGood <- uncTotalClasses[[i_classToGenerate]][i_allGood]
    i_selected <- order(uncGood, decreasing = TRUE)[
      1:min(n_sampling_classes[i_classToGenerate], length(uncGood))]
    x_mainSelectedGood <- x_mainGood[i_selected, , drop = FALSE]
    n_selected <- nrow(x_mainSelectedGood)

    # generation with the generate_* function of the selected type
    x_synStep <- switch(
      type,
      ROS = generate_ROS(x_mainSelectedGood, n_syn = n_synPerSampling)$x_syn,
      RWO = generate_RWO(x_mainSelectedGood, n_syn = n_synPerSampling,
                         se = se_classes[[i_classToGenerate]])$x_syn,
      SMOTE = {
        k_step <- if (is.null(k_max)) ceiling(n / n_selected) else k_max
        if (n_selected < 2) {
          generate_ROS(x_mainSelectedGood, n_syn = n_synPerSampling)$x_syn
        } else {
          generate_SMOTE(x_mainSelectedGood, n_syn = n_synPerSampling,
                         k = k_step)$x_syn
        }
      },
      MCSMOTE = do.call(
        generate_MCSMOTE,
        c(list(x_pos = x_mainSelectedGood, n_syn = n_synPerSampling),
          generator_args[names(generator_args) %in% c("thresh_qntl", "tol", "max_iter")])
      )$x_syn
    )

    # relocation of the generated samples that are noise
    NN_synStep2all <- FNN::get.knnx(data = x,
                                    query = x_synStep,
                                    k = k_after)$nn.index
    n_same <- rowSums(matrix(y[NN_synStep2all] == class_c, nrow = nrow(x_synStep)))
    i_generatedNoise <- n_same <= k_after / 2

    if (any(i_generatedNoise)) {
      NN_synStep2selected <- FNN::get.knnx(
        data = x_mainSelectedGood,
        query = x_synStep[i_generatedNoise, , drop = FALSE],
        k = 1)$nn.index
      x_synStep[i_generatedNoise, ] <- x_mainSelectedGood[NN_synStep2selected, ]
    }

    n_synStep <- nrow(x_synStep)
    x_syn <- rbind(x_syn, x_synStep)
    y_syn <- factor(c(as.character(y_syn), rep(class_c, n_synStep)),
                    levels = class_names, labels = class_names)

    x_new <- rbind(x_new, x_synStep)
    y_new <- factor(c(as.character(y_new), rep(class_c, n_synStep)),
                    levels = class_names, labels = class_names)
    counter <- counter + 1

    if (verbose) {
      cat("\r", "iteration: ", counter, " | n_new = ", nrow(x_new),
          paste0(" | ", class_names, ": ", formatC(unc_means, digits = 3, format = "f")),
          " |   ", sep = "")
    }

    if (nrow(x_new) > lambda_max * k_class * n) {
      stop_reason <- "max_size"
      if (verbose) {
        message("\nmaximum data size reached")
      }
      break
    }
  }

  return(finish(x_syn, y_syn, stop_reason, counter, unc))
}
