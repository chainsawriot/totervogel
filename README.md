
<!-- README.md is generated from README.Rmd. Please edit that file -->

# totervogel <img src="man/figures/logo.png" align="right" height="200" />

<!-- badges: start -->

<!-- badges: end -->

The goal of totervogel is to detect malicious twitter accounts using
Benford’s Law.

Please refer to Golbeck (2015) and Golbeck (2019) for more details.

1.  Golbeck, J. (2015). Benford’s law applies to online social networks.
    PloS one, 10(8), e0135169. doi:
    [10.1371/journal.pone.0135169](https://doi.org/10.1371/journal.pone.0135169)
2.  Golbeck, J. (2019). Benford’s Law can detect malicious social bots.
    First Monday. doi:
    [10.5210/fm.v24i8.10163](https://doi.org/10.5210/fm.v24i8.10163)

## Installation

You can install the development version of totervogel from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("chainsawriot/totervogel")
```

## Example

This is how my totervogel looks like:

``` r
library(totervogel)
res <- create_totervogel("chainsawriot")
res
#> User ID: chainsawriot 
#> Friends Correlation:  0.9931321 
#> Friends MAD:  0.007438397 ( Acceptable conformity )
#> Statuses Correlation: 0.9909444 
#> Statuses MAD:  0.01188518 ( Acceptable conformity )
#> Followers Correlation:  0.9949865 
#> Followers MAD:  0.006927456 ( Acceptable conformity )
```

<img src="man/figures/README-plotmyaccount-1.png" width="100%" />

This is how a potentially malicious twitter account’s totervogel looks
like:

(Please don’t visit the account.)

``` r


malicious_res <- create_totervogel("badluck_jones")
malicious_res
#> User ID: badluck_jones 
#> Friends Correlation:  0.9541358 
#> Friends MAD:  0.0176604 ( Nonconformity )
#> Statuses Correlation: 0.9995895 
#> Statuses MAD:  0.002337229 ( Close conformity )
#> Followers Correlation:  0.9965724 
#> Followers MAD:  0.007286108 ( Acceptable conformity )
```

``` r
plot(malicious_res)
```

<img src="man/figures/README-plotmalicious-1.png" width="100%" />

``` r
malicious_res$friends_benford
#> 
#> Benford object:
#>  
#> Data: info$friends_count 
#> Number of observations used = 4998 
#> Number of obs. for second order = 3335 
#> First digits analysed = 1
#> 
#> Mantissa: 
#> 
#>    Statistic  Value
#>         Mean  0.500
#>          Var  0.075
#>  Ex.Kurtosis -1.055
#>     Skewness -0.064
#> 
#> 
#> The 5 largest deviations: 
#> 
#>   digits absolute.diff
#> 1      4        287.64
#> 2      1        115.55
#> 3      3        109.56
#> 4      6         80.60
#> 5      7         70.84
#> 
#> Stats:
#> 
#>  Pearson's Chi-squared test
#> 
#> data:  info$friends_count
#> X-squared = 251.28, df = 8, p-value < 2.2e-16
#> 
#> 
#>  Mantissa Arc Test
#> 
#> data:  info$friends_count
#> L2 = 0.0085522, df = 2, p-value < 2.2e-16
#> 
#> Mean Absolute Deviation (MAD): 0.0176604
#> MAD Conformity - Nigrini (2012): Nonconformity
#> Distortion Factor: -2.12435
#> 
#> Remember: Real data will never conform perfectly to Benford's Law. You should not focus on p-values!
```

# Notes

  - In Globeck (2015), 89.7% of Twitter users had a correction of over
    0.9. Less than 1% had a correlation under 0.5. An account must be
    very suspicious to have such a low correction.

  - Accounts with a lower friends count are more likely to detect a low
    Benfordness.
