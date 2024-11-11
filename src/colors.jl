"""
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
    ColorSchemes.distinguishable_colors(max(5, n),
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
    ColorSchemes.distinguishable_colors(max(5, n),
                                        [Colors.RGB(1.0, 0.0, 0.0), Colors.RGB(0.0, 1.0, 0.0), Colors.RGB(0.0, 0.0, 1.0)];
                                        lchoices = range(50; stop = 75, length = 10),
                                        cchoices = range(75; stop = 100, length = 10),
                                        hchoices = range(20; stop = 360, length = 30))
end

"""
$(SIGNATURES)

Create RGB color from color name string.

julia> Colors.RGB("red")
RGB{Float64}(1.0,0.0,0.0)
```
"""
function Colors.RGB(c::String)
    c64 = Colors.color_names[c]
    Colors.RGB(c64[1] / 255, c64[2] / 255, c64[3] / 255)
end

"""
$(SIGNATURES)

Create RGB color from color name symbol.

```jldoctest
julia> Colors.RGB(:red)
RGB{Float64}(1.0, 0.0, 0.0)
```
"""
Colors.RGB(c::Symbol) = Colors.RGB(String(c))

"""
$(SIGNATURES)

Create RGB color from tuple

```jldoctest
julia> Colors.RGB((1.0,0,0))
RGB{Float64}(1.0, 0.0, 0.0)
```
"""
Colors.RGB(c::Tuple) = Colors.RGB(c...)

"""
$(SIGNATURES)

Create color tuple from  color description (e.g. string)

```jldoctest
julia> rgbtuple(:red)
(1.0, 0.0, 0.0)

julia> rgbtuple("red")
(1.0, 0.0, 0.0)
```
"""
rgbtuple(c) = rgbtuple(Colors.RGB(c))

"""
$(SIGNATURES)

Create color tuple from  RGB color.

```jldoctest
julia> rgbtuple(RGB(0.0,1,0))
(0.0, 1.0, 0.0)
```
"""
rgbtuple(c::Colors.RGB) = (Colors.red(c), Colors.green(c), Colors.blue(c))
