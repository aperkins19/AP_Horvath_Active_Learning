using ProgressBars
using CSV
using DataFrames
using Plots 
using OrderedCollections
import JSON

# Global settings: paths and plot
PATH_PARAMS = pwd()*"/model/params"
Data_Path = "./datasets/"
Plot_Path = "./Plots/"


# readdlm is in here somewhere
include("./model/scripts/DataFile.jl");
include("./model/scripts/MassBalances.jl");
include("./AL_Scripts/grid_generators.jl");

# Active learning implementation by Alex Perkins, SBSG, University of Edinburgh

# 0.5) Define Species to Modulate
# Look Up Dict
TargetSpecies = OrderedDict(
                     "Ribosomes" => Dict("Look_Up" => "RIBOSOME", "initial_condition_vector_index" => "76", "max_conc_mM" => "0.5"),
                     "RNAP" => Dict("Look_Up" => "RNAP", "initial_condition_vector_index" => "73", "max_conc_mM" => "0.3"),
                     "Acetyl_CoA" => Dict("Look_Up" => "M_accoa_c", "initial_condition_vector_index" => "11", "max_conc_mM" => "1")
                     )


# manual check of the originals
#working_initial_condition_vector = vec(broadcast(abs, float(open(readdlm,PATH_PARAMS*"/seed_initial_condition.dat"))));
#println(working_initial_condition_vector[ parse(Int64, TargetSpecies["Ribosomes"]["initial_condition_vector_index"]) ] )

# Define Search Parameters
NumOfTargetSpecies = length(TargetSpecies)

# Define which fractions of the original max concentrations the algorithm can choose from
# e.g. 0.6 * 4 mM = 2.4 mM
# N.B. These are all discrete values to be chosen rather than a continum 
PermissiblePercentagesOfMaxConcs = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]




# Grid size
# This will be defined by how many experiments / composition variants can be put on one plate - in duplicate or else.
grid_size = 96


# 1) Initial parameter sampling

# this function and it's subordinates can be found in "./AL_Scripts/grid_generators.jl"
initialgrid = generate_initial_grid(grid_size, PermissiblePercentagesOfMaxConcs, NumOfTargetSpecies)
@info "Initial Grid Generated."

#heatmap(Matrix(initialgrid), c=:bluegreenyellow,yaxis="composition",axis="ID")
#savefig(Plot_Path*"initial_grid.png")

# save the initial grid for posterity
# gets the keys and then converts to an array.
initialgrid_columns = collect(keys(TargetSpecies))
CSV.write(Data_Path*"initial_grid.csv", DataFrame(initialgrid, initialgrid_columns)) 


# create a nested dict
# loop over the rows of the array

# first we need to create an array of strings for the dictionary to use as keys
record_names = []
for i = 1:size(initialgrid)[1]
    push!(record_names, string(i))
end

InitialGridDict = OrderedDict()

for i = 1:size(initialgrid)[1]

    Individual_record_dict = OrderedDict()

    comp = initialgrid[i,:]

    for j in 1:size(comp)[1]

        Protein_dict = OrderedDict(
        "initial_condition_vector_index" => TargetSpecies[initialgrid_columns[j]]["initial_condition_vector_index"],
        "new_concentration" => comp[j]
        )

        Individual_record_dict[initialgrid_columns[j]] = Protein_dict
    end
    InitialGridDict[record_names[i]] = Individual_record_dict
end

# save the whole initial grid dict as a JSON
open(Data_Path*"initial_grid_instructions.json","w") do f
    JSON.print(f, InitialGridDict)
 end


# iterate over the compositon
@info "Running compositions through Horvath Model..."
for (key, value) in ProgressBar(InitialGridDict)
    

    # save the working compostion as a json to be run in the model
    #working_composition_json_string = JSON.json(value)
    
    open(Data_Path*"working_composition.json","w") do f
        JSON.print(f, value)
    end

    # Run the ModulateInitialConditions.jl
    include("./model/scripts/ModulateInitialConditions.jl")

    # Conduct the Horvath Modelling
    include("run_model.jl");






end



# Run the ModulateInitialConditions.jl
#include("./model/scripts/ModulateInitialConditions.jl")

# Conduct the Horvath Modelling
#include("run_model.jl");

#C:\Users\Alex\OneDrive - University of Edinburgh\coding\nllab-CFPS-metabolic
#docker run -it --rm -p 8765:8888 -v "%CD%":/app --name jim julia_cfps_metabolic