# modified by N Laohakunakorn
# University of Edinburgh 2020

include("Kinetics.jl");
include("Control.jl");

# ----------------------------------------------------------------------------------- #
# Copyright (c) 2017 Varnerlab
# School of Chemical Engineering Purdue University
# W. Lafayette IN 46907 USA

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ----------------------------------------------------------------------------------- #
#function MassBalances(dxdt_vector,x,t,data_dictionary)
function MassBalances(dxdt_vector,x,data_dictionary,t)
# ---------------------------------------------------------------------- #
# MassBalances.jl was generated using the Kwatee code generation system.
# Username: nicholas
# Type: CFPS-JULIA
# Version: 1.0
# Generation timestamp: 03-24-2017 13:01:36
# 
# Arguments: 
# t  - current time 
# x  - state vector 
# dxdt_vector - right hand side vector 
# data_dictionary  - Data dictionary instance (holds model parameters) 
# ---------------------------------------------------------------------- #


# Set RIBOSOME_START_CAT to RIBOSOME_START_CAT initial condition + RIBOSOME initial condition - RIBOSOME concentration
initial_condition = data_dictionary["INITIAL_CONDITION_ARRAY"]
x[76] = min(x[76], initial_condition[76]+initial_condition[77])
x[77] = min(x[77], initial_condition[76]+initial_condition[77])

# Correct negative x's = throws errors in control even if small - 
idx = x.<0;
x[idx] = zeros(size(x[idx]));

# Call the kinetics function - 
rate_vector = Kinetics(t,x,data_dictionary);

# Call the control function - 
rate_vector = Control(t,x,rate_vector,data_dictionary);

# Encode the balance equations as a matrix vector product - 
S = data_dictionary["STOICHIOMETRIC_MATRIX"];
tmp_vector = S*rate_vector;
number_of_states = length(tmp_vector);

for state_index in collect(1:number_of_states)
    dxdt_vector[state_index] = tmp_vector[state_index];	
end

dxdt_vector[[138;143]] .= 0; # Set M_h_c and M_o2_c to steady-state

end
