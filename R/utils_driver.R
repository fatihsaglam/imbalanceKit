# Shared driver of the oversamplers. For every class that needs synthetic
# samples it calls
#   generator(x_pos = <class>, x_neg = <all other classes>, n_syn = <number>, ...)
# which returns list(x_syn = <n_syn x p matrix>, <extras>). The driver
# takes care of validation, the number of samples per class (ovRate) and
# of assembling the results.
#
# per_class: named list of vectors with one element per class; element j is
#   passed to the generator of class j.
# extras: names of the additional generator outputs returned per class.
run_oversampler <- function(x, y, generator, ovRate, args = list(),
                            per_class = list(), extras = character()) {
  x <- check_xy(x, y)
  y <- droplevels(y)
  class_names <- levels(y)
  k_class <- length(class_names)
  check_ovRate(ovRate, k_class)

  var_names <- colnames(x)
  p <- ncol(x)
  n_classes <- as.vector(table(y))
  names(n_classes) <- class_names
  n_syn_classes <- n_needed_rule(ovRate, n_classes)
  names(n_syn_classes) <- class_names

  x_syn_list <- vector("list", k_class)
  extra_list <- stats::setNames(
    lapply(extras, function(e) stats::setNames(vector("list", k_class), class_names)),
    extras)

  for (j in seq_len(k_class)) {
    if (n_syn_classes[j] <= 0) {
      next
    }
    is_class <- y == class_names[j]
    args_j <- c(list(x_pos = x[is_class, , drop = FALSE],
                     x_neg = x[!is_class, , drop = FALSE],
                     n_syn = n_syn_classes[j]),
                args,
                lapply(per_class, function(v) v[j]))
    m_syn <- do.call(generator, args_j)
    if (!is.matrix(m_syn$x_syn) || nrow(m_syn$x_syn) != n_syn_classes[j]) {
      stop("internal error: generator returned a wrong number of samples")
    }
    x_syn_list[[j]] <- m_syn$x_syn
    for (e in extras) {
      extra_list[[e]][[j]] <- m_syn[[e]]
    }
  }

  x_syn <- do.call(rbind, x_syn_list)
  if (is.null(x_syn)) {
    x_syn <- empty_syn(p)
  }
  colnames(x_syn) <- var_names
  y_syn <- factor(rep(class_names, times = pmax(n_syn_classes, 0)),
                  levels = class_names)

  c(list(x_new = rbind(x, x_syn),
         y_new = factor(c(as.character(y), as.character(y_syn)), levels = class_names),
         x_syn = x_syn,
         y_syn = y_syn),
    extra_list)
}
