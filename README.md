<!-- badges: start -->
[![CRAN
status](https://www.r-pkg.org/badges/version/BFS)](https://CRAN.R-project.org/package=BFS)
[![Grand
total](http://cranlogs.r-pkg.org/badges/grand-total/BFS)](https://cran.r-project.org/package=BFS)
[![pipeline
status](https://gitlab.com/lgnbhl/BFS/badges/master/pipeline.svg)](https://gitlab.com/lgnbhl/BFS/pipelines)
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
```

Caching and path gestion will be improved in the next `BFS` package
release (for now only available on Github) using the `pins` R package.
You can try the `BFS` development version by installing it from Github.

``` r
# install from Github
devtools::install_github("lgnbhl/BFS")
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
meta_en_uni <- bfs_search("university students", data = meta_en)

print(meta_en_uni)
```

    ## # A tibble: 2 x 6
    ##   title           period     published  source   url_bfs           url_px       
    ##   <chr>           <chr>      <chr>      <chr>    <chr>             <chr>        
    ## 1 University stu… Observati… 27.03.2019 Federal… https://www.bfs.… https://www.…
    ## 2 University stu… Observati… 27.03.2019 Federal… https://www.bfs.… https://www.…

To download a BFS dataset, add the related url link from the `url_px`
column of the downloaded metadata as an argument to the
`bfs_get_dataset()` function.

``` r
df_uni <- bfs_get_dataset(meta_en_uni$url_px[1])

print(df_uni)
```

    ## # A tibble: 16,380 x 5
    ##    studienstufe                           geschlecht isced_field     jahr  value
    ##    <fct>                                  <fct>      <fct>           <fct> <dbl>
    ##  1 First university degree or diploma     Male       Education scie… 1980    545
    ##  2 Bachelor                               Male       Education scie… 1980      0
    ##  3 Master                                 Male       Education scie… 1980      0
    ##  4 Doctorate                              Male       Education scie… 1980     93
    ##  5 Further education, advanced studies a… Male       Education scie… 1980     13
    ##  6 First university degree or diploma     Female     Education scie… 1980    946
    ##  7 Bachelor                               Female     Education scie… 1980      0
    ##  8 Master                                 Female     Education scie… 1980      0
    ##  9 Doctorate                              Female     Education scie… 1980     70
    ## 10 Further education, advanced studies a… Female     Education scie… 1980     52
    ## # … with 16,370 more rows

In case the `url_px` link to download the PC-Axis file is broken, you
can have a look at its related BFS webpage using the `url` link.

``` r
browseURL(df_uni$url_bfs[1]) # open webpage
```

Sometimes the PC-Axis file of the dataset doesn’t exist. You should then
use the “STAT-TAB - interactive table” service provided by BFS to
download manually the dataset.

To open the folder containing the downloaded BFS dataset (only available
in the development version on Github for now), you can simply use the
`bfs_open_dir()` function.

``` r
bfs_open_dir()
```

### Other information

Alternative R package:
<a href="https://github.com/rOpenGov/pxweb" target="_blank">pxweb</a>

This package is in no way officially related to or endorsed by the Swiss
Federal Statistical Office (BFS).
