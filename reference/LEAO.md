# Local Entropy-Adversarial Oversampling (LEAO, 2025)

Resampling with LEAO.

## Usage

``` r
LEAO(
  x,
  y,
  iters = 50,
  alpha = 1,
  prob_type = c("bagging", "logistic", "knn", "nb"),
  k = 3,
  stop_prob = 0.3,
  step_max = 0.1,
  step_min = NULL,
  eps = 1e-06,
  cov_ridge = 1e-08,
  ovRate = 1,
  ...
)
```

## Arguments

- x:

  feature matrix or dataframe.

- y:

  a factor class variable. Can have more than two classes.

- iters:

  maximum number of gradient steps per synthetic sample. Default is 50.

- alpha:

  decay of the potential. Default is 1.

- prob_type:

  how the class probabilities, which give the entropies, are estimated:
  `"bagging"` (classification trees, default), `"logistic"`, `"knn"` or
  `"nb"` (Gaussian naive Bayes).

- k:

  number of nearest samples of the other classes (Mahalanobis distance)
  from which one is chosen. Default is 3.

- stop_prob:

  probability to stop at each step. Default is 0.3.

- step_max, step_min:

  range of the random step size. `step_min` is `step_max / 10` if
  `NULL`.

- eps:

  numerical constant of the entropy. Default is 1e-6.

- cov_ridge:

  value added to the diagonal of the covariance matrix. Default is 1e-8.

- ovRate:

  Oversampling rate. Class \\j\\ receives
  `round(ovRate * (n_max - n_j))` synthetic samples, where `n_max` is
  the size of the largest class (halves are rounded up). Default is 1
  meaning full balance. A vector with one value per class is also
  accepted.

- ...:

  not used.

## Value

a list with resampled dataset.

- x_new:

  Resampled feature matrix.

- y_new:

  Resampled target variable.

- x_syn:

  Generated synthetic feature data.

- y_syn:

  Generated synthetic label data.

## Details

**Year: 2025.**

Seeds are drawn with probabilities proportional to the entropy of their
class probability. Each synthetic sample starts at its seed and moves by
gradient descent on a potential that is high near the seed and low near
a nearby sample of the other classes, until it is not positive, the
maximum number of steps is reached or the random stop happens.

The method is defined for two classes. With more than two classes every
class is oversampled against the union of the other classes
(one-versus-rest).

## References

Tao, L. (2025). Local entropy-adversarial oversampling for imbalanced
datasets. Neurocomputing, 131959.

## Author

Fatih Saglam, saglamf89@gmail.com

## Examples

``` r

set.seed(1)
x <- rbind(matrix(rnorm(600, 3, 1), ncol = 2),
           matrix(rnorm(60, 5, 1), ncol = 2))
y <- as.factor(c(rep("negative", 300), rep("positive", 30)))

m <- LEAO(x = x, y = y)
table(m$y_new)
#> 
#> negative positive 
#>      300      300 
```
