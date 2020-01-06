# TODO: Tests

struct BayesianMixtureModel
    components::Vector{Distribution}
    priors::Vector{Distribution}
    weights::Vector{Float64}

    function BayesianMixtureModel(components, priors, weights)
        @argcheck length(components) == length(priors) == length(weights)
	new(components, priors, weights)
    end
end

"""
	BayesianMixtureModel(::Type{T}, prior, σ, LP)

Constructs a BMM with components of type T
and with the same prior.

# Example
```julia
BayesianMixtureModel(Normal, NormalInverseChisq(10, 2, 1, 1), 0.1, 10)
```
"""
function BayesianMixtureModel(::Type{T}, prior, σ, LP) where T
    components = map(_ -> rand(T, prior), 1:LP)
    priors = map(_ -> prior, 1:LP)
    weights = rand(Dirichlet(LP, σ/LP))
    BayesianMixtureModel(components, priors, weights)
end

MixtureModel(d::BayesianMixtureModel) = MixtureModel(d.components, d.weights)

ncomponents(d::BayesianMixtureModel) = length(d.components)

function resample(d::BayesianMixtureModel, σ, Y)
    @argcheck length(Y) == ncomponents(d)

    # TODO: Should we sample from the prior if x is empty or not change it ?
    components = map(zip(d.components, d.priors, Y)) do (component, prior, y)
        rand(component, prior, y)
    end

    counts = length.(Y)
    weights = rand(Dirichlet((σ / ncomponents(d)) .+ counts))

    BayesianMixtureModel(components, d.priors, weights)
end

