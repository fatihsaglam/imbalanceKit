# Synthetic Minority Based on Probabilistic Distribution (SyMProD, 2020)

Resampling with SyMProD.

## Usage

``` r
SyMProD(x, y, NT = 3, CT = 0, K = 5, M = 5, ovRate = 1, ...)
```

## Arguments

- x:

  feature matrix or dataframe.

- y:

  a factor class variable. Can have more than two classes.

- NT:

  z-score threshold of the noise removal. Samples with an absolute
  z-score above `NT` in any feature are removed from the calculations.
  Default is 3.

- CT:

  threshold of the selection: a sample is used if its density in the
  class is larger than `CT` times its density of the other classes.
  Default is 0.

- K:

  number of neighbours of the density calculation. Default is 5.

- M:

  number of neighbours that are combined with the selected base sample.
  Default is 5.

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

**Year: 2020.**

After noise removal, each sample of the class gets a closeness factor
and a density from its neighbours in the class and in the other classes.
Base samples are selected with probabilities proportional to their
density ratio and replaced by a random convex combination of the base
sample and its `M` nearest neighbours. If too few samples remain, random
oversampling is used with a warning.

The method is defined for two classes. With more than two classes every
class is oversampled against the union of the other classes
(one-versus-rest).

## References

Kunakorntum, I., Hinthong, W., & Phunchongharn, P. (2020). A synthetic
minority based on probabilistic distribution (SyMProD) oversampling for
imbalanced datasets. IEEE Access, 8, 114692-114704.

## Author

Fatih Saglam, saglamf89@gmail.com

## Examples

``` r

set.seed(1)
x <- rbind(matrix(rnorm(600, 3, 1), ncol = 2),
           matrix(rnorm(60, 5, 1), ncol = 2))
y <- as.factor(c(rep("negative", 300), rep("positive", 30)))

m <- SyMProD(x = x, y = y)
table(m$y_new)
#> 
#> negative positive 
#>      300      300 
```
