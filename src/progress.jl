# TODO: Handle threads / coroutines
mutable struct Progress
    cur::Int64
    tot::Int64
    msg::String
    last::UInt64
end

function Progress(tot, msg="")
    p = Progress(0, tot, msg, 0)
    print(p)
    p
end

function print(p::Progress)
    diff = time_ns() - p.last
    if diff > 0.1e9
        print!(p)
        p.last = time_ns()
    end
end

print!(p::Progress) = @printf("\33[2K\r%s%d/%d", p.msg, p.cur, p.tot)

next!(p::Progress) = (p.cur += 1; print(p))

close(p::Progress) = print!(p), @printf("\33[2K\r")