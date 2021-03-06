#' @param package (optional) a string indicating the target package. If not
#'   assigned, the function will try to use the name of the active project
#'   directory.
#' @param devtools_load (optional) a [`logical`][base::logical()] value
#'   indicating if the function must call `devtools::load_all(".")` before
#'   running. This is useful if you use [devtools](https://devtools.r-lib.org/)
#'   for package development. If `devtools_load = FALSE` and the dev package is
#'   not loaded, the function will use a installed version of the package
#'   (default: `FALSE`).
