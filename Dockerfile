# Dockerfile 12/2020
# nllab-julia - basic Julia environment 

FROM julia:1.5.3 AS Base

MAINTAINER Nadanai Laohakunakorn <nadanai.laohakunakorn@ed.ac.uk>
MAINTAINER Alex Perkins <a.j.p.perkins@sms.ed.ac.uk>


#WORKDIR /app
#COPY . .

RUN julia -e 'import Pkg; Pkg.update()' && \
    julia -e 'using Pkg; Pkg.add("DelimitedFiles")' && \
    julia -e 'using Pkg; Pkg.add("DataFrames")' && \
    julia -e 'using Pkg; Pkg.add("OrderedCollections")'  && \
    julia -e 'using Pkg; Pkg.add("CSV")' && \
    julia -e 'using Pkg; Pkg.add("JSON")' && \
    julia -e 'using Pkg; Pkg.add("XLSX")' && \
    julia -e 'using Pkg; Pkg.add("Interpolations")' && \
    julia -e 'using Pkg; Pkg.add("Plots")' && \
    julia -e 'using Pkg; Pkg.add("DifferentialEquations")' && \
    julia -e 'using Pkg; Pkg.add("ProgressBars")' && \
    julia -e 'using Pkg; Pkg.add("Statistics")' && \
    julia -e 'using Pkg; Pkg.add("DiffEqFlux")' && \
    julia -e 'using Pkg; Pkg.add("DiffEqParamEstim")' && \
    julia -e 'using Pkg; Pkg.add("BlackBoxOptim")' && \
    julia -e 'using Pkg; Pkg.add("Flux")' && \
    julia -e 'using Pkg; Pkg.add("RecursiveArrayTools")' && \
    julia -e 'using Pkg; Pkg.add("Optim")' && \
    julia -e 'using Pkg; Pkg.add("IJulia")' && \
    julia -e 'using Pkg; Pkg.add("PyCall")' && \
    julia -e 'using Pkg; Pkg.add("PyPlot")' && \
    julia -e 'using Pkg; Pkg.add("Sundials")' && \
    julia -e 'using Pkg; Pkg.add("Colors")' && \
    julia -e 'using Pkg; Pkg.add("GraphPlot")' && \
    julia -e 'using Pkg; Pkg.add("LightGraphs")' && \
    julia -e 'using Pkg; Pkg.add("BSON")' && \
    julia -e 'using Pkg; Pkg.add("CUDA")' && \
    julia -e 'using Pkg; Pkg.add("Cairo")' && \
    julia -e 'using Pkg; Pkg.add("DataDrivenDiffEq")' && \
    julia -e 'using Pkg; Pkg.add("DiffEqBayes")' && \
    julia -e 'using Pkg; Pkg.add("DiffEqSensitivity")' && \
    julia -e 'using Pkg; Pkg.add("Distributions")' && \
    julia -e 'using Pkg; Pkg.add("Gadfly")' && \
    julia -e 'using Pkg; Pkg.add("HDF5")' && \
    julia -e 'using Pkg; Pkg.add("LinearAlgebra")' && \
    julia -e 'using Pkg; Pkg.add("LsqFit")' && \
    julia -e 'using Pkg; Pkg.add("MLDatasets")' && \
    julia -e 'using Pkg; Pkg.add("Metrics")' && \
    julia -e 'using Pkg; Pkg.add("ModelingToolkit")' && \
    julia -e 'using Pkg; Pkg.add("OrdinaryDiffEq")' && \
    julia -e 'using Pkg; Pkg.add("StatsPlots")' && \
    julia -e 'using Pkg; Pkg.add("Turing")' && \
    julia -e 'using Pkg; Pkg.add("TerminalLoggers")' && \
    julia -e 'using Pkg; Pkg.precompile()'

# start the julia environment on start-up
RUN julia -e 'using Pkg; Pkg.activate(".")'

# navigate into /app
WORKDIR /app

# automatically run 
CMD julia -e 'include("run.jl")'