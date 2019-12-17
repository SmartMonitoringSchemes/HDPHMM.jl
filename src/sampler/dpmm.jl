const ObservationMixture = Tuple{MixtureModel, Vector{Distribution}}

# TODO: Constructor that checks that all mixtures
# have the same number of components.
struct DPMMObservationModel
    mixtures::Vector{ObservationMixture}
    σ::Tuple{Float64,Gamma}
end

function DPMMObservationModel(L::Integer, LP::Integer, σ_prior::Gamma, obs_prior::Distribution, ::Type{T}) where T
    σ = rand(σ_prior)
    mixtures = Vector{ObservationMixture}(undef, L)
    for k in 1:L
        priors = [obs_prior for _ in 1:LP]
        distns = [rand(T, obs_prior) for _ in 1:LP]
        weights = rand(Dirichlet(LP, σ/LP))
        mixtures[k] = (MixtureModel(distns, weights), priors)
    end
    DPMMObservationModel(mixtures, (σ, σ_prior))
end

# TODO: Test/Check correctness
# TODO: @argcheck for sizes (n, np, Y, ...)
function resample(m::DPMMObservationModel, n, np, Y)
    L, LP = size(np)
    mixtures = Vector{ObservationMixture}(undef, L)

    for k = 1:L
        distns = m.mixtures[k][1].components
        priors = m.mixtures[k][2]

        # Should we sample from the prior if x is empty or not change it ?
        new_distns = [rand(distns[j], priors[j], Y[k][j]) for j in 1:LP]
        new_weights = rand(Dirichlet(m.σ[1]/LP .+ np[k,:]))

        mixtures[k] = (MixtureModel(new_distns, new_weights), priors)
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