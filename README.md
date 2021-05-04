
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/BFS)](https://CRAN.R-project.org/package=BFS)
[![Grand
total](https://cranlogs.r-pkg.org/badges/grand-total/BFS)](https://cran.r-project.org/package=BFS)
[![pipeline
status](https://gitlab.com/lgnbhl/BFS/badges/master/pipeline.svg)](https://gitlab.com/lgnbhl/BFS/pipelines)
[![R build
status](https://github.com/lgnbhl/BFS/workflows/R-CMD-check/badge.svg)](https://github.com/lgnbhl/BFS/actions)
<!-- badges: end -->

# BFS <img src="man/figures/logo.png" align="right" />

> Search and download data from the Swiss Federal Statistical Office

The `BFS` package allows to search and download public data from the
[Swiss Federal Statistical Office
(BFS)](https://www.bfs.admin.ch/bfs/en/home/statistics/catalogues-databases/data.html)
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

### Download metadata

To search and download data from the Swiss Federal Statistical Office,
you first need to retrieve information about the available public data
sets.

The function `bfs_get_metadata()` returns a data frame/tibble containing
the titles, publication dates, observation periods, data sources,
website URLs and download URLs of all the [BFS data sets
available](https://www.bfs.admin.ch/bfs/en/home/statistics/catalogues-databases/data.html)
in a given language. You can get the metadata in German (“de”, by
default), French (“fr”), Italian (“it”) or English (“en”). Note that
Italian and English metadata give access to less data sets.

``` r
meta_en <- bfs_get_metadata(language = "en")

meta_en
```

    ## # A tibble: 162 x 6
    ##    title        observation_period  published  source  url_bfs       url_px     
    ##    <chr>        <chr>               <chr>      <chr>   <chr>         <chr>      
    ##  1 Foreign cro~ 1.1.1999-31.3.2021  04.05.2021 Federa~ https://www.~ https://ww~
    ##  2 Retail Trad~ 1.1.2000-31.3.2021  30.04.2021 Federa~ https://www.~ https://ww~
    ##  3 Retail Trad~ 1.1.2000-31.3.2021  30.04.2021 Federa~ https://www.~ https://ww~
    ##  4 Retail Trad~ 2000-2020           30.04.2021 Federa~ https://www.~ https://ww~
    ##  5 New registr~ 1.1.2020-31.3.2020~ 13.04.2021 Federa~ https://www.~ https://ww~
    ##  6 Deaths per ~ 1803-2019           06.04.2021 Federa~ https://www.~ https://ww~
    ##  7 Hotel accom~ 1.1.2005-28.2.2021  06.04.2021 Federa~ https://www.~ https://ww~
    ##  8 Hotel accom~ 1.1.2005-28.2.2021  06.04.2021 Federa~ https://www.~ https://ww~
    ##  9 Hotel accom~ 1.1.2013-28.2.2021  06.04.2021 Federa~ https://www.~ https://ww~
    ## 10 Hotel secto~ 1.1.2005-28.2.2021  06.04.2021 Federa~ https://www.~ https://ww~
    ## # ... with 152 more rows

You can also get the catalog data by language based on the new RSS feed
provided by the Swiss Federal Statistical Office. Note that the number
of datasets available with `bfs_get_catalog()` may differ from the
output of the `bfs_get_metadata()`.

``` r
catalog_en <- bfs_get_catalog(language = "en")

catalog_en
```

    ## # A tibble: 162 x 5
    ##    title            language published           url_bfs           url_px       
    ##    <chr>            <chr>    <dttm>              <chr>             <chr>        
    ##  1 Foreign cross-b~ en       2021-05-04 08:30:00 https://www.bfs.~ https://www.~
    ##  2 Retail Trade Tu~ en       2021-04-30 08:30:00 https://www.bfs.~ https://www.~
    ##  3 Retail Trade Tu~ en       2021-04-30 08:30:00 https://www.bfs.~ https://www.~
    ##  4 Retail Trade Tu~ en       2021-04-30 08:30:00 https://www.bfs.~ https://www.~
    ##  5 New registratio~ en       2021-04-13 08:30:00 https://www.bfs.~ https://www.~
    ##  6 Deaths per mont~ en       2021-04-06 08:30:00 https://www.bfs.~ https://www.~
    ##  7 Hotel accommoda~ en       2021-04-06 08:30:00 https://www.bfs.~ https://www.~
    ##  8 Hotel accommoda~ en       2021-04-06 08:30:00 https://www.bfs.~ https://www.~
    ##  9 Hotel accommoda~ en       2021-04-06 08:30:00 https://www.bfs.~ https://www.~
    ## 10 Hotel sector: S~ en       2021-04-06 08:30:00 https://www.bfs.~ https://www.~
    ## # ... with 152 more rows

### Search for data

To search for a specific data set title in the BFS metadata, you can use
the `bfs_search()` function. This function leverages the R base function
`grepl()` but calls the `data` argument first to allow the use of the
pipe operator `%>%`.

``` r
library(magrittr)

meta_en_uni <- bfs_get_metadata("en") %>%
  bfs_search("university students")

meta_en_uni
```

    ## # A tibble: 2 x 6
    ##   title         observation_peri~ published  source   url_bfs        url_px     
    ##   <chr>         <chr>             <chr>      <chr>    <chr>          <chr>      
    ## 1 University s~ 1990-2020         26.03.2021 Federal~ https://www.b~ https://ww~
    ## 2 University s~ 1980-2020         26.03.2021 Federal~ https://www.b~ https://ww~

### Download data set

To download a BFS data set, add the related URL link from the `url_px`
column of the downloaded metadata as an argument to the `bfs_get_data
set()` function. For now, the data can be downloaded only in German.

``` r
df_uni <- bfs_get_dataset(url_px = meta_en_uni$url_px[2])

df_uni
```

    ## # A tibble: 17,220 x 5
    ##    studienstufe                     geschlecht isced_fach           jahr   value
    ##    <fct>                            <fct>      <fct>                <fct>  <dbl>
    ##  1 Lizenziat/Diplom                 Mann       Erziehungswissensch~ 1980/~   545
    ##  2 Bachelor                         Mann       Erziehungswissensch~ 1980/~     0
    ##  3 Master                           Mann       Erziehungswissensch~ 1980/~     0
    ##  4 Doktorat                         Mann       Erziehungswissensch~ 1980/~    93
    ##  5 Weiterbildung, Vertiefung und A~ Mann       Erziehungswissensch~ 1980/~    13
    ##  6 Lizenziat/Diplom                 Frau       Erziehungswissensch~ 1980/~   946
    ##  7 Bachelor                         Frau       Erziehungswissensch~ 1980/~     0
    ##  8 Master                           Frau       Erziehungswissensch~ 1980/~     0
    ##  9 Doktorat                         Frau       Erziehungswissensch~ 1980/~    70
    ## 10 Weiterbildung, Vertiefung und A~ Frau       Erziehungswissensch~ 1980/~    52
    ## # ... with 17,210 more rows

You can access additional information about the downloaded data set
using the R base `attributes()` function.

``` r
attributes(df_uni) %>%
  str()
```

    ## List of 14
    ##  $ names        : chr [1:5] "studienstufe" "geschlecht" "isced_fach" "jahr" ...
    ##  $ row.names    : int [1:17220] 1 2 3 4 5 6 7 8 9 10 ...
    ##  $ last_update  : chr "20210326 08:30"
    ##  $ download_date: Date[1:1], format: "2021-05-04"
    ##  $ contact      : chr "Sektion Bildungsprozesse, E-Mail: sius@bfs.admin.ch"
    ##  $ description  : chr "Studierende an den universitären Hochschulen nach Jahr, ISCED Fach, Geschlecht und Studienstufe"
    ##  $ link         : chr "https://www.bfs.admin.ch/asset/de/px-x-1502040100_131"
    ##  $ note         : chr "<B>Metainformation:</B>#Letzte Änderungen: Neuer Datensatz (Jahr 2020)#Stand der Datenbank: 26.03.2021#Erhebung"| __truncated__
    ##  $ subject_area : chr "15 - Bildung, Wissenschaft"
    ##  $ survey       : chr "Studierende und Abschlüsse der Hochschulen (SHIS-studex)"
    ##  $ title        : chr "Studierende an den universitären Hochschulen nach Jahr, ISCED Fach, Geschlecht und Studienstufe"
    ##  $ source       : chr "BFS - Studierende und Abschlüsse der Hochschulen - © BFS"
    ##  $ units        : chr "Student"
    ##  $ class        : chr [1:3] "tbl_df" "tbl" "data.frame"

In case the function fails to download the data set, you can have a look
at its related BFS webpage using the `url_bfs` link.

``` r
browseURL(meta_en_uni$url_bfs[1]) # open webpage
```

Sometimes the PC-Axis file of the data set doesn’t exist. You should
then use the “STAT-TAB - interactive table” service provided by BFS to
download manually the data set.

### Data caching

Data caching is handled using the [pins](https://pins.rstudio.com/) R
package. To open the folder containing all the BFS data sets you already
downloaded, you can use the `bfs_open_dir()` function.

``` r
bfs_open_dir()
```

If a data set has already been downloaded during the day, the functions
`bfs_get_metadata()` and `bfs_get_data set()` retrieve the already
downloaded data sets from your local pins caching folder. Caching speeds
up code and reduces BFS server requests. However, if a given data set
has not been downloaded during the day, the functions download it again
to be sure that you have the lastest data available. You can also force
the download using the `force` argument.

## Other information

A [blog
article](https://felixluginbuhl.com/blog/posts/2019-11-07-swiss-data/)
showing a concret example about how to use the BFS package.

Alternative R package: [pxweb](https://github.com/rOpenGov/pxweb).

This package is in no way officially related to or endorsed by the Swiss
Federal Statistical Office (BFS).
