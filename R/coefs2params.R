#' Transformation of linear coefficients to kinetic parameters
#'
#' @param betas A vector with coefficients from an lm() object
#' @param method Selection of a linearization method. Options are "lineweaver", "eadie", "hanes", "nonlinear".
#' @return A function that takes betas as input and returns a vector with Km and Vmax parameters
#' @examples
#' coefs2params(betas, method="hanes")
coefs2params <- function(method = c("lineweaver", "eadie", "hanes", "nonlinear")) {
  method <- match.arg(method)
  wrapper <- switch(method,
                    "lineweaver" = function(betas) c(Vmax = 1 / betas[1], Km = betas[2] / betas[1]),
                    "eadie" = function(betas) c(Vmax = betas[1], Km = -betas[2]),
                    "hanes" = function(betas) c(Vmax = 1 / betas[2], Km = betas[1] / betas[2]),
                    "nonlinear" = function(betas) c(Vmax = betas[1], Km = betas[2])
  )

  return(wrapper)
}
# Example usage:
# coefs2params(lm(I(S/v) ~ s, df)$coefficients)
