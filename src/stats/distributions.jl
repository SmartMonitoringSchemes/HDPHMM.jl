"""
    UnnormalizedCategorical

**NOTE:** This assumes (and does not verify) that `p` is positive.
"""
struct UnnormalizedCategorical{T} <: Distribution{Univariate,Discrete}
    p::T
    s::Float64
end

function UnnormalizedCategorical(p::Array{Float64})
    UnnormalizedCategorical(p, sum(p))
end

function rand(d::UnnormalizedCategorical)
    draw = Base.rand() * d.s
    cp = 0.0
    i = 0
    while cp < draw
        cp += d.p[i += 1]
    end
    Tuple(CartesianIndices(size(d.p))[max(1,i)])
end

rand(d::UnnormalizedCategorical, n::Int) = map(_ -> rand(d), 1:n)
