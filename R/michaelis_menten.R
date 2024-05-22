#' Determination of Vmax and Km parameters for irreversible MM equation
#'
#' @param df Substrate-time or substrate-reaction rate dataset
#' @param model Selection of the model type ("time" for substrate-time or "rate" for substrate-reaction rate)
#' @param method Selection of a linearization strategy ("lb" for Lineweaver-Burk, "eh" for Eadie-Hofstee, "hw" for Hanes-Woolf)
#' @return A list with Km and Vmax parameters
#' @examples
#' michaelis_menten(df, model="time", method="lb")
michaelis_menten <- function(df, model = c("time", "rate"), method = c("lb", "eh", "hw")) {
  # Ensure the model and method arguments are correctly matched
  model <- match.arg(model)
  method <- match.arg(method)
  
  # Save the original column names
  savednames <- colnames(df)
  
  # Set the appropriate column names for substrate (S) and rate (v)
  colnames(df) <- c("S", "v")
  
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
  
  # Transform the data based on the model type
  if (model == "time") {
    df <- data.frame(S = df$S, v = diff(df$S) / diff(df$time))
  }
  
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
# michaelis_menten(df, model = "time", method = "lb")
