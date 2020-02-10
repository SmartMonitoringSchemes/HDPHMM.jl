"""
An initializer must implement the following function:

    initialize(it, observations) -> sequence

sequence may be shorter than observations, in which case
only the matching part will be used for the first resampling.
"""
abstract type Initializer end

struct KMeansInit <: Initializer
    K::Integer
end

struct BinsInit <: Initializer
    K::Integer
end

struct FixedInit <: Initializer
    seq::Vector{Int}
end

initialize(it::FixedInit, ::Any; kwargs...) = it.seq

function initialize(it::KMeansInit, X; verb = false)
    X = copy(X)
    ffill!(X)
    bfill!(X)
    kmeans(permutedims(X), it.K, display = verb ? :final : :none).assignments
end

function initialize(it::BinsInit, X; kwargs...)
    X = copy(X)
    ffill!(X)
    bfill!(X)

    # Normalize series in [0,1]
    X = X .- minimum(X)
    X = X ./ maximum(X)

    width = 1 / it.K
    edges = 0:width:(1-width)
    seq = zeros(Int, length(X))

    for (i, left_val) in enumerate(edges)
        idxs = (X .>= left_val) .& (X .<= (left_val + width))
        seq[idxs] .= i
    end

    seq
end

# TODO: Move these outside...

function ffill!(X)
    for i = 2:length(X)
        ismissing(X[i]) && (X[i] = X[i-1])
    end
end

function bfill!(X)
    for i = length(X)-1:-1:1
        ismissing(X[i]) && (X[i] = X[i+1])
    end
end
