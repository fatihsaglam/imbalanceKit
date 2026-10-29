# Package index

## Methods of the author

Resampling methods developed by the package author. All oversamplers
take a feature matrix and a factor class variable and return the
resampled data together with the synthetic samples.

- [`SMOTEWB()`](https://fatihsaglam.github.io/imbalanceKit/reference/SMOTEWB.md)
  : SMOTE with Boosting (SMOTEWB, 2022)
- [`MCSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/MCSMOTE.md)
  : Markov Chain SMOTE (MCSMOTE, 2025)
- [`BiSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/BiSMOTE.md)
  : Bi-directional SMOTE (BiSMOTE, 2027)

## Procedures built on a base method

DatRel moves synthetic samples back into their class region and can be
applied to samples from any source. UGO uses a base oversampler together
with a classifier.

- [`DatRel()`](https://fatihsaglam.github.io/imbalanceKit/reference/DatRel.md)
  : Data Relocation (DatRel, 2025)
- [`oversampleDatRel()`](https://fatihsaglam.github.io/imbalanceKit/reference/oversampleDatRel.md)
  : Oversampling followed by DatRel (2025)
- [`UGO()`](https://fatihsaglam.github.io/imbalanceKit/reference/UGO.md)
  : Uncertainty Guided Oversampling (UGO, 2026)

## Other oversampling methods

Listed by year of publication.

- [`ROS()`](https://fatihsaglam.github.io/imbalanceKit/reference/ROS.md)
  : Random Oversampling (ROS)
- [`SMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/SMOTE.md)
  : Synthetic Minority Oversampling Technique (SMOTE, 2002)
- [`BLSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/BLSMOTE.md)
  : Borderline-SMOTE (BLSMOTE, 2005)
- [`ADASYN()`](https://fatihsaglam.github.io/imbalanceKit/reference/ADASYN.md)
  : Adaptive Synthetic Sampling (ADASYN, 2008)
- [`SLSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/SLSMOTE.md)
  : Safe-Level SMOTE (SLSMOTE, 2009)
- [`RWO()`](https://fatihsaglam.github.io/imbalanceKit/reference/RWO.md)
  : Random Walk Oversampling (RWO, 2014)
- [`ROSE()`](https://fatihsaglam.github.io/imbalanceKit/reference/ROSE.md)
  : Random Over-Sampling Examples (ROSE, 2014)
- [`RSLSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/RSLSMOTE.md)
  : Relocating Safe-Level SMOTE (RSLSMOTE, 2016)
- [`EBSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/EBSMOTE.md)
  : Evaluation-Based SMOTE (EBSMOTE, 2019)
- [`GSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/GSMOTE.md)
  : Geometric SMOTE (GSMOTE, 2019)
- [`SyMProD()`](https://fatihsaglam.github.io/imbalanceKit/reference/SyMProD.md)
  : Synthetic Minority Based on Probabilistic Distribution (SyMProD,
  2020)
- [`RadiusSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/RadiusSMOTE.md)
  : Radius-SMOTE (RadiusSMOTE, 2021)
- [`GQEO()`](https://fatihsaglam.github.io/imbalanceKit/reference/GQEO.md)
  : Quadrilateral Element Oversampling (GQEO, 2025)
- [`LEAO()`](https://fatihsaglam.github.io/imbalanceKit/reference/LEAO.md)
  : Local Entropy-Adversarial Oversampling (LEAO, 2025)
- [`VSSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/VSSMOTE.md)
  : VS-SMOTE (VSSMOTE, 2025)

## Undersampling

- [`RUS()`](https://fatihsaglam.github.io/imbalanceKit/reference/RUS.md)
  : Random Undersampling (RUS)

## Performance evaluation

Metrics for imbalanced classification and a function that calculates
several of them.

- [`evaluate()`](https://fatihsaglam.github.io/imbalanceKit/reference/evaluate.md)
  : Evaluate a Classifier with Several Metrics
- [`ACC()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`BACC()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`GMEAN()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`MCC()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`KAPPA()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`IAM()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`F1()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`PRECISION()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`RECALL()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`SPECIFICITY()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`P4()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`ROCAUC()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`PRAUC()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`Brier()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`PBrier()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`BBrier()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`ECE()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`BECE()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  [`LOGLOSS()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md)
  : Performance Metrics for Imbalanced Classification

## Data complexity measures

Measures of class imbalance, class overlap and noise, each as a separate
function and all together through
[`complexity()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity.md).

- [`complexity()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity.md)
  : Calculate Several Complexity Measures
- [`complexity_IR()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_C1()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_C2()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_ID()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_F1()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_F1v()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_F2()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_F3()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_F4()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_N1()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_N2()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_N3()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_N3_bal()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_N4()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_LSC()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_R()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_R_aug()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_SAFE()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_BORDERLINE()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_RARE()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  [`complexity_OUTLIER()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md)
  : Complexity Measures for Imbalanced Classification Data
