




function present_in_array(this_sample_conc, array_to_avoid)
# Checks whether composition sample is already present in array
# present,i = present_in_array(this_sample_conc,x_data)
    present = false

    #defining this variable as global allows it to persist outside the function
    global ind = 0

    # iterate over the array presenting each sample slice
    # sample slice = array_to_avoid[i,:]
    for i = 1:size(array_to_avoid)[1]

        # if said sample slice is equal to this proposed sample concentration composition then:
        # sent present equal to true, save the index and return both
        if array_to_avoid[i,:] == this_sample_conc
            present = true 
            ind = i
            break
        end
    end
    return present,ind
end









function generate_random_grid(array_to_avoid, total_grid_size, NumOfTargetSpecies, PermissiblePercentagesOfMaxConcs)
# Generates random grid while avoiding compositions already defined
# ID and number of compositions hard-coded

    # a counter for tracking how many samples have been accepted
    accepted_counter = 0
    # initialise array for holding the accepted samples
    ALarray = []

    #show(stdout, "text/plain", array_to_avoid)

    # the process repeats until the total number is full
    while accepted_counter < total_grid_size

        ### 1) Make random sample (an array)

        # choose from a range from 1 to the length of the allowed %s
        # The array is the length of the number of target species
        this_sample = rand(1:length(PermissiblePercentagesOfMaxConcs), NumOfTargetSpecies)

        # the array can then be scaled by passing it to the PermissiblePercentagesOfMaxConcs
        # this will use the array of ints as indexes and effectively randomly sample the allowed % 
        this_sample_conc = PermissiblePercentagesOfMaxConcs[this_sample]

        ### 2) Check to see if Sample already exists.

        # if not already present
        if ! present_in_array(this_sample_conc, array_to_avoid)[1]

            # Add sample to new ALarray as well as array_to_avoid
            accepted_counter +=1

            # reshape the sample to 1 row x as many columns as species
            reshapedsample = reshape(this_sample_conc,(1,NumOfTargetSpecies))


            # if it's the first then add it.
            if ALarray == []
                ALarray = reshapedsample
                #@info "first one success"

            # if it's not then vertical concat.
            else
                ALarray = vcat(ALarray,reshapedsample)

            end

            # add also to the array to avoid...
            array_to_avoid = vcat(array_to_avoid,reshapedsample)
        else
           #@warn("skipping")
        end
    end
    return ALarray
end






function generate_initial_grid(grid_size, PermissiblePercentagesOfMaxConcs, NumOfTargetSpecies)

    max_concentration_fraction = maximum(PermissiblePercentagesOfMaxConcs)
    min_concentration_fraction = minimum(PermissiblePercentagesOfMaxConcs)

    ###  1) Create an array containing all maximum compositions except one which is the minimum.

    # create a 1D array full of 1.0 which is the length of how many species are being varied.
    # Scale the 1.0 by the maximum to generate an array of maximum fractions.

    allmax = ones(1,NumOfTargetSpecies) * max_concentration_fraction

    # store the max array as the first element in the final array.
    allmaxonelow = allmax

    # create the diagonal array
    # use the index of the length of the array to walk across the array, setting that element to the minimum.
    # And then append
    for idx = 1:NumOfTargetSpecies
        this_sample = copy(allmax)
        this_sample[idx] = min_concentration_fraction

        # stack the array
        allmaxonelow = vcat(allmaxonelow,this_sample)
    end

    ### 2) Now do the inverse - all min but one which is max
    # all minimum
    allmin = ones(1, NumOfTargetSpecies) * min_concentration_fraction
    # init 2d array
    allminonehigh =  allmin

    for idx = 1: NumOfTargetSpecies
        this_sample = copy(allmin)
        this_sample[idx] = max_concentration_fraction

        # stack
        allminonehigh = vcat(allminonehigh, this_sample)
    end

    ### 3) Now combine the two high & low arrays
    # we will pass this into to the random generator which will use it to ensure that compositions are not duplicated
    high_and_low = vcat(allmaxonelow, allminonehigh)
    #show(stdout, "text/plain", high_and_low)

    ### 4) Now generate the randomally sampled array
    total_grid_size = (grid_size - 2) * (NumOfTargetSpecies + 1)

    randomgrid = generate_random_grid(high_and_low, total_grid_size, NumOfTargetSpecies, PermissiblePercentagesOfMaxConcs);
    

    # now concatenate all the grids to produce the initial grid

    initialgrid = vcat(high_and_low, randomgrid)

    return initialgrid
    
end