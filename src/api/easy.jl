# High-level API for model inference and data segmentation.

struct DataSegmentationModel{T}
    data::Vector{Union{T, Missing}}
    index::Vector{Int}
    state::Vector{Int}
    model::HMM
end

function segment(index, data, prior; L = 10, LP = 5, init = KMeansInit(L), kwargs...)
    config = MCConfig(init = init; kwargs...)
    chains = HDPHMM.sample(BlockedSampler(L, LP), prior, data, config = config)
    _, z, s, state = select_hamming(chains[1])
    DataSegmentationModel(data, index, z, HMM(state, z))
end

