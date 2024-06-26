% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simulate_kinetics.R
\name{simulate_kinetics}
\alias{simulate_kinetics}
\title{Use kinetic parameters to simulate data over time, substrate or rate with Michaelis-Menten like models}
\usage{
simulate_kinetics(time, params)
}
\arguments{
\item{time}{A seq(a,b,n) vector setting size of simulation}

\item{params}{list of parameters useful for the simulation (S0, Km, Vmax, Ki, Ka)}
}
\value{
df dataset with a time, substrate or reaction rate structure
}
\description{
Use kinetic parameters to simulate data over time, substrate or rate with Michaelis-Menten like models
}
\examples{
simulate_kinetics(time, params=list(S0=1,Km=0.0149,Vmax=2.533))
}
