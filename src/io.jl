# Currently (as of Julia 1.4) it is not possible to directly
# dezerialize JSON to a Julia structure.
# E.g. `Normal(JSON.parse(JSON.json(Normal())))` is not possible.
# We provide the following methods for convenience.

function HMM(::Type{MixtureModel}, D::Type{<:Distribution}, d::Dict)
    a = Vector{Float64}(d["a"])
    A = Matrix{Float64}(hcat(d["A"]...))
    B = map(x -> MixtureModel(D, x), d["B"])
    HMM(a, A, B)
end

function MixtureModel(T::Type{<:Distribution}, d::Dict)
    components = map(T, d["components"])
    prior = Vector{Float64}(d["prior"]["p"])
    MixtureModel(components, prior)
end

Normal(d::Dict) = Normal(d["μ"], d["σ"])

function DataSegmentationModel(d::Dict)
    index = Vector{Int}(d["index"])
    state = Vector{Int}(d["state"])
    model = HMM(MixtureModel, Normal, d["model"])
    data = replace(d["data"], nothing => missing)
    data = Vector{Union{Float64, Missing}}(data)
    DataSegmentationModel(index, state, model, data)
end

function parsefile(::Type{DataSegmentationModel}, filename)
    DataSegmentationModel(parsefile(filename))
end
