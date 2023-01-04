function run_sim(runs, thresh_func)
    # essentially just iterate forward through the dataset (not rlly a simulation)
    loc = start_coord
    
    state_list = [] #list of unique states
    holding_times = [] #list of holding times of each unique state (unit =  number of steps)

    state = thresh_func(start_coord)
    cnt = 0

    for i in 1:runs
        loc = make_step(loc)
        # before, we had a push!x, etc. but in this case the history of ground truth is already known and written down

        if thresh_func(loc) == state
            cnt += 1
        else
            push!(state_list, state)
            push!(holding_times, cnt)
            state = thresh_func(x,y,z)
            cnt = 0
        end
    end
    return state_list, holding_times
end

