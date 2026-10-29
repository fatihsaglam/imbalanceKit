# Complexity Measures for Imbalanced Classification Data

Measures of the class imbalance, of the class overlap and of the noise
of a classification data set, taken from the literature. Higher values
mean a more imbalanced or a more complex (harder) problem. Each measure
is a function of its own;
[`complexity`](https://fatihsaglam.github.io/imbalanceKit/reference/complexity.md)
calculates all of them or the selected ones.

## Usage

``` r
complexity_IR(x = NULL, y)

complexity_C1(x = NULL, y)

complexity_C2(x = NULL, y)

complexity_ID(x = NULL, y)

complexity_F1(x, y)

complexity_F1v(x, y)

complexity_F2(x, y)

complexity_F3(x, y)

complexity_F4(x, y)

complexity_N1(x, y, scale = "minmax")

complexity_N2(x, y, scale = "minmax")

complexity_N3(x, y, scale = "minmax")

complexity_N3_bal(x, y, scale = "minmax")

complexity_N4(x, y, scale = "minmax", seed = NULL)

complexity_LSC(x, y, scale = "minmax")

complexity_R(x, y, k = 7, theta = 3, scale = "minmax")

complexity_R_aug(x, y, k = 7, theta = 3, scale = "minmax")

complexity_SAFE(x, y, k = 5, scale = "minmax")

complexity_BORDERLINE(x, y, k = 5, scale = "minmax")

complexity_RARE(x, y, k = 5, scale = "minmax")

complexity_OUTLIER(x, y, k = 5, scale = "minmax")
```

## Arguments

- x:

  feature matrix or data.frame (numeric).

- y:

  a factor class variable. Can have more than two classes (see Details).

- scale:

  scaling of the features before distances are calculated: `"minmax"`
  (default, to \[0, 1\]), `"zscore"` or `"none"`. Feature based measures
  (`F1`, `F1v`, `F2`, `F3`, `F4`) use the original features.

- seed:

  seed of the random interpolation of `N4`. Default is `NULL` (the
  random number stream is not touched).

- k:

  number of nearest neighbors. Default is 7 for `R` and `R_aug`
  (Oh, 2011) and 5 for the types of minority examples (Napierala &
  Stefanowski, 2016).

- theta:

  threshold of the R-value: a sample is in the overlapping region if
  more than `theta` of its `k` nearest neighbors are from other classes.
  Default is 3.

## Value

a number.

## Details

**Class imbalance** (they use `y` only; `x` may be `NULL`):

- `IR`: imbalance ratio, size of the largest class divided by the size
  of the smallest class.

- `C1`: \\1 + \sum_k p_k \log p_k / \log K\\, one minus the normalized
  entropy of the class proportions \\p_k\\ (Lorena et al., 2019). 0
  means balanced, 1 means one class has all the samples.

- `C2`: \\1 - 1 / IR\_{K}\\ with \\IR\_{K} = \frac{K - 1}{K} \sum_k n_k
  / (n - n_k)\\ (Lorena et al., 2019).

- `ID`: imbalance degree (Ortigosa-Hernandez et al., 2017), with the
  Euclidean distance. 0 means balanced; the integer part is the number
  of minority classes minus one.

**Overlap, feature based** (Ho & Basu, 2002; Lorena et al., 2019). They
are defined for two classes; with more classes the mean over all pairs
of classes (one-versus-one) is returned. They are transformed so that
higher means more overlap:

- `F1`: \\1 / (1 + r)\\, with \\r\\ the maximum Fisher's discriminant
  ratio over the features. `F1v`: the same with the directional (vector)
  Fisher's ratio (Orriols-Puig et al., 2010).

- `F2`: volume of the overlapping region (product over the features of
  the relative overlap).

- `F3`: maximum individual feature efficiency, inverted: the smallest
  proportion of samples in the overlapping interval of a single feature.

- `F4`: collective feature efficiency: proportion of samples that remain
  after the features have been used one after another to separate the
  classes.

**Overlap, neighborhood based** (they work with any number of classes;
Ho & Basu, 2002; Leyva et al., 2015):

- `N1`: proportion of samples that are connected to a sample of another
  class in the minimum spanning tree.

- `N2`: ratio of the intra-class to the inter-class nearest neighbor
  distances, \\r / (1 + r)\\.

- `N3`: error rate of the leave-one-out 1-nearest neighbor classifier.
  `N3_bal`: the mean of its class-wise error rates (a class-balanced
  variant, not in Ho & Basu).

- `N4`: error rate of the 1-nearest neighbor classifier on randomly
  interpolated samples (of the same class) (needs a random number
  stream, see `seed`).

- `LSC`: local set cardinality, \\1 - \sum \|LS\| / n^2\\.

**Overlap and imbalance together**:

- `R`: R-value (Oh, 2011), the proportion of samples in the overlapping
  region (\\\> theta\\ of the `k` nearest neighbors from another class).
  For two classes it is \\(IR \cdot R\_{maj} + R\_{min}) / (IR + 1)\\,
  so it is dominated by the majority class.

- `R_aug`: augmented R-value (Borsos et al., 2018), \\(R\_{maj} + IR
  \cdot R\_{min}) / (IR + 1)\\: the weights are swapped so that the
  minority class, which is more affected by overlap, is dominant. For
  more than two classes the class weights are \\n\_{max} / n_k\\
  (normalized); this generalization is ours.

**Noise, types of minority examples** (Napierala & Stefanowski, 2016).
The minority samples (all classes except the largest one) are labelled
by the proportion \\s\\ of their `k` nearest neighbors from their own
class: safe (\\s \ge 0.8\\), borderline (\\0.4 \le s \< 0.8\\), rare
(\\0 \< s \< 0.4\\) and outlier (\\s = 0\\). With `k = 5` these are 4-5,
2-3, 1 and 0 neighbors. The measures `SAFE`, `BORDERLINE`, `RARE` and
`OUTLIER` are the proportions of minority samples of each type. Larger
`RARE` and `OUTLIER` mean a noisier minority class.

## References

Borsos, Z., Lemnaru, C., & Potolea, R. (2018). Dealing with overlap and
imbalance: a new metric and approach. Pattern Analysis and Applications,
21(2), 381-395.

Ho, T. K., & Basu, M. (2002). Complexity measures of supervised
classification problems. IEEE Transactions on Pattern Analysis and
Machine Intelligence, 24(3), 289-300.

Leyva, E., Gonzalez, A., & Perez, R. (2015). A set of complexity
measures designed for applying meta-learning to instance selection. IEEE
Transactions on Knowledge and Data Engineering, 27(2), 354-367.

Lorena, A. C., Garcia, L. P., Lehmann, J., Souto, M. C., & Ho, T. K.
(2019). How complex is your classification problem? A survey on
measuring classification complexity. ACM Computing Surveys, 52(5), 1-34.

Napierala, K., & Stefanowski, J. (2016). Types of minority class
examples and their influence on learning classifiers in imbalanced
domains. Journal of Intelligent Information Systems, 46(3), 563-597.

Oh, S. (2011). A new dataset evaluation method based on category
overlap. Computers in Biology and Medicine, 41(2), 115-122.

Orriols-Puig, A., Macia, N., & Ho, T. K. (2010). Documentation for the
data complexity library in C++. Technical report, La Salle, Universitat
Ramon Llull.

Ortigosa-Hernandez, J., Inza, I., & Lozano, J. A. (2017). Measuring the
class-imbalance extent of multi-class problems. Pattern Recognition
Letters, 98, 32-38.

## Author

Fatih Saglam, saglamf89@gmail.com

## Examples

``` r
set.seed(1)
x <- rbind(matrix(rnorm(400, 3, 1), ncol = 2), matrix(rnorm(40, 4, 1), ncol = 2))
y <- factor(rep(c("negative", "positive"), c(200, 20)))

complexity_IR(y = y)
#> Error in complexity_IR(y = y): could not find function "complexity_IR"
complexity_R_aug(x, y)
#> Error in complexity_R_aug(x, y): could not find function "complexity_R_aug"
complexity_N3(x, y)
#> Error in complexity_N3(x, y): could not find function "complexity_N3"
```
