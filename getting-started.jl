using NetCDF
using Dates
using Statistics

include("utils.jl")

# precip

# ncinfo("jan1959-precip.nc")
# filename = "jan1959-precip.nc"

# tp = ncread(filename, "tp")
# tp = (tp*1.1494792990447085e-6).+0.03766383871249891
# tp_slice = ncread(filename,"tp",start=[180,45,1], count=[1,1,-1])

tvec = DateTime(1900,1,1)+Hour.(ncread(temp_file,"time"))


lons = ncread(temp_file,"longitude")
lats = ncread(temp_file,"latitude")
tp_slice = ncread(filename,"tp",start=[941,161,700], count=[240,100,1])
plot(heatmap(x=lons,y=lats,z=tp_slice))

map = dropdims(sum(tp[:,:,:],dims=3), dims=3)

hm = GLMakie.heatmap(lons, lats, map)


avg_ts = dropdims(mean(tp[:,:,:], dims=[1,2]), dims=(1,2))
avg_ts = (avg_ts*1.1494792990447085e-6).+0.03766383871249891

Plots.plot(tvec,avg_ts)


## temp

temp_file = "/storage3/mgeo/earth-mc/data/pressure-levels/t1000-1960.nc"
ncinfo(temp_file)
tvec = get_tvec(temp_file)

t2m = ncread(temp_file, "t2m")
t2m = normalize_t2m(t2m, temp_file)
t2m_slice = ncread(temp_file,"t2m",start=[941,161,700], count=[240,100,1])
plot(heatmap(1:240,1:100,reshape(t2m_slice,(240, 100))))

plot(heatmap(1:length(lats),1:length(lons),t2m[:,:,1]))
plot(heatmap(lons,reverse(lats),t2m[:,:,1]))


heatmap(1:length(lons),1:length(lats),rand(length(lons), length(lats)))

GLMakie.heatmap(lons, lats, t2m[:,:,1])

GLMakie.heatmap(t2m_slice)

t2m_ts = t2m[:,:,:]
sum(t2m, dims=1)


for i in range(1,1,744)
    i = Int(i)
    if tvec[i] != DateTime(1959,1,1)+Hour(i-1)
        print(tvec[i])
        break
    end
end

##

JLD.load("vars/nigeria/seasonal-1981-1991.jld","ts")