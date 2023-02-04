using Test, Documenter, GridVisualizeTools, ColorTypes

DocMeta.setdocmeta!(GridVisualizeTools, :DocTestSetup, :(using GridVisualizeTools, ColorTypes); recursive = true)
doctest(GridVisualizeTools)
