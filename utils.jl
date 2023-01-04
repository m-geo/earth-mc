
function show_full(array)
    show(IOContext(stdout, :limit=>false), MIME"text/plain"(), array)
end


function get_tvec(filename)
    return DateTime(1900,1,1)+Hour.(ncread(filename,"time"))
end

function convert_lon(lon)
    # in: lon on a +/- scale
    # out: lon on 360
    if lon > 0
        return lon
    else
        return 360 + lon
    end
end

function index(vec, value) #surely there's a better way to do this directly from the definition?
    # in: actual date (datetime format)
    # func: find the correct location on the tvector,
            # get index on tvec
    # out: index, can be applied to any other vector tbh:
        #for lat and lon, works in increments of 0.25

    return findfirst(x -> x==value, vec)
end


function normalize_tp(tp)
    # apply normalization func to precip
    # where tp is an array
    return (tp*1.1494792990447085e-6).+0.03766383871249891
end

function normalize_t2m(t2m)
    # apply normalization to temp
    return (t2m*0.001715080858817671).+264.37076263779323
end

function normalize_t1000(t1000)
    return (t1000*0.0017247656599448226).+269.11825535398646
end

function get_season(date)
    month = parse(Int64, Dates.format(date, "mm"))
    if month <= 2
        return 1
    elseif 3 <= month <= 5
        return 2
    elseif 6 <= month <= 8
        return 3
    elseif 9 <= month <= 11
        return 4
    else #december
        return 1
    end
end

function steady_state(T_matrix; number_of_states=12)
    Λ, V = eigen(T_matrix)
    vec = V[:,number_of_states] 
    return vec./sum(vec)
end