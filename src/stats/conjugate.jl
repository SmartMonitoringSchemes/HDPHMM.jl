# rand(::T, args...) where T <: Distribution = rand(T, args...)

function rand(::Type{T}, pri::NormalInverseChisq) where T <: Normal
    μ, σ2 = rand(pri)
    Normal(μ, sqrt(σ2))
end

function rand(::Type{T}, pri::NormalInverseChisq, X) where T <: Normal
    X = collect(skipmissing(X))
    if length(X) > 0
        pri = posterior_canon(pri, suffstats(Normal, X))
    end
    rand(T, pri)
end
