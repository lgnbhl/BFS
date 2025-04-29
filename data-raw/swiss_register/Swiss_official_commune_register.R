# Get Swiss official commune register data
# https://www.bfs.admin.ch/bfs/de/home/grundlagen/agvch.html

library(BFS)
library(readxl)
library(dplyr)
library(usethis)

# Download Excel file
# https://www.bfs.admin.ch/bfs/fr/home/bases-statistiques/repertoire-officiel-communes-suisse.assetdetail.23886073.html
register_path <- BFS::bfs_download_asset(
  number_asset = "23886073",
  destfile = "data-raw/swiss_register/swiss_register.xlsx"
)

# Get dataset from each Excel sheet
register_gde <- readxl::read_excel(path = register_path, sheet = "GDE")
register_gde_other <- readxl::read_excel(path = register_path, sheet = "Geb. ohne Gem.｜T. sans comm.")
register_bzn <- readxl::read_excel(path = register_path, sheet = "BZN")
register_kt <- readxl::read_excel(path = register_path, sheet = "KT")
register_kt_seeanteile <- readxl::read_excel(path = register_path, sheet = "Kt. Seeanteile｜Part. cant. lac")

# create dictionary
register_dic_de <- readxl::read_excel(
  path = register_path,
  sheet = "01.01.2023",
  col_names = c("title", "abbreviation", "spec", "notes"),
  range = "A5:D13"
)
register_dic_de$language <- "de"
register_dic_fr <- readxl::read_excel(
  path = register_path,
  sheet = "01.01.2023",
  col_names = c("title", "abbreviation", "spec", "notes"),
  range = "A19:D27"
)
register_dic_fr$language <- "fr"
register_dic_it <- readxl::read_excel(
  path = register_path,
  sheet = "01.01.2023",
  col_names = c("title", "abbreviation", "spec", "notes"),
  range = "A33:D41"
)
register_dic_it$language <- "it"

register_dic_raw <- rbind(register_dic_de, register_dic_fr, register_dic_it)

# reorder variables
register_dic <- register_dic_raw %>%
  dplyr::select(language, abbreviation, title, spec, notes)

# save data in package
usethis::use_data(register_gde, register_gde_other, register_bzn, register_kt, register_kt_seeanteile, register_dic, overwrite = TRUE)
