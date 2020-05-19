# Warn if duplicates (more than 1 sample in an interval) ?
# Move to HMMBase ?
function resample_interval(index, data, interval; align = false)
    @argcheck length(index) == length(data)
    @argcheck interval > 0

    align && throw(ErrorException("align = true is not implemented"))
    length(index) < 2 && (return index, data)

    perm = sortperm(index)
    index, data = index[perm], data[perm]

    index_ = [index[1]]
    data_ = allowmissing([data[1]])

    i = 2
    while i <= length(index)
        if index[i] <= index_[end] + (interval * 1.5)
            push!(index_, index[i])
            push!(data_, data[i])
            i += 1
        else
            push!(index_, index_[end] + interval)
            push!(data_, missing)
        end
    end

    index_, data_
end
