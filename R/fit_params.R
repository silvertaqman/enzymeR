#' Determination of Vmax and Km parameters for irreversible MM equation
#'
#' @param df Substrate-time or substrate-reaction rate dataset
#' @param model Selection of the model type ("time" for substrate-time or "rate" for substrate-reaction rate)
#' @param method Selection of a linearization strategy ("lb" for Lineweaver-Burk, "eh" for Eadie-Hofstee, "hw" for Hanes-Woolf)
#' @return A list with Km and Vmax parameters, and a matrix with its statistics
#' @examples
#' fit_params(df, model="pH", method="lineweaver")
library(pracma)
fit_params <- function(df, model = c("one-substrate", "pH", "temperature", "ionic", "inhibition", "allosteric"),
                       method = c("lineweaver", "eadie", "hanes", "nonlinear"), 
                       level = 0.95, ...) {
  # Argument validation
  model <- match.arg(model)
  method <- match.arg(method)
  
  if (!is.data.frame(df) || !all(c("S", "v") %in% colnames(df))) 
    stop("`df` must be a dataframe with columns 'S' and 'v'.")
  
  # Fit the model
  fit <- if (method == "nonlinear") {
    nls(v ~ Vmax * S / (Km + S),
        start = list(Vmax = max(df$v), Km = quantile(df$S, 0.2)), # aproximaciones 
        data = df)
  } else {
    fit_linear_model(df, method)
  }
  
  # Compute statistics
  statistics <- compute_statistics(fit, df, level)
  
  # Return results
  result <- list(fit = fit, statistics = statistics, method = method, model = model)
  class(result) <- "kinetic_fit"
  return(result)
}

# Example usage:
# load(file = "data/kinetics.rda")
# df <- kinetics |>
# dplyr::filter(ecnumber == "4.1.1.39", type=="irreversible") |>
# dplyr::select(time, substrate) |>
# tidyr::drop_na()
# fit_params(df, model = "one-substrate", method = "nonlinear")
