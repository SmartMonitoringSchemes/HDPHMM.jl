module HDPHMM

using ArgCheck
using Clustering
using Distributions
using HMMBase
using Missings

# TODO: Remove unused, if any
import Base: OneTo, cat, getindex, lastindex, length, size, rand
import ConjugatePriors: NormalInverseChisq, posterior_canon, suffstats
import Distributions: invsqrt2π, log2π, logpdf, pdf, zval, sample
import InteractiveUtils: @which
import Printf: @printf

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
    resample_interval

include("stats/conjugate.jl")
include("stats/distributions.jl")
include("stats/missings.jl")
include("stats/vector.jl")

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
