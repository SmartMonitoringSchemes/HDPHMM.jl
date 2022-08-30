using Pkg

Pkg.Registry.add("General")
Pkg.Registry.add(RegistrySpec(url="https://github.com/SmartMonitoringSchemes/Registry"))

if haskey(ENV, "GITHUB_ACTIONS")
    Pkg.add("PyCall")
    Pkg.develop(path = joinpath(@__DIR__, "..", ".."))
else
    Pkg.add("PyCall")
    Pkg.add("HDPHMM")
end
