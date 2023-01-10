function run_sim(;run_years=2, thresh_func=nothing, var="t2m", start_date=DateTime(1960,1,1), step_size=Dates.Hour(6), 
    collection=nothing, box="globe", data_mode=false, seasonal=false, yearly_avg=false)
    # essentially just iterate forward through the dataset (not rlly a simulation)
    #options:
    #   box: area of analysis. options: {cali_box, nigeria, globe}
    #   data_mode: if true: collect data without any partitioning/states
                # if false: keep track of state evolution only
    #   yearly_avg: sub-mode of data mode, just an integrated way to collect yearly averages

    date = start_date
    year = Dates.year(start_date)
    current_year = year
    timeseries = [] #list of all states (not unique)

    if seasonal
        timeseries = [[],[],[],[]]
    end
    yearly_ts = []

    for yr in 1:run_years
        # iterate through n number of years set by run_years
        file = "/storage3/mgeo/earth-mc/data/pressure-levels/$var-$year.nc" #automate storage locations!!
        tvec = get_tvec(file)
        lats = ncread(file,"latitude")
        lons = ncread(file,"longitude")
        vecs = [tvec, lons, lats]
        scale_factor, add_offset = get_normalization(file, var)
        
        println("STARTING $year")

        while current_year == year
            #keep going through a single year
            date += step_size
            current_year = Dates.year(date+step_size)
            
            if !data_mode
                # get and record classification
                snap = get_snap(file, vecs, date, var, box)
                state = thresh_func(collection, date, snap)
                push!(timeseries, state)
            else #if data mode
                # get parameter of interest over the field  
                snap = get_snap(file, vecs, date, var, box)
                
                param = 0.0
                if box == "globe"
                    param = spherical_mean(normalize.(snap, scale_factor, add_offset), vecs[3])
                else
                    param = mean(normalize.(snap, scale_factor, add_offset), dims=[1,2])[1]
                end
                if seasonal
                    season = get_season(date)
                    push!(timeseries[season], param)               
                else    
                    push!(timeseries, param)
                end
                
            end
            
        end

        #if we end up here, we've gone through a full year
        if yearly_avg
            push!(yearly_ts,mean(timeseries))
            timeseries = []
        end
        year += 1 #start again in the next year
    end
    
    if yearly_avg
        return yearly_ts
    else
        return timeseries
    end
end

function get_snap(file, vecs, date, var="t2m", mode="globe")
    # return 2d snapshot of var field at specified time 
    # vecs: [tvec, lons, lats]
    ind = index(vecs[1], date)

    start = []
    count = []
    if mode == "globe"
        start = [1,1,ind]
        count = [-1, -1, 1]
    elseif mode == "cali_box"
        start = [index(vecs[2],convert_lon(-125)), index(vecs[3],42), ind]
        count = [11*4, 11*4, 1]
    elseif mode == "nigeria"
        start = [index(vecs[2],convert_lon(2)), index(vecs[3],14), ind]
        count = [13*4,10*4,1]
    end

    if var == "t1000"   #systematize this somehow
        var = "t"
    end

    snap = ncread(file, var, start=start, count=count) 
    return dropdims(snap, dims=3)
end

##test
# fn = "/storage3/mgeo/earth-mc/data/pressure-levels/t1000-1959.nc"
# vecs = [get_tvec(fn), ncread(fn,"longitude"), ncread(fn,"latitude")]
# snap = get_snap(fn, vecs, DateTime(1959, 1, 20), "t1000", "globe")
# scale_factor, add_offset = get_normalization(fn, "t")
# snap = normalize.(snap, scale_factor, add_offset)
# spherical_mean(snap, vecs[3])
# mean(snap)