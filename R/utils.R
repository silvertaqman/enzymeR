# ---------------------------
# Utils.R - Funciones Auxiliares
# ---------------------------
# ---------------------------
# Preparación de Datos
# ---------------------------
#' Preparación de datos cinéticos para análisis
#'
#' Esta función renombra las columnas de un dataframe para ajustarse a 
#' la estructura esperada por las funciones de análisis cinético.
#'
#' @param data Un dataframe que contiene las columnas `substrate` y `rate`.
#' @return Un dataframe con las columnas renombradas a `S` y `v`.
#' @examples
#' data <- tibble(substrate = c(10, 20), rate = c(0.5, 0.8))
#' prepare_kinetics_data(data)
#' @export
library(dplyr)
prepare_kinetics_data <- function(data) {
  required_cols <- colnames(data)
  data |>
    rename(S = required_cols[1], v = required_cols[2])
}
# ---------------------------
# Transformaciones
# ---------------------------
#' Transformation of Linear Coefficients to Kinetic Parameters
#'
#' Converts regression coefficients from linearized models or nonlinear fits 
#' into kinetic parameters (\eqn{V_{max}} and \eqn{K_m}) for various Michaelis-Menten models.
#'
#' @param method A string specifying the kinetic model. Options include:
#'   \describe{
#'     \item{"lineweaver"}{Lineweaver-Burk transformation for single-substrate kinetics.}
#'     \item{"eadie"}{Eadie-Hofstee transformation for single-substrate kinetics.}
#'     \item{"hanes"}{Hanes-Woolf transformation for single-substrate kinetics.}
#'     \item{"nonlinear"}{Nonlinear regression for single-substrate kinetics.}
#'     \item{"two-substrate"}{Two-substrate kinetics (requires four coefficients).}
#'   }
#' @return A function that takes a vector of regression coefficients (`betas`) 
#'   and returns a named vector with the kinetic parameters (\eqn{V_{max}}, \eqn{K_m}, etc.).
#' @examples
#' # Example for single-substrate kinetics (Lineweaver-Burk)
#' betas <- c(0.5, 0.2)  # Coefficients from a Lineweaver-Burk fit
#' transform <- coefs2params("lineweaver")
#' params <- transform(betas)
#' print(params)
#'
#' # Example for two-substrate kinetics
#' betas <- c(1.2, 0.5, 0.3, 0.1)  # Coefficients for two-substrate kinetics
#' transform <- coefs2params("two-substrate")
#' params <- transform(betas)
#' print(params)
#'
#' @keywords internal
coefs2params <- function(method = c("lineweaver", "eadie", "hanes", "nonlinear", "two-substrate")) {
  method <- match.arg(method)
  
  # Define transformations for single-substrate kinetics
  single_substrate <- list(
    "lineweaver" = function(betas) {
      if (length(betas) != 2) stop("Lineweaver-Burk requires exactly 2 coefficients.")
      c(Vmax = 1 / betas[1], Km = betas[2] / betas[1])
    },
    "eadie" = function(betas) {
      if (length(betas) != 2) stop("Eadie-Hofstee requires exactly 2 coefficients.")
      c(Vmax = betas[1], Km = -betas[2])
    },
    "hanes" = function(betas) {
      if (length(betas) != 2) stop("Hanes-Woolf requires exactly 2 coefficients.")
      c(Vmax = 1 / betas[2], Km = betas[1] / betas[2])
    },
    "nonlinear" = function(betas) {
      if (length(betas) != 2) stop("Nonlinear fitting requires exactly 2 coefficients.")
      c(Vmax = betas[1], Km = betas[2])
    }
  )
  
  # Define transformations for two-substrate kinetics
  two_substrate <- function(betas) {
    if (length(betas) != 4) stop("Two-substrate kinetics require exactly 4 coefficients.")
    c(Vmax = betas[1], # Cambiar y ajustar a los modelos
      KmA = betas[2], 
      KmB = betas[3], 
      KAB = betas[4])  # Interaction term, if applicable
  }
  
  # Choose appropriate transformation
  if (method == "two-substrate") {
    return(two_substrate)
  } else if (method %in% names(single_substrate)) {
    return(single_substrate[[method]])
  } else {
    stop("Unsupported method.")
  }
}
