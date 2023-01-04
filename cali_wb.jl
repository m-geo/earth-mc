using NetCDF
using Dates
using Statistics
using LinearAlgebra
using JLD
using Latexify

include("run-sim.jl")
include("utils.jl")
include("MCHammer/construct_from_data.jl")

#LET'S DEFINE AN EXTREME STATE

# definition years: 1959-1969: 10 years
# walk through the years and get a temp. distribution (4 of them, one for each season)

## generate reference timeseries:
data_ts = run_sim(;run_years=60, thresh_func=nothing, var="t1000", box="globe",
                        start_date=DateTime(1959,1,1), step_size=Dates.Hour(6), collection=nothing, data_mode=true, yearly_avg=true)
#
JLD.save("/home/mgeo/earth-mc/vars/t1000_yearly_ts.jld","ts",data_ts)

# base_timeseries = JLD.load("./vars/globe/base_timeseries.jld","ts")


# DJF = base_timeseries[1]
# MMA = base_timeseries[2]
# JJA = base_timeseries[3]
# SON = base_timeseries[4]

# Statistics.quantile(DJF, 0.95) #287.93533181145926
# Statistics.quantile(MMA, 0.95) #294.136056852706
# Statistics.quantile(JJA, 0.95)
# Statistics.quantile(SON, 0.95)


# function assign_state(ref_collection, date, snap)
#     #ref collection is a list of four lists, per season
#     season = get_season(date) #numebr 1-4
#     ref = ref_collection[season]
#     thresh95 = Statistics.quantile(ref,0.95)
#     thresh75 = Statistics.quantile(ref,0.75)
#     param = mean(normalize_t2m.(snap), dims=[1,2])[1] # this could be generalized to take a function
#     out = 0
#     if param > thresh95
#         out = 1
#     elseif param > thresh75
#         out = 2
#     else
#         out = 3
#     end
#     out += 3 * (season-1)
#     return out
# end


# ts = run_sim(;run_years=20, thresh_func=assign_state, var="t2m", 
#                         start_date=DateTime(1970,1,1), step_size=Dates.Hour(6), collection=base_timeseries, data_mode=false)

# cnt_op = count_operator(ts, 12)
# per_frob = perron_frobenius(ts, 12)
# hold_time = holding_times(ts, 12; dt=6)
# gen_matrix = generator(ts, 12; dt=6)

# latexify(round.(per_frob, digits=3))
# latexify(round.(gen_matrix, digits=3))                        

# ss = steady_state(gen_matrix, number_of_states=12)
# latexify(round.(real.(ss), digits=3))