module Leaf

using ArgCheck
using Clustering
using Distributions
using HMMBase

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
    KMeansInit

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

printinfo(msg) = println("[Leaf #$(Threads.threadid())] $(msg)")

end
