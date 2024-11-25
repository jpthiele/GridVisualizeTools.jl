"""depend
$(SIGNATURES)

Create customized distinguishable colormap for interior regions.
For this we use a kind of pastel colors.


```jldoctest
region_cmap(10)[1]

# output

RGB{Float64}(0.85, 0.6, 0.6)
```

"""
function region_cmap(n)
    ColorSchemes.distinguishable_colors(n,
                                        [Colors.RGB(0.85, 0.6, 0.6), Colors.RGB(0.6, 0.85, 0.6), Colors.RGB(0.6, 0.6, 0.85)];
                                        lchoices = range(70; stop = 80, length = 5),
                                        cchoices = range(25; stop = 65, length = 15),
                                        hchoices = range(20; stop = 360, length = 15))
end

"""
$(SIGNATURES)

Create customized distinguishable colormap for boundary regions.
These use fully saturated colors.

```jldoctest
bregion_cmap(10)[1]

# output

RGB{Float64}(1.0, 0.0, 0.0)
```

"""
function bregion_cmap(n)
    ColorSchemes.distinguishable_colors(n,
                                        [Colors.RGB(1.0, 0.0, 0.0), Colors.RGB(0.0, 1.0, 0.0), Colors.RGB(0.0, 0.0, 1.0)];
                                        lchoices = range(50; stop = 75, length = 10),
                                        cchoices = range(75; stop = 100, length = 10),
                                        hchoices = range(20; stop = 360, length = 30))
end

"""
Create color tuple from  color description (e.g. string)

```jldoctest
julia> rgbtuple(:red)
(1.0, 0.0, 0.0)

julia> rgbtuple("red")
(1.0, 0.0, 0.0)
```
"""
rgbtuple(c) = rgbtuple(parse(Colors.RGB{Float64},c))

"""
$(SIGNATURES)

Create color tuple from  RGB color.

```jldoctest
julia> rgbtuple(RGB(0.0,1,0))
(0.0, 1.0, 0.0)
```
"""
rgbtuple(c::Colors.RGB) = (Colors.red(c), Colors.green(c), Colors.blue(c))


"""
    rgbcolor(col::Any)

Return Colors.RGB object from string or symbol. 

```jldoctest
julia> rgbcolor(:red)
RGB{Float64}(1.0, 0.0, 0.0)

julia> rgbcolor("red")
RGB{Float64}(1.0, 0.0, 0.0)
```

"""
rgbcolor(col::Any) = parse(Colors.RGB{Float64},col) 


"""
    rgbcolor(col::RGB)

Pass through of RGB color object.
```jldoctest
julia> rgbcolor(RGB(1.0,0.0, 0.0))
RGB{Float64}(1.0, 0.0, 0.0)
```

"""
rgbcolor(col::Colors.RGB) = col

"""
    rgbcolor(col::Tuple)

Create RGB color object from tuple
```jldoctest
julia> rgbcolor((1.0,0.0, 0.0))
RGB{Float64}(1.0, 0.0, 0.0)
```

"""
function rgbcolor(col::Tuple)
    # Base.depwarn(
    #     "Setting custom colors as `Tuple`, e.g. `color=(0.,0.,1.)` will be removed in the next major release. "*
    #     "Please use color=RGB(0.,0.,1.) instead.",
    #     :update_lines,
    # )
    return Colors.RGB(col...)
end
