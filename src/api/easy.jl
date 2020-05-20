# High-level API for model inference and data segmentation.

struct DataSegmentationModel{T}
    data::Vector{T}
    index::Vector{Int}
    state::Vector{Int}
    model::HMM
end

function segment(index, data, prior; L = 10, LP = 5, init = KMeansInit(L), kwargs...)
    config = MCConfig(init = init; kwargs...)
    chains = HDPHMM.sample(BlockedSampler(L, LP), prior, data, config = config)
    _, z, s, state = select_hamming(chains[1])
    hmm, znew = HMM(state, z, return_z = true)
    DataSegmentationModel(data, index, znew, hmm)
end

segment(data, prior; kwargs...) = segment(collect(1:length(data)), data, prior; kwargs...)
