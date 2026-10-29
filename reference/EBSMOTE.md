# Evaluation-Based SMOTE (EBSMOTE, 2019)

Resampling with EBSMOTE.

## Usage

``` r
EBSMOTE(
  x,
  y,
  m_alpha = 5,
  m_beta = 5,
  lambda = 3,
  v_alpha = 5,
  w_alpha = 5,
  expand_alpha = 0.3,
  ovRate = 1,
  ...
)
```

## Arguments

- x:

  feature matrix or dataframe.

- y:

  a factor class variable. Can have more than two classes.

- m_alpha, m_beta:

  number of nearest neighbours that decide whether a sample of the class
  (`m_alpha`) or of the other classes (`m_beta`) is on the border.
  Default is 5.

- lambda:

  a sample is on the border if at least `m / lambda` but not all of its
  `m` nearest neighbours are from the other side. Default is 3.

- v_alpha:

  number of the nearest borderline samples of the other side from which
  one is selected. Default is 5.

- w_alpha:

  number of the nearest borderline samples of the class, around the
  selected other side sample, from which one is selected. Default is 5.

- expand_alpha:

  weight of the other side sample in the generated sample, in \\\[0,
  1)\\. Default is 0.3.

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

**Year: 2019.**

A borderline sample of the class, a nearby borderline sample of the
other classes and a borderline sample of the class near that one are
combined: the generated sample is \\(1 - \alpha)(\phi p_i + (1 - \phi)
p_k) + \alpha t_j\\ with a uniform \\\phi\\. If no borderline samples
exist, random oversampling is used with a warning.

The method is defined for two classes. With more than two classes every
class is oversampled against the union of the other classes
(one-versus-rest).

## References

Hussein, A. S., Diallo, B., & Liu, J. (2019). EBSMOTE: Evaluation-based
synthetic minority oversampling technique for imbalanced dataset
learning. In 2019 IEEE 14th International Conference on Intelligent
Systems and Knowledge Engineering (ISKE) (pp. 1226-1233). IEEE.

## Author

Fatih Saglam, saglamf89@gmail.com

## Examples

``` r

set.seed(1)
x <- rbind(matrix(rnorm(600, 3, 1), ncol = 2),
           matrix(rnorm(60, 5, 1), ncol = 2))
y <- as.factor(c(rep("negative", 300), rep("positive", 30)))

m <- EBSMOTE(x = x, y = y)
table(m$y_new)
#> 
#> negative positive 
#>      300      300 
```
