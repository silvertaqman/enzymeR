#' Use kinetic parameters to simulate data over time, substrate or rate with Michaelis-Menten like models
#'
#' @param time A seq(a,b,n) vector setting size of simulation
#' @param params list of parameters useful for the simulation (S0, Km, Vmax, Ki, Ka)
#' @param mode Choose between irreversible or reversible models
#' @param inhibition Choose a kind of inhibition: competitive, uncompetitive and others
#' @return df dataset with a time, substrate or reaction rate structure
#' @examples
#' simulate_kinetics(time, params=list(S0=1,Km=0.0149,Vmax=2.533), inhibition=NULL)
# Create an equations db

simulate_kinetics <- function(time, params) {
  # set equations
  # Definir las ecuaciones como funciones
  equations <- list(
    # "irreversible MM rate equation"
    irrev = function(time, params) {
      df <- with(params, {
        data.frame(
          time=time,
          Substrate = Km*pracma::lambertWp(S0*exp((S0-Vmax*time)/Km)/Km), #Schnell-Mendoza eq
          rate = Vmax*Substrate/(Km+Substrate) # MM equation
        )})
      return(df)},
    # Competitive Inhibition
    eq2 = function(time, params) { a * b * c },
    eq3 = function(time, params) { a^2 + b^2 + c^2 }
  )
  # validate params names
  required_params <- unique(unlist(lapply(equations, function(eq) {
    names(formals(eq))
  })))
  if (!all(required_params %in% names(params))) {
    stop("Missing required parameters")
  }
  results <- sapply(equations, function(eq) {
    do.call(eq, params)
  })
  return(results)
}
# Evaluar las ecuaciones
# results <- simulate_kinetics(time, params)
# print(results)
