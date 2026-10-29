# imbalanceKit

Resampling methods and tools for imbalanced classification in R.

`imbalanceKit` brings the resampling methods of the author together in
one package. It continues the
[SMOTEWB](https://CRAN.R-project.org/package=SMOTEWB) package and also
includes the data relocation approach of the `imbalanceDatRel` package,
so that package is not needed any more. It adds newer methods. All
resamplers take a feature matrix `x` and a factor class variable `y`,
and return a list with the resampled data (`x_new`, `y_new`) and the
generated synthetic samples (`x_syn`, `y_syn`).

## Installation

``` r

# development version
# install.packages("remotes")
remotes::install_github("fatihsaglam/imbalanceKit")

# with the vignette (takes a little longer)
remotes::install_github("fatihsaglam/imbalanceKit", build_vignettes = TRUE)
vignette("imbalanceKit")
```

The vignette is also available on the [package
website](https://fatihsaglam.github.io/imbalanceKit/).

## Methods

Every method name below is followed by the **year** of its publication.

### Oversamplers

| Year | Function | Method | Reference |
|----|----|----|----|
| 2002 | [`SMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/SMOTE.md) | Synthetic minority oversampling technique | Chawla et al. (2002), *JAIR* |
| 2005 | [`BLSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/BLSMOTE.md) | Borderline-SMOTE | Han et al. (2005), *ICIC* |
| 2008 | [`ADASYN()`](https://fatihsaglam.github.io/imbalanceKit/reference/ADASYN.md) | Adaptive synthetic sampling | He et al. (2008), *IJCNN* |
| 2009 | [`SLSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/SLSMOTE.md) | Safe-level SMOTE | Bunkhumpornpat et al. (2009), *PAKDD* |
| 2014 | [`ROSE()`](https://fatihsaglam.github.io/imbalanceKit/reference/ROSE.md) | Randomly over sampling examples | Lunardon et al. (2014), *R Journal* |
| 2014 | [`RWO()`](https://fatihsaglam.github.io/imbalanceKit/reference/RWO.md) | Random walk oversampling | Zhang & Li (2014), *Information Fusion* |
| 2016 | [`RSLSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/RSLSMOTE.md) | Relocating safe-level SMOTE | Siriseriwan & Sinapiromsaran (2016), *Chiang Mai J. Sci.* |
| 2019 | [`GSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/GSMOTE.md) | Geometric SMOTE | Douzas & Bacao (2019), *Information Sciences* |
| 2019 | [`EBSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/EBSMOTE.md) | Evaluation-based SMOTE | Hussein et al. (2019), *ISKE* |
| 2020 | [`SyMProD()`](https://fatihsaglam.github.io/imbalanceKit/reference/SyMProD.md) | Synthetic minority based on probabilistic distribution | Kunakorntum et al. (2020), *IEEE Access* |
| 2021 | [`RadiusSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/RadiusSMOTE.md) | Radius-SMOTE | Pradipta et al. (2021), *IEEE Access* |
| 2022 | [`SMOTEWB()`](https://fatihsaglam.github.io/imbalanceKit/reference/SMOTEWB.md) | SMOTE with boosting | Sağlam & Cengiz (2022), *Expert Systems with Applications* |
| 2025 | [`MCSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/MCSMOTE.md) | Markov chain (transition matrix driven) SMOTE | Sağlam & Cengiz (2025), *Applied Soft Computing* |
| 2025 | [`VSSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/VSSMOTE.md) | VS-SMOTE (high-value spaces) | Qiu et al. (2025), *Neurocomputing* |
| 2025 | [`GQEO()`](https://fatihsaglam.github.io/imbalanceKit/reference/GQEO.md) | Quadrilateral element oversampling | Dai et al. (2025), *Neural Networks* |
| 2025 | [`LEAO()`](https://fatihsaglam.github.io/imbalanceKit/reference/LEAO.md) | Local entropy-adversarial oversampling | Tao (2025), *Neurocomputing* |
| 2027 | [`BiSMOTE()`](https://fatihsaglam.github.io/imbalanceKit/reference/BiSMOTE.md) | Bi-directional SMOTE | Sağlam & Yamak (2027), *Expert Systems with Applications* |
| – | [`ROS()`](https://fatihsaglam.github.io/imbalanceKit/reference/ROS.md), [`RUS()`](https://fatihsaglam.github.io/imbalanceKit/reference/RUS.md) | Random over- and undersampling | classical |

### Methods built on top of other resamplers

These two are not resamplers by themselves: they *use* a base
oversampling method.

| Year | Function | Method | What it needs |
|----|----|----|----|
| 2025 | [`DatRel()`](https://fatihsaglam.github.io/imbalanceKit/reference/DatRel.md) | Data relocation, a post-processing step: moves synthetic samples that fall outside the class region back into it (Sağlam, 2025, *Machine Learning*) | `x`, `y` and any synthetic samples `x_syn`, `y_syn` ([`oversampleDatRel()`](https://fatihsaglam.github.io/imbalanceKit/reference/oversampleDatRel.md) runs a base oversampler first) |
| 2026 | [`UGO()`](https://fatihsaglam.github.io/imbalanceKit/reference/UGO.md) | Uncertainty guided oversampling (Sağlam & Cengiz, 2026, *Knowledge-Based Systems*) | a base `type` and a `classifier` |

[`UGO()`](https://fatihsaglam.github.io/imbalanceKit/reference/UGO.md)
has seven built-in classifiers (`"CART"`, `"RF"`, `"LogReg"`, `"KNN"`,
`"NaiveBayes"`, `"LDA"`, `"NNET"`) and accepts any function
`function(x_train, y_train, x_test, ...)` that returns class
probabilities.

## Metrics

Metrics for imbalanced and multi-class classification take `y_true` and
either predicted classes (`y_pred`) or class probabilities (`y_prob`):

| Based on classes | Based on probabilities |
|----|----|
| [`ACC()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`BACC()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`F1()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`GMEAN()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`MCC()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`P4()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`IAM()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`KAPPA()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`PRECISION()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`RECALL()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`SPECIFICITY()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md) | [`ROCAUC()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`PRAUC()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`Brier()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`PBrier()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`BBrier()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`ECE()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`BECE()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md), [`LOGLOSS()`](https://fatihsaglam.github.io/imbalanceKit/reference/metrics.md) |

Metrics defined for one class (`F1`, `P4`, `ROCAUC`, `PRAUC`, …) have an
`average` argument (`"binary"`, `"macro"`, `"micro"`, `"weighted"`).
[`evaluate()`](https://fatihsaglam.github.io/imbalanceKit/reference/evaluate.md)
calculates all of them, or the selected `metrics`, in one call.

``` r

evaluate(y_true, y_prob = prob)                         # everything
evaluate(y_true, y_prob = prob, metrics = c("MCC", "IAM", "BECE"))
```

## Complexity measures

Measures of class imbalance, overlap and noise from the literature
(higher = more imbalanced / harder). Each is a function of its own;
[`complexity()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity.md)
calculates all of them or the selected ones.

| Group | Measures |
|----|----|
| Imbalance | [`complexity_IR()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_C1()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_C2()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_ID()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md) |
| Overlap (features) | [`complexity_F1()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_F1v()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_F2()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_F3()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_F4()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md) |
| Overlap (neighbourhood) | [`complexity_N1()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_N2()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_N3()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_N3_bal()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_N4()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_LSC()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md) |
| Overlap + imbalance | [`complexity_R()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md) (Oh, 2011), [`complexity_R_aug()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md) (Borsos et al., 2018) |
| Noise (types of minority examples) | [`complexity_SAFE()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_BORDERLINE()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_RARE()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md), [`complexity_OUTLIER()`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity_measures.md) |

``` r

complexity(x, y)                                  # everything
complexity(x, y, measures = c("IR", "R", "R_aug", "N4"), seed = 1)
```

## Example

``` r

library(imbalanceKit)

set.seed(1)
x <- rbind(matrix(rnorm(2000, 3, 1), ncol = 2),
           matrix(rnorm(100, 5, 1), ncol = 2))
y <- factor(c(rep("negative", 1000), rep("positive", 50)))

m <- MCSMOTE(x, y, thresh_qntl = 0.05)
table(m$y_new)
plot(m$x_new, col = m$y_new)

# UGO decides the number of synthetic samples itself and is
# classifier specific: use the classifier you will train afterwards
m <- UGO(x, y, type = "SMOTE", classifier = "LDA")
table(m$y_new)

# DatRel post-processes synthetic samples (any method, any number of classes)
m0 <- SMOTE(x, y, k = 7)                    # or any synthetic samples
m <- DatRel(x, y, m0$x_syn, m0$y_syn)
m$n_relocated
```

## Citation

Please cite the paper of the method you use. `citation("imbalanceKit")`
lists the package and the method references.
