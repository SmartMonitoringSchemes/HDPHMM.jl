using Pkg

Pkg.Registry.add("General")
Pkg.Registry.add(RegistrySpec(url="git@github.com:SmartMonitoringSchemes/Registry.git"))

if haskey(ENV, "GITHUB_ACTIONS")
    Pkg.add("PyCall")
    Pkg.develop(path = joinpath(@__DIR__, "..", ".."))
else
    Pkg.add("PyCall")
    Pkg.add("HDPHMM")
end
