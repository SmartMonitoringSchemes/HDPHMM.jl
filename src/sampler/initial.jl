struct InitialStateDistribution
    π0::Vector{Float64}
    α0::Float64
end

function InitialStateDistribution(L::Integer, α0::Real)
    π0 = rand(Dirichlet(L, α0))
    InitialStateDistribution(π0, α0)
end

function resample(d::InitialStateDistribution, z0::Integer)
    weights = zeros(size(d.π0)) .+ d.α0
    weights[z0] += 1
    π0 = rand(Dirichlet(weights))
    InitialStateDistribution(π0, d.α0)
end