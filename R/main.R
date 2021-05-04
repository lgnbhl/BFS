utils::globalVariables(
  c(
    ".",
    "pb",
    "url_px",
    "link_2",
    "pubDate_2",
    "published",
    "title",
    "title_2",
    "url_bfs",
    "url_p"
  )
)
env <- new.env(parent = emptyenv())

#' Get metadata of a give url page
#'
#' @param url character The url of a BFS webpage
#'
#' @return A data frame
#'
#' @importFrom xml2 read_html
#' @importFrom magrittr "%>%"
#' @importFrom rvest html_node html_nodes html_text
#' @importFrom tibble tibble as_tibble
#' @importFrom purrr map_dfr
#' @importFrom pxR read.px
#' @importFrom janitor clean_names
#' @importFrom progress progress_bar
#' @importFrom utils download.file
#' @importFrom pins pin pin_get board_register_local board_local_storage

get_bfs_metadata <- function(url) {
  html_data <- url %>%
    xml2::read_html() %>%
    rvest::html_nodes(".media-body")
  
  metadata_info <- html_data %>%
    rvest::html_nodes(".data") %>%
    rvest::html_text()
  
  metadata_observation_period <-
    tryCatch(
      metadata_info[seq(1, length(metadata_info), 3)],
      error = function(e)
        NA
    )
  metadata_observation_period <-
    iconv(metadata_observation_period, "latin1", "ASCII", sub = "") # remove non-ASCII characters
  metadata_observation_period <-
    gsub("Dargestellter Zeitraum: ", "", metadata_observation_period)
  metadata_observation_period <-
    gsub("Priode d'observation: ", "", metadata_observation_period)
  metadata_observation_period <-
    gsub("Periodo contemplato: ", "", metadata_observation_period)
  metadata_observation_period <-
    gsub("Observation period: ", "", metadata_observation_period)
  
  source <-
    tryCatch(
      metadata_info[seq(2, length(metadata_info), 3)],
      error = function(e)
        NA
    )
  
  metadata_info3 <-
    tryCatch(
      metadata_info[seq(3, length(metadata_info), 3)],
      error = function(e)
        NA
    )
  metadata_published <-
    tryCatch(
      gsub("[^0-9.-]", "", metadata_info3),
      error = function(e)
        NA
    )
  
  metadata_title <- html_data %>%
    rvest::html_nodes("a") %>%
    rvest::html_text()
  
  metadata_href <- html_data %>%
    rvest::html_nodes("a") %>%
    rvest::html_attr("href") %>%
    paste0("https://www.bfs.admin.ch", .)
  
  metadata_url_px <- metadata_href %>%
    gsub("[^0-9]", "", .) %>%
    paste0("https://www.bfs.admin.ch/bfsstatic/dam/assets/",
           .,
           "/master")
  
  df <- tibble::tibble(
    title = metadata_title,
    observation_period = metadata_observation_period,
    published = metadata_published,
    source = source,
    url_bfs = metadata_href,
    url_px = metadata_url_px
  )
  
  return(df)
}

#' Looping on a list of BFS webpages urls
#'
#' @param i character The url of a BFS webpage
#'
#' @return A data frame
#'

get_bfs_metadata_all <- function(i) {
  env$pb$tick() # progress bar
  df_metadata <- get_bfs_metadata(i)
  df_metadata_all <- rbind.data.frame(
    df_metadata,
    tibble::tibble(
      title = character(0),
      observation_period = character(0),
      published = character(0),
      source = character(0),
      url_bfs = character(0),
      url_px = character(0)
    )
  )
}

#' Download BFS metadata in a given language
#'
#' Returns a tibble containing the titles, publication dates,
#' observation periods, data source, metadata webpage urls and download link urls
#' in a given language of the current public BFS datasets available. If the path of
#' the cache argument is not provided, the downloaded BFS dataset will be saved in
#' the default cache folder of the {pins} package.
#'
#' Languages availables are German ("de", as default), French ("fr"),
#' Italian ("it") and English ("en"). Note that Italian and English BFS
#' metadata doesn't give access to all the BFS datasets availables online.
#'
#' The BFS metadata is saved in a local folder using the pins package. The
#' function allows to download the BFS metadata only once per day in a given
#' language. If the metadata has alread been downloaded in a given language
#' during the day, the existing dataset is loaded into R from the pins caching
#' folder instead of downloading again the metadata from the BFS website.
#'
#' @param language character The language of the metadata.
#' @param path Path to local folder to use as a cache, default to {pins} cache.
#' @param force Force to download metadata even if already downloaded today.
#'
#' @return A tibble
#'
#' @seealso \code{\link{bfs_get_dataset}}
#'
#' @examples
#' \donttest{meta_en <- bfs_get_metadata(language = "en")}
#'
#' @export

