#' Determination of Vmax and Km parameters for irreversible MM equation
#'
#' @param df Substrate-time or substrate-reaction rate dataset
#' @param model Selection of the model type ("time" for substrate-time or "rate" for substrate-reaction rate)
#' @param method Selection of a linearization strategy ("lb" for Lineweaver-Burk, "eh" for Eadie-Hofstee, "hw" for Hanes-Woolf)
#' @return A list with Km and Vmax parameters
#' @examples
#' fit_params(df, model="time", method="lb")
fit_params <- function(df, model = c("time", "rate"), method = c("lin", "nonlin")) {
  # Transform the data based on the model type
  if (model == "time") {
    # Set the appropriate column names for time (t) and substrate (S)
    colnames(df) <- c("t", "S")
    # Generates rate column and discard initial substrate
    df <- data.frame(
      S = df$S[-1],
      v = diff(df$S) / diff(df$t)) #time2rate
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
  params <- list(
    lineweaver = ##### RETOMAR AQUI
      # ORDENA LA LISTA DE CONSTANTES A REGRESAR
    Km = as.double(stats::coef(fits[[1]])[2] / stats::coef(fits[[1]])[1]),
    Vmax = as.double(1 / stats::coef(fits[[1]])[1]))
  params <- list(
    Km = as.double(-stats::coef(fits[[2]])[2]),
    Vmax = as.double(stats::coef(fits[[2]])[1]))
  params <- list(
    Km = as.double(stats::coef(fits[[3]])[1] / stats::coef(fits[[3]])[2]),
    Vmax = as.double(1 / stats::coef(3)[2]))
  # return the params list
  params
}

# Example usage:
# df <- datos |>
# dplyr::filter(ecnumber == "4.1.1.39", type=="irreversible") |>
# dplyr::select(time, substrate)
# fit_params(df, model = "time", method = "lb")
