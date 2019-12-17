struct BlockedSampler
    L::Int
    LP::Int
end

struct BlockedSamplerState
    init_distn::InitialStateDistribution
    trans_distn::TransitionDistribution
    obs_model::DPMMObservationModel
end

function resample(sampler, state, y)
    logpw, logp = likelihoods(sampler, state, y)
    z, s = resample_z(sampler, state, logpw, logp)
    resample(sampler, state, y, z, s)
end

function resample(sampler, state, y, z, s)
    n, np, Y    = suffstats(sampler, state, y, z, s)
    init_distn  = resample(state.init_distn, z[1])
    trans_distn = resample(state.trans_distn, n)
    obs_model   = resample(state.obs_model, n, np, Y)
    z, s, BlockedSamplerState(init_distn, trans_distn, obs_model)
end

# IDEA: Implement suffstats like
# suffstats(::Type{TransitionDistribution}, z, s)
# suffstats(::Type{DPMMObservationModel}, z, s, y)
function suffstats(sampler, state, y, z, s)
    @argcheck length(y) == length(z) == length(s)
    L, LP = sampler.L, sampler.LP

    # n[j,k]  = number of customers in restaurant j eating dish k
    # n'[k,j] = number of observations associated to component j of state k mixture
    n  = zeros(Int, L, L)
    np = zeros(Int, L, LP)

    # Observations assigned to each components
    # TODO: Generic type ?
    Y = [[Float64[] for _ in OneTo(LP)] for _ in OneTo(L)]
    ismissing(y[1]) || push!(Y[z[1]][s[1]], y[1])

    @inbounds for t in 2:T
        n[z[t-1],z[t]] += 1
        np[z[t],s[t]] += 1
        ismissing(y[t]) || push!(Y[z[t]][s[t]], y[t])
    end

    n, np, Y
end