bfs_get_metadata <-
  function(language = "de",
           path = pins::board_cache_path(),
           force = FALSE) {
    pins::board_register_local(cache = path) # pins temp folder by default
    
    # Do NOT download metadata again if metadata already downloaded today
    bfs_metadata <-
      tryCatch(
        pins::pin_get(paste0("bfs_meta_", language), board = "local"),
        error = function(e)
          "Metadata not downloaded today"
      )
    bfs_metadata_today <-
      attr(bfs_metadata, "download_date") == Sys.Date()
    
    if (!isTRUE(bfs_metadata_today) | force == TRUE) {
      # extract the number pages to load
      bfs_loadpages <- function(url) {
        html_number_pages <- url %>%
          xml2::read_html() %>%
          rvest::html_node(".pull-right") %>%
          rvest::html_nodes(".separator-left") %>%
          .[[2]] %>%
          rvest::html_node("a") %>%
          as.character() %>%
          gsub("[^0-9.]", "", .) %>%
          as.numeric(.)
        
        c(0:html_number_pages)
      }
      
      if (language == "de") {
        url_de <-
          "https://www.bfs.admin.ch/bfs/de/home/statistiken/kataloge-datenbanken/daten/_jcr_content/par/ws_catalog.dynamiclist.html?pageIndex="
        url_all <- paste0(url_de, bfs_loadpages(url_de))
      } else if (language == "fr") {
        url_fr <-
          "https://www.bfs.admin.ch/bfs/fr/home/statistiques/catalogues-banques-donnees/donnees/_jcr_content/par/ws_catalog.dynamiclist.html?pageIndex="
        url_all <- paste0(url_fr, bfs_loadpages(url_fr))
      } else if (language == "it") {
        url_it <-
          "https://www.bfs.admin.ch/bfs/it/home/statistiche/cataloghi-banche-dati/dati/_jcr_content/par/ws_catalog.dynamiclist.html?pageIndex="
        url_all <- paste0(url_it, bfs_loadpages(url_it))
      } else if (language == "en") {
        url_en <-
          "https://www.bfs.admin.ch/bfs/en/home/statistics/catalogues-databases/data/_jcr_content/par/ws_catalog.dynamiclist.html?pageIndex="
        url_all <- paste0(url_en, bfs_loadpages(url_en))
      } else {
        cat("Please select between the following languages: de, fr, it, en")
      }
      
      env$pb <-
        progress::progress_bar$new(format = "  downloading [:bar] :percent in :elapsed",
                                   total = length(url_all),
                                   clear = FALSE)
      
      bfs_metadata <-
        purrr::map_dfr(url_all, get_bfs_metadata_all) %>%
        tibble::as_tibble()
      
      attr(bfs_metadata, "download_date") <- Sys.Date()
      
      pins::pin(bfs_metadata,
                name = paste0("bfs_meta_", language),
                board = "local")
      
      rm(pb, envir = env)
      
    }
    
    bfs_metadata <-
      pins::pin_get(paste0("bfs_meta_", language), board = "local")
    
    return(bfs_metadata)
  }

#' Search titles of available BFS datasets
#'
#' Returns a tibble containing the titles, publication date,
#' observation periods, data source, metadata url and download urls of
#' available BFS datasets in a given language which match
#' the given criteria. This function leverages the R base function \code{grepl}
#' but calls the data argument first to allow the use of the pipe operator from
#' magrittr.
#'
#' @param data The data frame to search. This can be either a data frame
#' previously fetched using \code{\link{bfs_get_metadata}} (recommended) or left
#' blank, in which case a temporary data frame is fetched. The second option
#' adds a few seconds to each search query.
#' @param pattern A regular expression string to search for.
#' @param ignore.case Whether the search should be case-insensitive.
#' @param fixed logical. If TRUE, pattern is a string to be matched as is.
#'
#' @return A data frame.
#'
#' @seealso \code{\link{bfs_get_metadata}}
#'
#' @examples
#' \donttest{meta_en <- bfs_get_metadata(language = "en")}
#' \donttest{bfs_search(data = meta_en, pattern = "university students")}
#'
#' @export

bfs_search <-
  function(data = bfs_get_metadata(),
           pattern,
           ignore.case = TRUE,
           fixed = FALSE) {
    data[grepl(pattern,
               data$title,
               ignore.case = ignore.case,
               fixed = fixed),]
  }

