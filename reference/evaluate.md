# Evaluate a Classifier with Several Metrics

Calculates the performance metrics of
[`metrics`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
in one call.

## Usage

``` r
evaluate(
  y_true,
  y_pred = NULL,
  y_prob = NULL,
  metrics = NULL,
  average = "auto",
  positive = NULL,
  n_bins = 10
)
```

## Arguments

- y_true:

  factor of the true classes.

- y_pred:

  predicted classes. If `NULL`, the class with the highest probability
  in `y_prob` is used.

- y_prob:

  predicted class probabilities (matrix with one column per class, or
  for two classes a vector with the probability of `positive`). Needed
  for the probability based metrics.

- metrics:

  character vector with the names of the metrics. The default `NULL`
  calculates all metrics that the inputs allow: without `y_prob` only
  the metrics based on predicted classes.

- average, positive, n_bins:

  see
  [`metrics`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md).

## Value

a named numeric vector.

## Details

The available metrics are `ACC`, `BACC`, `F1`, `GMEAN`, `MCC`, `ROCAUC`,
`PRAUC`, `Brier`, `PBrier`, `BBrier`, `ECE`, `BECE`, `P4`, `IAM`,
`PRECISION`, `RECALL`, `SPECIFICITY`, `KAPPA` and `LOGLOSS`. `average`
is used by `F1`, `P4`, `PRECISION`, `RECALL`, `SPECIFICITY`, `ROCAUC`
and `PRAUC`; the other metrics are defined for any number of classes.

## Examples

``` r
set.seed(1)
y_true <- factor(sample(c("neg", "pos"), 200, replace = TRUE, prob = c(0.9, 0.1)))
p_pos <- ifelse(y_true == "pos", rbeta(200, 3, 2), rbeta(200, 2, 4))
evaluate(y_true, y_prob = p_pos, positive = "pos")
#>         ACC        BACC          F1       GMEAN         MCC      ROCAUC 
#>   0.8300000   0.7855856   0.3928571   0.7838459   0.3726553   0.8580180 
#>       PRAUC       Brier      PBrier      BBrier         ECE        BECE 
#>   0.3387313   0.2759018   0.3609018   0.3367819   0.1215861   0.1082395 
#>          P4         IAM   PRECISION      RECALL SPECIFICITY       KAPPA 
#>   0.5471759   0.1061305   0.2682927   0.7333333   0.8378378   0.3179539 
#>     LOGLOSS 
#>   0.4386952 
evaluate(y_true, y_prob = p_pos, positive = "pos", metrics = c("MCC", "IAM", "BECE"))
#>       MCC       IAM      BECE 
#> 0.3726553 0.1061305 0.1082395 
```
