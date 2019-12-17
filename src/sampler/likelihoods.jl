# TODO: Rename, check stability and put inside
@views function __inner_loop2(log_pdfs_w, k)
    cs = maximum(log_pdfs_w[k,:,:], dims=1)
    cs .+ log.(sum(exp.(log_pdfs_w[k,:,:] .- cs), dims=1))
end

# TODO: Check type stability of function
function likelihoods(sampler, state, y)
    L, LP, T = sampler.L, sampler.LP, length(y)

    log_ψ  = map(eachindex(state.obs_model.mixtures)) do k
        log.(probs(state.obs_model.mixtures[k][1]))
    end

    # Per-mixture, per-component, *weighted* log-likelihoods
    log_pdfs_w = zeros(L, LP, T)
    log_likelihoods = zeros(T, L)

    @inbounds for (k, mixture) in enumerate(state.obs_model.mixtures)
        @inbounds for lp in OneTo(LP)
            log_pdfs_w[k,lp,:] .= log_ψ[k][lp] .+ logpdf(mixture[1].components[lp], y)
        end
        # TODO: Optimize this line
        log_likelihoods[:,k] = __inner_loop2(log_pdfs_w, k)
    end

    log_pdfs_w, log_likelihoods
end