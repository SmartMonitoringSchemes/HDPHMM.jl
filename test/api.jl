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

    data = rand(2520)
    config = MCConfig(
        chains = 2,
        verb = true
    )

    @test_nowarn sample(sampler, prior, data, config = config)
end

@testset "Cleaning API" begin
    index = [730, 247]
    data = [2., 1.]

    index_, data_ = resample_interval(index, data, 240)

    @test length(index_) == 3
    @test index_ == [247, 487, 730]

    @test length(data_) == 3
    @test data_[[1,3]] == [1., 2.]
    @test data_[2] === missing

    index = [1, 3, 5]
    data = [1., 2., 3.]
    index_, data_ = resample_interval(index, data, 2)
    @test index_ == index
    @test data_ == data

    index_, data_ = resample_interval([], [], 100)
    @test index_ == []
    @test data_ == []
end
