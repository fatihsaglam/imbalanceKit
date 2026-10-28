# imbalanceKit

Resampling methods and tools for imbalanced classification in R.

`imbalanceKit` brings the resampling methods of the author together in one
package. It continues the
[SMOTEWB](https://CRAN.R-project.org/package=SMOTEWB) package and adds newer
methods. All resamplers take a feature matrix `x` and a factor class variable
`y`, and return a list with the resampled data (`x_new`, `y_new`) and the
generated synthetic samples (`x_syn`, `y_syn`).

## Installation

```r
# development version
# install.packages("remotes")
remotes::install_github("fatihsaglam/imbalanceKit")
```

## Methods

Every method name below is followed by the **year** of its publication.

### Oversamplers

| Year | Function | Method | Reference |
|---|---|---|---|
| 2002 | `SMOTE()` | Synthetic minority oversampling technique | Chawla et al. (2002), *JAIR* |
| 2005 | `BLSMOTE()` | Borderline-SMOTE | Han et al. (2005), *ICIC* |
| 2008 | `ADASYN()` | Adaptive synthetic sampling | He et al. (2008), *IJCNN* |
| 2009 | `SLSMOTE()` | Safe-level SMOTE | Bunkhumpornpat et al. (2009), *PAKDD* |
| 2014 | `ROSE()` | Randomly over sampling examples | Lunardon et al. (2014), *R Journal* |
| 2014 | `RWO()` | Random walk oversampling | Zhang & Li (2014), *Information Fusion* |
| 2016 | `RSLSMOTE()` | Relocating safe-level SMOTE | Siriseriwan & Sinapiromsaran (2016), *Chiang Mai J. Sci.* |
| 2019 | `GSMOTE()` | Geometric SMOTE | Douzas & Bacao (2019), *Information Sciences* |
| 2019 | `EBSMOTE()` | Evaluation-based SMOTE | Hussein et al. (2019), *ISKE* |
| 2020 | `SyMProD()` | Synthetic minority based on probabilistic distribution | Kunakorntum et al. (2020), *IEEE Access* |
| 2022 | `SMOTEWB()` | SMOTE with boosting | Sağlam & Cengiz (2022), *Expert Systems with Applications* |
| 2025 | `MCSMOTE()` | Markov chain (transition matrix driven) SMOTE | Sağlam & Cengiz (2025), *Applied Soft Computing* |
| 2025 | `GQEO()` | Quadrilateral element oversampling | Dai et al. (2025), *Neural Networks* |
| 2025 | `LEAO()` | Local entropy-adversarial oversampling | Tao (2025), *Neurocomputing* |
| 2027 | `BiSMOTE()` | Bi-directional SMOTE | Sağlam & Yamak (2027), *Expert Systems with Applications* |
| – | `ROS()`, `RUS()` | Random over- and undersampling | classical |

### Methods built on top of other resamplers

These two are not resamplers by themselves: they *use* a base oversampling
method.

| Year | Function | Method | What it needs |
|---|---|---|---|
| 2025 | `DatRel()` | Data relocation, a post-processing step: moves synthetic samples that fall outside the class region back into it (Sağlam, 2025, *Machine Learning*) | `x`, `y` and any synthetic samples `x_syn`, `y_syn` (`oversampleDatRel()` runs a base oversampler first) |
| 2026 | `UGO()` | Uncertainty guided oversampling (Sağlam & Cengiz, 2026, *Knowledge-Based Systems*) | a base `type` and a `classifier` |

`UGO()` has seven built-in classifiers (`"CART"`, `"RF"`, `"LogReg"`, `"KNN"`,
`"NaiveBayes"`, `"LDA"`, `"NNET"`) and accepts any function
`function(x_train, y_train, x_test, ...)` that returns class probabilities.

## Metrics

Metrics for imbalanced and multi-class classification take `y_true` and either
predicted classes (`y_pred`) or class probabilities (`y_prob`):

| Based on classes | Based on probabilities |
|---|---|
| `ACC()`, `BACC()`, `F1()`, `GMEAN()`, `MCC()`, `P4()`, `IAM()`, `KAPPA()`, `PRECISION()`, `RECALL()`, `SPECIFICITY()` | `ROCAUC()`, `PRAUC()`, `Brier()`, `PBrier()`, `BBrier()`, `ECE()`, `BECE()`, `LOGLOSS()` |

Metrics defined for one class (`F1`, `P4`, `ROCAUC`, `PRAUC`, ...) have an
`average` argument (`"binary"`, `"macro"`, `"micro"`, `"weighted"`). `evaluate()`
calculates all of them, or the selected `metrics`, in one call.

```r
evaluate(y_true, y_prob = prob)                         # everything
evaluate(y_true, y_prob = prob, metrics = c("MCC", "IAM", "BECE"))
```

## Example

```r
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

Please cite the paper of the method you use. `citation("imbalanceKit")` lists
the package and the method references.
