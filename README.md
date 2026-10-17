
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
(BFS, *Bundesamt für Statistik*) in R, as tidy data frames, in German,
French, Italian or English. It covers the four APIs of the BFS:

| You want | Use | API |
|----|----|----|
| Statistics of the Swiss Stats Explorer | `bfs_get_sse_metadata()`, `bfs_get_sse_data()` | [Swiss Stats Explorer](https://stats.swiss/) |
| Datasets of the BFS data catalog | `bfs_get_catalog_data()`, `bfs_get_data()` | [PXWeb](https://www.pxweb.bfs.admin.ch/pxweb/en/) |
| Tables and files (Excel, CSV, PX, …) | `bfs_get_catalog_tables()`, `bfs_download_asset()` | [DAM](https://dam-api.bfs.admin.ch/hub/swagger-ui/index.html) |
| Maps and geodata | `bfs_get_base_maps()`, `bfs_get_catalog_geodata()`, `bfs_download_geodata()` | [ThemaKart](https://www.bfs.admin.ch/bfs/en/home/statistics/regional-statistics/base-maps/cartographic-bases.html), [STAC](https://data.geo.admin.ch/api/stac/v0.9/) |

The BFS is replacing STAT-TAB, the platform of the PXWeb API, with the
Swiss Stats Explorer: see [Get
started](https://felixluginbuhl.com/BFS/articles/introduction.html#from-stat-tab-to-the-swiss-stats-explorer).

<p class="buttons">

<a href="https://felixluginbuhl.com/BFS/articles/introduction.html">Get
started</a>
<a href="https://felixluginbuhl.com/BFS/reference/index.html">Reference</a>
<a href="https://github.com/lgnbhl/BFS">GitHub</a>
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

Get the codelists of a dataset, pick the codes you need, and download
the data. The dataset id (here `DF_LWZ_1`, the vacant dwellings) is in
the URL of the dataset on [stats.swiss](https://stats.swiss/).

``` r
codelist <- bfs_get_sse_metadata("DF_LWZ_1", language = "en")
codelist
```

    ## # A tibble: 2,317 × 5
    ##    code      text                            value valueText  position_dimension
    ##    <chr>     <chr>                           <chr> <chr>                   <int>
    ##  1 GR_KT_GDE Cantons, districts and communes 1     Aeugst am…                  1
    ##  2 GR_KT_GDE Cantons, districts and communes 10    Obfelden                    1
    ##  3 GR_KT_GDE Cantons, districts and communes 100   Stadel                      1
    ##  4 GR_KT_GDE Cantons, districts and communes 1001  Dopplesch…                  1
    ##  5 GR_KT_GDE Cantons, districts and communes 1002  Entlebuch                   1
    ##  6 GR_KT_GDE Cantons, districts and communes 1004  Flühli                      1
    ##  7 GR_KT_GDE Cantons, districts and communes 1005  Hasle (LU)                  1
    ##  8 GR_KT_GDE Cantons, districts and communes 1007  Romoos                      1
    ##  9 GR_KT_GDE Cantons, districts and communes 1008  Schüpfheim                  1
    ## 10 GR_KT_GDE Cantons, districts and communes 1009  Werthenst…                  1
    ## # ℹ 2,307 more rows

``` r
bfs_get_sse_data(
  number_bfs = "DF_LWZ_1",
  language = "en",
  query = list(
    GR_KT_GDE = c("4001", "2581"), # Aarau and Olten
    WOHN_ANZAHL = "_T",            # all numbers of rooms
    LEERWOHN_TYP = "4",            # vacant dwellings for rent
    MEASURE_DIMENSION = "OBS"      # number of dwellings (not the rate)
  ),
  start_period = "2020",
  end_period = "2023"
)
```

    ## # A tibble: 8 × 7
    ##   TIME_PERIOD GR_KT_GDE WOHN_ANZAHL LEERWOHN_TYP   MEASURE_DIMENSION FREQ  value
    ##   <chr>       <chr>     <chr>       <chr>          <chr>             <chr> <dbl>
    ## 1 2020        Olten     Total       Vacant dwelli… Observed Value    Annu…   350
    ## 2 2021        Olten     Total       Vacant dwelli… Observed Value    Annu…   393
    ## 3 2022        Olten     Total       Vacant dwelli… Observed Value    Annu…   418
    ## 4 2023        Olten     Total       Vacant dwelli… Observed Value    Annu…   266
    ## 5 2020        Aarau     Total       Vacant dwelli… Observed Value    Annu…   110
    ## 6 2021        Aarau     Total       Vacant dwelli… Observed Value    Annu…    85
    ## 7 2022        Aarau     Total       Vacant dwelli… Observed Value    Annu…    61
    ## 8 2023        Aarau     Total       Vacant dwelli… Observed Value    Annu…    49

### Data catalog

Search the BFS data catalog, then download a dataset with its BFS
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

Many statistics are published as Excel or CSV tables. Search them, then
download the file with its asset number.

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

Get the official borders of Switzerland, the cantons, districts or
communes as sf objects.

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
  build a query from the codelists.
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
