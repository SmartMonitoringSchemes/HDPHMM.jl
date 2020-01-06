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
    stats       = suffstats(state.obs_model, y, z, s)
    init_distn  = resample(state.init_distn, z[1])
    trans_distn = resample(state.trans_distn, stats.n)
    obs_model   = resample(state.obs_model, stats.n, stats.np, stats.Y)
    z, s, BlockedSamplerState(init_distn, trans_distn, obs_model)
end

# TODO: Test for type stability

function suffstats(d::TransitionDistribution, z)
   L, T = length(d.β), length(z)

    # n[j,k]  = number of customers in restaurant j eating dish k
    n = zeros(Int, L, L)

    # DANGER: @inbounds so make sure that z[t] is in 1:L
    @inbounds for t in 2:T
	n[z[t-1],z[t]] += 1
    end

    n
end

# TODO: Test that counts in np matches Y
function suffstats(d::DPMMObservationModel, y::U, z, s) where U
    @argcheck length(y) == length(z) == length(s)
    # DANGER: This makes the assumptions that each obs. distn.
    # have the same number of components (LP).
    L, LP, T = length(d.mixtures), ncomponents(d.mixtures[1]), length(z)

    # n[j,k]  = number of customers in restaurant j eating dish k
    # n'[k,j] = number of observations associated to component j of state k mixture
    n  = zeros(Int, L, L)
    np = zeros(Int, L, LP)

    # Observations assigned to each components
    Y = Matrix{U}(undef, L, LP)
    for i in eachindex(Y); Y[i] = U(); end
    push!(Y[z[1],s[1]], y[1])

    # DANGER: @inbounds so make sure that z[t] is in 1:L
    @inbounds for t in 2:T
        n[z[t-1],z[t]] += 1
	np[z[t],s[t]] += 1
        push!(Y[z[t],s[t]], y[t])
    end

    DPMMObservationModelStats(n, np, Y)
end

