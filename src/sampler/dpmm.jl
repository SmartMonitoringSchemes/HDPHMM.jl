# TODO: Rename to TruncatedDPMM... ?
struct DPMMObservationModel
    mixtures::Vector{BayesianMixtureModel}
    σ::Tuple{Float64,Gamma}

    function DPMMObservationModel(mixtures, σ)
        # All mixtures must have the same number of components
        @argcheck all(ncomponents.(mixtures) .== ncomponents(mixtures[1]))
	new(mixtures, σ)
    end
end

# TODO: Consistent arguments ordering
function DPMMObservationModel(L, LP, σ_prior, obs_prior, ::Type{T}) where T
    σ = rand(σ_prior)
    mixtures = map(_ -> BayesianMixtureModel(T, obs_prior, σ, LP), 1:L)
    DPMMObservationModel(mixtures, (σ, σ_prior))
end

size(m::DPMMObservationModel, dim=:) = (length(m.mixtures), ncomponents(m.mixtures[1]))[dim]

# Sufficient Statistics

"""
	DPMMObservationModelStats

- n[j,k]:  number of customers in restaurant j eating dish k
- n'[k,j]: number of observations associated to component j of state k mixture
- Y[k,j]:  observations associated to components j of state k mixture
"""
struct DPMMObservationModelStats{U}
    n::Matrix{Int}
    np::Matrix{Int}
    Y::Matrix{U}
end

# Resampling

# TODO: Test/Check correctness
function resample(m::DPMMObservationModel, n, np, Y)
    @argcheck size(np, 1) == size(Y, 1) == size(m, 1) == size(n, 1) == size(n, 2)
    @argcheck size(np, 2) == size(Y, 2) == size(m, 2)

    mixtures = map(enumerate(m.mixtures)) do (k, mixture)
	# k = mixture index
	# Y[K,:] = observations associated to each components of the mixture
        resample(mixture, m.σ[1], Y[k,:])
    end

    σ = resample_σ(m.σ..., n, np, niter = 50)
    DPMMObservationModel(mixtures, σ)
end

function resample_σ(σ, σ_prior, counts, countsp; niter = 1)
    L = size(counts)[1]
    
    # Auxiliary variables
    rp = zeros(L)
    sp = zeros(L)

    # K'_k = number of currently instantiated mixture components for the state k mixture
    Kp = sum(countsp .> 0) # or sum over cols ?

    for _ in 1:niter
        for j in 1:L
            cs = sum(counts[j,:])
            # Hack ?
            rp[j] = cs == 0 ? 1.0 : rand(Beta(σ + 1, cs))
            sp[j] = rand(Bernoulli((cs / (cs + σ))))
        end

        # TODO
        if σ_prior.α + Kp - sum(sp) <= 0 || (1/σ_prior.θ) - sum(log.(rp)) <= 0
            # println(σ_prior.α + Kp - sum(sp))
            # println((1/σ_prior.θ) - sum(log.(rp)))
        else
            σ = rand(Gamma(σ_prior.α + Kp - sum(sp), (1/σ_prior.θ) - sum(log.(rp))))
        end
    end

    σ, σ_prior
end
