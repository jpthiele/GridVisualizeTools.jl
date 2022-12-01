```@eval
using Markdown
Markdown.parse("""
$(read("../../README.md",String))
""")
```


## Color and colormaps

```@docs
region_cmap
```
```@example
region_cmap(5)
```


```@docs
bregion_cmap
```
```@example
bregion_cmap(5)
```

```@docs
rgbtuple
```

```@jldoctest
rgbtuple(:red)
# output

(1.0,1.0,1.0)
```

```@docs
ColorTypes.RGB
```

```@example
using ColorTypes,GridVisualizeTools # hide
RGB(:red)
```
```@example
using ColorTypes,GridVisualizeTools # hide
RGB("green")
```

## Visibility handling of grid cells

```@docs
extract_visible_cells3D
extract_visible_bfaces3D
```

## Marching triangles and tetrahdra
```@docs
marching_triangles
marching_tetrahedra
```

## Equidistant markers on polylines

```@docs
markerpoints
```

## Makeplanes
```@docs
makeplanes
```

```jldoctest
using GridVisualizeTools # hide
makeplanes([0.,0,0], [1.,1,1], [0.5], [],[])
# output
1-element Vector{Vector{Float64}}:
 [1.0, 0.0, 0.0, -0.5]
```

```jldoctest
using GridVisualizeTools # hide
makeplanes([0.,0,0], [1.,1,1], [0.5], [0.5],[])
# output
2-element Vector{Vector{Float64}}:
 [1.0, 0.0, 0.0, -0.5]
 [0.0, 1.0, 0.0, -0.5]
```
