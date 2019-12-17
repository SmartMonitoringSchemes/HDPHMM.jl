mutable struct MCConfig
    burnin::Float64
    chains::Integer
    iter::Integer
    init::Union{Nothing,Initializer}
    verb::Bool   
    # TODO: refit_states::Bool
end

function MCConfig(; kwargs...)
    d = Dict(
        :burnin => 0.1,
        :chains => 1,
        :iter => 100,
        :init => nothing,
        :verb => false
    )
    merge!(d, kwargs)
    MCConfig(d[:burnin], d[:chains], d[:iter], d[:init], d[:verb])
end

# function sample(prior, data, sampler; config = MCConfig())
#     state = initialize(sampler, prior)

#     if config.init !== nothing
#         seq = initialize(config.init, data, verb = config.verb)
#         state = resample(state, data[1:length(seq)], seq, ones(Int, length(seq)))
#     end

#     sample(state, data, config = config)
# end

function sample(sampler::BlockedSampler, state, data; config = MCConfig())
    nchains, niter, nobs = config.chains, config.iter, length(data)

    seqs   = zeros(Int, nchains, niter, nobs)
    comps  = zeros(Int, nchains, niter, nobs)
    states = Matrix{BlockedSamplerState}(undef, nchains, niter)

    Threads.@threads for c in 1:nchains
        # Initial State
        seqs[c,1,:], comps[c,1,:], states[c,1] = resample(sampler, state, data)

        for i in 2:niter
            config.verb && (i % div(niter, 10) == 0) && printinfo("Chain $c Iteration $i")
            seqs[c,i,:], comps[c,i,:], states[c,i] = resample(sampler, states[c,i-1], data)
        end
    end

    start = Int(floor(config.burnin * config.iter))
    seqs[:,start+1:end,:], comps[:,start+1:end,:], states[:,start+1:end]
end