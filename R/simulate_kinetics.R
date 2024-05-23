#' Use kinetic parameters to simulate data over time, substrate or rate
#'
#' @param time A seq(a,b,n) vector setting size of simulation
#' @param params list of parameters useful for the simulation (S0, Km, Vmax, Ki, Ka)
#' @return df dataset with a time, substrate, reaction rate structure
#' @examples
#' simulate_kinetics(time, params=list(Km=0.0149,Vmax=2.533), inhibition=NULL)

#Create an equations db
# Definir las ecuaciones como funciones
equations <- list(
  # "irreversible MM rate equation"
  A = function(time, params) {
    df <- with(params, {
      data.frame(
        time=time,
        Substrate = Km*pracma::lambertWp(S0*exp((S0-Vmax*time)/Km)/Km), #Schnell-Mendoza eq
        rate = Vmax*Substrate/(Km+Substrate) # MM equation
        )
      }
      )
    return(df)}, 
  # Inhibition
  eq2 = function(time, params) { a * b * c },
  eq3 = function(time, params) { a^2 + b^2 + c^2 }
)

simulate_kinetics <- function(from=0, to=1, n=10, params, equations=equations) {
  t = seq(from, to, n)
  # Validar que params contiene los nombres correctos
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
# results <- evaluate_equations(equations, params)
# print(results)