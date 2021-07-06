mutable struct MCConfig
    burnin::Float64
    chains::Integer
    iter::Integer
    init::Union{Nothing,Initializer}
    verb::Bool
end

"""
    MCConfig(; burnin = 0.1, chains = 1, iter = 100, init = nothing, verb = false)

Sampler configuration.
"""
function MCConfig(; kwargs...)
    d = Dict{Symbol,Any}(:burnin => 0.1, :chains => 1, :iter => 100, :init => nothing, :verb => false)
    merge!(d, kwargs)
    MCConfig(d[:burnin], d[:chains], d[:iter], d[:init], d[:verb])
end

# TODO: Different init state for each chains
function sample(sampler::BlockedSampler, prior, data; config = MCConfig())
    state = BlockedSamplerState(sampler, prior)

    if config.init !== nothing
        seq = initialize(config.init, data, verb = config.verb)
        _, _, state = resample(sampler, state, prior, data[1:length(seq)], seq, ones(Int, length(seq)))
    end

    sample(sampler, state, prior, data, config = config)
end

# TODO: Different init state for each chains
function sample(sampler::BlockedSampler, state, prior, data; config = MCConfig())
    chains = [Chain(config.iter, length(data), i) for i = 1:config.chains]

    Threads.@threads for c in chains
        c.zseqs[1, :], c.sseqs[1, :], c.states[1] = resample(sampler, state, prior, data)

        for i = 2:config.iter
            config.verb &&
            (i % div(config.iter, 10) == 0) && printinfo("Chain $(c.index) Iteration $i")
            c.zseqs[i, :], c.sseqs[i, :], c.states[i] =
                resample(sampler, c.states[i-1], prior, data)
        end
    end

    start = Int(floor(config.burnin * config.iter))
    [c[start+1:end] for c in chains]
end
