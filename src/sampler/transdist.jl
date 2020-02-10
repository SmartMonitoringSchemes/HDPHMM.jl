struct TransitionDistribution
    # Global transition distribution (root DP)
    β::Vector{Float64}

    # Transition matrix (one child DP per row)
    π::Matrix{Float64}

    # Root DP concentration
    γ::Float64

    # Child DPs concentration and self-transition (sticky) parameter
    # α = (1-ρ)(α+κ)
    # κ = ρ(α+κ)
    α::Float64
    κ::Float64

    # Self-transition proportion parameter
    # ρ = κ/(α+κ)
    ρ::Float64
end

function TransitionDistribution(L, prior)
    γ, α, κ, ρ = rand(prior)
    β = rand(Dirichlet(L, γ / L))
    π = TransitionMatrix(Dirichlet(α * β))
    TransitionDistribution(β, π, γ, α, κ, ρ)
end

struct TransitionDistributionPrior
    γ_prior::Gamma
    α_κ_prior::Gamma
    ρ_prior::Beta
end

function rand(prior::TransitionDistributionPrior)
    γ = rand(prior.γ_prior)
    ρ = rand(prior.ρ_prior)
    α_κ = rand(prior.α_κ_prior)
    α = (1 - ρ) * α_κ
    κ = ρ * α_κ
    γ, α, κ, ρ
end

function TransitionMatrix(prior; trials = 10)
    for _ = 1:trials
        try
            return randtransmat(prior)
        catch
        end
    end
    throw(ErrorException("Failed to initialize transition matrix (NaN values), please check your priors."))
end

function sample_auxiliary(α, β, κ, ρ, counts)
    L = length(β)

    # m[j,k]: number of tables in restaurant j that were served dish k
    m = zeros(Int, L, L)

    for j = 1:L, k = 1:L, i = 1:counts[j, k]
        p = (α * β[k] + κ * (j == k)) / ((i - 1) + α * β[k] + κ * (j == k))
        m[j, k] += rand(Bernoulli(p))
    end

    # mbar[j,k]: number of tables in restaurant j that considered dish k
    # w[j]: number of override variables in restaurant j
    mbar = copy(m)
    w = zeros(Int, L)

    for j = 1:L
        w[j] = rand(Binomial(m[j, j], ρ / (ρ + β[j] * (1 - ρ))))
        mbar[j, j] -= w[j]
    end

    m, mbar, w
end

# Hyperparameters
# See Appendix D.

function resample_alpha_kappa(α, κ, α_κ_prior, ρ, counts, m; niter = 1)
    L = size(counts)[1]

    # Auxiliary variables
    r = zeros(L)
    s = zeros(L)

    # Prior on (α+κ)
    a, b = α_κ_prior.α, 1 / α_κ_prior.θ

    for _ = 1:niter
        for j = 1:L
            cs = sum(counts[j, :])
            # Beta(.,0) -> 1.0
            r[j] = cs == 0 ? 1.0 : rand(Beta(α + κ + 1, cs))
            s[j] = rand(Bernoulli(cs / (cs + α + κ)))
        end

        alpha_kappa = rand(Gamma(a + sum(m) - sum(s), b - sum(log.(r))))

        α = (1 - ρ) * alpha_kappa
        κ = ρ * alpha_kappa
    end

    α, κ
end

function resample_gamma(γ, γ_prior, mbar; niter = 1)
    # Kbar: number of unique dishes considered in the franchise
    # mbars[j,k]: number of tables in restaurant j that considered dish k
    Kbar = sum(sum(mbar, dims = 1) .> 0)
    mbars = sum(mbar)

    # Prior on γ
    α, β = γ_prior.α, 1 / γ_prior.θ

    for _ = 1:niter
        ζ = rand(Bernoulli(mbars / (mbars + γ)))
        η = rand(Beta(γ + 1, mbars))
        γ = rand(Gamma(α + Kbar - ζ, β - log(η)))
    end

    γ
end

function resample_rho(ρ_prior, m, w)
    ws = sum(w)
    ms = sum(m)
    c, d = ρ_prior.α, ρ_prior.β
    rand(Beta(ws + c, ms - ws + d))
end

function resample_beta(γ, mbar)
    L = size(mbar, 1)
    rand(Dirichlet(γ / L .+ sum(mbar, dims = 1)[:]))
end

function resample_pi(α, β, κ, n)
    L = size(n, 1)
    π = zeros(L, L)
    for k = 1:L
        p = α * β + n[k, :] .+ eps()
        p[k] += κ
        π[k, :] = rand(Dirichlet(p))
    end
    π
end

function resample(d::TransitionDistribution, prior, n)
    m, mbar, w = sample_auxiliary(d.α, d.β, d.κ, d.ρ, n)

    # HACK (otherwise mbar = 0 on series with only 1 state)
    (sum(mbar) == 0) && (mbar[argmax(m)] = 1)

    β = resample_beta(d.γ, mbar)
    π = resample_pi(d.α, β, d.κ, n)
    ρ = resample_rho(prior.ρ_prior, m, w)
    γ = resample_gamma(d.γ, prior.γ_prior, mbar, niter = 50)
    α, κ = resample_alpha_kappa(d.α, d.κ, prior.α_κ_prior, ρ, n, m, niter = 50)

    TransitionDistribution(β, π, γ, α, κ, ρ)
end

function suffstats(d::TransitionDistribution, z)
    L, T = length(d.β), length(z)

    # n[j,k]  = number of customers in restaurant j eating dish k
    n = zeros(Int, L, L)

    # DANGER: @inbounds so make sure that z[t] is in 1:L
    @inbounds for t = 2:T
        n[z[t-1], z[t]] += 1
    end

    n
end
