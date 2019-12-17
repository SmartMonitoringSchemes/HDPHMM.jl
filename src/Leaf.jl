module Leaf

using ArgCheck
using Clustering
using Distributions
using HMMBase
using MCMCChains

import Base: OneTo, length, rand
import ConjugatePriors: NormalInverseChisq, posterior_canon
import Impute

export
    InitialStateDistribution,
    TransitionDistribution,
    DPMMObservationModel,
    ObservationMixture,
    BlockedSamplerState,
    resample

include("conjugate.jl")
# include("initialize.jl")

include("sampler/initial.jl")
include("sampler/transmat.jl")
include("sampler/dpmm.jl")
include("sampler/likelihoods.jl")
include("sampler/sampler.jl")

# include("api/sample.jl")

end
