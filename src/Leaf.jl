module Leaf

using ArgCheck
using Clustering
using Distributions
using HMMBase

import Base: OneTo, length, rand
import ConjugatePriors: NormalInverseChisq, posterior_canon, suffstats
import Distributions: invsqrt2π, log2π, logpdf, pdf, zval
import InteractiveUtils: @which
import Printf: @printf

export
    InitialStateDistribution,
    TransitionDistribution,
    DPMMObservationModel,
    ObservationMixture,
    BlockedSamplerState,
    BlockedSampler,
    resample

include("progress.jl")

include("stats/conjugate.jl")
include("stats/distributions.jl")
include("stats/missings.jl")
include("stats/vector.jl")

include("sampler/initial.jl")
include("sampler/transmat.jl")
include("sampler/dpmm.jl")
include("sampler/stateseq.jl")
include("sampler/likelihoods.jl")
include("sampler/sampler.jl")
include("sampler/init.jl")

include("api/sample.jl")

printinfo(msg) = println("[Leaf #$(Threads.threadid())] $(msg)")

end
