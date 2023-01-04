using NetCDF
using Dates
using LinearAlgebra
using JLD

include("utils.jl")
include("run-sim.jl")


function assign_state(collection, loc)
    return argmin([LinearAlgebra.norm(loc .- item) for item in collection])
end


collection = JLD.load("/home/mgeo/earth-mc/vars/collection.jld","collection") #locations of everything has moved!!!

runs = 20

timeseries = run_sim(;run_years=runs, thresh_func=assign_state, var="t2m", 
                start_date=DateTime(2000,1,1), step_size=Dates.Hour(6), collection=collection)

JLD.save("/home/mgeo/earth-mc/vars/timeseries-later-$runs-years.jld", "timeseries", timeseries)