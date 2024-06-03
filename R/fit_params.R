#' Determination of Vmax and Km parameters for irreversible MM equation
#'
#' @param df Substrate-time or substrate-reaction rate dataset
#' @param model Selection of the model type ("time" for substrate-time or "rate" for substrate-reaction rate)
#' @param method Selection of a linearization strategy ("lb" for Lineweaver-Burk, "eh" for Eadie-Hofstee, "hw" for Hanes-Woolf)
#' @return A list with Km and Vmax parameters
#' @examples
#' fit_params(df, model="time", method="lin")
fit_params <- function(df, model = c("time", "rate"), method = c("lin", "nonlin"),level=.95,...) {
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
  # Ensure the model and method arguments are correctly matched
  model <- match.arg(model)
  method <- match.arg(method)

  # Call lm function
  linfun <- function(df, X) do.call("lm", list(X, quote(df)))
  # Define linearization models
  models <- list(
    lineweaver = I(1/v) ~ I(1/S),
    eadie = v ~ I(v/S),
    hanes = I(S/v) ~ S)
  fits <- lapply(X = models, FUN = linfun, df=df)
  parms <- list(
    lineweaver = list(
      b = fits$lineweaver$coefficients[1],
      m = fits$lineweaver$coefficients[2],
      Km = fits$lineweaver$coefficients[2] / fits$lineweaver$coefficients[1],
      Vmax = 1 / fits$lineweaver$coefficients[1]),
    eadie = list(
      b = fits$eadie$coefficients[1],
      m = fits$eadie$coefficients[2],
      Km = - fits$eadie$coefficients[2],
      Vmax = fits$eadie$coefficients[1]),
    hanes = list(
      b = fits$hanes$coefficients[1],
      m = fits$hanes$coefficients[2],
      Km = fits$hanes$coefficients[1] / fits$hanes$coefficients[2],
      Vmax = 1/fits$hanes$coefficients[2])
  )
  kinetics <- list(
    lineweaver = fits$lineweaver |>
      confint() |>
      rbind(Vmax=c(parms$lineweaver$Vmax - qt(level, df=nrow(df)-2) * summary(fits$lineweaver)$coefficients[1,2] / parms$lineweaver$b^2,
                   parms$lineweaver$Vmax + qt(level, df=nrow(df)-2) * summary(fits$lineweaver)$coefficients[1,2] / parms$lineweaver$b^2)) |>
      rbind(Km=c(parms$lineweaver$Km - qt(level, df=nrow(df)-2) * sqrt(summary(fits$lineweaver)$coefficients[2,2]^2 /parms$lineweaver$b^2 + parms$lineweaver$m^2 * summary(fits$lineweaver)$coefficients[1,2]^2 / parms$lineweaver$b^4 - 2 * parms$lineweaver$m * vcov(fits$lineweaver)[2,1] / parms$lineweaver$b^3),
                 parms$lineweaver$Km + qt(level, df=nrow(df)-2) *sqrt(summary(fits$lineweaver)$coefficients[2,2]^2 /parms$lineweaver$b^2 + parms$lineweaver$m^2 * summary(fits$lineweaver)$coefficients[1,2]^2 / parms$lineweaver$b^4 - 2 * parms$lineweaver$m * vcov(fits$lineweaver)[2,1] / parms$lineweaver$b^3))) |>
      cbind(estimate=parms$lineweaver),
    eadie = fits$eadie |>
      confint(level=level,...) |>
      rbind(Vmax=c(parms$eadie$Vmax - qt(level, df=nrow(df)-2) * summary(fits$eadie)$coefficients[1,2] / parms$eadie$b^2,
                   parms$eadie$Vmax + qt(level, df=nrow(df)-2) * summary(fits$eadie)$coefficients[1,2] / parms$eadie$b^2)) |>
      rbind(Km=c(parms$eadie$Km - qt(level, df=nrow(df)-2) * sqrt(summary(fits$eadie)$coefficients[2,2]^2 /parms$eadie$b^2 + parms$eadie$m^2 * summary(fits$eadie)$coefficients[1,2]^2 / parms$eadie$b^4 - 2 * parms$eadie$m * vcov(fits$eadie)[2,1] / parms$eadie$b^3),
                 parms$eadie$Km + qt(level, df=nrow(df)-2) *sqrt(summary(fits$eadie)$coefficients[2,2]^2 /parms$eadie$b^2 + parms$eadie$m^2 * summary(fits$eadie)$coefficients[1,2]^2 / parms$eadie$b^4 - 2 * parms$eadie$m * vcov(fits$eadie)[2,1] / parms$eadie$b^3))) |>
      cbind(estimate=parms$eadie),
    hanes = fits$hanes |>
      confint(level=level,...) |>
      rbind(Vmax=c(parms$hanes$Vmax - qt(level, df=nrow(df)-2) * summary(fits$hanes)$coefficients[1,2] / parms$hanes$b^2,
                   parms$hanes$Vmax + qt(level, df=nrow(df)-2) * summary(fits$hanes)$coefficients[1,2] / parms$hanes$b^2)) |>
      rbind(Km=c(parms$hanes$Km - qt(level, df=nrow(df)-2) * sqrt(summary(fits$hanes)$coefficients[2,2]^2 /parms$hanes$b^2 + parms$hanes$m^2 * summary(fits$hanes)$coefficients[1,2]^2 / parms$hanes$b^4 - 2 * parms$hanes$m * vcov(fits$hanes)[2,1] / parms$hanes$b^3),
                 parms$hanes$Km + qt(level, df=nrow(df)-2) *sqrt(summary(fits$hanes)$coefficients[2,2]^2 /parms$hanes$b^2 + parms$hanes$m^2 * summary(fits$hanes)$coefficients[1,2]^2 / parms$hanes$b^4 - 2 * parms$hanes$m * vcov(fits$hanes)[2,1] / parms$hanes$b^3)))  |>
      cbind(estimate=parms$hanes)
    )

  # return the parameters list
  return(kinetics)
}

# Example usage:
# df <- kinetics |>
# dplyr::filter(ecnumber == "4.1.1.39", type=="irreversible") |>
# dplyr::select(time, substrate)
# fit_params(df, model = "time", method = "lin")
