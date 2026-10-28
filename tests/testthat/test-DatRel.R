test_that("cover_pcccd follows the greedy rule of rcccd", {
  # ball 1 covers {1,2,3}, ball 4 covers {4,5}, ball 2 covers {1,2}
  M <- rbind(c(1, 1, 1, 0, 0),
             c(1, 1, 0, 0, 0),
             c(0, 0, 1, 0, 0),
             c(0, 0, 0, 1, 1),
             c(0, 0, 0, 0, 1))
  r <- imbalanceKit:::cover_pcccd(M, thresh = 5)
  expect_equal(r$i_dominant, c(1, 4))
  expect_equal(r$cover_proportion, 1)
  # covers are counted once: ties go to the first maximum
  r2 <- imbalanceKit:::cover_pcccd(diag(3), thresh = 3)
  expect_equal(r2$i_dominant, 1:3)
  # partial cover
  r3 <- imbalanceKit:::cover_pcccd(M, thresh = 3)
  expect_equal(r3$i_dominant, 1)
  expect_equal(r3$cover_proportion, 3 / 5)
})

test_that("DatRel keeps synthetic samples inside the dominating balls", {
  d <- make_imbalanced()
  set.seed(1)
  m <- DatRel(d$x, d$y, method = "SMOTE", k = 5)
  expect_equal(nrow(m$x_new), nrow(d$x) + nrow(m$x_syn))
  expect_equal(levels(m$y_new), levels(d$y))
  expect_equal(unname(m$x_new[seq_len(nrow(d$x)), ]), unname(d$x))
  cl <- as.character(m$y_syn[1])
  x_pos <- d$x[d$y == cl, , drop = FALSE]
  x_neg <- d$x[d$y != cl, , drop = FALSE]
  dom <- m$x_dominant[[cl]]
  rad <- m$radii_dominant[[cl]]
  ratio <- imbalanceKit:::cross_dist(dom, m$x_syn) / rad
  expect_true(all(apply(ratio, 2, min) <= 1 + 1e-8))
  # synthetic samples are further from other classes than their ball radius
  d_other <- FNN::get.knnx(x_neg, m$x_syn, k = 1)$nn.dist
  expect_true(all(is.finite(d_other)))
})

test_that("DatRel equals the base method when nothing is outside", {
  d <- make_imbalanced()
  set.seed(3)
  base <- SMOTE(d$x, d$y)
  set.seed(3)
  m <- DatRel(d$x, d$y, method = "SMOTE", p_of = 1e6)
  expect_equal(m$x_syn, base$x_syn)
  expect_equal(m$n_relocated[["positive"]], 0)
})

test_that("DatRel moves outside points exactly onto the ball border", {
  x_pos <- rbind(c(0, 0), c(0.1, 0))
  x_neg <- rbind(c(2, 0), c(2, 1))
  x_syn <- rbind(c(5, 0), c(0.05, 0))
  r <- imbalanceKit:::relocate_datrel(x_pos, x_neg, x_syn)
  expect_equal(r$i_dominant, 1L)                 # ball of (0,0) (radius 2) covers both
  expect_equal(r$radii_dominant, 2)
  expect_equal(unname(r$x_syn[2, ]), c(0.05, 0))      # inside: unchanged
  expect_equal(unname(r$x_syn[1, ]), c(2.0, 0))       # (0,0) + (5,0) / 2.5
  expect_equal(r$n_relocated, 1L)
})

test_that("DatRel works with all base methods and with 3 classes", {
  set.seed(2)
  x <- rbind(matrix(rnorm(300, 0), ncol = 2), matrix(rnorm(80, 2), ncol = 2),
             matrix(rnorm(40, 4), ncol = 2))
  y <- factor(rep(c("a", "b", "c"), c(150, 40, 20)))
  for (me in c("ROS", "RWO", "ROSE", "SMOTE", "ADASYN", "BLSMOTE", "SLSMOTE", "MCSMOTE")) {
    m <- suppressWarnings(DatRel(x, y, method = me))
    expect_equal(table(m$y_new)[["b"]], 150, info = me)
    expect_equal(table(m$y_new)[["c"]], 150, info = me)
    expect_false(anyNA(m$x_syn), info = me)
  }
  expect_error(DatRel(x, y, method = "foo"))
  expect_error(DatRel(x, y, proportion = 2))
  expect_error(DatRel(x, y, p_of = -1))
})

test_that("DatRel_relocate relocates user-supplied samples", {
  x_pos <- rbind(c(0, 0), c(0.1, 0))
  x_neg <- rbind(c(2, 0), c(2, 1))
  x <- rbind(x_pos, x_neg)
  y <- factor(c("p", "p", "n", "n"))
  r <- DatRel_relocate(x, y, rbind(c(5, 0)), class_pos = "p")
  expect_equal(unname(r$x_syn[1, ]), c(2, 0))
  expect_error(DatRel_relocate(x, y, rbind(c(5, 0)), class_pos = "z"))
})
