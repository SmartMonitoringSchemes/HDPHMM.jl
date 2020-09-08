module HDPHMM

using ArgCheck
using Clustering
using HMMBase
using Missings
using Statistics
using StatsBase

# Re-export for convenience
# https://github.com/simonster/Reexport.jl
# https://github.com/JuliaLang/julia/issues/1986
using Reexport
@reexport using ConjugatePriors
@reexport using Distributions

using Base: OneTo
using Distributions: invsqrt2π, log2π
using InteractiveUtils: @which
using Printf: @printf

import Base: cat, getindex, lastindex, length, size, rand
import Distributions: MixtureModel, Normal, logpdf, pdf, suffstats, zval, sample
import JSON: parsefile
import HMMBase: HMM

export InitialStateDistribution,
    TransitionDistribution,
    TransitionDistributionPrior,
    DPMMObservationModel,
    DPMMObservationModelPrior,
    DPGMMObservationModelPrior,
    ObservationMixture,
    BlockedSampler,
    BlockedSamplerPrior,
    BlockedSamplerState,
    DataSegmentationModel,
    MCConfig,
    resample,
    BinsInit,
    FixedInit,
    KMeansInit,
    select_hamming,
    resample_interval,
    robuststats,
    parsefile,
    segment

include("stats/conjugate.jl")
include("stats/distributions.jl")
include("stats/missings.jl")
include("stats/vector.jl")
include("stats/robust.jl")

include("sampler/dpmm.jl")
include("sampler/initstate.jl")
include("sampler/transdist.jl")
include("sampler/stateseq.jl")
include("sampler/sampler.jl")

include("api/chain.jl")
include("api/init.jl")
include("api/sample.jl")
include("api/cleaning.jl")
include("api/hmm.jl")
include("api/easy.jl")

include("io.jl")

printinfo(msg) = println("[HDPHMM #$(Threads.threadid())] $(msg)")

end
