# enzymeR
![enzymeR](https://github.com/silvertaqman/enzymeR/assets/89056118/f6acaddc-5f3f-4026-9002-0e4165fb651a)
## Overview

**Determination of parameters for Michaelis-Menten Dynamics and more**

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

## Installation

## Usage

### fit_params()

The general sintaxis works with a relational dataset with the following structure with suggested units:

- *t*: time for kinetic determination [min]
- *S*: substrate concentration data [mM],
- *v*: reaction rate [mM/min]

Even if these variables are often measured within enzymatic kinetical experiments, only two of them are truly useful to fit parameters. You shoud choose the "time" options if your model data, usually at your excel file, has only time and Substrate concentration. If you calculated or measured reaction rate then choose "rate". Finally, choose a linearization method . Then, the function must be run:
```
fit_params(df, model="time", method="lb")
```

### simulate_kinetics()
