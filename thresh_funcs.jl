function generate_cutoffs(ref_collection; percentiles=[0.75, 0.95])
    # ref collection is a list of twelve lists of parameters, one per month
    # returns list of two lists, eac with the 75th and 95th cutoffs for the twelve months
    return [Statistics.quantile.(ref_collection, percentile) for percentile in percentiles]
    # return [Statistics.quantile.(ref_collection, 0.75),Statistics.quantile.(ref_collection, 0.95)]
    
end

function assign_state(cutoffs, date, param)
    # cutoffs: list of two lists, eac with the 75th and 95th cutoffs for the twelve months
    month = get_month(date)
    thresh75 = cutoffs[1][month]
    thresh95 = cutoffs[2][month]
    out = 0
    #check where current parameter falls within thresholds
    if param > thresh95
        out = 1
    elseif param > thresh75
        out = 2
    else
        out = 3
    end
    return out + 3 * (month-1) #structure of resulting partition is [jan1,jan2,jan3, feb1, feb2....]
end

function assign_state_night(cutoffs, date, param)
    # cutoffs: list of two lists, eac with the 75th and 95th cutoffs for the twelve months
    month = get_month(date)
    night = is_night(date)
    thresh75 = 0.0
    thresh95 = 0.0 
    if night
        thresh75 = cutoffs[1][month*2]
        thresh95 = cutoffs[2][month*2]
    else
        thresh75 = cutoffs[1][month*2-1]
        thresh95 = cutoffs[2][month*2-1]
    end
    out = 0
    #check where current parameter falls within thresholds
    if param > thresh95
        out = 1
    elseif param > thresh75
        out = 2
    else
        out = 3
    end
    return 6 * (month-1) + 2*(out-1) + night + 1
end

function assign_five_state_cold(cutoffs, date, param)
    month = get_month(date)
    thresh05 = cutoffs[1][month]
    thresh25 = cutoffs[2][month]
    thresh75 = cutoffs[3][month]
    thresh95 = cutoffs[4][month]
    out = 0
    #check where current parameter falls within thresholds
    if param > thresh95
        out = 1
    elseif param > thresh75
        out = 2
    elseif param > thresh25
        out = 3
    elseif param > thresh05
        out = 4
    else #most extreme col 0.05
        out = 5 
    end
    return out + 5 * (month-1)
end