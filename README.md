<!-- badges: start -->
[![CRAN
status](https://www.r-pkg.org/badges/version/BFS)](https://CRAN.R-project.org/package=BFS)
<!-- badges: end -->

BFS <img src="man/figures/logo.png" align="right" />
----------------------------------------------------

### Introduction

The `BFS` package allows the user to download public data from the
<a href="https://www.bfs.admin.ch/bfs/en/home.html" target="_blank">Swiss Federal Statistical Office (BFS)</a>
in a dynamic and reproducible way.

The package can be installed from Github (development version):

``` r
# From Github
library(devtools)
install_github("lgnbhl/BFS")
library(BFS)
```

### Usage Example

The `bfs_get_metadata()` function returns a data frame/tibble containing
the titles, publication dates, observation periods, website urls and
download urls of available BFS datasets in a given language (in German
by default):

``` r
meta_de <- bfs_get_metadata()
```

You can also retrieve the metadata in French (“fr”), Italian (“it”) or
English (“en”). Note that Italian and English languages give access to
less datasets.

To find a dataset, use either `View()` in RStudio or the `bfs_search()`
function:

``` r
meta_en <- bfs_get_metadata(language = "en")
meta_en_edu <- bfs_search("education", data = meta_en)
```

To download a BFS dataset, add the related url link from the `url_px`
column of the downloaded metadata as an argument to the
`bfs_get_dataset()` function.

``` r
df_edu <- bfs_get_dataset(meta_en_edu$url_px[3])
df_edu
```

In case the `url_px` link to download the PC-Axis file is broken, you
can have a look at its related BFS webpage using the `url` link.

``` r
browseURL(meta_en_edu$url[3])
```

### Other information

Alternative R package:
<a href="https://github.com/rOpenGov/pxweb" target="_blank">pxweb</a>

This package is in no way officially related to or endorsed by the Swiss
Federal Statistical Office (BFS).
