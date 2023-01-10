
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


function get_normalization(file, var)
    if var == "t1000"
        var = "t"
    end
    scale_factor = ncgetatt(file, var, "scale_factor")
    add_offset = ncgetatt(file, var, "add_offset")
    return scale_factor, add_offset
end

function normalize(x, scale_factor, add_offset)
    return (x * scale_factor) .+ add_offset
end

function spherical_mean(array, latvec)
    metric_kind_of = reshape(cos.(latvec / 180 * π), (1, length(latvec)))
    return mean( metric_kind_of .* (array) ) / mean(metric_kind_of)
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