function HMM(state::BlockedSamplerState)
    a = state.initstate.π0
    A = state.transdist.π
    B = state.obsmodel.mixtures
    HMM(a, A, [B...])
end

function HMM(state::BlockedSamplerState, z::Vector{Int})
    zmap = Dict(old => new for (new, old) in enumerate(sort(unique(z))))
    znew = [zmap[x] for x in z]

    A = gettransmat(znew, relabel = false)[2]
    a = zeros(length(zmap))
    B = Vector(undef, length(zmap))

    for (old, new) in zmap
        a[new] = state.initstate.π0[old]
        B[new] = state.obsmodel.mixtures[old]
    end

    HMM(a / sum(a), A, [B...])
end