#' Download BFS dataset in a given language
#'
#' Returns a data frame/tibble from  the URL of a given BFS PC-Axis file.
#' The default language is German and the column names are renamed
#' using the \code{\link[janitor]{clean_names}} function of the
#' janitor package. If the path of the cache argument is not provided, the
#' downloaded BFS dataset will be saved in the default cache
#' folder of the {pins} package. The metadata can be accessed by making the
#' downloaded dataset an argument of the base R function \code{attributes()}.
#'
#' The BFS data is saved in a local folder using the pins package. The
#' function allows to download the BFS data only once per day. If the data
#' has alread been downloaded during the day, the existing dataset is loaded
#' into R from the pins caching folder instead of downloading again the
#' data from the BFS website.
#'
#' @param url_px The url link to download the PC-Axis file.
#' @param language Language of the dataset to be translated if exists.
#' @param path The local folder to use as a cache, default to {pins} cache.
#' @param force Force download to download data even if already downloaded today.
#' @param clean_names Clean column names using \code{janitor::clean_names()}
#'
#' @seealso \code{\link{bfs_get_metadata}}
#'
#' @export

bfs_get_dataset <-
  function(url_px,
           language = "de",
           path = pins::board_cache_path(),
           clean_names = TRUE,
           force = FALSE) {
    pins::board_register_local(cache = path) # temp folder of the spins package
    dataset_name <- "bfs_data_" %+%
      gsub("[^0-9]", "", url_px)  %+%
      "_"  %+%
      language
    tempfile_path <- tempdir() %>%
      file.path(dataset_name %+% ".px")
    # Do NOT download data again if data already downloaded today
    bfs_data <- tryCatch(
      pins::pin_get(dataset_name, board = "local"),
      error = function(e)
        "Data not downloaded today"
    )
    bfs_data_today <- attr(bfs_data, "download_date") == Sys.Date()
    
    if (!isTRUE(bfs_data_today) | force == TRUE) {
      download.file(url_px, destfile = tempfile_path)
      if (.Platform['OS.type'] == "windows") {
        patch_pxR(tempfile_path)
      }
      bfs_px <-
        pxR::read.px(
          tempfile_path,
          na.strings = c(
            '"."',
            '".."',
            '"..."',
            '"...."',
            '"....."',
            '"......"',
            '":"'
          )
        )
      bfs_data <- bfs_px %>%
        pluck("DATA") %>%
        tibble::as_tibble()
      # exceptions
      attr(bfs_data, "last_update") <- pluck(bfs_px, "LAST.UPDATED")
      attr(bfs_data, "download_date") <- Sys.Date()
      lang_suffix <- "" # default: no language definition
      languages_availables <- pluck(bfs_px, "LANGUAGES")
      if (grepl(language, languages_availables, fixed = TRUE)) {
        if(language %in% c("fr", "it", "en")) {
          lang_suffix <- "." %+% language %+% "."  
        }
        # TODO translation : use JSON
        # https://www.pxweb.bfs.admin.ch/api/v1/{language}/
      } else {
        cat(
          'Language "' %+%
          language %+%
          '" not available. Dataset downloaded in the default language.' %+%
          ' Try with another language.'
        )
      }
      attr_names <-  c(
        "contact",
        "description",
        "link",
        "note",
        "subject.area",
        "survey",
        "title",
        "source",
        "units"
      )
      for (k in attr_names) {
        K <- toupper(k)
        K_lang_suffix <- K %+% lang_suffix
        k_snake <- snake_case(k)
        attr(bfs_data, k_snake) <- pluck(bfs_px, K_lang_suffix)
      }
        
      if (clean_names) {
        bfs_data <- janitor::clean_names(bfs_data)
      }
      pins::pin(bfs_data,
                name = paste0(dataset_name),
                board = "local")
    }
    bfs_data <- pins::pin_get(dataset_name, board = "local")
    return(bfs_data)
  }

#' Open folder containing all downloaded BFS datasets
#'
#' Opens the folder which contains all the BFS datasets downloaded
#' relatively to their path argument, using the {pins} package. If
#' no path argument is provided, the downloaded BFS datasets will be
#' saved in the default cache folder of the {pins} package.
#'
#' @param path The local folder to use as a cache, default to {pins} cache.
#'
#' @seealso \code{\link{bfs_get_dataset}}
#'
#' @examples
#' \donttest{bfs_open_dir()}
#'
#' @export

bfs_open_dir <- function(path = pins::board_local_storage()) {
  if (.Platform['OS.type'] == "windows") {
    shell.exec(path)
  } else {
    system(paste(Sys.getenv("R_BROWSER"), path))
  }
}
