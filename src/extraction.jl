"""
$(SIGNATURES)

Extract visible tetrahedra - those intersecting with the planes
`x=xyzcut[1]` or `y=xyzcut[2]`  or `z=xyzcut[3]`. 

Return corresponding points and facets for each region for drawing as mesh (Makie,MeshCat)
or trisurf (pyplot)
"""
function extract_visible_cells3D(coord, cellnodes, cellregions, nregions, xyzcut;
                                 primepoints = zeros(0, 0), Tp = SVector{3, Float32}, Tf = SVector{3, Int32})
    all_lt = ones(Bool, 3)
    all_gt = ones(Bool, 3)

    function take(coord, simplex, xyzcut, all_lt, all_gt)
        for idim = 1:3
            all_lt[idim] = true
            all_gt[idim] = true
            for inode = 1:4
                c = coord[idim, simplex[inode]] - xyzcut[idim]
                all_lt[idim] = all_lt[idim] && (c < 0.0)
                all_gt[idim] = all_gt[idim] && (c > 0.0)
            end
        end
        tke = false
        tke = tke || (!all_lt[1]) && (!all_gt[1]) && (!all_gt[2]) && (!all_gt[3])
        tke = tke || (!all_lt[2]) && (!all_gt[2]) && (!all_gt[1]) && (!all_gt[3])
        tke = tke || (!all_lt[3]) && (!all_gt[3]) && (!all_gt[1]) && (!all_gt[2])
    end

    faces = [Vector{Tf}(undef, 0) for iregion = 1:nregions]
    points = [Vector{Tp}(undef, 0) for iregion = 1:nregions]

    for iregion = 1:nregions
        for iprime = 1:size(primepoints, 2)
            @views push!(points[iregion], Tp(primepoints[:, iprime]))
        end
    end
    tet = zeros(Int32, 4)

    for itet = 1:size(cellnodes, 2)
        iregion = cellregions[itet]
        for i = 1:4
            tet[i] = cellnodes[i, itet]
        end
        if take(coord, tet, xyzcut, all_lt, all_gt)
            npts = size(points[iregion], 1)
            @views begin
                push!(points[iregion], coord[:, cellnodes[1, itet]])
                push!(points[iregion], coord[:, cellnodes[2, itet]])
                push!(points[iregion], coord[:, cellnodes[3, itet]])
                push!(points[iregion], coord[:, cellnodes[4, itet]])
                push!(faces[iregion], (npts + 1, npts + 2, npts + 3))
                push!(faces[iregion], (npts + 1, npts + 2, npts + 4))
                push!(faces[iregion], (npts + 2, npts + 3, npts + 4))
                push!(faces[iregion], (npts + 3, npts + 1, npts + 4))
            end
        end
    end
    points, faces
end

"""
$(SIGNATURES)

Extract visible boundary faces - those not cut off by the planes
`x=xyzcut[1]` or `y=xyzcut[2]`  or `z=xyzcut[3]`. 

Return corresponding points and facets for each region for drawing as mesh (Makie,MeshCat)
or trisurf (pyplot)
"""
function extract_visible_bfaces3D(coord, bfacenodes, bfaceregions, nbregions, xyzcut;
                                  primepoints = zeros(0, 0), Tp = SVector{3, Float32}, Tf = SVector{3, Int32})
    nbfaces = size(bfacenodes, 2)
    cutcoord = zeros(3)

    function take(coord, simplex, xyzcut)
        for idim = 1:3
            all_gt = true
            for inode = 1:3
                c = coord[idim, simplex[inode]] - xyzcut[idim]
                all_gt = all_gt && c > 0
            end
            if all_gt
                return false
            end
        end
        return true
    end

    Tc = SVector{3, eltype(coord)}
    xcoord = reinterpret(Tc, reshape(coord, (length(coord),)))

    faces = [Vector{Tf}(undef, 0) for iregion = 1:nbregions]
    points = [Vector{Tp}(undef, 0) for iregion = 1:nbregions]
    for iregion = 1:nbregions
        for iprime = 1:size(primepoints, 2)
            @views push!(points[iregion], Tp(primepoints[:, iprime]))
        end
    end

    # remove some type instability here
    function collct(points, faces)
        trinodes = [1, 2, 3]
        for i = 1:nbfaces
            iregion = bfaceregions[i]
            trinodes[1] = bfacenodes[1, i]
            trinodes[2] = bfacenodes[2, i]
            trinodes[3] = bfacenodes[3, i]
            if take(coord, trinodes, xyzcut)
                npts = size(points[iregion], 1)
                @views push!(points[iregion], xcoord[trinodes[1]])
                @views push!(points[iregion], xcoord[trinodes[2]])
                @views push!(points[iregion], xcoord[trinodes[3]])
                @views push!(faces[iregion], (npts + 1, npts + 2, npts + 3))
            end
        end
    end
    collct(points, faces)
    points, faces
end
