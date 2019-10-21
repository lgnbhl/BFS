<!-- badges: start -->
[![CRAN
status](https://www.r-pkg.org/badges/version/BFS)](https://CRAN.R-project.org/package=BFS)
<!-- badges: end -->

BFS <img src="man/figures/logo.png" align="right" />
----------------------------------------------------

### Introduction

The `BFS` R package allows the user to search and download public data
from the
<a href="https://www.bfs.admin.ch/bfs/en/home.html" target="_blank">Swiss Federal Statistical Office (BFS)</a>
in a dynamic and reproducible way.

``` r
# install from CRAN
install.packages("BFS")

# install from Github
# devtools::install_github("lgnbhl/BFS")
```

### Usage Example

To search and download data from the BFS, you first need to retrieve
information about the available datasets. The `bfs_get_metadata()`
function returns a data frame/tibble containing the titles, publication
dates, observation periods, website urls and download urls of all
available BFS datasets of a given language: German (“de”, by default),
French (“fr”), Italian (“it”) or English (“en”). Note that Italian and
English languages give access to less datasets.

``` r
library(BFS)

meta_en <- bfs_get_metadata(language = "en")
```

To search for a dataset, you can use the `bfs_search()` function.

``` r
meta_en_edu <- bfs_search("education", data = meta_en)

print(meta_en_edu)
```

    ## # A tibble: 5 x 5
    ##   title          observation_period  published  url           url_px       
    ##   <chr>          <chr>               <chr>      <chr>         <chr>        
    ## 1 Difficulties … Observation period… 29.08.2019 https://www.… https://www.…
    ## 2 Difficulties … Observation period… 29.08.2019 https://www.… https://www.…
    ## 3 University of… Observation period… 27.03.2019 https://www.… https://www.…
    ## 4 University of… Observation period… 27.03.2019 https://www.… https://www.…
    ## 5 Compulsory ed… Observation period… 28.02.2019 https://www.… https://www.…

To download a BFS dataset, add the related url link from the `url_px`
column of the downloaded metadata as an argument to the
`bfs_get_dataset()` function.

``` r
df_edu <- bfs_get_dataset(meta_en_edu$url_px[3]) # get 3rd dataset of meta_en_edu

print(df_edu)
```

    ## # A tibble: 7,392 x 5
    ##    studienstufe     geschlecht isced_field                      jahr  value
    ##    <fct>            <fct>      <fct>                            <fct> <dbl>
    ##  1 Diploma          Male       Education science                1997      0
    ##  2 Bachelor         Male       Education science                1997      0
    ##  3 Master           Male       Education science                1997      0
    ##  4 Further educati… Male       Education science                1997      0
    ##  5 Diploma          Female     Education science                1997      0
    ##  6 Bachelor         Female     Education science                1997      0
    ##  7 Master           Female     Education science                1997      0
    ##  8 Further educati… Female     Education science                1997      0
    ##  9 Diploma          Male       Teacher training without subjec… 1997      0
    ## 10 Bachelor         Male       Teacher training without subjec… 1997      0
    ## # … with 7,382 more rows

In case the `url_px` link to download the PC-Axis file is broken, you
can have a look at its related BFS webpage using the `url` link.

``` r
browseURL(meta_en_edu$url[3]) # open webpage
```

Sometimes the PC-Axis file of the dataset doesn’t exist. You should then
use the “STAT-TAB - interactive table” service provided by BFS to
download manually the dataset.

### Other information

Alternative R package:
<a href="https://github.com/rOpenGov/pxweb" target="_blank">pxweb</a>

This package is in no way officially related to or endorsed by the Swiss
Federal Statistical Office (BFS).
