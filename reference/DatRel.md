# Data Relocation (DatRel, 2025)

DatRel (Saglam, 2025) is a post-processing method for synthetic samples.
Synthetic samples that fall outside the region covered by their class
are moved back into it. The synthetic samples can come from any
oversampling method; `DatRel` only needs the original data and the
synthetic data.

## Usage

``` r
DatRel(x, y, x_syn, y_syn, proportion = 1, p_of = 0)
```

## Arguments

- x:

  feature matrix of the original data.

- y:

  a factor class variable of the original data. Can have more than two
  classes.

- x_syn:

  feature matrix of the synthetic samples.

- y_syn:

  factor (or vector) with the class of each synthetic sample. Every
  class is relocated against the union of the other classes
  (one-versus-rest), so any number of classes is allowed.

- proportion:

  proportion of the samples of a class that has to be covered by the
  dominating balls. Default is 1 (all samples).

- p_of:

  overflow proportion: the radii of the balls are multiplied by
  `1 + p_of`, so the synthetic samples may stay slightly outside of the
  class region. Default is 0.

## Value

a list with

- x_new:

  Original data followed by the relocated synthetic samples.

- y_new:

  Class variable of `x_new`.

- x_syn:

  Relocated synthetic samples, in the order of the input.

- y_syn:

  Classes of the synthetic samples.

- i_dominant, x_dominant, radii_dominant, cover_proportion, n_relocated:

  Lists with one element per class that has synthetic samples: indices
  and coordinates of the dominating samples, radii of their balls,
  proportion of the class covered, and the number of relocated samples.

## Details

**Year: 2025.** For every class a ball is placed around each sample
whose radius is the distance to the nearest sample of the other classes
(times `1 + p_of`), so that the ball contains no sample of another
class. A small set of dominating samples whose balls cover the class
(pure and proper class cover catch digraph, PCCCD) is selected greedily;
the cover algorithm is the one of the rcccd package. Each synthetic
sample is assigned to the dominating ball of its class with the smallest
ratio of distance to radius. If it is outside that ball, it is moved
onto the border of the ball along the line to the dominating sample.

## References

Saglam, F. (2025). DatRel: a noise-tolerant data relocation approach for
effective synthetic data generation in imbalanced classifiers. Machine
Learning. doi:10.1007/s10994-025-06755-8

## Author

Fatih Saglam, saglamf89@gmail.com

## Examples

``` r
set.seed(1)
x <- rbind(matrix(rnorm(400, 3, 1), ncol = 2), matrix(rnorm(40, 5, 1), ncol = 2))
y <- factor(rep(c("negative", "positive"), c(200, 20)))

m0 <- SMOTE(x, y)                       # any method, or your own samples
m <- DatRel(x, y, m0$x_syn, m0$y_syn)
m$n_relocated
#> $positive
#> [1] 27
#> 
```
