


#@info " "
#@info " "
#@info "Running ModulateInitialConcentrations.."
#@info " "

using Printf
import JSON

# Global settings: paths and plot
PATH_PARAMS = pwd()*"/model/params"
Data_Path = "./datasets/"

# readdlm is in here somewhere
include("DataFile.jl");
include("MassBalances.jl");


# import the initial condition vector
#@info "Importing Seed Concentrations"
working_initial_condition_vector = vec(broadcast(abs, float(open(readdlm,PATH_PARAMS*"/seed_initial_condition.dat"))));

# import the json as a dictionary
#@info "Importing New Concentrations"
species_dict = Dict()

open(Data_Path*"working_composition.json", "r") do file
    global species_dict
    species_dict = JSON.parse(file)  # parse and transform data
end


# iterate over the species dict
# each value is it's own dictionary
# extract the useful info out
# use it to update the vector

for (key, value) in species_dict

    #println("  ")

    #extract and convert to int or float as appropriate
    # for both the new concentration..
    new_conc = get!(value, "new_concentration",3)

    if new_conc isa Float64
        
    else
        new_conc = parse(Float64, new_conc)
    end

    # and it's index
    index = get!(value, "initial_condition_vector_index", 3)
    if index isa Int64
        
    else
        index = parse(Int64, index)
    end

    # store the old conc
    #@info "Updating $(key) ..."
    old_conc = working_initial_condition_vector[index]

    # update    
    working_initial_condition_vector[index] = new_conc

end

# Export the new array as a .dat file
# create the new file and open it
open(PATH_PARAMS*"/initial_condition.dat", "w") do file

    # iterate over the elements in the 1D array and write each line
    for i in working_initial_condition_vector
        println(file, i)
    end

end

#@info "Saving /initial_condition.dat"
#@info " "
#@info " "
#@info "ModulateInitialConcentrations complete."
#@info " "
#@info " "