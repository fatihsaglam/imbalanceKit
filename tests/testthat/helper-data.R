make_imbalanced <- function(seed = 1, n_neg = 200, n_pos = 20) {
  set.seed(seed)
  x <- rbind(matrix(rnorm(n_neg * 2, 3, 1), ncol = 2),
             matrix(rnorm(n_pos * 2, 5, 1), ncol = 2))
  colnames(x) <- c("x1", "x2")
  y <- factor(c(rep("negative", n_neg), rep("positive", n_pos)),
              levels = c("negative", "positive"))
  list(x = x, y = y)
}
