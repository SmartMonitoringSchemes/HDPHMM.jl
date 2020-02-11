using HDPHMM
using Test
using Distributions
import ConjugatePriors: NormalInverseChisq
import HDPHMM: DPMMObservationModelStats

# TODO: Add tests with missing values:
# - Float64 observations only
# - Mixed Float64/Missing observations
# - Missing observations only

# TODO: Basic inference test with simple HMM,
# test that we find the same state sequence,
# and similar distributions (?)


function fake(::Type{DPMMObservationModelStats}; L = 10, LP = 5)
    n  = rand(1:100, L, L)
    np = rand(1:100, L, LP)
    Y = Matrix{Vector{Float64}}(undef, L, LP)
    for i in eachindex(Y); Y[i] = rand(10); end
    DPMMObservationModelStats(n, np, Y)
end


@testset "Initial Distribution" begin
    L = 10
    d = InitialStateDistribution(L, 1)
    @test_nowarn resample(d, 1)
end

@testset "Transition Distribution" begin
    L = 10

    p = TransitionDistributionPrior(
        Gamma(1, 1/0.001),
        Gamma(1, 1/0.001),
        Beta(50, 1)
    )

    d = TransitionDistribution(L, p)

    n = zeros(L, L)
    @test_nowarn resample(d, p, n)

    n = rand(0:100, L, L)
    @test_nowarn resample(d, p, n)
end


@testset "DPMM - MixtureModel" begin
    d = MixtureModel([Normal(0,1) for _ in 1:10])
    p = NormalInverseChisq(10, 2, 1, 1)
    @test_nowarn resample(d, p, 1.0, [rand(100) for _ in 1:10])
end

@testset "DPMM - Stats" begin
    L, LP = 10, 5

    prior = DPMMObservationModelPrior{Normal}(
        NormalInverseChisq(10, 2, 1, 1),
        Gamma(1, 0.5)
    )

    m = DPMMObservationModel(L, LP, prior)
    stats = fake(DPMMObservationModelStats)

    @test_nowarn resample(m, prior, stats.n, stats.np, stats.Y)
end


@testset "Sampler" begin
    L, LP = 10, 5

    tp = TransitionDistributionPrior(
        Gamma(1, 1/0.001),
        Gamma(1, 1/0.001),
        Beta(500, 1)
    )

    op = DPMMObservationModelPrior{Normal}(
        NormalInverseChisq(1, 1, 1, 1),
        Gamma(1, 0.5),
    )

    sampler = BlockedSampler(L, LP)
    prior = BlockedSamplerPrior(1.0, tp, op)
    state = BlockedSamplerState(sampler, prior)

    # TODO: Multivariate observations
    # TODO: Missing observations
    @test_nowarn resample(sampler, state, prior, rand(1000))
end
