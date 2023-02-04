"""
$(SIGNATURES)


Assume that `points` are nodes of a polyline.
Place `nmarkers` equidistant markers  at the polyline, under
the assumption that the points are transformed via the transformation
matrix M vor visualization.
"""
function markerpoints(points, nmarkers, transform)
    dist(p1, p2) = norm(transform * (p1 - p2))

    llen = 0.0
    for i = 2:length(points)
        llen += dist(points[i], points[i - 1])
    end

    mdist = llen / (nmarkers - 1)

    mpoints = [points[1]]

    i = 2
    l = 0.0
    lnext = l + mdist
    while i < length(points)
        d = dist(points[i], points[i - 1])
        while l + d <= lnext && i < length(points)
            i = i + 1
            l = l + d
            d = dist(points[i], points[i - 1])
        end

        while lnext <= l + d && length(mpoints) < nmarkers - 1
            α = (lnext - l) / d
            push!(mpoints, Point2f(α * points[i] + (1 - α) * points[i - 1]))
            lnext = lnext + mdist
        end
    end
    push!(mpoints, points[end])
end
