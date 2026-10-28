# Random oversampling: n_syn copies of randomly selected samples of x_pos.
generate_ROS <- function(x_pos, x_neg = NULL, n_syn) {
  i_selected <- sample.int(nrow(x_pos), n_syn, replace = TRUE)
  list(x_syn = x_pos[i_selected, , drop = FALSE])
}
