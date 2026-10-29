# Radius-SMOTE (RadiusSMOTE, 2021)

Resampling with RadiusSMOTE.

## Usage

``` r
RadiusSMOTE(x, y, k = 5, ovRate = 1, ...)
```

## Arguments

- x:

  feature matrix or data.frame.

- y:

  a factor class variable. Can have more than two classes.

- k:

  number of neighbors used to decide whether a sample is safe (a sample
  is safe when more than `k / 2` of its `k` nearest neighbors in the
  whole data are from its own class). Default is 5.

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

**Year: 2021.** Samples of the class that are safe are used as centers.
Synthetic samples are generated on the line between a center and its
nearest sample of the other classes, either towards it or in the
opposite direction, at a random distance of at most the distance to that
sample (the safe radius), so they do not reach the other classes. If no
sample is safe, all samples are used with a warning.

Can work with classes more than 2: every class is oversampled against
the union of the other classes (one-versus-rest).

## References

Pradipta, G. A., Wardoyo, R., Musdholifah, A., & Sanjaya, I. N. H.
(2021). Radius-SMOTE: a new oversampling technique of minority samples
based on radius distance for learning from imbalanced data. IEEE Access,
9, 74763-74777.

## Author

Fatih Saglam, saglamf89@gmail.com

## Examples

``` r

set.seed(1)
x <- rbind(matrix(rnorm(2000, 3, 1), ncol = 2, nrow = 1000),
           matrix(rnorm(100, 5, 1), ncol = 2, nrow = 50))
y <- as.factor(c(rep("negative", 1000), rep("positive", 50)))

m <- RadiusSMOTE(x = x, y = y, k = 5)
table(m$y_new)
#> 
#> negative positive 
#>     1000     1000 
plot(m$x_new, col = m$y_new)

```
