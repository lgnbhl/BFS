#' Swiss official commune register GDE
#'
#' The official commune register is structured according to cantons and 
#' districts or comparable administrative entities. Various federal, cantonal 
#' and communal governments and private businesses use this register when 
#' identifying and referring to communes.
#'
#' The Federal Statistical Office assigns a number to each commune and creates, 
#' administers and publishes the Swiss official commune register.
#'
#' @format ## `register_gde`
#' A data frame with 2,136 rows and 8 columns:
#' \describe{
#'   \item{GDEKT}{Kantonskuerzel}
#'   \item{GDEBZNR}{Bezirksnummer}
#'   \item{GDENR}{BFS-Gemeindenummer}
#'   \item{GDENAME}{Amtlicher Gemeindename}
#'   \item{GDENAMK}{Gemeindename, kurz}
#'   \item{GDEBZNA}{Bezirksname}
#'   \item{GDEKTNA}{Kantonsname}
#'   \item{GDEMUTDAT}{Datum der letzten Anderung}
#' }
#' @source <https://www.bfs.admin.ch/bfs/fr/home/bases-statistiques/repertoire-officiel-communes-suisse.html>
"register_gde"

#' Swiss official commune register GDE Other
#'
#' The official commune register is structured according to cantons and 
#' districts or comparable administrative entities. Various federal, cantonal 
#' and communal governments and private businesses use this register when 
#' identifying and referring to communes.
#'
#' The Federal Statistical Office assigns a number to each commune and creates, 
#' administers and publishes the Swiss official commune register.
#'
#' @format ## `register_gde_other`
#' A data frame with 3 rows and 4 columns:
#' \describe{
#'   \item{GDENR}{BFS-Gemeindenummer}
#'   \item{GDENAME}{Amtlicher Gemeindename}
#'   \item{KTNR}{Kantonsnummer}
#'   \item{GDEBZNR}{Bezirksnummer}
#' }
#' @source <https://www.bfs.admin.ch/bfs/fr/home/bases-statistiques/repertoire-officiel-communes-suisse.html>
"register_gde_other"

#' Swiss official commune register BZN
#'
#' The official commune register is structured according to cantons and 
#' districts or comparable administrative entities. Various federal, cantonal 
#' and communal governments and private businesses use this register when 
#' identifying and referring to communes.
#'
#' The Federal Statistical Office assigns a number to each commune and creates, 
#' administers and publishes the Swiss official commune register.
#'
#' @format ## `register_bzn`
#' A data frame with 143 rows and 3 columns:
#' \describe{
#'   \item{GDEKT}{Kantonskuerzel}
#'   \item{GDEBZNR}{Bezirksnummer}
#'   \item{GDEBZNA}{Bezirksname}
#' }
#' @source <https://www.bfs.admin.ch/bfs/fr/home/bases-statistiques/repertoire-officiel-communes-suisse.html>
"register_bzn"

#' Swiss official commune register KT
#'
#' The official commune register is structured according to cantons and 
#' districts or comparable administrative entities. Various federal, cantonal 
#' and communal governments and private businesses use this register when 
#' identifying and referring to communes.
#'
#' The Federal Statistical Office assigns a number to each commune and creates, 
#' administers and publishes the Swiss official commune register.
#'
#' @format ## `register_kt`
#' A data frame with 26 rows and 3 columns:
#' \describe{
#'   \item{KTNR}{Kantonsnummer}
#'   \item{GDEKT}{Kantonskuerzel}
#'   \item{GDEKTNA}{Kantonsname}
#' }
#' @source <https://www.bfs.admin.ch/bfs/fr/home/bases-statistiques/repertoire-officiel-communes-suisse.html>
"register_kt"

#' Swiss official commune register KT Seeanteile
#'
#' The official commune register is structured according to cantons and 
#' districts or comparable administrative entities. Various federal, cantonal 
#' and communal governments and private businesses use this register when 
#' identifying and referring to communes.
#'
#' The Federal Statistical Office assigns a number to each commune and creates, 
#' administers and publishes the Swiss official commune register.
#'
#' @format ## `register_kt_seeanteile`
#' A data frame with 9 rows and 5 columns:
#' \describe{
#'   \item{GDENR}{BFS-Gemeindenummer}
#'   \item{GDENAME}{Amtlicher Gemeindename}
#'   \item{KTNR}{Kantonsnummer}
#' }
#' @source <https://www.bfs.admin.ch/bfs/fr/home/bases-statistiques/repertoire-officiel-communes-suisse.html>
"register_kt_seeanteile"

#' Swiss official commune register Dictionary
#'
#' The official commune register is structured according to cantons and 
#' districts or comparable administrative entities. Various federal, cantonal 
#' and communal governments and private businesses use this register when 
#' identifying and referring to communes.
#'
#' The Federal Statistical Office assigns a number to each commune and creates, 
#' administers and publishes the Swiss official commune register.
#'
#' @format ## `register_dic`
#' A data frame with 27 rows and 5 columns:
#' \describe{
#'   \item{language}{Language}
#'   \item{abbreviation}{Abbreviation}
#'   \item{title}{Title}
#'   \item{spec}{Specifications}
#'   \item{notes}{General notes}
#' }
#' @source <https://www.bfs.admin.ch/bfs/fr/home/bases-statistiques/repertoire-officiel-communes-suisse.html>
"register_dic"
