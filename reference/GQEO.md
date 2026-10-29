# Quadrilateral Element Oversampling (GQEO, 2025)

Resampling with GQEO.

## Usage

``` r
GQEO(x, y, k = 5, check_planarity = TRUE, ovRate = 1, ...)
```

## Arguments

- x:

  feature matrix or dataframe.

- y:

  a factor class variable. Can have more than two classes.

- k:

  number of nearest neighbours from which the corners of the
  quadrilaterals are chosen (at least 3). Default is 5.

- check_planarity:

  if `TRUE`, quadrilaterals whose edges violate the polygon inequality
  are removed. Default is `TRUE`.

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

Synthetic samples are generated inside quadrilaterals made of a sample
and three of its `k` nearest neighbours of the same class, by bilinear
interpolation of the four corners. Classes that are too small to form a
quadrilateral are oversampled randomly with a warning.

## References

Dai, Q., Wang, L., Zhang, J., Ding, W., & Chen, L. (2025). GQEO: Nearest
neighbor graph-based generalized quadrilateral element oversampling for
class-imbalance problem. Neural Networks, 184, 107107.

## Author

Fatih Saglam, saglamf89@gmail.com

## Examples

``` r

set.seed(1)
x <- rbind(matrix(rnorm(600, 3, 1), ncol = 2),
           matrix(rnorm(60, 5, 1), ncol = 2))
y <- as.factor(c(rep("negative", 300), rep("positive", 30)))

m <- GQEO(x = x, y = y)
table(m$y_new)
#> 
#> negative positive 
#>      300      300 
```
