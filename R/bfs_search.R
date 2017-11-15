#' Search in BFS metadata "list of the cubes"
#'
#' @export

bfs_search <- function(word = NULL, word2 = NULL, langage = "de") {
  bfsDataPath <- system.file("extdata", package = "bfsdata")
  assign("bfsDataPath", bfsDataPath, envir = .GlobalEnv)
  library(readxl)
  if(langage == "de") {
    if(!file.exists(system.file("extdata/bfsMetadata_de.xls", package = "bfsdata"))) {
    download.file(url = "https://www.pxweb.bfs.admin.ch/ShowCubeList.aspx?px_language=de",
                  destfile = paste0("", bfsDataPath, "/bfsMetadata_de.xls"))
    }
    bfsMetadata <- readxl::read_excel(paste0("", bfsDataPath, "/bfsMetadata_de.xls"))
    assign("bfsMetadata", bfsMetadata, envir = .GlobalEnv)
  } else if(langage == "fr") {
    if(!file.exists(system.file("extdata/bfsMetadata_fr.xls", package = "bfsdata"))) {
      download.file(url = "https://www.pxweb.bfs.admin.ch/ShowCubeList.aspx?px_language=fr",
                    destfile = paste0("", bfsDataPath, "/bfsMetadata_fr.xls"))
    }
    bfsMetadata <- readxl::read_excel(paste0("", bfsDataPath, "/bfsMetadata_fr.xls"))
    assign("bfsMetadata", bfsMetadata, envir = .GlobalEnv)
  } else if (langage == "en") {
    if(!file.exists(system.file("extdata/bfsMetadata_en.xls", package = "bfsdata"))) {
      download.file(url = "https://www.pxweb.bfs.admin.ch/ShowCubeList.aspx?px_language=en",
                    destfile = paste0("", bfsDataPath, "/bfsMetadata_en.xls"))
    }
    bfsMetadata <- readxl::read_excel(paste0("", bfsDataPath, "/bfsMetadata_en.xls"))
    assign("bfsMetadata", bfsMetadata, envir = .GlobalEnv)
  } else if (langage == "it") {
    if(!file.exists(system.file("extdata/bfsMetadata_it.xls", package = "bfsdata"))) {
      download.file(url = "https://www.pxweb.bfs.admin.ch/ShowCubeList.aspx?px_language=it",
                    destfile = paste0("", bfsDataPath, "/bfsMetadata_it.xls"))
    }
    bfsMetadata <- readxl::read_excel(paste0("", bfsDataPath, "/bfsMetadata_it.xls"))
    assign("bfsMetadata", bfsMetadata, envir = .GlobalEnv)
  } else {
    message("WARNING: choose between German, French, English or Italien (langage = “de“, “fr“, “en“, “it“)")
  }
  if(exists("bfsMetadata")) {
    bfsMetadata <- na.omit(bfsMetadata)
    colnames(bfsMetadata)[1] <- "Title"
    colnames(bfsMetadata)[2] <- "Timespan"
    colnames(bfsMetadata)[3] <- "Last Update"
    colnames(bfsMetadata)[4] <- "Link"
    colnames(bfsMetadata)[5] <- "Languages available"
    # bfsMetadata$ID <- seq.int(nrow(bfsMetadata)) # add an ID variable
    assign("bfsMetadata", bfsMetadata, envir = .GlobalEnv)
    # URL: https://stackoverflow.com/questions/13187414/r-grep-is-there-an-and-operator
    if(missing(word2)) {
      bfsMetadataSubset <- bfsMetadata[grep(paste0("", word, ""), bfsMetadata$Title, ignore.case = TRUE), ]
      assign("bfsMetadataSubset", bfsMetadataSubset, envir = .GlobalEnv)
      print.table(bfsMetadataSubset$Title)
    } else {
      bfsMetadataSubset <- bfsMetadata[grep(paste0("(?=.*", word,")(?=.*", word2, ")"), bfsMetadata$Title, perl = TRUE, ignore.case = TRUE), ]
      assign("bfsMetadataSubset", bfsMetadataSubset, envir = .GlobalEnv)
      print.table(bfsMetadataSubset$Title)
    }
  }
}
