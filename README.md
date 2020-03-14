<!-- badges: start -->
[![CRAN
status](https://www.r-pkg.org/badges/version/BFS)](https://CRAN.R-project.org/package=BFS)
[![Grand
total](http://cranlogs.r-pkg.org/badges/grand-total/BFS)](https://cran.r-project.org/package=BFS)
[![pipeline
status](https://gitlab.com/lgnbhl/BFS/badges/master/pipeline.svg)](https://gitlab.com/lgnbhl/BFS/pipelines)
<!-- badges: end -->

BFS <img src="man/figures/logo.png" align="right" />
====================================================

The `BFS` package allows to search and download public data from the
<a href="https://www.bfs.admin.ch/bfs/en/home/statistics/catalogues-databases/data.html" target="_blank">Swiss Federal Statistical Office (BFS)</a>
in a dynamic and reproducible way.

Installation
------------

``` r
# Install the released version from CRAN
install.packages("BFS")
```

To get a bug fix, or use a feature from the development version, you can
install BFS from GitHub.

``` r
# install from Github
devtools::install_github("lgnbhl/BFS")
```

Usage
-----

``` r
library(BFS)
```

### Download metadata

To search and download data from the Swiss Federal Statistical Office,
you first need to retrieve information about the available public
datasets. The `bfs_get_metadata()` function returns a data frame/tibble
containing the titles, publication dates, observation periods, data
sources, website urls and download urls of all the BFS datasets
available in a given language. You can get the metadata in German (“de”,
by default), French (“fr”), Italian (“it”) or English (“en”). Note that
Italian and English metadata give access to less datasets.

``` r
meta_en <- bfs_get_metadata(language = "en")
```

To search for a dataset in the BFS metadata, you can use the
`bfs_search()` function.

``` r
meta_en_uni <- bfs_search(data = meta_en, string = "university students")

print(meta_en_uni)
```

    ## # A tibble: 2 x 6
    ##   title           period     published  source   url_bfs           url_px       
    ##   <chr>           <chr>      <chr>      <chr>    <chr>             <chr>        
    ## 1 University stu… Observati… 27.03.2019 Federal… https://www.bfs.… https://www.…
    ## 2 University stu… Observati… 27.03.2019 Federal… https://www.bfs.… https://www.…

### Download datasets

To download a BFS dataset, add the related url link from the `url_px`
column of the downloaded metadata as an argument to the
`bfs_get_dataset()` function.

``` r
df_uni <- bfs_get_dataset(url_px = meta_en_uni$url_px[1])

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
can have a look at its related BFS webpage using the `url_bfs` link.

``` r
browseURL(meta_en_uni$url_bfs[1]) # open webpage
```

Sometimes the PC-Axis file of the dataset doesn’t exist. You should then
use the “STAT-TAB - interactive table” service provided by BFS to
download manually the dataset.

### Data caching

Data caching is handled using the [pins](https://pins.rstudio.com/) R
package. To open the folder containing all the BFS datasets you already
downloaded, you can use the `bfs_open_dir()` function.

``` r
bfs_open_dir()
```

If a dataset has already been downloaded during the day, the functions
`bfs_get_metadata()` and `bfs_get_dataset()` retrieve the already
downloaded datasets from your local pins caching folder. Caching speeds
up code and reduces BFS server requests. However, if a given dataset has
not been downloaded during the day, the functions download it again to
be sure that you have the last BFS data available.

### Other information

Alternative R package:
<a href="https://github.com/rOpenGov/pxweb" target="_blank">pxweb</a>

This package is in no way officially related to or endorsed by the Swiss
Federal Statistical Office (BFS).
