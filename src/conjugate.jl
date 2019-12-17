rand(::T, args...) where T = rand(T, args...)

# TODO: type stability ?
# ::Type{T} where T <: Normal instead ?

function rand(T::Type{<:Normal}, pri::NormalInverseChisq)
    μ, σ2 = rand(pri)
    Normal(μ, sqrt(σ2))
end

function rand(T::Type{<:Normal}, pri::NormalInverseChisq, X)
    if length(X) > 0
        pri = posterior_canon(pri, suffstats(Normal, X))
    end
    rand(T, pri)
end
