using NetCDF
using Dates
using Statistics

include("utils.jl")
include("run-sim.jl")

temp_file = "/storage3/mgeo/earth-mc/data/pressure-levels/t1000-1960.nc"
ncinfo(temp_file)
tvec = get_tvec(temp_file)
lons = ncread(temp_file,"longitude")
lats = ncread(temp_file,"latitude")
vecs=[tvec, lons, lats]
scale_factor, add_offset = get_normalization(temp_file, "t1000")

metric_kind_of = reshape(cos.(lats / 180 * π), (1, length(lats)))

snap = get_snap(temp_file, vecs, DateTime(1960, 1, 20), "t1000")

snap = normalize_era5(snap, scale_factor, add_offset)

snap = metric_kind_of .* snap