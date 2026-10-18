
<!-- README.md is generated from README.Rmd. Please edit that file -->

# BFS <img src="man/figures/logo.png" align="right" height="138" alt="BFS hex logo" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/BFS)](https://CRAN.R-project.org/package=BFS)
[![Grand
total](https://cranlogs.r-pkg.org/badges/grand-total/BFS)](https://cran.r-project.org/package=BFS)
[![R-CMD-check](https://github.com/lgnbhl/BFS/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lgnbhl/BFS/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/lgnbhl/BFS/graph/badge.svg)](https://app.codecov.io/gh/lgnbhl/BFS)
<!-- badges: end -->

> Search and download data from the Swiss Federal Statistical Office

BFS gives you the open data of the [Swiss Federal Statistical
Office](https://www.bfs.admin.ch/bfs/en/home/statistics/catalogue.html)
(BFS, *Bundesamt für Statistik*) in R. You get tidy data frames, in
German, French, Italian or English. The package works with the four APIs
of the BFS:

| You want | Use | API |
|----|----|----|
| Statistics of the Swiss Stats Explorer | `bfs_sse_datasets()`, `bfs_sse_dimensions()`, `bfs_sse_data()` | [Swiss Stats Explorer](https://stats.swiss/) |
| Datasets of the BFS data catalog | `bfs_get_catalog_data()`, `bfs_get_data()` | [PXWeb](https://www.pxweb.bfs.admin.ch/pxweb/en/) |
| Tables and files (Excel, CSV, PX, …) | `bfs_get_catalog_tables()`, `bfs_download_asset()` | [DAM](https://dam-api.bfs.admin.ch/hub/swagger-ui/index.html) |
| Maps and geodata | `bfs_get_base_maps()`, `bfs_get_catalog_geodata()`, `bfs_download_geodata()` | [ThemaKart](https://www.bfs.admin.ch/bfs/en/home/statistics/regional-statistics/base-maps/cartographic-bases.html), [STAC](https://data.geo.admin.ch/api/stac/v0.9/) |

The BFS is replacing STAT-TAB (the platform of the PXWeb API) with the
Swiss Stats Explorer. See [Get
started](https://felixluginbuhl.com/BFS/articles/introduction.html#from-stat-tab-to-the-swiss-stats-explorer).

<p class="buttons">

<a href="https://felixluginbuhl.com/BFS/articles/introduction.html">Get
started</a>
<a href="https://felixluginbuhl.com/BFS/articles/swiss-stats-explorer.html">Swiss
Stats Explorer</a>
<a href="https://felixluginbuhl.com/BFS/articles/tables-and-files.html">Tables
and files</a>
</p>

## Installation

``` r
install.packages("BFS")

# or the development version
# install.packages("remotes")
remotes::install_github("lgnbhl/BFS")
```

## Quick tour

``` r
library(BFS)
```

### Swiss Stats Explorer

Let’s get the vacancy rate (the share of empty homes, in %) of the
cantons of Geneva, Zurich and Bern. The dataset is `DF_LWZ_1`, the
vacant dwellings. You find this id with `bfs_sse_datasets()`, or in the
URL of the dataset on [stats.swiss](https://stats.swiss/).

First, see the dimensions of the dataset and the codes of their values.
Then download the data with the codes you need:

``` r
dimensions <- bfs_sse_dimensions("DF_LWZ_1", language = "en")
dimensions
```

    ## # A tibble: 2,317 × 6
    ##    dimension dimension_label                 value value_label   position parent
    ##    <chr>     <chr>                           <chr> <chr>            <int> <chr> 
    ##  1 GR_KT_GDE Cantons, districts and communes 1     Aeugst am Al…        1 B_101 
    ##  2 GR_KT_GDE Cantons, districts and communes 10    Obfelden             1 B_101 
    ##  3 GR_KT_GDE Cantons, districts and communes 100   Stadel               1 B_104 
    ##  4 GR_KT_GDE Cantons, districts and communes 1001  Doppleschwand        1 B_316 
    ##  5 GR_KT_GDE Cantons, districts and communes 1002  Entlebuch            1 B_316 
    ##  6 GR_KT_GDE Cantons, districts and communes 1004  Flühli               1 B_316 
    ##  7 GR_KT_GDE Cantons, districts and communes 1005  Hasle (LU)           1 B_316 
    ##  8 GR_KT_GDE Cantons, districts and communes 1007  Romoos               1 B_316 
    ##  9 GR_KT_GDE Cantons, districts and communes 1008  Schüpfheim           1 B_316 
    ## 10 GR_KT_GDE Cantons, districts and communes 1009  Werthenstein         1 B_316 
    ## # ℹ 2,307 more rows

``` r
bfs_sse_data(
  "DF_LWZ_1",
  filters = list(
    GR_KT_GDE = c("GE", "ZH", "BE"), # the cantons of Geneva, Zurich and Bern
    WOHN_ANZAHL = "_T",              # all numbers of rooms
    LEERWOHN_TYP = "_T",             # all types of vacant dwellings
    MEASURE_DIMENSION = "RATE"       # the vacancy rate, in %
  ),
  start_period = "2020",
  language = "en"
)
```

    ## # A tibble: 21 × 12
    ##    GR_KT_GDE GR_KT_GDE_label WOHN_ANZAHL WOHN_ANZAHL_label LEERWOHN_TYP
    ##    <chr>     <chr>           <chr>       <chr>             <chr>       
    ##  1 ZH        Zurich          _T          Total             _T          
    ##  2 ZH        Zurich          _T          Total             _T          
    ##  3 ZH        Zurich          _T          Total             _T          
    ##  4 ZH        Zurich          _T          Total             _T          
    ##  5 ZH        Zurich          _T          Total             _T          
    ##  6 ZH        Zurich          _T          Total             _T          
    ##  7 ZH        Zurich          _T          Total             _T          
    ##  8 BE        Bern            _T          Total             _T          
    ##  9 BE        Bern            _T          Total             _T          
    ## 10 BE        Bern            _T          Total             _T          
    ## # ℹ 11 more rows
    ## # ℹ 7 more variables: LEERWOHN_TYP_label <chr>, MEASURE_DIMENSION <chr>,
    ## #   MEASURE_DIMENSION_label <chr>, FREQ <chr>, FREQ_label <chr>,
    ## #   TIME_PERIOD <chr>, value <dbl>

### Data catalog

Search the BFS data catalog. Then download a dataset with its BFS
number.

``` r
bfs_get_catalog_data(language = "en", extended_search = "university students")
```

    ## # A tibble: 4 × 6
    ##   title                 language number_bfs number_asset publication_date url_px
    ##   <chr>                 <chr>    <chr>      <chr>        <date>           <chr> 
    ## 1 University of applie… en       px-x-1502… 36454608     2026-03-24       https…
    ## 2 University of applie… en       px-x-1502… 36454606     2026-03-24       https…
    ## 3 University students … en       px-x-1502… 36454426     2026-03-24       https…
    ## 4 University students … en       px-x-1502… 36454424     2026-03-24       https…

``` r
bfs_get_data(number_bfs = "px-x-1502040100_131", language = "en")
```

    ## # A tibble: 19,320 × 5
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
    ## # ℹ 19,310 more rows

### Tables and files

The BFS publishes many statistics as Excel or CSV tables. Search them.
Then download a file with its asset number.

``` r
tables <- bfs_get_catalog_tables(language = "en", extended_search = "students")
tables
```

    ## # A tibble: 6 × 5
    ##   title                          language number_asset publication_date order_nr
    ##   <chr>                          <chr>    <chr>        <date>           <chr>   
    ## 1 Students at universities and … en       36460671     2026-03-24       ts-x-15…
    ## 2 Students at universities and … en       36460677     2026-03-24       su-e-15…
    ## 3 Students at universities of a… en       36460666     2026-03-24       ts-x-15…
    ## 4 Students at universities of a… en       36460675     2026-03-24       su-e-15…
    ## 5 Students at universities of t… en       36460673     2026-03-24       su-e-15…
    ## 6 Students at universities of a… en       7746958      2019-03-27       su-e-15…

``` r
bfs_download_asset(number_asset = tables$number_asset[1], destfile = "students.xlsx")
```

### Maps

Get the official borders of Switzerland, the cantons, the districts or
the communes as sf objects.

``` r
library(ggplot2)

ggplot(bfs_get_base_maps(geom = "kant")) +
  geom_sf() +
  theme_void()
```

## Learn more

- [Get
  started](https://felixluginbuhl.com/BFS/articles/introduction.html):
  which API for which data, and the move from STAT-TAB to the Swiss
  Stats Explorer.
- [Swiss Stats
  Explorer](https://felixluginbuhl.com/BFS/articles/swiss-stats-explorer.html):
  find a dataset, choose the data and download it, step by step.
- [Data catalog and PXWeb
  datasets](https://felixluginbuhl.com/BFS/articles/pxweb.html): search
  the catalog and download all or part of a dataset.
- [Tables and
  files](https://felixluginbuhl.com/BFS/articles/tables-and-files.html):
  download any BFS file.
- [Geodata and base
  maps](https://felixluginbuhl.com/BFS/articles/geodata.html): maps of
  Switzerland and geodata of the Swiss geo-portal.
- [API errors and rate
  limits](https://felixluginbuhl.com/BFS/articles/troubleshooting.html):
  what to do when an API is not available.

## Related packages

- [pxweb](https://ropengov.github.io/pxweb/): the PXWeb client used by
  BFS.
- [rstac](https://brazil-data-cube.github.io/rstac/): the STAC client
  used by `bfs_download_geodata()`.
- [swissMunicipalities](https://github.com/SwissStatsR/swissMunicipalities):
  the historicized list of Swiss communes.
- [I14Y](https://felixluginbuhl.com/I14Y/): the metadata of the Swiss
  interoperability platform I14Y.

## Contributing

BFS is not affiliated with the Swiss Federal Statistical Office. Bug
reports, questions and pull requests are welcome on
[GitHub](https://github.com/lgnbhl/BFS/issues).
