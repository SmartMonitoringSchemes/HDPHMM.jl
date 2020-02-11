function enablemissing(val = missing)
    Base.eval(Distributions, :(pdf(::Distribution, ::Missing) = $val))
    Base.eval(Distributions, :(logpdf(::Distribution, ::Missing) = log($val)))
    Base.eval(Distributions, :(zval(::Normal, ::Missing) = log($val)))
    nothing
end

function disablemissing()
    try
        Base.delete_method(@which pdf(Normal(), missing))
        Base.delete_method(@which logpdf(Normal(), missing))
        Base.delete_method(@which zval(Normal(), missing))
    catch
    end
end
