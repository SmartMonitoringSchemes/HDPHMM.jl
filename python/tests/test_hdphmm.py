import random

from hdphmm.py import (
    Beta,
    BlockedSamplerPrior,
    DPGMMObservationModelPrior,
    Gamma,
    Normal,
    NormalInverseChisq,
    TransitionDistributionPrior,
    robuststats,
    segment,
)


def test_basic():
    data = [random.random() for _ in range(1000)]
    obs_med, obs_var = robuststats(Normal, data)
    tp = TransitionDistributionPrior(Gamma(2, 10), Gamma(100, 10), Beta(500, 1))
    op = DPGMMObservationModelPrior(
        NormalInverseChisq(obs_med, obs_var, 1, 10), Gamma(1, 0.5)
    )
    prior = BlockedSamplerPrior(1.0, tp, op)
    segment(data, prior, L=10, LP=5, iter=10, verbose=True)
