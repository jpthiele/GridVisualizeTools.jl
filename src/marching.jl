"""
  $(SIGNATURES)
  Calculate intersections between tetrahedron with given piecewise linear
  function data and plane 

  Adapted from https://github.com/j-fu/gltools/blob/master/glm-3d.c#L341
 
  A non-empty intersection is either a triangle or a planar quadrilateral,
  define by either 3 or 4 intersection points between tetrahedron edges
  and the plane.

  Input: 
  -       pointlist: 3xN array of grid point coordinates
  -    node_indices: 4 element array of node indices (pointing into pointlist and function_values)
  -   planeq_values: 4 element array of plane equation evaluated at the node coordinates
  - function_values: N element array of function values

  Mutates:
  -  ixcoord: 3x4 array of plane - tetedge intersection coordinates
  - ixvalues: 4 element array of fuction values at plane - tetdedge intersections

  Returns:
  - nxs,ixcoord,ixvalues
  
  This method can be used both for the evaluation of plane sections and for
  the evaluation of function isosurfaces.
"""
function tet_x_plane!(ixcoord,
                      ixvalues,
                      pointlist,
                      node_indices,
                      planeq_values,
                      function_values;
                      tol = 0.0)

    # If all nodes lie on one side of the plane, no intersection
    @fastmath if (mapreduce(a -> a < -tol, *, planeq_values) ||
                  mapreduce(a -> a > tol, *, planeq_values))
        return 0
    end
    # Interpolate coordinates and function_values according to
    # evaluation of the plane equation
    nxs = 0
    @inbounds @simd for n1 = 1:3
        N1 = node_indices[n1]
        @inbounds @fastmath @simd for n2 = (n1 + 1):4
            N2 = node_indices[n2]
            if planeq_values[n1] != planeq_values[n2] &&
               planeq_values[n1] * planeq_values[n2] < tol
                nxs += 1
                t = planeq_values[n1] / (planeq_values[n1] - planeq_values[n2])
                ixcoord[1, nxs] = pointlist[1, N1] + t * (pointlist[1, N2] - pointlist[1, N1])
                ixcoord[2, nxs] = pointlist[2, N1] + t * (pointlist[2, N2] - pointlist[2, N1])
                ixcoord[3, nxs] = pointlist[3, N1] + t * (pointlist[3, N2] - pointlist[3, N1])
                ixvalues[nxs] = function_values[N1] + t * (function_values[N2] - function_values[N1])
            end
        end
    end
    return nxs
end

"""
 We should be able to parametrize this
 with a pushdata function which will remove one copy
 step for GeometryBasics.mesh creation - perhaps a meshcollector struct we
 can dispatch on.
 flevel could be flevels
 xyzcut could be a vector of plane data
 perhaps we can also collect isolines.
 Just an optional collector parameter, defaulting to somethig makie independent.

    Better yet:

 struct TetrahedronMarcher
  ...
 end
 tm=TetrahedronMarcher(planes,levels)

 foreach tet
       collect!(tm, tet_node_coord, node_function_values)
 end
 tm.colors=AbstractPlotting.interpolated_getindex.((cmap,), mcoll.vals, (fminmax,))
 mesh!(collect(mcoll),backlight=1f0) 
"""

