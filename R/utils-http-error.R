# Evaluate a request and, if the Internet resource is not available
# (e.g. HTTP 429 Too Many Requests, timeout or server error), signal an
# informative error of class "bfs_http_error". The original classes are
# kept, so existing handlers (e.g. for "httr2_http_429") still work.
# Handles httr2 errors, httr errors (raised by pxweb, e.g. "http_429") and
# curl network errors (raised by curl::curl_download(), e.g.
# "curl_error_couldnt_connect").
abort_on_http_error <- function(expr) {
  tryCatch(
    expr,
    httr2_http = abort_bfs_http,
    httr2_failure = abort_bfs_http,
    http_error = abort_bfs_http,
    curl_error = abort_bfs_http
  )
}

abort_bfs_http <- function(e) {
  rlang::abort(
    c("The BFS API is not available.", i = conditionMessage(e)),
    class = c("bfs_http_error", setdiff(class(e), c("rlang_error", "error", "condition"))),
    parent = e,
    call = NULL
  )
}
