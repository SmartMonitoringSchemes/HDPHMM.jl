mutable struct MCConfig
    init::Union{Nothing,Initializer}
    chains::Integer
    iter::Integer
    verb::Bool   
    # TODO: refit_states::Bool
end

function MCConfig(; kwargs...)
    d = Dict(
        :init => nothing,
        :chains => 1,
        :iter => 100,
        :verb => false
    )
    merge!(d, kwargs)
    MCConfig(d[:init], d[:chains], d[:iter], d[:verb])
end

function sample(prior, data, sampler; config = MCConfig())
    state = initialize(sampler, prior)

    if config.init !== nothing
        seq = initialize(config.init, data, verb = config.verb)
        state = resample(state, data[1:length(seq)], seq, ones(Int, length(seq)))
    end

    sample(state, data, config = config)
end

function sample(state, data; config = MCConfig())
    config.verb && (p = Progress(config.iter, "[HDPHMM #$(Threads.threadid())] Sampling: "))
    seqs, comps, states = [], [], []

    seq, comp, state = resample(state, data)
    push!(seqs, seq); push!(comps, comp); push!(states, state)
    config.verb && next!(p)
    
    for i in 2:config.iter
        seq, comp, state = resample(state, data)
        push!(seqs, seq); push!(comps, comp); push!(states, state)
        config.verb && next!(p)
    end
    
    config.verb && close(p)
    collect(hcat(seqs...)'), collect(hcat(comps...)'), states
end