"""
$(SIGNATURES)

Extract isosurfaces and plane interpolation for function on 3D tetrahedral mesh.

The basic observation is that locally on a tetrahedron, cuts with planes and isosurfaces
of P1 functions look the same. This method calculates data for several plane cuts and several
isosurfaces at once. 

Input parameters:
- `coord`: 3 x n_points matrix of point coordinates
- `cellnodes`: 4 x n_cells matrix of point numbers per tetrahedron
- `func`: n_points vector of piecewise linear function values
- `planes`: vector of plane equations `ax+by+cz+d=0`,each  stored as vector [a,b,c,d]
- `flevels`: vector of function isolevels

Keyword arguments:
- `tol`: tolerance for tet x plane intersection
- `primepoints`:  3 x n_prime matrix of "corner points" of domain to be plotted. These are not in the mesh but are used to calculate the axis size e.g. by Makie
- `primevalues`:  n_prime vector of function values in corner points. These can be used to calculate function limits e.g. by Makie
- `Tv`:  type of function values returned
- `Tp`:  type of points returned
- `Tf`:  type of facets returned

Return values: (points, tris, values)
- `points`: vector of points (Tp)
- `tris`: vector of triangles (Tf)
- `values`: vector of function values (Tv)

These can be readily turned into a mesh with function values on it.

Caveat: points with similar coordinates are not identified, e.g. an intersection of a plane and an edge will generate as many edge intersection points as there are tetrahedra adjacent to that edge. As a consequence, normal calculations for visualization alway will end up with facet normals, not point normals, and the visual impression of a rendered isosurface will show its piecewise linear genealogy.

"""
function marching_tetrahedra(coord::Matrix{Tc},
                             cellnodes::Matrix{Ti},
                             func,
                             planes,
                             flevels;
                             tol = 1.0e-12,
                             primepoints = zeros(0, 0),
                             primevalues = zeros(0),
                             Tv = Float32,
                             Tp = SVector{3, Float32},
                             Tf = SVector{3, Int32}) where {Tc, Ti}
    marching_tetrahedra([coord],
                        [cellnodes],
                        [func],
                        planes,
                        flevels;
                        tol,
                        primepoints,
                        primevalues,
                        Tv,
                        Tp,
                        Tf)
end

function marching_tetrahedra(allcoords::Vector{Matrix{Tc}},
                             allcellnodes::Vector{Matrix{Ti}},
                             allfuncs,
                             planes,
                             flevels;
                             tol = 1.0e-12,
                             primepoints = zeros(0, 0),
                             primevalues = zeros(0),
                             Tv = Float32,
                             Tp = SVector{3, Float32},
                             Tf = SVector{3, Int32}) where {Tc, Ti}

    # We could rewrite this for Meshing.jl
    # CellNodes::Vector{Ttet}, Coord::Vector{Tpt}
    nplanes = length(planes)
    nlevels = length(flevels)

    # Create output vectors
    all_ixfaces = Vector{Tf}(undef, 0)
    all_ixcoord = Vector{Tp}(undef, 0)
    all_ixvalues = Vector{Tv}(undef, 0)

    @assert(length(primevalues)==size(primepoints, 2))
    for iprime = 1:size(primepoints, 2)
        @views push!(all_ixcoord, primepoints[:, iprime])
        @views push!(all_ixvalues, primevalues[iprime])
    end

    planeq = zeros(4)
    ixcoord = zeros(3, 6)
    ixvalues = zeros(6)
    cn = zeros(4)
    node_indices = zeros(Int32, 4)

    # Function to evaluate plane equation
    @inbounds @fastmath plane_equation(plane, coord) = coord[1] * plane[1] + coord[2] * plane[2] + coord[3] * plane[3] + plane[4]

    function pushtris(ns, ixcoord, ixvalues)
        # number of intersection points can be 3 or 4
        if ns >= 3
            last_i = length(all_ixvalues)
            for is = 1:ns
                @views push!(all_ixcoord, ixcoord[:, is])
                push!(all_ixvalues, ixvalues[is]) # todo consider nan_replacement here
            end
            push!(all_ixfaces, (last_i + 1, last_i + 2, last_i + 3))
            if ns == 4
                push!(all_ixfaces, (last_i + 3, last_i + 2, last_i + 4))
            end
        end
    end

    for igrid = 1:length(allcoords)
        coord = allcoords[igrid]
        cellnodes = allcellnodes[igrid]
        func = allfuncs[igrid]
        nnodes = size(coord, 2)
        ntet = size(cellnodes, 2)
        all_planeq = Vector{Float32}(undef, nnodes)

        function calcxs()
            @inbounds for itet = 1:ntet
                node_indices[1] = cellnodes[1, itet]
                node_indices[2] = cellnodes[2, itet]
                node_indices[3] = cellnodes[3, itet]
                node_indices[4] = cellnodes[4, itet]
                planeq[1] = all_planeq[node_indices[1]]
                planeq[2] = all_planeq[node_indices[2]]
                planeq[3] = all_planeq[node_indices[3]]
                planeq[4] = all_planeq[node_indices[4]]
                nxs = tet_x_plane!(ixcoord,
                                   ixvalues,
                                   coord,
                                   node_indices,
                                   planeq,
                                   func;
                                   tol = tol)
                pushtris(nxs, ixcoord, ixvalues)
            end
        end

        @inbounds for iplane = 1:nplanes
            @views @inbounds map!(inode -> plane_equation(planes[iplane], coord[:, inode]),
                                  all_planeq,
                                  1:nnodes)
            calcxs()
        end

        # allocation free (besides push!)
        @inbounds for ilevel = 1:nlevels
            @views @inbounds @fastmath map!(inode -> (func[inode] - flevels[ilevel]),
                                            all_planeq,
                                            1:nnodes)
            calcxs()
        end
    end
    all_ixcoord, all_ixfaces, all_ixvalues
