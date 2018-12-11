
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shouldbeverified <img src="man/figures/logo.png" width="160px" align="right" />

[![Build
status](https://travis-ci.org/mkearney/shouldbeverified.svg?branch=master)](https://travis-ci.org/mkearney/shouldbeverified)
[![CRAN
status](https://www.r-pkg.org/badges/version/shouldbeverified)](https://cran.r-project.org/package=shouldbeverified)
[![Coverage
Status](https://codecov.io/gh/mkearney/shouldbeverified/branch/master/graph/badge.svg)](https://codecov.io/gh/mkearney/shouldbeverified?branch=master)

<!--#![Downloads](https://cranlogs.r-pkg.org/badges/shouldbeverified)
#![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/shouldbeverified)-->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

> An R package for predicting whether Twitter users should be verified

## Installation

Install the development version from Github with:

``` r
## install remotes pkg if not already
if (!requireNamespace("remotes")) {
  install.packages("remotes")
}

## install from github
remotes::install_github("mkearney/shouldbeverified")
```

## Use

The key function `should_be_verified()` accepts either a character
vector with Twitter screen names or user IDs *or* a data frame returned
by [rtweet](https://rtweet.info).

``` r
## load package
library(shouldbeverified)

## predict whether user(s) should be verified
should_be_verified(
  c("kearneymw", "MizzouDataSci", "gelliottmorris")
)
#>      kearneymw  MizzouDataSci gelliottmorris 
#>     0.99266025     0.00247785     0.99867730
```
