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

| Function | Method | Reference |
|---|---|---|
| `SMOTEWB()` | SMOTE with boosting | Sağlam & Cengiz (2022), *Expert Systems with Applications* |
| `MCSMOTE()` | Transition matrix driven oversampling | Sağlam & Cengiz (2025), *Applied Soft Computing* |
| `UGO()` | Uncertainty guided oversampling | Sağlam & Cengiz (2026), *Knowledge-Based Systems* |
| `BiSMOTE()` | Bi-directional SMOTE | Sağlam & Yamak (2027), *Expert Systems with Applications* |
| `SMOTE()`, `ADASYN()`, `BLSMOTE()`, `SLSMOTE()`, `RSLSMOTE()`, `GSMOTE()` | SMOTE and variants | see the help pages |
| `ROS()`, `RWO()`, `ROSE()`, `RUS()` | Random over- and undersampling | see the help pages |

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
m <- UGO(x, y, type = "SMOTE", classifier = "randomForest")
table(m$y_new)
```

## Citation

Please cite the paper of the method you use. `citation("imbalanceKit")` lists
the package and the method references.
