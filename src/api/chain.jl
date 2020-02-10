struct Chain
    index::Int
    zseqs::Matrix{Int}
    sseqs::Matrix{Int}
    states::Vector{BlockedSamplerState}
end

"""
    Chain(n, t, index = 1)

Pre-allocate a chain for n samples and t observations.
"""
function Chain(nsamples, nobs, index = 1)
    Chain(
        index,
        zeros(Int, nsamples, nobs),
        zeros(Int, nsamples, nobs),
        Vector{BlockedSamplerState}(undef, nsamples),
    )
end

getindex(c::Chain, idx::Integer) =
    (c.index, c.zseqs[idx,:], c.sseqs[idx,:], c.states[idx])

getindex(c::Chain, inds...) =
    Chain(c.index, c.zseqs[inds..., :], c.sseqs[inds..., :], c.states[inds...])

lastindex(c::Chain) = lastindex(c.states)

length(c::Chain) = length(c.states)

# TODO: Label permutation problem !!!
function cat(cs::Vector{Chain})
    zseqs = vcat([c.zseqs for c in cs]...)
    sseqs = vcat([c.sseqs for c in cs]...)
    states = vcat([c.states for c in cs]...)
    Chain(1, zseqs, sseqs, states)
end


function split(X; a = 0.5, b = 0.5)
    N = length(X)
    sz_a = Int(round(N * a))
    sz_b = Int(round(N * b))
    idxs = sample(1:N, sz_a + sz_b, replace = false)
    X[idxs[1:sz_a]], X[idxs[sz_a+1:end]]
end

"""
    select_sample(seqs::Matrix, ref_p=0.45, test_p=0.45)

Select the sequence that minimizes the expected Hamming distance.  
See p. 27 https://people.eecs.berkeley.edu/~jordan/papers/stickyHDPHMM_LIDS_TR.pdf
"""
function select_hamming(c::Chain, refsize = 0.45, testsize = 0.45)
    ref, test = split(c, a = refsize, b = testsize)

    distances = zeros(length(test), length(ref))
    for i in 1:length(test), j in 1:length(ref)
        distances[i,j] = sum(test.zseqs[i,:] .!= ref.zseqs[j,:])
    end

    # TODO: Verify
    idx = argmin(mean(distances, dims=2))[1]
    test[idx]
end
