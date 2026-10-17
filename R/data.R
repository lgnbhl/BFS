#' Swiss official commune register: communes
#'
#' The communes of Switzerland on 1 January 2023, with their district and
#' canton. The BFS assigns a number to each commune and publishes the Swiss
#' official commune register, used by the federal, cantonal and communal
#' administrations to identify communes. See [register_dic] for the
#' variables in German, French and Italian.
#'
#' @format A data frame with 2,136 rows and 8 columns:
#' \describe{
#'   \item{GDEKT}{Canton abbreviation, e.g. "ZH".}
#'   \item{GDEBZNR}{District number.}
#'   \item{GDENR}{BFS commune number.}
#'   \item{GDENAME}{Official commune name.}
#'   \item{GDENAMK}{Short commune name.}
#'   \item{GDEBZNA}{District name.}
#'   \item{GDEKTNA}{Canton name.}
#'   \item{GDEMUTDAT}{Date of the last change, as "dd.mm.yyyy".}
#' }
#' @source <https://www.bfs.admin.ch/bfs/en/home/basics/swiss-official-commune-register.html>
#' @family commune register
"register_gde"

#' Swiss official commune register: areas without a commune
#'
#' The areas of Switzerland that belong to no commune (e.g. the Staatswald
#' Galm), on 1 January 2023.
#'
#' @format A data frame with 3 rows and 4 columns:
#' \describe{
#'   \item{GDENR}{BFS number of the area.}
#'   \item{GDENAME}{Name of the area.}
#'   \item{KTNR}{Canton number.}
#'   \item{GDEBZNR}{District number.}
#' }
#' @source <https://www.bfs.admin.ch/bfs/en/home/basics/swiss-official-commune-register.html>
#' @family commune register
"register_gde_other"

#' Swiss official commune register: districts
#'
#' The districts of Switzerland (or comparable administrative entities) on
#' 1 January 2023.
#'
#' @format A data frame with 143 rows and 3 columns:
#' \describe{
#'   \item{GDEKT}{Canton abbreviation, e.g. "ZH".}
#'   \item{GDEBZNR}{District number.}
#'   \item{GDEBZNA}{District name.}
#' }
#' @source <https://www.bfs.admin.ch/bfs/en/home/basics/swiss-official-commune-register.html>
#' @family commune register
"register_bzn"

#' Swiss official commune register: cantons
#'
#' The 26 cantons of Switzerland.
#'
#' @format A data frame with 26 rows and 3 columns:
#' \describe{
#'   \item{KTNR}{Canton number.}
#'   \item{GDEKT}{Canton abbreviation, e.g. "ZH".}
#'   \item{GDEKTNA}{Canton name.}
#' }
#' @source <https://www.bfs.admin.ch/bfs/en/home/basics/swiss-official-commune-register.html>
#' @family commune register
"register_kt"

#' Swiss official commune register: cantonal shares of lakes
#'
#' The lakes of Switzerland, split by canton (e.g. "Zürichsee (ZH)" and
#' "Zürichsee (SZ)"), on 1 January 2023.
#'
#' @format A data frame with 41 rows and 3 columns:
#' \describe{
#'   \item{GDENR}{BFS number of the lake share.}
#'   \item{GDENAME}{Name of the lake share.}
#'   \item{KTNR}{Canton number.}
#' }
#' @source <https://www.bfs.admin.ch/bfs/en/home/basics/swiss-official-commune-register.html>
#' @family commune register
"register_kt_seeanteile"

#' Swiss official commune register: dictionary
#'
#' The variables of the commune register datasets, in German, French and
#' Italian.
#'
#' @format A data frame with 27 rows and 5 columns:
#' \describe{
#'   \item{language}{Language: "de", "fr" or "it".}
#'   \item{abbreviation}{Variable name, e.g. "GDENR".}
#'   \item{title}{Variable label.}
#'   \item{spec}{Specifications.}
#'   \item{notes}{General notes.}
#' }
#' @source <https://www.bfs.admin.ch/bfs/en/home/basics/swiss-official-commune-register.html>
#' @family commune register
"register_dic"
