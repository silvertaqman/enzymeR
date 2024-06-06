#' Determination of Vmax and Km parameters for irreversible MM equation
#'
#' @param df Substrate-time or substrate-reaction rate dataset
#' @param model Selection of the model type ("time" for substrate-time or "rate" for substrate-reaction rate)
#' @param method Selection of a linearization strategy ("lb" for Lineweaver-Burk, "eh" for Eadie-Hofstee, "hw" for Hanes-Woolf)
#' @return A list with Km and Vmax parameters
#' @examples
#' fit_params(df, model="time", method="lin")
fit_params <- function(df, model = c("time", "rate"), method = c("lineweaver","eadie","hanes","nonlinear"),level=.95,...) {
  # Ensure the model and method arguments are correctly matched
  model <- match.arg(model)
  method <- match.arg(method)
  # Transform the data based on the model type
  if (model == "time") {
    # Set the appropriate column names for time (t) and substrate (S)
    colnames(df) <- c("t", "S")
    # Generates rate column and discard initial substrate
    df <- data.frame(
      S = df$S[-1],
      v = - diff(df$S) / diff(df$t)) #time2rate
  } else if (model == "rate") {
    # Set the appropriate column names for substrate (S) and rate (v)
    colnames(df) <- c("S", "v")
  } else {
    stop("Invalid options: No time or rate data")
  }

  # Call lm function to define linearization models
  parms <- switch(
      method,
      "lineweaver" = {
        m <- lm(I(1/v) ~ I(1/S), df)
        fits <- coef(m)
        list(
          m = m,
          beta0 = fits[1],
          beta1 = fits[2],
          Km = fits[2] / fits[1],
          Vmax = 1 / fits[1],
          varbeta0 = summary(m)$coefficients[1, 2],
          varbeta1 = summary(m)$coefficients[2, 2])
      },
      "eadie" = {
        m <- lm(v ~ I(v/S), df)
        fits <- coef(m)
        list(
          m = m,
          beta0 = fits[1],
          beta1 = fits[2],
          Km = -fits[2],
          Vmax = fits[1],
          varbeta0 = summary(m)$coefficients[1, 2],
          varbeta1 = summary(m)$coefficients[2, 2])
      },
      "hanes" = {
        m <- lm(I(S/v) ~ S, df)
        fits <- coef(m)
        list(
          m = m,
          beta0 = fits[1],
          beta1 = fits[2],
          Km = fits[1] / fits[2],
          Vmax = 1 / fits[2],
          varbeta0 = summary(m)$coefficients[1, 2],
          varbeta1 = summary(m)$coefficients[2, 2])
      },
      "nonlinear" = {
        m <- nls(v ~ Vmax * S / (Km + S), start = list(Vmax = 1, Km = 1), data = df)
        list(
          m = m,
          Km = coef(m)[2],
          Vmax = coef(m)[1],
          varVmax = summary(m)$coefficients[1, 2],
          varKm = summary(m)$coefficients[2, 2])
      }
    )

  # Get statistics like confidence intervals and p-value with error propagation formula
  statistics <- with(parms, m |>
      confint(level = level) |>
    rbind(Vmax=c(
      Vmax - qt(level, df=nrow(df)-2) * varbeta0 / beta0^2,
      Vmax + qt(level, df=nrow(df)-2) * varbeta0 / beta0^2)) |>
    rbind(Km=c(
      Km - qt(level, df=nrow(df)-2) * sqrt(varbeta1 / beta0^2 + beta1^2 * varbeta0 / beta0^4 - 2 * beta1 * vcov(m)[2,1] / beta0^3),
      Km + qt(level, df=nrow(df)-2) *sqrt(varbeta1 / beta0^2 + beta1^2 * varbeta0 / beta0^4 - 2 * beta1 * vcov(m)[2,1] / beta0^3)))) |>
      cbind(estimate=parms[names(parms)[2:5]]) # add se, t and p value test

  # return the parameters list
  return(list(unlist(parms[names(parms)[2:5]]), statistics))
}

# Example usage:
# df <- kinetics |>
# dplyr::filter(ecnumber == "4.1.1.39", type=="irreversible") |>
# dplyr::select(time, substrate) |>
# tidyr::drop_na() |>
# fit_params(model = "rate", method = "nonlinear")
