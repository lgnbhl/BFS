
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/BFS)](https://CRAN.R-project.org/package=BFS)
[![Grand
total](https://cranlogs.r-pkg.org/badges/grand-total/BFS)](https://cran.r-project.org/package=BFS)
[![R build
status](https://github.com/lgnbhl/BFS/workflows/R-CMD-check/badge.svg)](https://github.com/lgnbhl/BFS/actions)
<!-- badges: end -->

# BFS <img src="man/figures/logo.png" align="right" />

> Search and download data from the Swiss Federal Statistical Office

The `BFS` package allows to search and download public data from the
<a href="https://www.bfs.admin.ch/bfs/en/home/statistics/catalogues-databases/data.html" target="_blank">Swiss Federal Statistical Office (BFS is for Bundesamt für Statistik in German)</a>
in a dynamic and reproducible way.

## Installation

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

## Usage

``` r
library(BFS)
```

### Get the data catalog

To search and download data from the Swiss Federal Statistical Office,
you first need to retrieve information about the available public
datasets.

You can get the data catalog by language based on their official [RSS
feed](https://www.bfs.admin.ch/bfs/en/home/statistiken/kataloge-datenbanken/daten/_jcr_content/par/ws_catalog.rss.xml).
Unfortunately, it seems that not all data is listed inside the RSS feed.
Note also that Italian and English give access to less datasets.

``` r
catalog_en <- bfs_get_catalog(language = "en")

catalog_en
```

    ## # A tibble: 170 x 5
    ##    title            language published           url_bfs           url_px       
    ##    <chr>            <chr>    <chr>               <chr>             <chr>        
    ##  1 Air emissions a~ en       Air emissions acco~ https://www.bfs.~ https://www.~
    ##  2 Deaths per mont~ en       Deaths per month a~ https://www.bfs.~ https://www.~
    ##  3 Divorces and di~ en       Divorces and divor~ https://www.bfs.~ https://www.~
    ##  4 Energy accounts~ en       Energy accounts of~ https://www.bfs.~ https://www.~
    ##  5 Environmentally~ en       Environmentally re~ https://www.bfs.~ https://www.~
    ##  6 Live births per~ en       Live births per mo~ https://www.bfs.~ https://www.~
    ##  7 Marriages and n~ en       Marriages and nupt~ https://www.bfs.~ https://www.~
    ##  8 Permanent resid~ en       Permanent resident~ https://www.bfs.~ https://www.~
    ##  9 New registratio~ en       New registrations ~ https://www.bfs.~ https://www.~
    ## 10 Hotel accommoda~ en       Hotel accommodatio~ https://www.bfs.~ https://www.~
    ## # ... with 160 more rows

### Search for a specific dataset

``` r
library(dplyr)

catalog_uni <- catalog_en %>%
  filter(title == "University students by year, ISCED field, sex and level of study")

catalog_uni
```

    ## # A tibble: 1 x 5
    ##   title           language published          url_bfs             url_px        
    ##   <chr>           <chr>    <chr>              <chr>               <chr>         
    ## 1 University stu~ en       University studen~ https://www.bfs.ad~ https://www.b~

### Download a dataset in any language

To download a BFS dataset, add the related URL link from the `url_bfs`
column of the downloaded metadata as an argument to the
`bfs_get_dataset()` function.

``` r
df_uni <- bfs_get_dataset(url_bfs = catalog_uni$url_bfs, language = "en")
```

    ##   Downloading large query (in 4 batches):
    ##   |                                                                              |                                                                      |   0%  |                                                                              |==================                                                    |  25%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================================                  |  75%  |                                                                              |======================================================================| 100%

``` r
df_uni
```

    ## # A tibble: 17,220 x 5
    ##    Year    `ISCED Field`     Sex   `Level of study`            `University stud~
    ##    <chr>   <chr>             <chr> <chr>                                   <dbl>
    ##  1 1980/81 Education science Man   First university degree or~               545
    ##  2 1980/81 Education science Man   Bachelor                                    0
    ##  3 1980/81 Education science Man   Master                                      0
    ##  4 1980/81 Education science Man   Doctorate                                  93
    ##  5 1980/81 Education science Man   Further education, advance~                13
    ##  6 1980/81 Education science Woman First university degree or~               946
    ##  7 1980/81 Education science Woman Bachelor                                    0
    ##  8 1980/81 Education science Woman Master                                      0
    ##  9 1980/81 Education science Woman Doctorate                                  70
    ## 10 1980/81 Education science Woman Further education, advance~                52
    ## # ... with 17,210 more rows

You can access additional information about the downloaded data set
using the `bfs_get_dataset_comments()` function.

``` r
bfs_get_dataset_comments(url_bfs = catalog_uni$url_bfs, language = "en")
```

    ##   Downloading large query (in 4 batches):
    ##   |                                                                              |                                                                      |   0%  |                                                                              |==================                                                    |  25%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================================                  |  75%  |                                                                              |======================================================================| 100%

    ## # A tibble: 1 x 4
    ##   row_no col_no comment_type   comment                                          
    ##    <int>  <int> <chr>          <chr>                                            
    ## 1     NA      4 column_comment "To ensure that the presentations from cubes con~

In case the data is not present in the data catalog, you can add
manually the BFS number in the `bfs_get_dataset()` function using the
`number_bfs` argument. For example, if the data used until now as an
example is not accessible using `bfs_get_catalog()`, you could try to
find the BFS number manually:

``` r
# open webpage
browseURL("https://www.bfs.admin.ch/content/bfs/en/home/statistiken/kataloge-datenbanken/daten.assetdetail.16324907.html")
```

<img style="border:1px solid black;" src="https://raw.githubusercontent.com/lgnbhl/BFS/master/man/figures/screenshot.png" align="center" />

<br/>

You can use again `bfs_get_dataset()` but this time with the
`number_bfs` argument.

``` r
bfs_get_dataset(number_bfs = "px-x-1502040100_131", language = "en")
```

A lot of data is not accessible through the API, but is still present in
the official BFS website. You can access the RSS tables catalog of the
Excel files using the `bfs_get_catalog_tables()`. Note that only a part
of the tables are accessible using the RSS feed.

``` r
bfs_get_catalog_tables(language = "en")
```

    ## # A tibble: 350 x 5
    ##    title           language published           url_bfs          url_table      
    ##    <chr>           <chr>    <chr>               <chr>            <chr>          
    ##  1 Admissions to ~ en       Admissions to univ~ https://www.bfs~ https://www.bf~
    ##  2 Admissions to ~ en       Admissions to univ~ https://www.bfs~ https://www.bf~
    ##  3 Air emission a~ en       Air emission accou~ https://www.bfs~ https://www.bf~
    ##  4 Air emission a~ en       Air emission accou~ https://www.bfs~ https://www.bf~
    ##  5 Average age at~ en       Average age at tim~ https://www.bfs~ https://www.bf~
    ##  6 Average age of~ en       Average age of the~ https://www.bfs~ https://www.bf~
    ##  7 Energy flow ac~ en       Energy flow accoun~ https://www.bfs~ https://www.bf~
    ##  8 Energy flow ac~ en       Energy flow accoun~ https://www.bfs~ https://www.bf~
    ##  9 Environmentall~ en       Environmentally re~ https://www.bfs~ https://www.bf~
    ## 10 Environmentall~ en       Environmentally re~ https://www.bfs~ https://www.bf~
    ## # ... with 340 more rows

## Other information

A [blog
article](https://felixluginbuhl.com/blog/posts/2019-11-07-swiss-data/)
showing a concrete example about how to use the BFS package and to
visualize the data in a Swiss map.

The BFS package is using the
<a href="https://github.com/rOpenGov/pxweb" target="_blank">pxweb</a> R
package under the hood to access the Swiss Federal Statistical Office
pxweb API.

This package is in no way officially related to or endorsed by the Swiss
Federal Statistical Office (BFS).
