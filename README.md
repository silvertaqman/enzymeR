# enzymeR <a href="https://github.com/silvertaqman/enzymeR"><img src="man/figures/enzymeR.png" align="right" height="140" /></a>

This is a recopilatory package dedicated to management of substrate consumption data over enzymatic assays to determine kinetic parameters. It could also be redirected to simulate kinetical experiments once you know or want to try some parameters and returns time, substrate and rate data. 
## Overview

**Determination of parameters for Michaelis-Menten Dynamics**

Individual biochemical reactions are a useful method when critical metabolic points are needed. This reactions have a ubiquitous form:

$$S \overset{\text{E}}{\longrightarrow} P$$

But is usually referred to show complex intermediates between substrate and enzymes:

\[ E+S \underset{\text{k_{-1}}}{\overset{\text{k_1}}{\rightleftharpoons}} ES \overset{\text{k_2}}{\longrightarrow} E+P
\]

This package aims to fully characterize kinetical and thermodynamic properties of irreversible metabolic enzymes throught deriving a Michaelis-menten like rate equation, parameters and plots for tidy datasets. So, you just only need two kind of measurements: 

a) Time & Substrate measurements
b) Substrate & Rate measurements

And you can obtain $V_{max}$ and $K_m$ estimations with statistical behaviour like deviance, confidence intervals and hypothesis testing capability compatible with R functions.

**So, what´s new?**

This package allows compatibility with statistical inquiries for the user, typical plots and linearization methods makes easy. Implements S4 OO programming logic to set an estimator and simulator environment. It includes functions and options to account for:

- Parameter estimation with
  + Linearization strategies by
    + Lineweaver-Burk Method
    + Eadie-Hofstee Method
    + Hanes-Woolf Method
  + Non-Linear strategies by
    + Weighted least-squares
    + Generalized Linear Models
- Elasticities
- Reversibility
- Mass Action Disequilibrium Ratio $\Gamma$ 
- the usual five kinds of *inhibition*, allowing to estimate:
  + Competitive
  + Non competitive
  + Uncompetitive
  + Partial Inhibition
  + Mixed Inhibition
  + Binding of inhibitors to enzyme,
  + Substrate inhibition
  + inhibition by binding to substrate
  + Binding of ligands to proteins
  + *Activation* of enzymes
- Cooperativity with:
  + Hill equation
  + Ligand Binding
  + Adair Equation
  + *Monod-Wynad-Changeaux* (MWC) rate expression for enzymes with sigmoid kinetics.
  + *KNF* Sequential Model
- Allostery
- Multireactant mechanisms with
  + Ordered Bi-Bi
  + Random Order
  + Ping-Pong Mechanism
- Temperature and pH dependence
- Generalized Rate laws
  + Linear
  + Linear - Logarithmic
  + Algebraic Aproximations
  + Hanekom Rate law
  + Liebermeister Rate Law
- Kinetics plots

And, as you may know by this time, you can use this package to simulate kinetics of gene regulation. We include example data and tests to simulate:

- Structure of a Microbial Genetic Unit
- Gene regulation
- Fractional Occupancy

If you want to colaborate send a mail to [adonisjgallardo@gmail.com](adonisjgallardo@gmail.com) with a list of reasons and a time disponibility schedule.

## Installation

This package is, for now, accesible from github only:

```
remotes::install_github("https://github.com/silvertaqman/enzymeR")
```

## Usage
The sintax is described in the plot below:

<p align="center">
  <a href="https://github.com/silvertaqman/enzymeR">
    <img src="man/figures/howto.png" height="250" />
  </a>
</p>


You need a *df* dataset with a tidy structure or a *params* list of kinetical parameters and you can conditionally exchange between those forms. See *data-raw* for examples over conditions.

### fit_params()

The general sintaxis works with a relational, or tidy, dataset with the following structure with suggested units:

- *t*: time for kinetic determination [min]
- *S*: substrate concentration data [mM],
- *v*: reaction rate [mM/min]

Even if these variables are often measured within enzymatic kinetical experiments, only two of them are truly useful to fit parameters. You shoud choose the "time" options if your model data, usually at your excel file, has only time and Substrate concentration. If you calculated or measured reaction rate then choose "rate". Finally, choose a linearization method . Then, the function must be run:
```
fit_params(df, model="time", method="lb")
```
This implementation allows to get a non-linear regression method with base on ... 

### simulate_kinetics()
You should provide a list with a set of parameters and a certain mode of operation:
- *K_m*: Concentration to get half of maximum rate
- *V_{max}*: Maximum reaction rate for enzymatic catalysis
- *K_i*: Inhibitor concentration constant
- *K_a*: Activator concentration constat

### kinetic_plots()
This function allows to get:
- Linearization plots and the direct plot method
```
df |>
  fit_params() |>
  kinetic_plots(mode="linearization")
```
  
- Substrate-Rate plot for the best model, or the one with minimum error, and the confidence intervals for parameters
```
df |>
  fit_params() |>
  kinetic_plots(mode="best")
```
 
- Substrate-Rate over time plot as an animated plot
```
simulate_kinetics(time, parms) |>
  kinetic_plots(mode="simulation")
```
