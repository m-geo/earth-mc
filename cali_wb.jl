# combined script + workbook
using NetCDF
using Dates
using Statistics
using LinearAlgebra
using JLD
using Latexify
# using MarkovChainHammer

include("run-sim.jl")
include("utils.jl")
include("thresh_funcs.jl")
# include("MCHammer/construct_from_data.jl")

# definition years: 1959-1969: 10 years
# walk through the years and get a temp. distribution (4 of them, one for each season)

## generate reference timeseries:
# data_ts = run_sim(;run_years=50, thresh_func=nothing, var="t1000", box="nigeria", start_date=DateTime(1959,1,1),
#                          step_size=Dates.Hour(6), collection=nothing, data_mode=true, seasonal=true, yearly_avg=false)
# #
# JLD.save("/home/mgeo/earth-mc/vars/nigeria/all_seasonal.jld","ts",data_ts)

# base_timeseries = JLD.load("./vars/globe/base_timeseries.jld","ts")

# Markov Chain implementation:


#test:
#generate reference 
data_ts = run_sim(;run_years=10, thresh_func=nothing, var="t1000", box="nigeria", start_date=DateTime(1960,1,1),
                         step_size=Dates.Hour(2), collection=nothing, data_mode=true, monthly=true, nights=false, yearly_avg=false)

JLD.save("./vars/nigeria/mc-ref-ts-five-2hrs.jld","ts",data_ts)

data_ts = JLD.load("./vars/nigeria/mc-ref-ts-five.jld","ts")
#generate cutoffs
cutoffs = generate_cutoffs(data_ts; percentiles=[0.05, 0.25, 0.75, 0.95])
#run mc step through sim
ts = run_sim(;run_years=20, thresh_func=assign_five_state_cold, var="t1000", box="nigeria",
                        start_date=DateTime(2000,1,1), step_size=Dates.Hour(2), collection=cutoffs, data_mode=false)

JLD.save("./vars/nigeria/mc_ts_five_00_2hrs.jld","ts",ts)


using MarkovChainHammer.TransitionMatrix: generator, perron_frobenius

per_frob = perron_frobenius(ts, 72)
gen_matrix = generator(ts, 36; dt=6)

latexify(round.(per_frob, digits=3))
latexify(round.(gen_matrix, digits=3))                        

ss = steady_state(gen_matrix, number_of_states=36)
latexify(round.(real.(transpose(ss)), digits=3))

##

# timeseries = JLD.load("./vars/t1000_yearly_ts_2.jld","ts")