# TODO: Rename to TruncatedDPMM... ?
# To simplify code we assume same distribution everywhere in the mixture
struct DPMMObservationModel
    mixtures::Vector{MixtureModel}
    σ::Float64
end

# Same distribution everywhere to simplify,
# but theoretically we could use different for
# each component of each mixture.
struct DPMMObservationModelPrior{T}
    prior::Distribution
    σ_prior::Gamma
end

function DPMMObservationModel(L, LP, prior::DPMMObservationModelPrior{T}) where {T}
    σ = rand(prior.σ_prior)
    mixtures = map(1:L) do _
        components = map(_ -> rand(T, prior.prior), 1:LP)
        weights = rand(Dirichlet(LP, σ / LP))
        MixtureModel(components, weights)
    end
    DPMMObservationModel(mixtures, σ)
end

const DPGMMObservationModelPrior = DPMMObservationModelPrior{Normal}

# (L, LP)
size(m::DPMMObservationModel, dim = :) =
    (length(m.mixtures), ncomponents(m.mixtures[1]))[dim]

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

# Assume same prior for each components
function resample(d::MixtureModel{<:Any,<:Any,T,<:Any}, prior, σ, Y) where {T}
    @argcheck length(Y) == ncomponents(d)
    components = map(y -> rand(T, prior, y), Y)
    counts = length.(Y)
    weights = rand(Dirichlet((σ / ncomponents(d)) .+ counts))
    MixtureModel(components, weights)
end

# TODO: Test/Check correctness
function resample(m::DPMMObservationModel, prior, n, np, Y)
    @argcheck size(np, 1) == size(Y, 1) == size(m, 1) == size(n, 1) == size(n, 2)
    @argcheck size(np, 2) == size(Y, 2) == size(m, 2)

    mixtures = map(enumerate(m.mixtures)) do (k, mixture)
        # k = mixture index
        # Y[K,:] = observations associated to each components of the mixture
        resample(mixture, prior.prior, m.σ[1], Y[k, :])
    end

    σ = resample_σ(m.σ, prior.σ_prior, n, np, niter = 50)
    DPMMObservationModel(mixtures, σ)
end

function resample_σ(σ, σ_prior, counts, countsp; niter = 1)
    L = size(counts)[1]

    # Auxiliary variables
    rp = zeros(L)
    sp = zeros(L)

    # K'_k = number of currently instantiated mixture components for the state k mixture
    Kp = sum(countsp .> 0) # or sum over cols ?

    for _ = 1:niter
        for j = 1:L
            cs = sum(counts[j, :])
            # Hack ?
            rp[j] = cs == 0 ? 1.0 : rand(Beta(σ + 1, cs))
            sp[j] = rand(Bernoulli((cs / (cs + σ))))
        end

        # TODO
        if σ_prior.α + Kp - sum(sp) <= 0 || (1 / σ_prior.θ) - sum(log.(rp)) <= 0
            # println(σ_prior.α + Kp - sum(sp))
            # println((1/σ_prior.θ) - sum(log.(rp)))
        else
            σ = rand(Gamma(σ_prior.α + Kp - sum(sp), (1 / σ_prior.θ) - sum(log.(rp))))
        end
    end

    σ
end

# TODO: Test that counts in np matches Y
function suffstats(d::DPMMObservationModel, y::U, z, s) where {U}
    @argcheck length(y) == length(z) == length(s)
    # DANGER: This makes the assumptions that each obs. distn.
    # have the same number of components (LP).
    L, LP, T = length(d.mixtures), ncomponents(d.mixtures[1]), length(z)

    # n[j,k]  = number of customers in restaurant j eating dish k
    # n'[k,j] = number of observations associated to component j of state k mixture
    n = zeros(Int, L, L)
    np = zeros(Int, L, LP)

    # Observations assigned to each components
    Y = Matrix{U}(undef, L, LP)
    for i in eachindex(Y)
        Y[i] = U()
    end
    push!(Y[z[1], s[1]], y[1])

    # DANGER: @inbounds so make sure that z[t] is in 1:L
    @inbounds for t = 2:T
        n[z[t-1], z[t]] += 1
        np[z[t], s[t]] += 1
        push!(Y[z[t], s[t]], y[t])
    end

    DPMMObservationModelStats(n, np, Y)
end
