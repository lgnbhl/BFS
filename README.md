
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

    ## # A tibble: 179 × 5
    ##    title                                       language published url_bfs url_px
    ##    <chr>                                       <chr>    <chr>     <chr>   <chr> 
    ##  1 New registrations of road vehicles by mont… en       New regi… https:… https…
    ##  2 Hotel accommodation: arrivals and overnigh… en       Hotel ac… https:… https…
    ##  3 Hotel accommodation: arrivals and overnigh… en       Hotel ac… https:… https…
    ##  4 Hotel accommodation: arrivals and overnigh… en       Hotel ac… https:… https…
    ##  5 Hotel sector: Supply and demand of open es… en       Hotel se… https:… https…
    ##  6 Hotel sector: Supply and demand of open es… en       Hotel se… https:… https…
    ##  7 Hotel sector: supply and demand of open es… en       Hotel se… https:… https…
    ##  8 Employees, farmholdings, utilized agricult… en       Employee… https:… https…
    ##  9 Foreign cross-border commuter by canton of… en       Foreign … https:… https…
    ## 10 Foreign cross-border commuters by canton o… en       Foreign … https:… https…
    ## # ℹ 169 more rows

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

    ## # A tibble: 1 × 5
    ##   title                                        language published url_bfs url_px
    ##   <chr>                                        <chr>    <chr>     <chr>   <chr> 
    ## 1 University students by year, ISCED field, s… en       Universi… https:… https…

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

You may also have an error the API calls too many requests.

    Error in pxweb_advanced_get(url = url, query = query, verbose = verbose) : 
      Too Many Requests (RFC 6585) (HTTP 429).

One solution is too query only specific elements of the dataset to
download less data. Here an example.

First you want to get the variable names, i.e. `code`, and categories,
i.e. `values`, of your dataset.

``` r
# choose a BFS number and language
bfs_get_metadata(number_bfs = "px-x-1502040100_131", language = "en")
```

    ## # A tibble: 4 × 6
    ##   code         text           values     valueTexts time  elimination
    ##   <chr>        <chr>          <list>     <list>     <lgl> <lgl>      
    ## 1 Jahr         Year           <chr [43]> <chr [43]> TRUE  NA         
    ## 2 ISCED Fach   ISCED Field    <chr [42]> <chr [42]> NA    TRUE       
    ## 3 Geschlecht   Sex            <chr [2]>  <chr [2]>  NA    TRUE       
    ## 4 Studienstufe Level of study <chr [5]>  <chr [5]>  NA    TRUE

Then you can manually select the dimensions of the dataset you want to
query.

``` r
# Manually create BFS query dimensions
# Use `code` and `values` elements in `px_meta$variables`
# Use "*" to select all
dimensions <- list(
  "Jahr" = c("40", "41"),
  "ISCED Fach" = c("0"),
  "Geschlecht" = c("0", "1"),
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
catalog](https://www.bfs.admin.ch/bfs/en/home/statistiken/kataloge-datenbanken/tabellen/_jcr_content/par/ws_catalog.rss.xml?skipLimit=true)
using `bfs_get_catalog_tables()`. Most of these tables are Excel or CSV
files. Note again that only a part of all the public tables accessible
are in the RSS feed (the most recently updated datasets).

``` r
catalog_tables_en <- bfs_get_catalog_tables(language = "en")

catalog_tables_en
```

    ## # A tibble: 350 × 5
    ##    title                                    language published url_bfs url_table
    ##    <chr>                                    <chr>    <chr>     <chr>   <chr>    
    ##  1 Deaths per week by 5-year age group, se… en       Deaths p… https:… https://…
    ##  2 Deaths per week by 5-year age group, se… en       Deaths p… https:… https://…
    ##  3 Weekly number of deaths, 2010-2023       en       Weekly n… https:… https://…
    ##  4 Employed persons (domestic concept) tot… en       Employed… https:… https://…
    ##  5 Employed persons working in Switzerland  en       Employed… https:… https://…
    ##  6 Index values, 1st quarter 2019 - 1st qu… en       Index va… https:… https://…
    ##  7 Rates of change compared with the previ… en       Rates of… https:… https://…
    ##  8 Rates of change compared with the same … en       Rates of… https:… https://…
    ##  9 Statistical key figure, 1st quarter 202… en       Statisti… https:… https://…
    ## 10 The weights of the subindices: Weights … en       The weig… https:… https://…
    ## # ℹ 340 more rows

``` r
library(dplyr)
library(openxlsx)

index_table_url <- catalog_tables_en %>%
  filter(grepl("index", title)) %>% # search table
  slice(1) %>%
  pull(url_table)

df <- tryCatch(expr = openxlsx::read.xlsx(index_table_url, startRow = 1),
    error = function(e) "Failed reading table") %>%
  as_tibble()

df
```

    ## # A tibble: 33 × 19
    ##    Sprache./.Langue./.Li…¹ X2    X3    X4    X5    X6    X7    X8    X9    X10  
    ##    <chr>                   <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
    ##  1 "Indexwerte, 1. Quarta…  <NA> <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA> 
    ##  2 "Schweizerischer Wohni…  <NA> <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA> 
    ##  3  <NA>                   "Woh… <NA>  <NA>  <NA>  <NA>  <NA>  Einf… <NA>  <NA> 
    ##  4 "Totalindex und Subind… "Tot… Geme… Geme… Geme… Geme… Geme… EFH   Geme… Geme…
    ##  5 "Q1 2019"               "97.… 95.5… 98.1… 97.7… 99.6… 97.7… 97.0… 95.2… 97.1…
    ##  6 "Q2 2019"               "98.… 97.7… 98.7… 99.1… 98.3… 97.1… 98.2… 98.1… 98.2…
    ##  7 "Q3 2019"               "98.… 96.9… 100.… 98.0… 98.7… 97.5… 98.5… 97.4… 100.…
    ##  8 "Q4 2019"               "100" 100   100   100   100   100   100   100   100  
    ##  9 "Q1 2020"               "99.… 98.8… 99.2… 98.3… 100.… 99.1… 99.4… 100.… 99.1…
    ## 10 "Q2 2020"               "100… 100.… 100.… 99.8… 100.… 99.8… 100.… 100.… 100.…
    ## # ℹ 23 more rows
    ## # ℹ abbreviated name: ¹​`Sprache./.Langue./.Lingua./.Language`
    ## # ℹ 9 more variables: X11 <chr>, X12 <chr>, X13 <chr>, X14 <chr>, X15 <chr>,
    ## #   X16 <chr>, X17 <chr>, X18 <chr>, X19 <chr>

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
