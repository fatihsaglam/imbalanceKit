# imbalanceKit 0.1.0

First release. `imbalanceKit` collects the resampling methods of the former
`SMOTEWB` package (version 1.2.5) and extends them.

## New methods

* `BiSMOTE()`: bi-directional SMOTE (Sağlam & Yamak).
* `MCSMOTE()`: transition matrix driven oversampling (Sağlam & Cengiz, 2025).
  Works with more than two classes.
* `UGO()`: uncertainty guided oversampling (Sağlam & Cengiz, 2026), with
  `"RWO"`, `"SMOTE"`, `"ROS"` and `"MCSMOTE"` as base methods. UGO is not a
  resampler by itself but a procedure that uses a base method and a
  classifier. The classifier is chosen with the `classifier` argument: one of
  the seven built-in classifiers (`"CART"`, `"RF"`, `"LogReg"`, `"KNN"`,
  `"NaiveBayes"`, `"LDA"`, `"NNET"`) or any function that returns class
  probabilities. The old names `"rpart"` and `"randomForest"` still work.
* `DatRel()` (Sağlam, 2025) is a post-processing method: `DatRel(x, y, x_syn, y_syn)`
  moves synthetic samples from any source that fall outside their class
  region back into it (pure and proper class cover; works with more than two
  classes). The cover algorithm of the `rcccd` package is included, so `rcccd`
  is not needed. `oversampleDatRel()` generates the samples with a base method
  first.

* `EBSMOTE()`, `GQEO()`, `LEAO()` and `SyMProD()`: further oversamplers that need
  no deep learning libraries. The first, third and fourth are defined for two
  classes; with more classes every class is oversampled against the union of
  the others. `LEAO()` estimates class probabilities with bagged `rpart` trees,
  logistic regression, k-nearest neighbours or naive Bayes (`prob_type`).

## Documentation

* The year of publication of every method is part of its help page title and is
  listed in the README.
* References were added for `EBSMOTE()`, `GQEO()`, `LEAO()` and `SyMProD()`
  (also in `citation()`).

## Metrics

* `evaluate()` calculates `ACC`, `BACC`, `F1`, `GMEAN`, `MCC`, `ROCAUC`,
  `PRAUC`, `Brier`, `PBrier` (penalized), `BBrier` (balanced), `ECE`, `BECE`
  (balanced), `P4` and `IAM` plus `PRECISION`, `RECALL`, `SPECIFICITY`, `KAPPA`
  and `LOGLOSS`, or the selected ones. Each metric is also a function of its own.
* Metrics are defined for two or more classes; class-wise metrics have an
  `average` argument (`"binary"`, `"macro"`, `"micro"`, `"weighted"`).

## Methods carried over from SMOTEWB 1.2.5

`ADASYN()`, `BLSMOTE()`, `GSMOTE()`, `ROS()`, `ROSE()`, `RSLSMOTE()`, `RUS()`,
`RWO()`, `SLSMOTE()`, `SMOTE()` and `SMOTEWB()`.

## Changes compared with SMOTEWB 1.2.5

* Every resampler is built from a `generate_<METHOD>()` function (one class at
  a time) and a shared driver. Generation is vectorised, so the methods are
  several times faster on large data. Because the random numbers are now drawn
  in bulk, a seed no longer reproduces the output of SMOTEWB 1.2.5 (`ROS()` and
  `ROSE()` still do); the distribution of the synthetic samples is unchanged.
* All resamplers work with more than two classes.
* `ovRate`: the number of synthetic samples is `ovRate * (n_max - n_j)` rounded
  half up for every method (before: `round()` for most, `ceiling()` for BiSMOTE
  and UGO). `ovRate` may also be a vector with one value per class and is
  validated.
* `RUS()` keeps the original row order and validates `n_neededToRemove`.

## Fixes

* `SMOTE(k = 1)` and `ADASYN(k = 1)` no longer fail; `k` larger than the class
  size is reduced. Classes with a single sample are duplicated with a warning.
* `ADASYN()` returns exactly the required number of samples (it was off by a
  few because of rounding) and its `C` is reported for every class.
* `RSLSMOTE()` used the neighbours of the first sample instead of those of the
  current sample when relocating; fixed.
* `BLSMOTE()` no longer modifies `k2` across classes and no longer loops forever
  when too few borderline samples exist.
* `GSMOTE()` now returns `y_syn` as documented.
