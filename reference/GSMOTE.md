# Geometric SMOTE (GSMOTE, 2019)

Resampling with GSMOTE.

## Usage

``` r
GSMOTE(
  x,
  y,
  k = 5,
  alpha_sel = c("combined", "minority", "majority"),
  alpha_trunc = 0.5,
  alpha_def = 0.5,
  ovRate = 1
)
```

## Arguments

- x:

  feature matrix.

- y:

  a factor class variable. Can have more than two classes.

- k:

  number of neighbors. Default is 5.

- alpha_sel:

  selection method. Can be "minority", "majority" or "combined". Default
  is "combined".

- alpha_trunc:

  truncation factor. A numeric value in \\\[-1,1\]\\. Default is 0.5.

- alpha_def:

  deformation factor. A numeric value in \\\[0,1\]\\. Default is 0.5

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

- C:

  List with one element per class: the number of synthetic samples
  generated from each sample of that class.

## Details

**Year: 2019.**

GSMOTE (Douzas & Bacao, 2019) is an oversampling method which creates
synthetic samples geometrically around selected minority samples.
Details are in the paper (Douzas & Bacao, 2019).

Can work with classes more than 2.

## References

Douzas, G., & Bacao, F. (2019). Geometric SMOTE a geometrically enhanced
drop-in replacement for SMOTE. Information sciences, 501, 118-135.

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
m <- GSMOTE(x = x, y = y, k = 7)

plot(m$x_new, col = m$y_new)

```