end

"""
    $(SIGNATURES)

Collect isoline snippets on triangles ready for linesegments!
"""
function marching_triangles(coord::Matrix{Tv},
                            cellnodes::Matrix{Ti},
                            func,
                            levels;
                            Tc = Float32,
                            Tp = SVector{2, Tc}) where {Tv <: Number, Ti <: Number}
    marching_triangles([coord], [cellnodes], [func], levels; Tc, Tp)
end

function marching_triangles(coords::Vector{Matrix{Tv}},
                            cellnodes::Vector{Matrix{Ti}},
                            funcs,
                            levels;
                            Tc = Float32,
                            Tp = SVector{2, Tc}) where {Tv <: Number, Ti <: Number}
    points = Vector{Tp}(undef, 0)

    for igrid = 1:length(coords)
        func = funcs[igrid]
        coord = coords[igrid]

        function isect(nodes)
            (i1, i2, i3) = (1, 2, 3)

            f = (func[nodes[1]], func[nodes[2]], func[nodes[3]])

            f[1] <= f[2] ? (i1, i2) = (1, 2) : (i1, i2) = (2, 1)
            f[i2] <= f[3] ? i3 = 3 : (i2, i3) = (3, i2)
            f[i1] > f[i2] ? (i1, i2) = (i2, i1) : nothing

            (n1, n2, n3) = (nodes[i1], nodes[i2], nodes[i3])

            dx31 = coord[1, n3] - coord[1, n1]
            dx21 = coord[1, n2] - coord[1, n1]
            dx32 = coord[1, n3] - coord[1, n2]

            dy31 = coord[2, n3] - coord[2, n1]
            dy21 = coord[2, n2] - coord[2, n1]
            dy32 = coord[2, n3] - coord[2, n2]

            df31 = f[i3] != f[i1] ? 1 / (f[i3] - f[i1]) : 0.0
            df21 = f[i2] != f[i1] ? 1 / (f[i2] - f[i1]) : 0.0
            df32 = f[i3] != f[i2] ? 1 / (f[i3] - f[i2]) : 0.0

            for level ∈ levels
                if (f[i1] <= level) && (level < f[i3])
                    α = (level - f[i1]) * df31
                    x1 = coord[1, n1] + α * dx31
                    y1 = coord[2, n1] + α * dy31

                    if (level < f[i2])
                        α = (level - f[i1]) * df21
                        x2 = coord[1, n1] + α * dx21
                        y2 = coord[2, n1] + α * dy21
                    else
                        α = (level - f[i2]) * df32
                        x2 = coord[1, n2] + α * dx32
                        y2 = coord[2, n2] + α * dy32
                    end
                    push!(points, SVector{2, Tc}((x1, y1)))
                    push!(points, SVector{2, Tc}((x2, y2)))
                end
            end
        end

        for itri = 1:size(cellnodes[igrid], 2)
            @views isect(cellnodes[igrid][:, itri])
        end
    end
    points
end
