# https://github.com/JuliaStats/Distributions.jl/blob/master/src/univariate/continuous/normal.jl#L110
function pdf(d::Normal, X::AbstractVector)
    T = size(X, 1)
    L = Vector{Float64}(undef, T)

    if iszero(d.σ)
        @inbounds for t in Base.OneTo(T)
            L[t] = d.μ == X[t] ? Inf : 0.0
        end
    else
        n = invsqrt2π / d.σ
        @inbounds for t in Base.OneTo(T)
            L[t] = exp(-zval(d, X[t])^2 / 2) * n
        end
    end

    L
end

# https://github.com/JuliaStats/Distributions.jl/blob/master/src/univariate/continuous/normal.jl#L102
function logpdf(d::Normal, X::AbstractVector)
    T = size(X, 1)
    L = Vector{Float64}(undef, T)

    if iszero(d.σ)
        @inbounds for t in Base.OneTo(T)
            L[t] = d.μ == X[t] ? Inf : -Inf
        end
    else
        logσ = log(d.σ)
        @inbounds for t in Base.OneTo(T)
            L[t] = -(zval(d, X[t])^2 + log2π) / 2 - logσ
        end
    end
    
    L
end