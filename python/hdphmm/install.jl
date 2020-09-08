using Pkg

Pkg.activate(@__DIR__)

pkg"""
registry add General
registry add git@github.com:SmartMonitoringSchemes/Registry.git
add HDPHMM PyCall
"""
