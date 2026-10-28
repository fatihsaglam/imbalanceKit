# imbalanceKit 0.1.0

First release. `imbalanceKit` collects the resampling methods of the former
`SMOTEWB` package (version 1.2.5) and extends them.

## New methods

* `BiSMOTE()`: bi-directional SMOTE (Sağlam & Yamak).
* `MCSMOTE()`: transition matrix driven oversampling (Sağlam & Cengiz, 2025).
  Works with more than two classes.
* `UGO()`: uncertainty guided oversampling (Sağlam & Cengiz, 2026), with
  `"RWO"`, `"SMOTE"`, `"ROS"` and `"MCSMOTE"` as base methods. The classifier is
  chosen with the `classifier` argument (`"randomForest"`, `"rpart"` or any
  function that returns class probabilities).

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
