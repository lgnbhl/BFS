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
datasets. The function `bfs_get_metadata()` returns a data frame/tibble
containing the titles, publication dates, observation periods, data
sources, website urls and download urls of all the BFS datasets
available in a given language. You can get the metadata in German (“de”,
by default), French (“fr”), Italian (“it”) or English (“en”). Note that
Italian and English metadata give access to less datasets.

``` r
meta_en <- bfs_get_metadata(language = "en")

head(meta_en)
```

    ## # A tibble: 6 x 6
    ##   title         observation_peri… published  source   url_bfs        url_px     
    ##   <chr>         <chr>             <chr>      <chr>    <chr>          <chr>      
    ## 1 University o… 1997-2019         25.03.2020 Federal… https://www.b… https://ww…
    ## 2 University o… 1997-2019         25.03.2020 Federal… https://www.b… https://ww…
    ## 3 University s… 1980-2019         25.03.2020 Federal… https://www.b… https://ww…
    ## 4 University s… 1990-2019         25.03.2020 Federal… https://www.b… https://ww…
    ## 5 Criminal off… 2009-2019         23.03.2020 Federal… https://www.b… https://ww…
    ## 6 Defendants r… 2009-2019         23.03.2020 Federal… https://www.b… https://ww…

### Search for data

To search for a specific dataset title in the BFS metadata, you can use
the `bfs_search()` function. This function leverages the R base function
`grepl()` but calls the `data` argument first to allow the use of the
pipe operator `%>%`.

``` r
library(magrittr)

meta_en_uni <- bfs_get_metadata("en") %>%
  bfs_search("university students")

print(meta_en_uni)
```

    ## # A tibble: 2 x 6
    ##   title         observation_peri… published  source   url_bfs        url_px     
    ##   <chr>         <chr>             <chr>      <chr>    <chr>          <chr>      
    ## 1 University s… 1980-2019         25.03.2020 Federal… https://www.b… https://ww…
    ## 2 University s… 1990-2019         25.03.2020 Federal… https://www.b… https://ww…

### Download dataset

To download a BFS dataset, add the related url link from the `url_px`
column of the downloaded metadata as an argument to the
`bfs_get_dataset()` function. You can choose the language (German,
French, Italian or English if any) in which the dataset is downloaded
with the `language` argument.

``` r
df_uni <- bfs_get_dataset(url_px = meta_en_uni$url_px[1], language = "en")

print(df_uni)
```

    ## # A tibble: 16,800 x 5
    ##    level_of_study                           gender isced_field      year   value
    ##    <fct>                                    <fct>  <fct>            <fct>  <dbl>
    ##  1 First university degree or diploma       Male   Education scien… 2019/…    46
    ##  2 Bachelor                                 Male   Education scien… 2019/…   149
    ##  3 Master                                   Male   Education scien… 2019/…   131
    ##  4 Doctorate                                Male   Education scien… 2019/…   120
    ##  5 Further education, advanced studies and… Male   Education scien… 2019/…    14
    ##  6 First university degree or diploma       Female Education scien… 2019/…    62
    ##  7 Bachelor                                 Female Education scien… 2019/…   696
    ##  8 Master                                   Female Education scien… 2019/…   540
    ##  9 Doctorate                                Female Education scien… 2019/…   313
    ## 10 Further education, advanced studies and… Female Education scien… 2019/…    24
    ## # … with 16,790 more rows

You can access additional information about the downloaded dataset using
the R base `attributes()` function.

``` r
attributes(df_uni) %>%
  str()
```

    ## List of 14
    ##  $ names        : chr [1:5] "level_of_study" "gender" "isced_field" "year" ...
    ##  $ row.names    : int [1:16800] 1 2 3 4 5 6 7 8 9 10 ...
    ##  $ download_date: Date[1:1], format: "2020-03-25"
    ##  $ contact      : chr "Section Educational Processes, e-mail  <a href=mailto:sius@bfs.admin.ch>sius@bfs.admin.ch</a>"
    ##  $ description  : chr "University students by year, ISCED field, gender and level of study"
    ##  $ last_update  : chr "20200325 08:30"
    ##  $ link         : chr "https://www.bfs.admin.ch/asset/en/px-x-1502040100_131"
    ##  $ note         : chr "<B>Meta information</B>#Data as of: 25.03.2020#Survey: Students and graduates in higher education institutions "| __truncated__
    ##  $ subject_area : chr "15 - Education and science"
    ##  $ survey       : chr "Students and degrees of higher education institutions (SHIS-studex)"
    ##  $ title        : chr "University students by Year, ISCED field, Gender and Level of study"
    ##  $ source       : chr "FSO - Students and degrees of higher education institutions - © FSO"
    ##  $ units        : chr "Person"
    ##  $ class        : chr [1:3] "tbl_df" "tbl" "data.frame"

In case the function fails to download the dataset, you can have a look
at its related BFS webpage using the `url_bfs` link.

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
be sure that you have the lastest data available. You can also force the
download using the `force` argument.

Other information
-----------------

A [blog article](https://felixluginbuhl.com/blog/2019/11/07/swiss-data)
showing a concret example about how to use the BFS package.

Alternative R package:
<a href="https://github.com/rOpenGov/pxweb" target="_blank">pxweb</a>.

This package is in no way officially related to or endorsed by the Swiss
Federal Statistical Office (BFS).
