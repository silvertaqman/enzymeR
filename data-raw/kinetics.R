#' kinetics
#'
#' A data frame containing example data for kinetics enzyme assay. Time, substrate and reaction rate are provided but filtering ans selection processes are neede to use them.
#'
#' @format A data frame with 58 rows and 5 columns
#' \describe{
#'   \item{time}{Minutes until measurement is done (min)}
#'   \item{substrate}{Concentration of the substrate until that moment from an initial fixed amount (uM)}
#'   \item{rate}{Change rate of product concentration over time per enzyme unit (uM/min)}
#'   \item{type}{Kind of Analysis, irreversible (default analysis, inital rate or progress curve) Inhibition or Activation}
#'   \item{ecnumber}{Enzyme identifier}
#' }
#' @source Generated for example purposes.
"kinetics"
