#' Fit Linearized Models
#' Internal function to fit linearized Michaelis-Menten models.
#' @param df A data frame with columns 'S' (substrate concentration) and 'v' (reaction rate).
#' @param method A string specifying the kinetic model. Options include:
#'   \describe{
#'     \item{"lineweaver"}{Lineweaver-Burk transformation for single-substrate kinetics.}
#'     \item{"eadie"}{Eadie-Hofstee transformation for single-substrate kinetics.}
#'     \item{"hanes"}{Hanes-Woolf transformation for single-substrate kinetics.}
#'     \item{"nonlinear"}{Nonlinear regression for single-substrate kinetics.}
#'   }
#' @return A fitted `lm` object.
#' @keywords internal
#' fit_linear_models(df, method = "eadie")
 fit_linear_model <- function(df, method) {
  switch(
    method,
    "lineweaver" = lm(I(1 / v) ~ I(1 / S), data = df),
    "eadie" = lm(v ~ I(v / S), data = df),
    "hanes" = lm(I(S / v) ~ S, data = df),
    stop("Invalid linearization method specified.")
  )
}
