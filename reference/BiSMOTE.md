# Bi-directional SMOTE (BiSMOTE, 2027)

Resampling with bi-directional SMOTE.

## Usage

``` r
BiSMOTE(x, y, k = 5, ovRate = 1, ...)
```

## Arguments

- x:

  feature matrix or dataframe.

- y:

  a factor class variable. Can have more than two classes.

- k:

  number of nearest neighbors within the class that define the
  interpolation directions. Default is 5. Reduced automatically for
  classes with fewer than `k + 1` samples.

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

**Year: 2027.**

BiSMOTE (Saglam & Yamak, 2027) is a geometrically constrained
oversampling method. For each synthetic sample, a center sample and one
of its `k` nearest neighbors from the same class are selected. Unlike
SMOTE, which places the new sample between the two, BiSMOTE interpolates
*bi-directionally* along the line through them. The interpolation
coefficient is drawn uniformly so that the synthetic sample stays within
the distance from the center sample to its nearest sample of another
class. In this way, generation is restricted to a locally bounded region
and does not cross towards other classes, which reduces class overlap
and synthetic noise.

Can work with classes more than 2.

## References

Saglam, F., & Yamak, U. (2027). Bi-SMOTE: bi-directional oversampling
for reducing class overlap and synthetic noise. Expert Systems with
Applications, 334, 134648.

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
m <- BiSMOTE(x = x, y = y, k = 5)

plot(m$x_new, col = m$y_new)

```
