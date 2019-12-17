using Leaf
using Test
using Distributions
import ConjugatePriors: NormalInverseChisq

# TODO: Add tests with missing values:
# - Float64 observations only
# - Mixed Float64/Missing observations
# - Missing observations only

# TODO: Basic inference test with simple HMM,
# test that we find the same state sequence,
# and similar distributions (?)

@testset "Initial Distribution" begin
    L = 10
    d = InitialStateDistribution(L, 1e-4)
    for z0 in 1:L
        dp = resample(d, z0)
        @test argmax(dp.π0) == z0
    end
end

@testset "Transition Distribution" begin
    L = 10

    d = TransitionDistribution(
        L,
        Gamma(1, 1/0.1),
        Gamma(1, 1/0.1),
        Beta(50, 1)
    )

    n = zeros(L, L)
    @test_nowarn resample(d, n)

    n = rand(0:100, L, L)
    @test_nowarn resample(d, n)
end

@testset "Observation Distribution" begin
    L, LP = 10, 5

    σ_prior = Gamma(1, 0.5)
    obs_prior = NormalInverseChisq(10, 2, 1, 1)

    d = DPMMObservationModel(L, LP, σ_prior, obs_prior, Normal)

    n  = rand(1:100, L, L)
    np = rand(1:100, L, LP)
    Y  = [[rand(k) for k in np[l,:]] for l in 1:L]

    @test_nowarn resample(d, n, np, Y)
end

@testset "Sampler" begin
    L, LP = 10, 5

    id = InitialStateDistribution(L, 1)

    td = TransitionDistribution(
        L,
        Gamma(1, 1/0.01),
        Gamma(1, 1/0.01),
        Beta(500, 1)
    )

    om = DPMMObservationModel(
        L,
        LP,
        Gamma(1, 0.5),
        NormalInverseChisq(1, 1, 1, 1),
        Normal
    )

    state = BlockedSamplerState(id, td, om)
    sampler = BlockedSampler(L, LP)

    # TODO: Multivariate observations
    @test_nowarn resample(sampler, state, rand(1000))
end