# Random Undersampling (RUS)

Resampling with RUS.

## Usage

``` r
RUS(x, y, n_neededToRemove = NULL, ...)
```

## Arguments

- x:

  feature matrix.

- y:

  a factor class variable. Can have more than two classes.

- n_neededToRemove:

  vector of desired number removal for each class. A vector of integers
  for each class. Default is NULL meaning full balance. Must be equal or
  lower than the number of samples in each class.

- ...:

  not used.

## Value

a list with resampled dataset.

- x_new:

  Resampled feature matrix.

- y_new:

  Resampled target variable.

## Details

Random Undersampling (RUS) is a method of removing negative samples
until balance is achieved.

Can work with classes more than 2.

## Author

Fatih Saglam, saglamf89@gmail.com

## Examples

``` r

set.seed(1)
x <- rbind(matrix(rnorm(2000, 3, 1), ncol = 2, nrow = 1000),
           matrix(rnorm(100, 5, 1), ncol = 2, nrow = 50))
y <- as.factor(c(rep("negative", 1000), rep("positive", 50)))

plot(x, col = y)


# resampling
m <- RUS(x = x, y = y)

plot(m$x_new, col = m$y_new)

```
