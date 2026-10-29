# Random Walk Oversampling (RWO, 2014)

Resampling with RWO

## Usage

``` r
RWO(x, y, ovRate = 1)
```

## Arguments

- x:

  feature matrix.

- y:

  a factor class variable. Can have more than two classes.

- ovRate:

  Oversampling rate. Class \\j\\ receives
  `round(ovRate * (n_max - n_j))` synthetic samples, where `n_max` is
  the size of the largest class (halves are rounded up). Default is 1
  meaning full balance. A vector with one value per class is also
  accepted.

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

**Year: 2014.**

RWO (Zhang and Li, 2014) is an oversampling method which generates data
using variable standard error in a way that it preserves the variances
of all variables.

Can work with classes more than 2.

## References

Zhang, H., & Li, M. (2014). RWO-Sampling: A random walk over-sampling
approach to imbalanced data classification. Information Fusion, 20,
99-116.

## Author

Fatih Saglam, saglamf89@gmail.com

## Examples

``` r

set.seed(1)
x <- rbind(matrix(rnorm(2000, 3, 1), ncol = 2, nrow = 1000),
           matrix(rnorm(100, 5, 1), ncol = 2, nrow = 50))
y <- as.factor(c(rep("negative", 1000), rep("positive", 50)))

plot(x, col = y)


# resampling
m <- RWO(x = x, y = y)

plot(m$x_new, col = m$y_new)

```
