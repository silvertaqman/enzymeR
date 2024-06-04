#' Use kinetic parameters to simulate data over time, substrate or rate with Michaelis-Menten like models
#'
#' @param time A seq(a,b,n) vector setting size of simulation
#' @param params list of parameters useful for the simulation (S0, Km, Vmax, Ki, Ka)
#' @return df dataset with a time, substrate or reaction rate structure
#' @examples
#' simulate_kinetics(time, params=list(S0=1,Km=0.0149,Vmax=2.533))
# Create an equations db

simulate_kinetics <- function(time, params) {
  # set equations
  substrate = with(params, Km*pracma::lambertWp(S0*exp((S0-Vmax*time)/Km)/Km)) #Schnell-Mendoza eq
  rate = with(params, Vmax*substrate/(Km+substrate)) # MM equation
  return(data.frame(t=time, S=substrate, v=rate))
}
# Evaluar las ecuaciones
# results <- simulate_kinetics(time, params)
# print(results)
