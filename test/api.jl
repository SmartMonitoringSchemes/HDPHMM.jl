using Leaf
using Test
using Distributions
import ConjugatePriors: NormalInverseChisq

@testset "Sampler API" begin
    L, LP = 10, 5

    tp = TransitionDistributionPrior(
        Gamma(1, 1/0.01),
        Gamma(1, 1/0.01),
        Beta(500, 1)
    )

    op = DPMMObservationModelPrior{Normal}(
        NormalInverseChisq(1, 1, 1, 1),
        Gamma(1, 0.5),
    )

    sampler = BlockedSampler(L, LP)
    prior = BlockedSamplerPrior(1.0, tp, op)
    state = BlockedSamplerState(sampler, prior)

    data = rand(2520)
    config = MCConfig(
        chains = 2,
        verb = true
    )

    @test_nowarn sample(sampler, state, prior, data, config = config)
end
