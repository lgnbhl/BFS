<!-- badges: start -->
[![CRAN
status](https://www.r-pkg.org/badges/version/BFS)](https://CRAN.R-project.org/package=BFS)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

BFS
---

### Introduction

The `BFS` package allows the user to download public data from the
[Swiss Federal Statistical Office (BFS)](https://www.bfs.admin.ch) in a
dynamic and reproducible way.

The package can be installed from Github (development version):

``` r
# From Github
library(devtools)
install_github("lgnbhl/BFS")
library(BFS)
```

### Usage Example

The `bfs_get_metadata` function returns a data frame/tibble containing
the titles, publication dates, observation periods, website urls and
download urls of available BFS datasets in a given language (in German
by default):

``` r
df_de <- bfs_get_metadata()
```

You can also retrieve the metadata in French (“fr”), Italian (“it”) or
English (“en”). Note that Italian and English languages give access to
less datasets.

To find a dataset, use either `View` in Rstudio or `bfs_search`:

``` r
df_en <- bfs_get_metadata(language = "en")
bfs_edu <- bfs_search("education", data = df_en)
```

To download the BFS dataset, select the `url_px` link from the metadata.

``` r
df_edu <- bfs_get_dataset(bfs_edu$url_px[3])
```

### Other information

This package is in no way officially related to or endorsed by the Swiss
Federal Statistical Office (BFS).
