#' Search in BFS metadata "list of the cubes"
#'
#' @export

bfs_search <- function(word = NULL, word2 = NULL, langage = "de") {
  bfsDataPath <- system.file("extdata", package = "bfsdata")
  assign("bfsDataPath", bfsDataPath, envir = .GlobalEnv)
  library(readxl)
  if(langage == "de") {
    if(!file.exists(system.file("extdata/bfs_metadata_de.xls", package = "bfsdata"))) {
    download.file(url = "https://www.pxweb.bfs.admin.ch/ShowCubeList.aspx?px_language=de",
                  destfile = paste0("", bfsDataPath, "/bfs_metadata_de.xls"))
    }
    bfs_metadata <- readxl::read_excel(paste0("", bfsDataPath, "/bfs_metadata_de.xls"))
    assign("bfs_metadata", bfs_metadata, envir = .GlobalEnv)
  } else if(langage == "fr") {
    if(!file.exists(system.file("extdata/bfs_metadata_fr.xls", package = "bfsdata"))) {
      download.file(url = "https://www.pxweb.bfs.admin.ch/ShowCubeList.aspx?px_language=fr",
                    destfile = paste0("", bfsDataPath, "/bfs_metadata_fr.xls"))
    }
    bfs_metadata <- readxl::read_excel(paste0("", bfsDataPath, "/bfs_metadata_fr.xls"))
    assign("bfs_metadata", bfs_metadata, envir = .GlobalEnv)
  } else if (langage == "en") {
    if(!file.exists(system.file("extdata/bfs_metadata_en.xls", package = "bfsdata"))) {
      download.file(url = "https://www.pxweb.bfs.admin.ch/ShowCubeList.aspx?px_language=en",
                    destfile = paste0("", bfsDataPath, "/bfs_metadata_en.xls"))
    }
    bfs_metadata <- readxl::read_excel(paste0("", bfsDataPath, "/bfs_metadata_en.xls"))
    assign("bfs_metadata", bfs_metadata, envir = .GlobalEnv)
  } else if (langage == "it") {
    if(!file.exists(system.file("extdata/bfs_metadata_it.xls", package = "bfsdata"))) {
      download.file(url = "https://www.pxweb.bfs.admin.ch/ShowCubeList.aspx?px_language=it",
                    destfile = paste0("", bfsDataPath, "/bfs_metadata_it.xls"))
    }
    bfs_metadata <- readxl::read_excel(paste0("", bfsDataPath, "/bfs_metadata_it.xls"))
    assign("bfs_metadata", bfs_metadata, envir = .GlobalEnv)
  } else {
    message("WARNING: choose between German, French, English or Italien (langage = “de“, “fr“, “en“, “it“)")
  }
  if(exists("bfs_metadata")) {
    bfs_metadata <- na.omit(bfs_metadata)
    colnames(bfs_metadata)[1] <- "Title"
    colnames(bfs_metadata)[2] <- "Timespan"
    colnames(bfs_metadata)[3] <- "Last Update"
    colnames(bfs_metadata)[4] <- "Link"
    colnames(bfs_metadata)[5] <- "Languages available"
    # bfs_metadata$ID <- seq.int(nrow(bfs_metadata)) # add an ID variable
    assign("bfs_metadata", bfs_metadata, envir = .GlobalEnv)
    # URL: https://stackoverflow.com/questions/13187414/r-grep-is-there-an-and-operator
    if(missing(word2)) {
      bfs_metadataSubset <- bfs_metadata[grep(paste0("", word, ""), bfs_metadata$Title, ignore.case = TRUE), ]
      assign("bfs_metadataSubset", bfs_metadataSubset, envir = .GlobalEnv)
      print.table(bfs_metadataSubset$Title)
    } else {
      bfs_metadataSubset <- bfs_metadata[grep(paste0("(?=.*", word,")(?=.*", word2, ")"), bfs_metadata$Title, perl = TRUE, ignore.case = TRUE), ]
      assign("bfs_metadataSubset", bfs_metadataSubset, envir = .GlobalEnv)
      print.table(bfs_metadataSubset$Title)
    }
  }
}
