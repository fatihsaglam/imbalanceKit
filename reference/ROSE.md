# Random Over-Sampling Examples (ROSE, 2014)

Generates synthetic data for each class to balance imbalanced datasets
using kernel density estimations. Can be used for multiclass datasets.

## Usage

``` r
ROSE(x, y, h = 1, ovRate = 1)
```

## Arguments

- x:

  feature matrix or data.frame.

- y:

  a factor class variable. Can be multiclass.

- h:

  A numeric vector of length one or number of classes in y. If one is
  given, all classes will have same shrink factor. If a value is given
  for each classes, it will match respectively to `levels(y)`. Default
  is 1.

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

## Details

**Year: 2014.**

Randomly Over Sampling Examples (ROSE) (Menardi and Torelli, 2014) is an
oversampling method which uses conditional kernel densities to balance
dataset. There is already an R package called \`ROSE\` (Lunardon et al.,
2014). Difference is that this one is much faster and can be applied for
more than two classes.

## References

Lunardon, N., Menardi, G., and Torelli, N. (2014). ROSE: a Package for
Binary Imbalanced Learning. R Jorunal, 6:82–92.

Menardi, G. and Torelli, N. (2014). Training and assessing
classification rules with imbalanced data. Data Mining and Knowledge
Discovery, 28:92–122.

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
m <- ROSE(x = x, y = y, h = c(0.12, 1))

plot(m$x_new, col = m$y_new)

```
