#' Determination of Vmax and Km parameters for irreversible MM equation
#'
#' @param df Substrate-time or substrate-reaction rate dataset
#' @param model Selection of the model type ("time" for substrate-time or "rate" for substrate-reaction rate)
#' @param method Selection of a linearization strategy ("lb" for Lineweaver-Burk, "eh" for Eadie-Hofstee, "hw" for Hanes-Woolf)
#' @return A list with Km and Vmax parameters
#' @examples
#' fit_params(df, model="time", method="lb")
fit_params <- function(df, model = c("time", "rate"), method = c("lb", "eh", "hw")) {
  # Transform the data based on the model type
  if (model == "time") {
    # Set the appropriate column names for time (t) and substrate (S)
    colnames(df) <- c("t", "S")
    df <- data.frame(S = df$S[-1], v = diff(df$S) / diff(df$t)) #time2rate
  } else if (model == "rate") {
    # Set the appropriate column names for substrate (S) and rate (v)
    colnames(df) <- c("S", "v")
  } else {
    stop("Invalid options: No time or rate data")
  }
  # Ensure the model and method arguments are correctly matched
  model <- match.arg(model)
  method <- match.arg(method)
  
  # Define linearization functions
  linfun <- list(
    linewaver = function(x) {
      m <- lm(I(1/v) ~ I(1/S), data = x)
      params <- list(
        Km = as.double(coef(m)[2] / coef(m)[1]),
        Vmax = as.double(1 / coef(m)[1])
      )
      return(params)
    },
    eadie = function(x) {
      m <- lm(v ~ I(v/S), data = x)
      params <- list(
        Km = as.double(-coef(m)[2]),
        Vmax = as.double(coef(m)[1])
      )
      return(params)
    },
    hanes = function(x) {
      m <- lm(I(S/v) ~ S, data = x)
      params <- list(
        Km = as.double(coef(m)[1] / coef(m)[2]),
        Vmax = as.double(1 / coef(m)[2])
      )
      return(params)
    }
  )
  
  # Apply the selected linearization method
  kinetic <- switch(method,
                    lb = linfun$linewaver(df),
                    eh = linfun$eadie(df),
                    hw = linfun$hanes(df),
                    stop("Method error: try again")
  )
  
  return(kinetic)
}

# Example usage:
# df <- data.frame(time = c(0, 10, 20, 30, 40, 50), S = c(1.0, 0.9, 0.8, 0.7, 0.6, 0.5))
# fit_params(df, model = "time", method = "lb")
