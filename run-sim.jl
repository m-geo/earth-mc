

function run_sim(;run_years=2, thresh_func=nothing, var="t2m", start_date=DateTime(1960,1,1), step_size=Dates.Hour(6), 
    collection=nothing, box="globe", data_mode=false, yearly_avg=false)
    # essentially just iterate forward through the dataset (not rlly a simulation)
    date = start_date
    year = Dates.year(start_date)
    current_year = year
    timeseries = [] #list of all states (not unique)
    if data_mode
        if !yearly_avg
            timeseries = [[],[],[],[]] # one for each season
        end
    end
    yearly_ts = []

    for yr in 1:run_years
        # iterate through n number of years set by run_years
        file = "/storage3/mgeo/earth-mc/data/pressure-levels/$var-$year.nc" #automate locations!!
        tvec = get_tvec(file)
        lats = ncread(file,"latitude")
        lons = ncread(file,"longitude")
        vecs = [tvec, lons, lats]
        
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
            else
                # get parameter of interest over the field
                # for now: average temperature over cali
                snap = get_snap(file, vecs, date, var, box)
                param = mean(normalize_t1000.(snap), dims=[1,2])[1] ##agregate and automate the normalize functions!!
                
                if yearly_avg
                    push!(timeseries, param)
                else
                    season = get_season(date)
                    push!(timeseries[season], param)
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
    # vecs: [tvec, lats, lons]
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
