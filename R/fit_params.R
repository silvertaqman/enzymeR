#' Determination of Vmax and Km parameters for irreversible MM equation
#'
#' @param df Substrate-time or substrate-reaction rate dataset
#' @param model Selection of the model type ("time" for substrate-time or "rate" for substrate-reaction rate)
#' @param method Selection of a linearization strategy ("lb" for Lineweaver-Burk, "eh" for Eadie-Hofstee, "hw" for Hanes-Woolf)
#' @return A list with Km and Vmax parameters, and a matrix with its statistics
#' @examples
#' fit_params(df, model="pH", method="lineweaver")
library(pracma)
library(minpack.lm)
fit_params <- function(df, model = c("one-substrate","pH","temperature","ionic","inhibition","allosteric"), method = c("lineweaver","eadie","hanes","nonlinear"), level=.95,...) {
    # Ensure the model and method arguments are correctly matched
  model <- match.arg(model)
  method <- match.arg(method)
  names(df)<-c("S","v") # be sure to set the standard before input
  # Edit lm function to define linearization models
  fit <- switch(
      method,
      "lineweaver" = with(df, {
        m <- lm(I(1/v) ~ I(1/S), df)
        f <- coefs2params(method)
        b <- m$coefficients
        names(b) = NULL
        m$params <- f(b)
        m$covR <- vcov(m)
        m$J <- jacobian(f,x0=b)
        return(m)
      }),
      "eadie" = with(df, {
        m <- lm(v ~ I(v/S), df)
        f <- coefs2params(method)
        b <- m$coefficients
        names(b) = NULL
        m$params <- f(b)
        m$covR <- vcov(m)
        m$J <- jacobian(f,x0=b)
        return(m)
      }),
      "hanes" = with(df, {
        m <- lm(I(S/v) ~ S, df)
        f <- coefs2params(method)
        b <- m$coefficients
        names(b) = NULL
        m$params <- f(b)
        m$covR <- vcov(m)
        m$J <- jacobian(f,x0=b)
        return(m)
      }),
      "nonlinear" = with(df, {
        m <- nls(v ~ Vmax * S / (Km + S),
                 start = list(Vmax = max(v), Km = quantile(S,probs=0.2)), # makes a better estimation
                 data = df)
        f <- coefs2params(method)
        b <- m$coefficients
        names(b) = NULL
        m$params <- f(b)
        m$covR <- vcov(m)
        m$J <- jacobian(f,x0=b)
        return(m)
      })
    )

  # Get statistics like confidence intervals and p-value with error propagation formula
  # Only for linear models
  statistics <- with(fit, {
    names(coefficients)<-NULL
    # Matricial error propagation aproximation to variance of non-linear transformation
    covT = J %*% covR %*% t(J)
    dof = nrow(df)-2
    t0 = qt(level, df=dof)
    Vmax = params[1]
    Km = params[2]
    seVmax = sqrt(covT[1,1] / dof)
    seKm = sqrt(covT[2,2] / dof)
    st <- matrix(nrow=2,ncol=0)
    rownames(st) <- c("Vmax","Km")
    st <- st|>
      cbind(estimate=c(Vmax,Km)) |>
      cbind(se = c(seVmax, seKm))|>
      cbind(t = c(Vmax/seVmax, Km/seKm)) |>
      cbind(p_value = c(
        2*pt(Vmax/seVmax, df=dof, lower.tail = FALSE),
        2*pt(Km/seKm, df=dof, lower.tail = FALSE))) |>
      cbind(Lower=c(
        Vmax - t0 * seVmax,
        Km - t0 * seKm)) |>
      cbind(Upper=c(
        Vmax + t0 * seVmax,
        Km + t0 * seKm))
    return(st)
  })

  # return the parameters list
  return(list(fit, statistics))
}

# Example usage:
# load(file = "data/kinetics.rda")
# df <- kinetics |>
# dplyr::filter(ecnumber == "4.1.1.39", type=="irreversible") |>
# dplyr::select(time, substrate) |>
# tidyr::drop_na() |>
# fit_params(model = "rate", method = "nonlinear")
