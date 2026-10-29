# Banana data

A two-dimensional, two-class imbalanced data set. The positive
(minority) class and the negative (majority) class both have a curved,
banana-like shape and overlap with each other, so the data set contains
the usual difficulties of imbalanced classification: a small minority
class, class overlap, noise and small disjuncts. It is used in the
examples and the vignette of the package.

## Usage

``` r
banana
```

## Format

A data frame with 2640 rows and 3 variables:

- At1:

  first feature.

- At2:

  second feature.

- Class:

  factor with levels `"negative"` (2376 samples) and `"positive"` (264
  samples). The imbalance ratio is 9.

## Source

The banana data set of the KEEL data set repository,
<https://sci2s.ugr.es/keel/datasets.php>.

## References

Alcalá-Fdez, J., Fernández, A., Luengo, J., Derrac, J., García, S.,
Sánchez, L., & Herrera, F. (2011). KEEL data-mining software tool: data
set repository, integration of algorithms and experimental analysis
framework. Journal of Multiple-Valued Logic and Soft Computing, 17(2-3),
255-287.

## Examples

``` r
table(banana$Class)
#> 
#> negative positive 
#>     2376      264 
plot(banana$At1, banana$At2, col = ifelse(banana$Class == "positive", "red", "grey60"),
     pch = 16, xlab = "At1", ylab = "At2")
```
