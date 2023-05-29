
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/BFS)](https://CRAN.R-project.org/package=BFS)
[![Grand
total](https://cranlogs.r-pkg.org/badges/grand-total/BFS)](https://cran.r-project.org/package=BFS)
[![R-CMD-check](https://github.com/lgnbhl/BFS/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lgnbhl/BFS/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

# BFS <img src="man/figures/logo.png" align="right" />

> Search and download data from the Swiss Federal Statistical Office

The `BFS` package allows to search and download public data from the
<a href="https://www.pxweb.bfs.admin.ch/pxweb/en/" target="_blank">Swiss
Federal Statistical Office</a> (BFS stands for *Bundesamt für Statistik*
in German) API in a dynamic and reproducible way.

## Installation

``` r
install.packages("BFS")
```

You can also install the development version from Github.

``` r
devtools::install_github("lgnbhl/BFS")
```

## Usage

``` r
library(BFS)
```

### Get the data catalog

Retrieve the list of publicly available datasets from the [data
catalog](https://www.bfs.admin.ch/bfs/de/home/statistiken/kataloge-datenbanken/daten.html)
in any language (“de”, “fr”, “it” or “en”) by calling
`bfs_get_catalog_data()`.

``` r
catalog_data_en <- bfs_get_catalog_data(language = "en")

catalog_data_en
```

    ## # A tibble: 180 × 7
    ##    title   language publication_date    url_bfs url_px guid  catalog_date       
    ##    <chr>   <chr>    <dttm>              <chr>   <chr>  <chr> <dttm>             
    ##  1 Provis… en       2023-04-04 08:30:00 https:… https… bfsR… 2023-04-04 08:30:00
    ##  2 Perman… en       2022-10-06 08:30:00 https:… https… bfsR… 2023-04-04 08:30:00
    ##  3 Privat… en       2022-10-06 08:30:00 https:… https… bfsR… 2023-04-04 08:30:00
    ##  4 Deaths… en       2022-09-26 08:30:00 https:… https… bfsR… 2023-04-04 08:30:00
    ##  5 Divorc… en       2022-09-26 08:30:00 https:… https… bfsR… 2023-04-04 08:30:00
    ##  6 Live b… en       2022-09-26 08:30:00 https:… https… bfsR… 2023-04-04 08:30:00
    ##  7 Marria… en       2022-09-26 08:30:00 https:… https… bfsR… 2023-04-04 08:30:00
    ##  8 Acquis… en       2022-08-25 08:30:00 https:… https… bfsR… 2023-04-04 08:30:00
    ##  9 Acquis… en       2022-08-25 08:30:00 https:… https… bfsR… 2023-04-04 08:30:00
    ## 10 Demogr… en       2022-08-25 08:30:00 https:… https… bfsR… 2023-04-04 08:30:00
    ## # ℹ 170 more rows

English and Italian data catalogs offer a limited list of datasets. For
the full list please get the French (“fr”) or German (“de”) data
catalogs.

### Download a dataset in any language

The function `bfs_get_data()` allows you to download any dataset for the
data catalog.

To download a specific dataset, you can either use the `url_bfs` or the
`number_bfs`.

The `url_bfs` argument refers to the offical webpage of a dataset. Find
below an example using “dplyr”.

``` r
library(dplyr)

url_bfs_uni_students <- catalog_data_en %>%
  dplyr::filter(title == "University students by year, ISCED field, sex and level of study") %>%
  dplyr::pull(url_bfs)

url_bfs_uni_students
```

    ## [1] "https://www.bfs.admin.ch/content/bfs/en/home/statistiken/kataloge-datenbanken/daten.assetdetail.24367729.html"

Then you can download the full dataset using `url_bfs`.

``` r
# https://www.bfs.admin.ch/content/bfs/en/home/statistiken/kataloge-datenbanken/daten.assetdetail.16324907.html
df_uni <- bfs_get_data(url_bfs = url_bfs_uni_students, language = "en")
```

    ##   Downloading large query (in 4 batches):
    ##   |                                                                              |                                                                      |   0%  |                                                                              |==================                                                    |  25%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================================                  |  75%  |                                                                              |======================================================================| 100%

``` r
df_uni
```

    ## # A tibble: 18,060 × 5
    ##    Year    `ISCED Field`     Sex    `Level of study`       `University students`
    ##    <chr>   <chr>             <chr>  <chr>                                  <dbl>
    ##  1 1980/81 Education science Male   First university degr…                   545
    ##  2 1980/81 Education science Male   Bachelor                                   0
    ##  3 1980/81 Education science Male   Master                                     0
    ##  4 1980/81 Education science Male   Doctorate                                 93
    ##  5 1980/81 Education science Male   Further education, ad…                    13
    ##  6 1980/81 Education science Female First university degr…                   946
    ##  7 1980/81 Education science Female Bachelor                                   0
    ##  8 1980/81 Education science Female Master                                     0
    ##  9 1980/81 Education science Female Doctorate                                 70
    ## 10 1980/81 Education science Female Further education, ad…                    52
    ## # ℹ 18,050 more rows

It is recommended to privilege the use of the `number_bfs` argument for
stability and reproducibility.

You can manually find the `number_bfs` by opening the official webpage
and looking for the “FSO number”.

``` r
# open Uni students dataset webpage
browseURL(url_bfs_uni_students)
```

<img style="border:1px solid black;" src="https://raw.githubusercontent.com/lgnbhl/BFS/master/man/figures/screenshot.png" align="center" />

<br/>

Then you can download the dataset using `number_bfs`.

``` r
bfs_get_data(number_bfs = "px-x-1502040100_131", language = "en")
```

You can also access additional information about the dataset by running
`bfs_get_data_comments()`.

``` r
bfs_get_data_comments(number_bfs = "px-x-1502040100_131", language = "en")
```

    ##   Downloading large query (in 4 batches):
    ##   |                                                                              |                                                                      |   0%  |                                                                              |==================                                                    |  25%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================================                  |  75%  |                                                                              |======================================================================| 100%

    ## # A tibble: 1 × 4
    ##   row_no col_no comment_type   comment                                          
    ##    <int>  <int> <chr>          <chr>                                            
    ## 1     NA      4 column_comment "To ensure that the presentations from cubes con…

#### Query specific elements

You may get an error message if the query is too large.

    Error: 
    Too large query. 
    The smallest batch size is 24030 and the maximum number of values 
    that can be downloaded through the API is 5000.

You may also have an error if the API calls too many requests.

    Error in pxweb_advanced_get(url = url, query = query, verbose = verbose) : 
      Too Many Requests (RFC 6585) (HTTP 429).

One solution is to query only specific elements of the dataset to
download less data. Here an example.

First you want to get the variable names, i.e. `code`, and categories,
i.e. `values`, of your dataset.

``` r
# choose a BFS number and language
metadata <- bfs_get_metadata(number_bfs = "px-x-1502040100_131", language = "en")

str(metadata)
```

    ## tibble [4 × 7] (S3: tbl_df/tbl/data.frame)
    ##  $ code       : chr [1:4] "Jahr" "ISCED Fach" "Geschlecht" "Studienstufe"
    ##  $ text       : chr [1:4] "Year" "ISCED Field" "Sex" "Level of study"
    ##  $ values     :List of 4
    ##   ..$ : chr [1:43] "0" "1" "2" "3" ...
    ##   ..$ : chr [1:42] "0" "1" "2" "3" ...
    ##   ..$ : chr [1:2] "0" "1"
    ##   ..$ : chr [1:5] "0" "1" "2" "3" ...
    ##  $ valueTexts :List of 4
    ##   ..$ : chr [1:43] "1980/81" "1981/82" "1982/83" "1983/84" ...
    ##   ..$ : chr [1:42] "Education science" "Teacher training without subject specialisation" "Teacher training with subject specialisation" "Fine arts" ...
    ##   ..$ : chr [1:2] "Male" "Female"
    ##   ..$ : chr [1:5] "First university degree or diploma" "Bachelor" "Master" "Doctorate" ...
    ##  $ time       : logi [1:4] TRUE NA NA NA
    ##  $ elimination: logi [1:4] NA TRUE TRUE TRUE
    ##  $ title      : chr [1:4] "University students by Year, ISCED Field, Sex and Level of study" "University students by Year, ISCED Field, Sex and Level of study" "University students by Year, ISCED Field, Sex and Level of study" "University students by Year, ISCED Field, Sex and Level of study"

Then you can manually select the dimensions of the dataset you want to
query.

``` r
# Manually create BFS query dimensions
# Use `code` and `values` elements
# Use "*" to select all
dimensions <- list(
  "Jahr" = c("40", "41"),
  "ISCED Fach" = c("0"),
  "Geschlecht" = c("*"),
  "Studienstufe" = c("2", "3"))

# Query BFS data with specific dimensions
BFS::bfs_get_data(
  number_bfs = "px-x-1502040100_131",
  language = "en",
  query = dimensions
  )
```

    ## # A tibble: 8 × 5
    ##   Year    `ISCED Field`     Sex    `Level of study` `University students`
    ##   <chr>   <chr>             <chr>  <chr>                            <dbl>
    ## 1 2020/21 Education science Male   Master                             151
    ## 2 2020/21 Education science Male   Doctorate                          121
    ## 3 2020/21 Education science Female Master                             555
    ## 4 2020/21 Education science Female Doctorate                          306
    ## 5 2021/22 Education science Male   Master                             143
    ## 6 2021/22 Education science Male   Doctorate                          115
    ## 7 2021/22 Education science Female Master                             599
    ## 8 2021/22 Education science Female Doctorate                          318

### Catalog of tables

A lot of tables are not accessible through the official API, but they
are still present in the official BFS website. You can access the [RSS
feed tables
catalog](https://www.bfs.admin.ch/bfs/en/home/statistics/catalogues-databases/tables.html)
using `bfs_get_catalog_tables()`.

``` r
catalog_tables_en_students <- bfs_get_catalog_tables(language = "en", title = "students")

catalog_tables_en_students
```

    ## # A tibble: 5 × 7
    ##   title language publication_date    url_bfs url_table guid  catalog_date       
    ##   <chr> <chr>    <dttm>              <chr>   <chr>     <chr> <dttm>             
    ## 1 Stud… en       2023-04-05 00:00:00 https:… https://… bfsR… 2023-04-05 00:00:00
    ## 2 Stud… en       2023-04-05 00:00:00 https:… https://… bfsR… 2023-04-05 00:00:00
    ## 3 Stud… en       2023-03-28 08:30:00 https:… https://… bfsR… 2023-04-05 00:00:00
    ## 4 Stud… en       2023-03-28 08:30:00 https:… https://… bfsR… 2023-04-05 00:00:00
    ## 5 Stud… en       2023-03-28 08:30:00 https:… https://… bfsR… 2023-04-05 00:00:00

Note that due to RSS feed limitation, only a part of all the public
tables are using `bfs_get_catalog_tables()`. You can access the full
tables catalog in the [official BFS website
page](https://www.bfs.admin.ch/bfs/de/home/statistiken/kataloge-datenbanken/tabellen.html).

Most of the BFS tables are Excel or CSV files. For example, you can use
the “openxlsx” R package to read a specific Excel table using the
`url_table` column.

``` r
library(dplyr)
library(openxlsx)

tables_bfs_uni_students <- catalog_tables_en_students %>%
  dplyr::slice(3) %>%
  dplyr::pull(url_table)

df_table <- tryCatch(expr = openxlsx::read.xlsx(tables_bfs_uni_students, startRow = 1),
    error = function(e) "Failed reading table") %>%
  dplyr::as_tibble()

df_table
```

    ## # A tibble: 6 × 2
    ##   Students.at.Universities.and.Institutes.of.Technology.(UIT).2022/23:.S…¹ X2   
    ##   <chr>                                                                    <chr>
    ## 1 "Definitions "                                                           Defi…
    ## 2 "Tab 1"                                                                  Entr…
    ## 3 "Tab 2"                                                                  Stud…
    ## 4 "Tab 3"                                                                  Stud…
    ## 5 "Tab 4"                                                                  Stud…
    ## 6 "Tab 5"                                                                  Fore…
    ## # ℹ abbreviated name:
    ## #   ¹​`Students.at.Universities.and.Institutes.of.Technology.(UIT).2022/23:.Standard.Tables`

## Main dependencies of the package

Under the hood, this package is using extensively the
<a href="https://ropengov.github.io/pxweb/index.html"
target="_blank">pxweb</a> R package to query the Swiss Federal
Statistical Office PXWEB API. PXWEB is an API structure developed by
Statistics Sweden and other national statistical institutions (NSI) to
disseminate public statistics in a structured way.

The list of available datasets is accessed using the
<a href="https://github.com/RobertMyles/tidyRSS"
target="_blank">tidyRSS</a> R package to scrap the official [BFS RSS
feed](https://www.bfs.admin.ch/bfs/en/home/statistiken/kataloge-datenbanken/daten/_jcr_content/par/ws_catalog.rss.xml?skipLimit=true).

You can clean the column names of the datasets automatically using
`janitor::clean_names()` by adding the argument `clean_names = TRUE` in
the `bfs_get_data()` function.

## Other information

A [blog
article](https://felixluginbuhl.com/blog/posts/2019-11-07-swiss-data/)
showing a concrete example about how to use the BFS package and to
visualize the data in a Swiss map.

This package is in no way officially related to or endorsed by the Swiss
Federal Statistical Office (BFS).

## Contribute

Any contribution is strongly appreciated. Feel free to report a bug, ask
any question or make a pull request for any remaining
[issue](https://github.com/lgnbhl/BFS/issues).
