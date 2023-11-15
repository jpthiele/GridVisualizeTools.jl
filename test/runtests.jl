using Test, Documenter, GridVisualizeTools, ColorTypes, Colors

DocMeta.setdocmeta!(GridVisualizeTools, :DocTestSetup, :(using GridVisualizeTools, ColorTypes, Colors); recursive = true)
doctest(GridVisualizeTools)
