# Skip on CI, except when BFS_TEST_BASE_MAPS is "true", i.e. in the scheduled
# or manual GitHub Actions runs on one runner (see R-CMD-check.yaml), so the
# base maps download is tested regularly without downloading on every push.
skip_on_ci_unless_base_maps <- function() {
  if (!identical(Sys.getenv("BFS_TEST_BASE_MAPS"), "true")) {
    skip_on_ci()
  }
}
