# nllab-CFPS-metabolic
Implementation of Horvath et al. 2020 cell-free metabolic model, originally developed by the Varner Lab at Cornell. Original code [here](https://github.com/varnerlab/Kinetic-CFPS-Model-Publication-Code) and original paper [here](https://www.sciencedirect.com/science/article/pii/S2214030118300452). Tested on Julia 1.4 and 1.5.

## Usage
The Julia script runs the model and outputs a plot of the kinetic production of chloramphenicol acetyltransferase (CAT) over 3h. It can be modified and interrogated as required.

With a working local installation of Julia, start up the REPL by running `julia` on the command line. Use the following two commands to call up the package manager and activating the environment: `]` `activate .` (don't forget the dot). Exit the package manager by pressing Backspace, and then run the model by calling `include("run.jl")`. This solves the model for the best fit parameter set; a specific parameter set (or multiple sets) can be selected in the script. 

Alternatively, run the scripts on our lab Julia Docker container according to the instructions [here](https://github.com/Laohakunakorn-Group/nllab-Dockerfiles).


## The model
The model is generated from a network stoichiometry (`"./model/network/Network.dat"` file) obtained by modifying an iAF1260 model for K12-MG1655 E. coli, in order to more closely approximate cell-free lysate conditions. ODEs are generated from the network, and encoded in `"./model/scripts/Kinetics.jl"`. 

There are a total of 148 metabolites, which take part in 204 enzyme-catalysed reactions. Each reaction is associated with a Vmax rate constant, a Km saturation constant, and if applicable, control constants. These parameters, and the initial conditions for all species, are found in `"./model/params"`. An ensemble of 100 parameter sets was obtained by MCMC fitting to HPLC time-series data for 37 metabolites. 


# Alex's notes

#### Docker set up
Using Nadanai's Dockerfile with some edits:

* Added JSON package  
On Start-Up:
* Will automatically activate environment
* Navigates into `/app`
* Executes `run.jl`

```bash
docker build -t julia_cfps_metabolic .
```

```bash
docker run -it --rm -p 8765:8888 -v "%CD%":/app --name jim julia_cfps_metabolic
```




## Edits to the workflow


### ModulateInitialConditions.jl

* Imports the `seed_initial_condition.dat` & `species_to_modulate.json`
* Uses information in the json to index the correct species to update the initial_condition_vector to the desired concentrations and exports it as `initial_condition.dat`