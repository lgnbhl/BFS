
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
<a href="https://www.bfs.admin.ch/bfs/en/home/statistics/catalogues-databases/data.html" target="_blank">Swiss Federal Statistical Office</a>
(BFS is for *Bundesamt für Statistik* in German) in a dynamic and
reproducible way.

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
feed](https://www.bfs.admin.ch/bfs/en/home/statistiken/kataloge-datenbanken/daten/_jcr_content/par/ws_catalog.rss.xml?skipLimit=true).
Unfortunately, it seems that not all public data is listed inside the
RSS feed. Note also that Italian and English give access to less
datasets.

``` r
catalog_data_en <- bfs_get_catalog_data(language = "en")

catalog_data_en
```

    ## # A tibble: 170 x 5
    ##    title            language published           url_bfs           url_px       
    ##    <chr>            <chr>    <chr>               <chr>             <chr>        
    ##  1 Permanent resid~ en       Permanent resident~ https://www.bfs.~ https://www.~
    ##  2 Private househo~ en       Private households~ https://www.bfs.~ https://www.~
    ##  3 Hotel accommoda~ en       Hotel accommodatio~ https://www.bfs.~ https://www.~
    ##  4 Hotel accommoda~ en       Hotel accommodatio~ https://www.bfs.~ https://www.~
    ##  5 Hotel accommoda~ en       Hotel accommodatio~ https://www.bfs.~ https://www.~
    ##  6 Hotel sector: S~ en       Hotel sector: Supp~ https://www.bfs.~ https://www.~
    ##  7 Hotel sector: S~ en       Hotel sector: Supp~ https://www.bfs.~ https://www.~
    ##  8 Hotel sector: s~ en       Hotel sector: supp~ https://www.bfs.~ https://www.~
    ##  9 Retail Trade Tu~ en       Retail Trade Turno~ https://www.bfs.~ https://www.~
    ## 10 Retail Trade Tu~ en       Retail Trade Turno~ https://www.bfs.~ https://www.~
    ## # ... with 160 more rows

### Search for a specific dataset

``` r
library(dplyr)

catalog_data_uni <- catalog_data_en %>%
  filter(title == "University students by year, ISCED field, sex and level of study")

catalog_data_uni
```

    ## # A tibble: 1 x 5
    ##   title           language published          url_bfs             url_px        
    ##   <chr>           <chr>    <chr>              <chr>               <chr>         
    ## 1 University stu~ en       University studen~ https://www.bfs.ad~ https://www.b~

### Download a dataset in any language

To download a BFS dataset, add the related URL link from the `url_bfs`
column of the downloaded metadata as an argument to the `bfs_get_data()`
function.

``` r
df_uni <- bfs_get_data(url_bfs = catalog_data_uni$url_bfs, language = "en")
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
using the `bfs_get_data_comments()` function.

``` r
bfs_get_data_comments(url_bfs = catalog_data_uni$url_bfs, language = "en")
```

    ##   Downloading large query (in 4 batches):
    ##   |                                                                              |                                                                      |   0%  |                                                                              |==================                                                    |  25%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================================                  |  75%  |                                                                              |======================================================================| 100%

    ## # A tibble: 1 x 4
    ##   row_no col_no comment_type   comment                                          
    ##    <int>  <int> <chr>          <chr>                                            
    ## 1     NA      4 column_comment "To ensure that the presentations from cubes con~

In case the data is not present in the data catalog, you can add
manually the BFS number in the `bfs_get_data()` function using the
`number_bfs` argument. For example, if the data used until now as an
example is not accessible using `bfs_get_catalog()`, you could try to
find the BFS number manually:

``` r
# open webpage
browseURL("https://www.bfs.admin.ch/content/bfs/en/home/statistiken/kataloge-datenbanken/daten.assetdetail.16324907.html")
```

<img style="border:1px solid black;" src="https://raw.githubusercontent.com/lgnbhl/BFS/master/man/figures/screenshot.png" align="center" />

<br/>

You can use again `bfs_get_data()` but this time with the `number_bfs`
argument.

``` r
bfs_get_data(number_bfs = "px-x-1502040100_131", language = "en")
```

### Catalog of tables

A lot of file are not accessible through the API, but is still present
in the official BFS website. You can access the [RSS feed tables
catalog](https://www.bfs.admin.ch/bfs/en/home/statistiken/kataloge-datenbanken/tabellen/_jcr_content/par/ws_catalog.rss.xml?skipLimit=true)
using the `bfs_get_catalog_tables()`. Most of them are Excel files. Note
that only a part of all the public tables seem accessible using the RSS
feed.

``` r
catalog_tables_en <- bfs_get_catalog_tables(language = "en")

catalog_tables_en
```

    ## # A tibble: 350 x 5
    ##    title           language published           url_bfs          url_table      
    ##    <chr>           <chr>    <chr>               <chr>            <chr>          
    ##  1 Permanent resi~ en       Permanent resident~ https://www.bfs~ https://www.bf~
    ##  2 Permanent resi~ en       Permanent resident~ https://www.bfs~ https://www.bf~
    ##  3 Private househ~ en       Private households~ https://www.bfs~ https://www.bf~
    ##  4 Private househ~ en       Private households~ https://www.bfs~ https://www.bf~
    ##  5 Deaths per wee~ en       Deaths per week by~ https://www.bfs~ https://www.bf~
    ##  6 Deaths per wee~ en       Deaths per week by~ https://www.bfs~ https://www.bf~
    ##  7 Weekly number ~ en       Weekly number of d~ https://www.bfs~ https://www.bf~
    ##  8 CPI (december ~ en       CPI (december 2020~ https://www.bfs~ https://www.bf~
    ##  9 CPI (december ~ en       CPI (december 2020~ https://www.bfs~ https://www.bf~
    ## 10 CPI, Global in~ en       CPI, Global index ~ https://www.bfs~ https://www.bf~
    ## # ... with 340 more rows

``` r
library(dplyr)
library(openxlsx)

catalog_tables_en %>%
  filter(title == "Admissions to universities of applied sciences at diploma and bachelor level by fields of specialisation") %>%
  pull(url_table) %>%
  openxlsx::read.xlsx(startRow = 2) %>%
  as_tibble()
```

    ## # A tibble: 20 x 73
    ##    X1      `1997` X3    X4    `1998` X6    X7    `1999` X9    X10   `2000` X12  
    ##    <chr>   <chr>  <chr> <chr> <chr>  <chr> <chr> <chr>  <chr> <chr> <chr>  <chr>
    ##  1 Field ~ Women  Men   "Pro~ Women  Men   "Pro~ Women  Men   "Pro~ Women  Men  
    ##  2 Total   866    4010  "17.~ 1635   4857  "25.~ 1927   5267  "26.~ 2707   5772 
    ##  3 Archit~ 99     606   "14.~ 90     590   "13.~ 91     532   "14.~ 112    578  
    ##  4 Engine~ 45     1969  "2.2~ 64     2095  "2.9~ 90     2188  "3.9~ 86     2351 
    ##  5 Chemis~ 43     184   "18.~ 71     248   "22.~ 67     193   "25.~ 68     172  
    ##  6 Agricu~ 19     72    "20.~ 19     66    "22.~ 27     76    "26.~ 21     88   
    ##  7 Econom~ 451    1046  "30.~ 544    1350  "28.~ 710    1566  "31.~ 838    1506 
    ##  8 Design  148    101   "59.~ 221    137   "61.~ 226    189   "54.~ 277    196  
    ##  9 Sports  0      0     "*"   0      0     "*"   7      28    "20"  0      0    
    ## 10 Music,~ 0      0     "*"   276    178   "60.~ 269    298   "47.~ 804    675  
    ## 11 Applie~ 0      0     "*"   0      0     "*"   58     X     "X"   69     12   
    ## 12 Social~ 61     32    "65.~ 285    171   "62.~ 313    168   "65.~ 390    185  
    ## 13 Applie~ 0      0     "*"   39     21    "65"  39     16    "70.~ 42     9    
    ## 14 Health  0      0     "*"   26     X     "X"   30     9     "76.~ 0      0    
    ## 15 Teache~ 0      0     "*"   0      0     "*"   0      0     "*"   0      0    
    ## 16 * Not ~ <NA>   <NA>   <NA> <NA>   <NA>   <NA> <NA>   <NA>   <NA> <NA>   <NA> 
    ## 17 X Not ~ <NA>   <NA>   <NA> <NA>   <NA>   <NA> <NA>   <NA>   <NA> <NA>   <NA> 
    ## 18 Source~ <NA>   <NA>   <NA> <NA>   <NA>   <NA> <NA>   <NA>   <NA> <NA>   <NA> 
    ## 19 © FSO  <NA>   <NA>   <NA> <NA>   <NA>   <NA> <NA>   <NA>   <NA> <NA>   <NA> 
    ## 20 Inform~ <NA>   <NA>   <NA> <NA>   <NA>   <NA> <NA>   <NA>   <NA> <NA>   <NA> 
    ## # ... with 61 more variables: X13 <chr>, 2001 <chr>, X15 <chr>, X16 <chr>,
    ## #   2002 <chr>, X18 <chr>, X19 <chr>, 2003 <chr>, X21 <chr>, X22 <chr>,
    ## #   2004 <chr>, X24 <chr>, X25 <chr>, 2005 <chr>, X27 <chr>, X28 <chr>,
    ## #   2006 <chr>, X30 <chr>, X31 <chr>, 2007 <chr>, X33 <chr>, X34 <chr>,
    ## #   2008 <chr>, X36 <chr>, X37 <chr>, 2009 <chr>, X39 <chr>, X40 <chr>,
    ## #   2010 <chr>, X42 <chr>, X43 <chr>, 2011 <chr>, X45 <chr>, X46 <chr>,
    ## #   2012 <chr>, X48 <chr>, X49 <chr>, 2013 <chr>, X51 <chr>, X52 <chr>, ...

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

## Code of Conduct

Please note that the BFS project is released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
