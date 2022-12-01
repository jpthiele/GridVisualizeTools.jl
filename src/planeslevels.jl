function makeplanes(mmin,mmax,n)
    if isa(n,Number)
        if n==0
            return [Inf]
        end
        p=collect(range(mmin,mmax,length=ceil(n)+2))
        p[2:end-1]
    else
        n
    end
end

function makeplanes(xyzmin,xyzmax,x,y,z)
    planes=Vector{Vector{Float64}}(undef,0)
#    ε=1.0e-1*(xyzmax.-xyzmin)
    
    X=makeplanes(xyzmin[1],xyzmax[1],x)
    Y=makeplanes(xyzmin[2],xyzmax[2],y)
    Z=makeplanes(xyzmin[3],xyzmax[3],z)

    for i=1:length(X)
        x=X[i]
        x>xyzmin[1] && x<xyzmax[1]  && push!(planes,[1,0,0,-x])
    end
    
    for i=1:length(Y)
        y=Y[i]
        y>xyzmin[2] && y<xyzmax[2]  && push!(planes,[0,1,0,-y])
    end
    
    for i=1:length(Z)
        z=Z[i]
        z>xyzmin[3] && z<xyzmax[3]  && push!(planes,[0,0,1,-z])
    end
    planes
end



# Calculate isolevel values and function limits
function isolevels(ctx,func)
    
    crange=ctx[:limits]
    if crange==:auto || crange[1]>crange[2] 
        crange=extrema(func)
    end
    
    if isa(ctx[:levels],Number)
        levels=collect(LinRange(crange[1],crange[2],ctx[:levels]+2))
    else
        levels=ctx[:levels]
    end

    if ctx[:colorbarticks] == :default
        colorbarticks = levels
    elseif isa(ctx[:colorbarticks],Number)
        colorbarticks = collect(crange[1]:(crange[2]-crange[1])/(ctx[:colorbarticks]-1):crange[2])
    else
        colorbarticks = ctx[:colorbarticks]
    end
    
    
    #    map(t->round(t,sigdigits=4),levels),crange,map(t->round(t,sigdigits=4),colorbarticks)
    levels,crange,colorbarticks

end

