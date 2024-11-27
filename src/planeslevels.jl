function makeplanes(mmin, mmax, n)
    return if isa(n, Number)
        if n == 0
            return [Inf]
        end
        p = collect(range(mmin, mmax; length = ceil(n) + 2))
        p[2:(end - 1)]
    else
        n
    end
end

"""
$(SIGNATURES)

For vectors of x, y and z coordinates, create equations for
planes parallel to the coordinate axes.    
"""
function makeplanes(xyzmin, xyzmax, x, y, z)
    planes = Vector{Vector{Float64}}(undef, 0)
    #    ε=1.0e-1*(xyzmax.-xyzmin)

    X = makeplanes(xyzmin[1], xyzmax[1], x)
    Y = makeplanes(xyzmin[2], xyzmax[2], y)
    Z = makeplanes(xyzmin[3], xyzmax[3], z)

    for i in 1:length(X)
        x = X[i]
        x > xyzmin[1] && x < xyzmax[1] && push!(planes, [1, 0, 0, -x])
    end

    for i in 1:length(Y)
        y = Y[i]
        y > xyzmin[2] && y < xyzmax[2] && push!(planes, [0, 1, 0, -y])
    end

    for i in 1:length(Z)
        z = Z[i]
        z > xyzmin[3] && z < xyzmax[3] && push!(planes, [0, 0, 1, -z])
    end
    return planes
end

"""
    $(SIGNATURES)

Update levels, limits, colorbartics based on vector given in func.

- if `limits[1]>limits[2]`, replace it by `extrema(func)`.
- if levels is a number, replace it with a linear range in `limits` of length levels+2
- if colorbarticks is `nothing` replace it with levels and add the limits to the result
  otherwise, if it is a number, replace it  with a linear range of corresponding length
"""
function makeisolevels(func::Vector{T}, levels, limits, colorbarticks) where {T <: Number}
    return makeisolevels([func], levels, limits, colorbarticks)
end

function makeisolevels(funcs::Vector{T}, levels, limits, colorbarticks) where {T <: AbstractVector}
    if limits[1] > limits[2]
        ext = extrema.(funcs)
        limits = (minimum(first.(ext)), maximum(last.(ext)))
    end

    if isa(levels, Number)
        levels = collect(LinRange(limits[1], limits[2], levels + 2))
    end

    if colorbarticks == nothing
        colorbarticks = unique([limits[1], levels..., limits[2]])
    elseif isa(colorbarticks, Number)
        colorbarticks = collect(limits[1]:((limits[2] - limits[1]) / (colorbarticks - 1)):limits[2])
    end

    #    map(t->round(t,sigdigits=4),levels),limits,map(t->round(t,sigdigits=4),colorbarticks)
    return levels, limits, colorbarticks
end
