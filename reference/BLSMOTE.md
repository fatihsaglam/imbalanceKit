# Borderline-SMOTE (BLSMOTE, 2005)

`BLSMOTE()` applies BLSMOTE (Borderline-SMOTE) which is a variation of
the SMOTE algorithm that generates synthetic samples only in the
vicinity of the borderline instances in imbalanced datasets.

## Usage

``` r
BLSMOTE(x, y, k1 = 5, k2 = 5, type = c("type1", "type2"), ovRate = 1)
```

## Arguments

- x:

  feature matrix or data.frame.

- y:

  a factor class variable. Can have more than two classes.

- k1:

  number of neighbors to link. Default is 5.

- k2:

  number of neighbors to determine safe levels. Default is 5.

- type:

  "type1" or "type2". Default is "type1".

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

## Details

**Year: 2005.**

BLSMOTE works by focusing on the instances that are near the decision
boundary between the minority and majority classes, known as borderline
instances. These instances are more informative and potentially more
challenging for classification, and thus generating synthetic samples in
their vicinity can be more effective than generating them randomly.

Can work with classes more than 2.

## References

Han, H., Wang, W. Y., & Mao, B. H. (2005). Borderline-SMOTE: a new
over-sampling method in imbalanced data sets learning. In Advances in
Intelligent Computing: International Conference on Intelligent
Computing, ICIC 2005, Hefei, China, August 23-26, 2005, Proceedings,
Part I 1 (pp. 878-887). Springer Berlin Heidelberg.

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
m <- BLSMOTE(x = x, y = y, k1 = 5, k2 = 5)

plot(m$x_new, col = m$y_new)

```
