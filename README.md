# enzymeR

## Determination of parameters for Michaelis-Menten Dynamics and more

Individual biochemical reactions are a useful method when critical metabolic points are needed. This package aims to fully characterize kinetical and thermodynamic properties of irreversible metabolic enzymes throught deriving a Michaelis-menten like rate equation, parameters and plots for tidy datasets. Also, there are functions and options to add:

- Reversibility,
- the usual five kinds of inhibition,
- binding of inhibitors to enzyme,
- substrate inhibition
- inhibition by binding to substrate
- Binding of ligands to proteins
- the Hill equation and
- the *Monod-Wynad-Changeaux* rate expression for enzymes with sigmoid kinetics. 

If you want to colaborate just ask for pull requests.

## How to use

The general sintaxis needs a dataframe or tibble dataset with *S*: substrate concentration data [mM], and *v*: reaction rate. 
