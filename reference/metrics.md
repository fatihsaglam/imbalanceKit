# Performance Metrics for Imbalanced Classification

Metrics that are suitable for imbalanced and multi-class classification.
All of them take the true classes `y_true` (a factor) and either the
predicted classes `y_pred` or the predicted class probabilities
`y_prob`. Use
[`evaluate`](https://fatihsaglam.github.io/imbalanceKit/reference/evaluate.md)
to calculate several metrics at once.

## Usage

``` r
ACC(y_true, y_pred)

BACC(y_true, y_pred)

GMEAN(y_true, y_pred)

MCC(y_true, y_pred)

KAPPA(y_true, y_pred)

IAM(y_true, y_pred)

F1(y_true, y_pred, average = "auto", positive = NULL)

PRECISION(y_true, y_pred, average = "auto", positive = NULL)

RECALL(y_true, y_pred, average = "auto", positive = NULL)

SPECIFICITY(y_true, y_pred, average = "auto", positive = NULL)

P4(y_true, y_pred, average = "auto", positive = NULL)

ROCAUC(y_true, y_prob, average = "auto", positive = NULL)

PRAUC(y_true, y_prob, average = "auto", positive = NULL)

Brier(y_true, y_prob, positive = NULL)

PBrier(y_true, y_prob, positive = NULL)

BBrier(y_true, y_prob, positive = NULL)

ECE(y_true, y_prob, n_bins = 10, positive = NULL)

BECE(y_true, y_prob, n_bins = 10, positive = NULL)

LOGLOSS(y_true, y_prob, positive = NULL)
```

## Arguments

- y_true:

  factor of the true classes.

- y_pred:

  predicted classes. A factor or a character vector with labels from the
  levels of `y_true`.

- average:

  how class-wise values are combined for metrics that are defined for
  one class: `"binary"` uses only the `positive` class, `"macro"` is the
  mean over classes, `"micro"` pools the counts (or scores) of all
  classes, `"weighted"` is the mean weighted by class sizes. The default
  `"auto"` is `"binary"` for two classes and `"macro"` for more.

- positive:

  the positive class of the binary versions. Default is the smallest
  class of `y_true`.

- y_prob:

  predicted class probabilities: a matrix with one column per class
  (named after the levels of `y_true`, or in level order), or, for two
  classes, a vector with the probability of `positive`.

- n_bins:

  number of equal width confidence bins of `ECE` and `BECE`. Default is
  10.

## Value

a number.

## Details

Metrics based on predicted classes:

- `ACC`: accuracy.

- `BACC`: balanced accuracy, the mean recall over the classes.

- `GMEAN`: geometric mean of the class recalls (for two classes
  \\\sqrt{sensitivity \cdot specificity}\\).

- `MCC`: Matthews correlation coefficient, in the multi-class form of
  Gorodkin (2004).

- `KAPPA`: Cohen's kappa.

- `IAM`: imbalanced accuracy measure (Mortaz, 2020), in \\\[-1, 1\]\\.

- `F1`, `PRECISION`, `RECALL`, `SPECIFICITY`, `P4`: class-wise metrics
  combined with `average`. `P4` is the harmonic mean of precision,
  recall, specificity and negative predictive value (Sitarz, 2022). A
  class-wise value with an empty denominator is 0; classes that do not
  occur in `y_true` are ignored by `"macro"` and `"weighted"`. Micro
  averaged `F1`, `PRECISION` and `RECALL` equal `ACC`.

Metrics based on probabilities:

- `ROCAUC`: area under the ROC curve. Multi-class values are
  one-versus-rest and combined with `average`.

- `PRAUC`: area under the precision-recall curve, calculated as average
  precision. Multi-class values are one-versus-rest and combined with
  `average`.

- `Brier`: the Brier score, the mean over observations of the sum over
  classes of the squared differences between the probabilities and the
  one-hot true class. Lies in \\\[0, 2\]\\; for two classes it is twice
  the usual \\(p - y)^2\\ form.

- `PBrier`: penalized Brier score (Ahmadian et al., 2024): the Brier
  score plus \\(K-1)/K\\ for every misclassified observation, which
  keeps a wrongly classified observation from scoring better than a
  correctly classified one.

- `BBrier`: balanced Brier score, the mean of the class-wise Brier
  scores, so that every class counts equally.

- `ECE`: expected calibration error of the predicted class (confidence),
  \\\sum_b (n_b/n) \|acc_b - conf_b\|\\ over equal width confidence
  bins.

- `BECE`: balanced expected calibration error, `ECE` where every
  observation is weighted by the inverse size of its true class.

- `LOGLOSS`: logarithmic loss.

The probabilities of `ECE`, `BECE`, `PBrier` use the class with the
highest probability as the predicted class.

## References

Gorodkin, J. (2004). Comparing two K-category assignments by a
K-category correlation coefficient. Computational Biology and Chemistry,
28(5-6), 367-374.

Mortaz, E. (2020). Imbalance accuracy metric for model selection in
multi-class imbalance classification problems. Knowledge-Based Systems,
210, 106490.

Sitarz, M. (2022). Extending F1 metric, probabilistic approach.
arXiv:2210.11997.

Ahmadian, S. et al. (2024). Superior scoring rules for probabilistic
evaluation of single-label multi-class classification tasks.
arXiv:2407.17697.

## Examples

``` r
set.seed(1)
y_true <- factor(sample(c("a", "b", "c"), 100, replace = TRUE, prob = c(0.7, 0.2, 0.1)))
prob <- matrix(runif(300), 100, 3, dimnames = list(NULL, levels(y_true)))
prob <- prob / rowSums(prob)
y_pred <- factor(levels(y_true)[max.col(prob)], levels = levels(y_true))
BACC(y_true, y_pred)
#> [1] 0.2183258
F1(y_true, y_pred, average = "micro")
#> [1] 0.3
MCC(y_true, y_pred)
#> [1] -0.05586563
ROCAUC(y_true, prob, average = "macro")
#> [1] 0.423633
Brier(y_true, prob)
#> [1] 0.7447057
```
