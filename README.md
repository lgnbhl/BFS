
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

The `BFS` package allows to search and download public data from the <a
href="https://www.bfs.admin.ch/bfs/en/home/statistics/catalogues-databases/data.html"
target="_blank">Swiss Federal Statistical Office</a> (BFS stands for
*Bundesamt für Statistik* in German) in a dynamic and reproducible way.

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

You can get the data catalog by language based on the official [RSS
feed](https://www.bfs.admin.ch/bfs/en/home/statistiken/kataloge-datenbanken/daten/_jcr_content/par/ws_catalog.rss.xml?skipLimit=true).
Unfortunately, it seems that not the all public datasets are in the RSS
feed, but only the most recently udpated. Note also that Italian and
English give access to less datasets.

``` r
catalog_data_en <- bfs_get_catalog_data(language = "en")

catalog_data_en
```

    ## # A tibble: 176 x 5
    ##    title                                       language published url_bfs url_px
    ##    <chr>                                       <chr>    <chr>     <chr>   <chr> 
    ##  1 New registrations of road vehicles by mont~ en       New regi~ https:~ https~
    ##  2 Hotel sector: arrivals and overnight stays~ en       Hotel se~ https:~ https~
    ##  3 Hotel sector: arrivals and overnight stays~ en       Hotel se~ https:~ https~
    ##  4 Hotel sector: arrivals and overnight stays~ en       Hotel se~ https:~ https~
    ##  5 Hotel sector: supply and demand of open es~ en       Hotel se~ https:~ https~
    ##  6 Hotel sector: supply and demand of open es~ en       Hotel se~ https:~ https~
    ##  7 Hotel sector: supply and demand of open es~ en       Hotel se~ https:~ https~
    ##  8 Retail Trade Turnover Statistics - monthly~ en       Retail T~ https:~ https~
    ##  9 Retail Trade Turnover Statistics - quarter~ en       Retail T~ https:~ https~
    ## 10 Retail Trade Turnover Statistics - yearly ~ en       Retail T~ https:~ https~
    ## # ... with 166 more rows

To find older datasets, you can use the search bar in the [official BFS
website](https://www.bfs.admin.ch/bfs/de/home/statistiken/kataloge-datenbanken/daten.html).

### Search for a specific dataset

You could use for example `dplyr` to search for a given dataset.

``` r
library(dplyr)

catalog_data_uni <- catalog_data_en %>%
  filter(title == "University students by year, ISCED field, sex and level of study")

catalog_data_uni
```

    ## # A tibble: 1 x 5
    ##   title                                        language published url_bfs url_px
    ##   <chr>                                        <chr>    <chr>     <chr>   <chr> 
    ## 1 University students by year, ISCED field, s~ en       Universi~ https:~ https~

### Download a dataset in any language

To download a BFS dataset, you have two options. You can add the
official BFS URL webpage to the `url_bfs` argument to the
`bfs_get_data()`. For example, you can use the URL of a given dataset
you found using `bfs_get_catalog_data()`.

``` r
# https://www.bfs.admin.ch/content/bfs/en/home/statistiken/kataloge-datenbanken/daten.assetdetail.16324907.html
df_uni <- bfs_get_data(url_bfs = catalog_data_uni$url_bfs, language = "en")
```

    ##   Downloading large query (in 4 batches):
    ##   |                                                                              |                                                                      |   0%  |                                                                              |==================                                                    |  25%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================================                  |  75%  |                                                                              |======================================================================| 100%

``` r
df_uni
```

    ## # A tibble: 17,640 x 5
    ##    Year    `ISCED Field`     Sex    `Level of study`            `University st~`
    ##    <chr>   <chr>             <chr>  <chr>                                  <dbl>
    ##  1 1980/81 Education science Male   First university degree or~              545
    ##  2 1980/81 Education science Male   Bachelor                                   0
    ##  3 1980/81 Education science Male   Master                                     0
    ##  4 1980/81 Education science Male   Doctorate                                 93
    ##  5 1980/81 Education science Male   Further education, advance~               13
    ##  6 1980/81 Education science Female First university degree or~              946
    ##  7 1980/81 Education science Female Bachelor                                   0
    ##  8 1980/81 Education science Female Master                                     0
    ##  9 1980/81 Education science Female Doctorate                                 70
    ## 10 1980/81 Education science Female Further education, advance~               52
    ## # ... with 17,630 more rows

Note that some datasets are only accessible in German and French.

In case the data is not accessible using `bfs_get_catalog_data()`, you
can manually add the BFS number in the `bfs_get_data()` function using
the `number_bfs` argument.

``` r
# open webpage
browseURL("https://www.bfs.admin.ch/content/bfs/en/home/statistiken/kataloge-datenbanken/daten.assetdetail.16324907.html")
```

<img style="border:1px solid black;" src="https://raw.githubusercontent.com/lgnbhl/BFS/master/man/figures/screenshot.png" align="center" />

<br/>

Use again `bfs_get_data()` but this time with the `number_bfs` argument.

``` r
bfs_get_data(number_bfs = "px-x-1502040100_131", language = "en")
```

Please privilege the `number_bfs` argument of the `bfs_get_data()` if
you want more stable and reproducible code.

You can access additional information about the dataset by running
`bfs_get_data_comments()`.

``` r
bfs_get_data_comments(number_bfs = "px-x-1502040100_131", language = "en")
```

    ##   Downloading large query (in 4 batches):
    ##   |                                                                              |                                                                      |   0%  |                                                                              |==================                                                    |  25%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================================                  |  75%  |                                                                              |======================================================================| 100%

    ## # A tibble: 1 x 4
    ##   row_no col_no comment_type   comment                                          
    ##    <int>  <int> <chr>          <chr>                                            
    ## 1     NA      4 column_comment "To ensure that the presentations from cubes con~

### Catalog of tables

A lot of tables are not accessible through the official API, but they
are still present in the official BFS website. You can access the [RSS
feed tables
catalog](https://www.bfs.admin.ch/bfs/en/home/statistiken/kataloge-datenbanken/tabellen/_jcr_content/par/ws_catalog.rss.xml?skipLimit=true)
using `bfs_get_catalog_tables()`. Most of these tables are Excel or CSV
files. Note again that only a part of all the public tables accessible
are in the RSS feed (the most recently updated datasets).

``` r
catalog_tables_en <- bfs_get_catalog_tables(language = "en")

catalog_tables_en
```

    ## # A tibble: 350 x 5
    ##    title                                    language published url_bfs url_table
    ##    <chr>                                    <chr>    <chr>     <chr>   <chr>    
    ##  1 Deaths per week by 5-year age group, se~ en       Deaths p~ https:~ https://~
    ##  2 Deaths per week by 5-year age group, se~ en       Deaths p~ https:~ https://~
    ##  3 Weekly number of deaths, 2010-2022       en       Weekly n~ https:~ https://~
    ##  4 1st certification rate at upper seconda~ en       1st cert~ https:~ https://~
    ##  5 Corruption perceptions index - Switzerl~ en       Corrupti~ https:~ https://~
    ##  6 Digital skills - Share of total populat~ en       Digital ~ https:~ https://~
    ##  7 Direct investments in developing countr~ en       Direct i~ https:~ https://~
    ##  8 Domestic violence - Number of victims o~ en       Domestic~ https:~ https://~
    ##  9 Domestic violence by sex - Number of vi~ en       Domestic~ https:~ https://~
    ## 10 Drinking water use - Consumption of hou~ en       Drinking~ https:~ https://~
    ## # ... with 340 more rows

``` r
library(dplyr)
library(openxlsx)

index_table_url <- catalog_tables_en %>%
  filter(grepl("index", title)) %>% # search table
  slice(1) %>%
  pull(url_table)

df <- tryCatch(expr = openxlsx::read.xlsx(index_table_url, startRow = 1),
    error = function(e) "Failed reading table")

df
```

    ##                                              T.21.02.30.1605.01.01   X2
    ## 1                                     Corruption perceptions index <NA>
    ## 2  Switzerland’s ranking in the Global Corruption Perception Index <NA>
    ## 3                                                             <NA> Data
    ## 4                                                             2012    6
    ## 5                                                             2013    7
    ## 6                                                             2014    5
    ## 7                                                             2015    6
    ## 8                                                             2016    5
    ## 9                                                             2017    3
    ## 10                                                            2018    3
    ## 11                                                            2019    4
    ## 12                                                            2020    3
    ## 13                                                            2021    7
    ## 14                                        Last update:  24.02.2022 <NA>
    ## 15                              Source: Transparency International <NA>
    ## 16                                                      © FSO 2022 <NA>

## Other information

A [blog
article](https://felixluginbuhl.com/blog/posts/2019-11-07-swiss-data/)
showing a concrete example about how to use the BFS package and to
visualize the data in a Swiss map.

The BFS package is using the
<a href="https://github.com/rOpenGov/pxweb" target="_blank">pxweb</a> R
package under the hood to access the Swiss Federal Statistical Office
pxweb API and <a href="https://github.com/RobertMyles/tidyRSS"
target="_blank">tidyRSS</a> to scrap the official BFS RSS feeds.

This package is in no way officially related to or endorsed by the Swiss
Federal Statistical Office (BFS).

## Contribute

Any contribution is strongly appreciated. Feel free to report a bug, ask
any question or make a pull request for any remaining
[issue](https://github.com/lgnbhl/BFS/issues).
