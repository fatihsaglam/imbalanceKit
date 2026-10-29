# Adaptive Synthetic Sampling (ADASYN, 2008)

Generates synthetic data for minority class to balance imbalanced
datasets using ADASYN.

## Usage

``` r
ADASYN(x, y, k = 5, ovRate = 1)
```

## Arguments

- x:

  feature matrix or data.frame.

- y:

  a factor class variable. Can have more than two classes.

- k:

  number of neighbors. Default is 5.

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

  Generated synthetic data.

- C:

  Number of synthetic samples for each positive class samples.

## Details

**Year: 2008.**

Adaptive Synthetic Sampling (ADASYN) is an extension of the Synthetic
Minority Over-sampling Technique (SMOTE) algorithm, which is used to
generate synthetic examples for the minority class (He et al., 2008). In
contrast to SMOTE, ADASYN adaptively generates synthetic examples by
focusing on the minority class examples that are harder to learn,
meaning those examples that are closer to the decision boundary.

Can work with classes more than 2.

## References

He, H., Bai, Y., Garcia, E. A., & Li, S. (2008, June). ADASYN: Adaptive
synthetic sampling approach for imbalanced learning. In 2008 IEEE
international joint conference on neural networks (IEEE world congress
on computational intelligence) (pp. 1322-1328). IEEE.

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
m <- ADASYN(x = x, y = y, k = 3)

plot(m$x_new, col = m$y_new)

```
