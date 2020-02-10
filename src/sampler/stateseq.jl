# TODO: in-place version
# resample_z(..., ..., ...; buffer = initbuffer(sampler))

# TODO: Use Gumbel-max trick ?
# It seems slower...

# TODO: @argcheck sizes

function resample_z(sampler, state, logpw, logp)
    L, LP, T = sampler.L, sampler.LP, size(logp, 1)

    # 0. Compute log transitions
    log_π0 = log.(state.initstate.π0)
    log_π = log.(state.transdist.π)

    # 1. Compute backward probabilities
    log_betas = log.(backward(state.initstate.π0, state.transdist.π, logp, logl = true)[1])

    # 2. Sample state sequence
    z = zeros(Int, T)
    s = zeros(Int, T)
    f = zeros(L, LP)

    for k in OneTo(L), j in OneTo(LP)
        f[k, j] = exp(log_π0[k] + logpw[k, j, 1] + log_betas[1, k])
    end
    z[1], s[1] = rand(UnnormalizedCategorical(f))

    @inbounds for t = 2:T
        for j in OneTo(LP), k in OneTo(L)
            f[k, j] = exp(log_π[z[t-1], k] + logpw[k, j, t] + log_betas[t, k])
        end
        z[t], s[t] = rand(UnnormalizedCategorical(f))
    end

    z, s
end
