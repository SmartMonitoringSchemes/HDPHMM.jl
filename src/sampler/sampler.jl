struct BlockedSampler
    L::Int
    LP::Int
end

struct BlockedSamplerState
    initstate::InitialStateDistribution
    transdist::TransitionDistribution
    obsmodel::DPMMObservationModel
end

struct BlockedSamplerPrior
    α0::Float64
    transprior::TransitionDistributionPrior
    obsprior::DPMMObservationModelPrior
end

"""
    BlockedSamplerState(sampler, prior)

Initialize (randomly) the blocked sampler state from the prior.
"""
function BlockedSamplerState(sampler::BlockedSampler, prior)
    BlockedSamplerState(
        InitialStateDistribution(sampler.L, prior.α0),
        TransitionDistribution(sampler.L, prior.transprior),
        DPMMObservationModel(sampler.L, sampler.LP, prior.obsprior),
    )
end

"""
    resample(sampler, state, y)

Sample next state using `sampler` and observations `y`.
"""
function resample(sampler::BlockedSampler, state, prior, y)
    logpw, logp = likelihoods(sampler, state, y)
    z, s = resample_z(sampler, state, logpw, logp)
    resample(sampler, state, prior, y, z, s)
end

"""
    resample(sampler, state, y, z, s)

Sample next state using `sampler`, observations `y`,
state sequence `z`, and components sequence `s`.
"""
function resample(sampler::BlockedSampler, state, prior, y, z, s)
    stats = suffstats(state.obsmodel, y, z, s)
    statep = BlockedSamplerState(
        resample(state.initstate, z[1]),
        resample(state.transdist, prior.transprior, stats.n),
        resample(state.obsmodel, prior.obsprior, stats.n, stats.np, stats.Y),
    )
    z, s, statep
end

# TODO: Rename, check stability and put inside
@views function __inner_loop2(log_pdfs_w, k)
    cs = maximum(log_pdfs_w[k, :, :], dims = 1)
    cs .+ log.(sum(exp.(log_pdfs_w[k, :, :] .- cs), dims = 1))
end

# TODO: Check type stability of function
function likelihoods(sampler::BlockedSampler, state, y)
    L, LP, T = sampler.L, sampler.LP, length(y)

    log_ψ = map(d -> log.(d.prior.p), state.obsmodel.mixtures)

    # Per-mixture, per-component, *weighted* log-likelihoods
    log_pdfs_w = zeros(L, LP, T)
    log_likelihoods = zeros(T, L)

    @inbounds for (k, mixture) in enumerate(state.obsmodel.mixtures)
        @inbounds for lp in OneTo(LP)
            log_pdfs_w[k, lp, :] .= log_ψ[k][lp] .+ logpdf(mixture.components[lp], y)
        end
        # TODO: Optimize this line
        log_likelihoods[:, k] = __inner_loop2(log_pdfs_w, k)
    end

    log_pdfs_w, log_likelihoods
end
