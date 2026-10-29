# Calculate Several Complexity Measures

Calculates the complexity measures of
[`complexity_measures`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
in one call.

## Usage

``` r
complexity(
  x,
  y,
  measures = NULL,
  k_R = 7,
  theta = 3,
  k_type = 5,
  scale = "minmax",
  seed = NULL
)
```

## Arguments

- x:

  feature matrix or data.frame (numeric).

- y:

  a factor class variable.

- measures:

  character vector with the names of the measures, for example
  `c("IR", "R_aug", "N3")`. The default `NULL` calculates all of them
  (`"IR"`, `"C1"`, `"C2"`, `"ID"`, `"F1"`, `"F1v"`, `"F2"`, `"F3"`,
  `"F4"`, `"N1"`, `"N2"`, `"N3"`, `"N3_bal"`, `"N4"`, `"LSC"`, `"R"`,
  `"R_aug"`, `"SAFE"`, `"BORDERLINE"`, `"RARE"`, `"OUTLIER"`).

- k_R:

  number of neighbors of `R` and `R_aug`. Default is 7.

- theta:

  threshold of `R` and `R_aug`. Default is 3.

- k_type:

  number of neighbors of the types of minority examples. Default is 5.

- scale, seed:

  see
  [`complexity_measures`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md).

## Value

a named numeric vector.

## Details

The distance matrix is calculated once and shared by the measures that
need it, so asking for several measures at once is faster than calling
them one by one. The measures that use all pairwise distances (`N1`,
`N2`, `LSC`) need memory of the order of \\n^2\\.

## References

see
[`complexity_measures`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md).

## Author

Fatih Saglam, saglamf89@gmail.com

## Examples

``` r
set.seed(1)
x <- rbind(matrix(rnorm(400, 3, 1), ncol = 2), matrix(rnorm(40, 4, 1), ncol = 2))
y <- factor(rep(c("negative", "positive"), c(200, 20)))
complexity(x, y)
#>          IR          C1          C2          ID          F1         F1v 
#> 10.00000000  0.56050301  0.80198020  0.81818182  0.58695972  0.86061593 
#>          F2          F3          F4          N1          N2          N3 
#>  0.36475028  0.69545455  0.59545455  0.18636364  0.22712955  0.11818182 
#>      N3_bal          N4         LSC           R       R_aug        SAFE 
#>  0.40250000  0.07727273  0.91997934  0.09090909  0.90909091  0.00000000 
#>  BORDERLINE        RARE     OUTLIER 
#>  0.15000000  0.50000000  0.35000000 
complexity(x, y, measures = c("IR", "R", "R_aug", "N4"), seed = 1)
#>          IR           R       R_aug          N4 
#> 10.00000000  0.09090909  0.90909091  0.12272727 
```
