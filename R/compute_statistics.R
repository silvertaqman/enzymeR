#' Determination statistics for parameter evaluation
#'
#' @param df Substrate-time or substrate-reaction rate dataset
#' @param fit A fit method model inputed for users requirements.
#' @param level The confidence level, inherited from confint-like functions
#' @return A list with Km and Vmax parameters, and a matrix with its statistics
#' @keywords internal
#' @examples
compute_statistics <- function(fit, df, level=0.95) {
  coefs <- coef(fit)
  names(coefs) <- NULL
  covR <- vcov(fit)
  # Extract coefficients and Jacobian if linear model
  if (inherits(fit, "lm")) {
    J <- jacobian(coefs2params(fit$call$method), x0 = coefs)
  } else if (inherits(fit, "nls")) {
    J <- jacobian(coefs2params("nonlinear"), x0 = coefs)
  } else {
    stop("Unsupported model type in compute_statistics.")
  }

  # Matricial error propagation approximation to variance
  covT <- J %*% covR %*% t(J)
  dof <- nrow(df) - length(coefs)
  t0 <- qt(level, df = dof)
  
  # Extract parameters and their uncertainties
  params <- coefs2params(fit$call$method)(coefs)
  se <- sqrt(diag(covT) / dof)
  
  statistics <- data.frame(
    Estimate = params,
    StdError = se,
    tValue = params / se,
    pValue = 2 * pt(abs(params / se), df = dof, lower.tail = FALSE),
    Lower = params - t0 * se,
    Upper = params + t0 * se,
    row.names = c("Vmax", "Km")
  )
  
  return(statistics)
}
