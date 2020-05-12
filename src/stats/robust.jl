# Robust estimator of the mean and the variance, under
# a Normal distribution assumption.
function robuststats(::Type{Normal}, x::AbstractVector)
    x = skipmissing(x)
    
    xmed = median(x)
    xmad = mad(x, normalize = true)

    # > If normalize is set to true, the MAD is multiplied by 1 / quantile(Normal(), 3/4) ≈ 1.4826,
    # > in order to obtain a consistent estimator of the standard deviation under the assumption that the data is normally distributed.
    xvar = xmad^2

    # Fallback to empirical mean/variance otherwise
    (xmed == 0) && (xmed = mean(x))
    (xvar == 0) && (xvar = var(data))

    xmed, xvar
end