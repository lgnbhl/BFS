
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

Due to a bug of a dependency of the package (i.e. `tidyRSS`), `BFS` is
currently only available from GitHub.

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
    ##    title                                          langu~1 publi~2 url_bfs url_px
    ##    <chr>                                          <chr>   <chr>   <chr>   <chr> 
    ##  1 Secondary Sector Production, Orders and Turno~ en      Second~ https:~ https~
    ##  2 Secondary Sector Production, Orders and Turno~ en      Second~ https:~ https~
    ##  3 New registrations of road vehicles by month (~ en      New re~ https:~ https~
    ##  4 Hotel accommodation: arrivals and overnight s~ en      Hotel ~ https:~ https~
    ##  5 Hotel accommodation: arrivals and overnight s~ en      Hotel ~ https:~ https~
    ##  6 Hotel accommodation: arrivals and overnight s~ en      Hotel ~ https:~ https~
    ##  7 Hotel sector: Supply and demand of open estab~ en      Hotel ~ https:~ https~
    ##  8 Hotel sector: Supply and demand of open estab~ en      Hotel ~ https:~ https~
    ##  9 Hotel sector: supply and demand of open estab~ en      Hotel ~ https:~ https~
    ## 10 Foreign cross-border commuter by canton of wo~ en      Foreig~ https:~ https~
    ## # ... with 166 more rows, and abbreviated variable names 1: language,
    ## #   2: published

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
    ##   title                                           langu~1 publi~2 url_bfs url_px
    ##   <chr>                                           <chr>   <chr>   <chr>   <chr> 
    ## 1 University students by year, ISCED field, sex ~ en      Univer~ https:~ https~
    ## # ... with abbreviated variable names 1: language, 2: published

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
    ##    Year    `ISCED Field`     Sex    `Level of study`                     Unive~1
    ##    <chr>   <chr>             <chr>  <chr>                                  <dbl>
    ##  1 1980/81 Education science Male   First university degree or diploma       545
    ##  2 1980/81 Education science Male   Bachelor                                   0
    ##  3 1980/81 Education science Male   Master                                     0
    ##  4 1980/81 Education science Male   Doctorate                                 93
    ##  5 1980/81 Education science Male   Further education, advanced studies~      13
    ##  6 1980/81 Education science Female First university degree or diploma       946
    ##  7 1980/81 Education science Female Bachelor                                   0
    ##  8 1980/81 Education science Female Master                                     0
    ##  9 1980/81 Education science Female Doctorate                                 70
    ## 10 1980/81 Education science Female Further education, advanced studies~      52
    ## # ... with 17,630 more rows, and abbreviated variable name
    ## #   1: `University students`

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
    ##    title                                         langu~1 publi~2 url_bfs url_t~3
    ##    <chr>                                         <chr>   <chr>   <chr>   <chr>  
    ##  1 Monthly industrial development - adjusted fo~ en      Monthl~ https:~ https:~
    ##  2 Monthly industrial development - non adjusted en      Monthl~ https:~ https:~
    ##  3 Monthly industrial development - seasonally ~ en      Monthl~ https:~ https:~
    ##  4 Quarterly development in secondary sector - ~ en      Quarte~ https:~ https:~
    ##  5 Quarterly development in secondary sector - ~ en      Quarte~ https:~ https:~
    ##  6 Quarterly development in secondary sector - ~ en      Quarte~ https:~ https:~
    ##  7 Employed persons (domestic concept) total nu~ en      Employ~ https:~ https:~
    ##  8 Employed persons working in Switzerland       en      Employ~ https:~ https:~
    ##  9 Deaths per week by 5-year age group, sex and~ en      Deaths~ https:~ https:~
    ## 10 Deaths per week by 5-year age group, sex and~ en      Deaths~ https:~ https:~
    ## # ... with 340 more rows, and abbreviated variable names 1: language,
    ## #   2: published, 3: url_table

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

    ##                                                     Sprache./.Langue./.Lingua./.Language
    ## 1                                          Indexwerte, 1. Quartal 2019 - 2. Quartal 2022
    ## 2                                         Schweizerischer Wohnimmobilienpreisindex, IMPI
    ## 3                                      Totalindex und Subindizes (Basis: Q4 2019 = 100) 
    ## 4                                                                                 Total 
    ## 5                                                                          GemeindeTyp 1
    ## 6                                                                          GemeindeTyp 2
    ## 7                                                                          GemeindeTyp 3
    ## 8                                                                          GemeindeTyp 4
    ## 9                                                                          GemeindeTyp 5
    ## 10                                                                                   EFH
    ## 11                                                                         GemeindeTyp 1
    ## 12                                                                         GemeindeTyp 2
    ## 13                                                                         GemeindeTyp 3
    ## 14                                                                         GemeindeTyp 4
    ## 15                                                                         GemeindeTyp 5
    ## 16                                                                                   EGW
    ## 17                                                                         GemeindeTyp 1
    ## 18                                                                         GemeindeTyp 2
    ## 19                                                                         GemeindeTyp 3
    ## 20                                                                         GemeindeTyp 4
    ## 21                                                                         GemeindeTyp 5
    ## 22                                                                              Legende:
    ## 23                                                    Total - Wohneigentum (EFH und EGW)
    ## 24                                                               EFH - Einfamilienhäuser
    ## 25                                                             EGW - Eigentumswohnungen 
    ## 26                       GemeindeTyp 1 - Städtische Gemeinde einer grossen Agglomeration
    ## 27                 GemeindeTyp 2 - Städtische Gemeinde einer mittelgrossen Agglomeration
    ## 28 GemeindeTyp 3 - Städtische Gemeinde einer kleinen oder ausserhalb einer Agglomeration
    ## 29                                                GemeindeTyp 4 - Intermediäre Gemeinde 
    ## 30                                                    GemeindeTyp 5 - Ländliche Gemeinde
    ## 31                          Quelle: BFS - Schweizerischer Wohnimmobilienpreisindex, IMPI
    ## 32                                                                            © BFS 2022
    ## 33     Auskunft: Bundesamt für Statistik (BFS), IMPI@bfs.admin.ch, Tel. +41 58 463 60 69
    ##                    X2                 X3                 X4      X5
    ## 1                <NA>               <NA>               <NA>    <NA>
    ## 2                <NA>               <NA>               <NA>    <NA>
    ## 3             Q1 2019            Q2 2019            Q3 2019 Q4 2019
    ## 4  97.627499999999998 98.135900000000007 98.272099999999995     100
    ## 5  95.586200000000005 97.743099999999998 96.994600000000005     100
    ## 6  98.126499999999993 98.722999999999999           100.4299     100
    ## 7  97.738200000000006 99.197900000000004 98.072299999999998     100
    ## 8  99.620400000000004 98.361000000000004 98.712900000000005     100
    ## 9             97.7453 97.192599999999999 97.532399999999996     100
    ## 10 97.070599999999999 98.208699999999993 98.573499999999996     100
    ## 11 95.286900000000003 98.134399999999999 97.421899999999994     100
    ## 12 97.159000000000006 98.297399999999996           100.4693     100
    ## 13 96.283600000000007 98.295199999999994 98.060500000000005     100
    ## 14 98.876800000000003 98.199600000000004 98.940100000000001     100
    ## 15 97.156499999999994 98.214299999999994 98.194900000000004     100
    ## 16 98.166200000000003 98.065399999999997 97.980699999999999     100
    ## 17 95.816999999999993 97.441299999999998 96.665000000000006     100
    ## 18 98.871899999999997 99.050899999999999 100.39960000000001     100
    ## 19 98.747699999999995 99.824399999999997 98.080399999999997     100
    ## 20           100.5461 98.561800000000005 98.430099999999996     100
    ## 21 98.701599999999999 95.532899999999998 96.456400000000002     100
    ## 22               <NA>               <NA>               <NA>    <NA>
    ## 23               <NA>               <NA>               <NA>    <NA>
    ## 24               <NA>               <NA>               <NA>    <NA>
    ## 25               <NA>               <NA>               <NA>    <NA>
    ## 26               <NA>               <NA>               <NA>    <NA>
    ## 27               <NA>               <NA>               <NA>    <NA>
    ## 28               <NA>               <NA>               <NA>    <NA>
    ## 29               <NA>               <NA>               <NA>    <NA>
    ## 30               <NA>               <NA>               <NA>    <NA>
    ## 31               <NA>               <NA>               <NA>    <NA>
    ## 32               <NA>               <NA>               <NA>    <NA>
    ## 33               <NA>               <NA>               <NA>    <NA>
    ##                    X6                 X7                 X8                 X9
    ## 1                <NA>               <NA>               <NA>               <NA>
    ## 2                <NA>               <NA>               <NA>               <NA>
    ## 3             Q1 2020            Q2 2020            Q3 2020            Q4 2020
    ## 4  99.244299999999996 100.59690000000001 100.81529999999999           103.1292
    ## 5  98.852900000000005 100.57899999999999           101.3617           102.6234
    ## 6  99.277500000000003 100.99299999999999 101.30029999999999            103.962
    ## 7  98.334900000000005 99.890299999999996 100.51479999999999 102.91930000000001
    ## 8            100.0419 100.98180000000001 99.951599999999999           102.8875
    ## 9  99.184200000000004 99.895700000000005            100.759           103.7079
    ## 10 99.451400000000007           100.5419           101.6683            103.154
    ## 11            100.432           100.5612           103.2119 103.69119999999999
    ## 12 99.155900000000003           100.3563            101.526           103.6537
    ## 13 98.752200000000002             100.04 100.92529999999999           101.2222
    ## 14 98.990700000000004           101.0146           100.0134           102.4526
    ## 15 99.191100000000006           100.1371 102.29730000000001             103.82
    ## 16 99.052000000000007            100.648           100.0234           103.1062
    ## 17 97.590299999999999           100.5933 99.882499999999993           101.7697
    ## 18 99.359099999999998           101.4198            101.149           104.1687
    ## 19 98.039199999999994 99.784199999999998           100.2239 104.12179999999999
    ## 20 101.26349999999999           100.9436            99.8797           103.3927
    ## 21 99.173900000000003 99.529799999999994 98.427599999999998 103.53789999999999
    ## 22               <NA>               <NA>               <NA>               <NA>
    ## 23               <NA>               <NA>               <NA>               <NA>
    ## 24               <NA>               <NA>               <NA>               <NA>
    ## 25               <NA>               <NA>               <NA>               <NA>
    ## 26               <NA>               <NA>               <NA>               <NA>
    ## 27               <NA>               <NA>               <NA>               <NA>
    ## 28               <NA>               <NA>               <NA>               <NA>
    ## 29               <NA>               <NA>               <NA>               <NA>
    ## 30               <NA>               <NA>               <NA>               <NA>
    ## 31               <NA>               <NA>               <NA>               <NA>
    ## 32               <NA>               <NA>               <NA>               <NA>
    ## 33               <NA>               <NA>               <NA>               <NA>
    ##                   X10                X11                X12                X13
    ## 1                <NA>               <NA>               <NA>               <NA>
    ## 2                <NA>               <NA>               <NA>               <NA>
    ## 3             Q1 2021            Q2 2021            Q3 2021            Q4 2021
    ## 4            103.0749 105.33799999999999           107.8175           110.6721
    ## 5            103.5239 105.53230000000001           108.8904 109.43689999999999
    ## 6  103.23260000000001 104.09990000000001 106.95359999999999           112.3689
    ## 7            103.8353           106.1336 107.34310000000001            109.902
    ## 8            103.1195           105.9314           107.5295           110.3694
    ## 9            101.5973 105.02200000000001 107.59350000000001           112.0684
    ## 10           103.2623           105.9631           108.4884           111.4037
    ## 11           104.3719 107.19710000000001 108.83199999999999           110.2594
    ## 12           102.7499 103.32259999999999 106.60980000000001           113.1674
    ## 13           104.5064 106.60899999999999 110.21040000000001           112.9512
    ## 14 103.74290000000001           106.3999 109.08199999999999           110.5641
    ## 15            100.999           105.6148           108.0384           112.0476
    ## 16            102.905           104.7728           107.2109           110.0106
    ## 17           102.8296 104.24160000000001 108.85250000000001           108.7569
    ## 18 103.57089999999999           104.6601           107.1863           111.7389
    ## 19           103.3647           105.8013            105.321           107.7514
    ## 20           102.4786           105.4594           105.8839           110.1953
    ## 21           102.4387           104.1678           106.9496           112.0868
    ## 22               <NA>               <NA>               <NA>               <NA>
    ## 23               <NA>               <NA>               <NA>               <NA>
    ## 24               <NA>               <NA>               <NA>               <NA>
    ## 25               <NA>               <NA>               <NA>               <NA>
    ## 26               <NA>               <NA>               <NA>               <NA>
    ## 27               <NA>               <NA>               <NA>               <NA>
    ## 28               <NA>               <NA>               <NA>               <NA>
    ## 29               <NA>               <NA>               <NA>               <NA>
    ## 30               <NA>               <NA>               <NA>               <NA>
    ## 31               <NA>               <NA>               <NA>               <NA>
    ## 32               <NA>               <NA>               <NA>               <NA>
    ## 33               <NA>               <NA>               <NA>               <NA>
    ##                   X14                X15
    ## 1                <NA>               <NA>
    ## 2                <NA>               <NA>
    ## 3             Q1 2022            Q2 2022
    ## 4            110.2636 113.21899999999999
    ## 5            111.6322 115.81829999999999
    ## 6              109.57            110.827
    ## 7            106.6691           109.6982
    ## 8  111.04300000000001           112.7697
    ## 9            109.4881 114.05500000000001
    ## 10           112.0222           114.3068
    ## 11           115.6568           116.6793
    ## 12           111.6066           111.2197
    ## 13           108.1986 112.99590000000001
    ## 14 111.17570000000001           114.1758
    ## 15           110.1499           114.2756
    ## 16           108.6991 112.24379999999999
    ## 17           108.6172 115.10550000000001
    ## 18           108.0515           110.4893
    ## 19           105.4674           107.3943
    ## 20           110.9359           111.2927
    ## 21 108.59059999999999 113.74930000000001
    ## 22               <NA>               <NA>
    ## 23               <NA>               <NA>
    ## 24               <NA>               <NA>
    ## 25               <NA>               <NA>
    ## 26               <NA>               <NA>
    ## 27               <NA>               <NA>
    ## 28               <NA>               <NA>
    ## 29               <NA>               <NA>
    ## 30               <NA>               <NA>
    ## 31               <NA>               <NA>
    ## 32               <NA>               <NA>
    ## 33               <NA>               <NA>

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
