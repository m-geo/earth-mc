using NetCDF
using Dates
using Statistics
using LinearAlgebra
using JLD
using Latexify

include("utils.jl")
include("run-sim.jl")

include("MCHammer/construct_from_data.jl")

# file = "/storage3/mgeo/earth-mc/data/t2m-1960.nc"
# ncinfo(file)
# tvec = get_tvec(file)
# lons = ncread(file,"longitude")
# lats = ncread(file,"latitude")

# index_time(tvec, DateTime(1960,12,31, 18))

## GENERATE COMPARISON COLLECTION

# collection = []
# for month in 1:12
#     ind = index_time(tvec, DateTime(1959,month,1))
#     next_ind = 0
#     try
#         next_ind = index_time(tvec, DateTime(1959,month+1,1))
#     catch
#         next_ind = length(tvec)+1
#     end
#     # println((next_ind-ind)/24)
#     month_nc = ncread(file, "t2m", start=[1,1, ind], count=[-1,-1, next_ind-ind])
#     avg = dropdims(mean(month_nc, dims=3), dims=3)
#     push!(collection, avg)
# end

# JLD.save("vars/collection.jld","collection", collection)

# test_bit = ncread(file, "t2m", start=[1,1,8137], count=[-1,-1,1])
# test_bit = dropdims(test_bit, dims=3)

function assign_state(collection, date, snap)
    return argmin([LinearAlgebra.norm(snap .- item) for item in collection])
end

###

timeseries = JLD.load("/home/mgeo/earth-mc/vars/timeseries-later-20-years.jld", "timeseries")

cnt_op = count_operator(timeseries, 12)
per_frob = perron_frobenius(timeseries, 12)
hold_time = holding_times(timeseries, 12; dt=6)
gen_matrix = generator(timeseries, 12; dt=6)

show_full(per_frob)
show_full(gen_matrix)

latexify(round.(per_frob, digits=3))
latexify(round.(gen_matrix, digits=3))


