module HDPHMM

using ArgCheck
using Clustering
using Distributions
using HMMBase
using Missings
using Statistics
using StatsBase

using Base: OneTo
using ConjugatePriors: NormalInverseChisq, posterior_canon
using Distributions: invsqrt2π, log2π
using InteractiveUtils: @which
using Printf: @printf

import Base: cat, getindex, lastindex, length, size, rand
import Distributions: logpdf, pdf, suffstats, zval, sample
import HMMBase: HMM

export InitialStateDistribution,
    TransitionDistribution,
    TransitionDistributionPrior,
    DPMMObservationModel,
    DPMMObservationModelPrior,
    ObservationMixture,
    BlockedSampler,
    BlockedSamplerPrior,
    BlockedSamplerState,
    MCConfig,
    resample,
    BinsInit,
    FixedInit,
    KMeansInit,
    select_hamming,
    resample_interval,
    robuststats

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

printinfo(msg) = println("[HDPHMM #$(Threads.threadid())] $(msg)")

end
