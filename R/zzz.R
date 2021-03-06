## be sure to update the 'Package Options' section of the package help file
##   in R/spades-core-package.R
##
.onLoad <- function(libname, pkgname) {
  ## set options using the approach used by devtools
  opts <- options()
  opts.spades <- list( # nolint
    spades.browserOnError = FALSE,
    spades.cachePath = file.path(.spadesTempDir, "cache"),
    spades.debug = TRUE, # TODO: is this the best default? see discussion in #5
    spades.inputPath = file.path(.spadesTempDir, "inputs"),
    spades.lowMemory = FALSE,
    spades.moduleCodeChecks = list(
      skipWith = TRUE,
      suppressNoLocalFun = TRUE,
      suppressParamUnused = FALSE,
      suppressPartialMatchArgs = FALSE,
      suppressUndefined = TRUE
    ),
    spades.modulePath = file.path(.spadesTempDir, "modules"),
    spades.moduleRepo = "PredictiveEcology/SpaDES-modules",
    spades.nCompleted = 10000L,
    spades.outputPath = file.path(.spadesTempDir, "outputs"),
    spades.switchPkgNamespaces = FALSE,
    spades.tolerance = .Machine$double.eps ^ 0.5,
    spades.useragent = "http://github.com/PredictiveEcology/SpaDES",
    spades.useRequire = TRUE,
    spades.keepCompleted = TRUE
  )
  toset <- !(names(opts.spades) %in% names(opts))
  if (any(toset)) options(opts.spades[toset])

  # table of equivalent time conversions of first 1e4 integers, in seconds
  .pkgEnv[["nUnitConversions"]] <- 1e4L
  bb <- 0:.pkgEnv[["nUnitConversions"]]
  bbs <- list()
  for (u in .spadesTimes) {
    bbs[[u]] <- bb
    attr(bbs[[u]], "unit") <- u
    bbs[[u]] <- round(as.numeric(convertTimeunit(bbs[[u]], "seconds",
                                                 skipChecks = TRUE)), 0)
  }
  .pkgEnv[["unitConversions"]] <- as.matrix(as.data.frame(bbs))

  invisible()
}

#' @importFrom reproducible normPath
#' @importFrom utils packageVersion
.onAttach <- function(libname, pkgname) {
  if (interactive()) {
    packageStartupMessage("Using SpaDES.core version ", utils::packageVersion("SpaDES.core"), ".")
    packageStartupMessage(
      "Default paths for SpaDES directories set to:\n",
      "  cachePath:  ", reproducible::normPath(.getOption("spades.cachePath")), "\n",
      "  inputPath:  ", reproducible::normPath(getOption("spades.inputPath")), "\n",
      "  modulePath: ", reproducible::normPath(getOption("spades.modulePath")), "\n",
      "  outputPath: ", reproducible::normPath(getOption("spades.outputPath")), "\n",
      "These can be changed using 'setPaths()'. See '?setPaths'."
    )
  }
}

.onUnload <- function(libpath) {
  ## if temp session dir is being used, ensure it gets reset each session
  if (.getOption("spades.cachePath") == file.path(.spadesTempDir, "cache")) {
    options(spades.cachePath = NULL)
  }
  if (getOption("spades.inputPath") == file.path(.spadesTempDir, "inputs")) {
    options(spades.inputPath = NULL)
  }
  if (getOption("spades.modulePath") == file.path(.spadesTempDir, "modules")) {
    options(spades.modulePath = NULL)
  }
  if (getOption("spades.outputPath") == file.path(.spadesTempDir, "outputs")) {
    options(spades.outputPath = NULL)
  }
}

.spadesTempDir <- file.path(tempdir(), "SpaDES")



