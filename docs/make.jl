using Documenter, GridVisualizeTools, ColorTypes, Colors

function mkdocs()
    DocMeta.setdocmeta!(GridVisualizeTools, :DocTestSetup, :(using GridVisualizeTools, ColorTypes, Colors); recursive = true)
    makedocs(;
        sitename = "GridVisualizeTools.jl",
        modules = [GridVisualizeTools],
        clean = false,
        doctest = true,
        authors = "J. Fuhrmann",
        repo = "https://github.com/WIAS-PDELib/GridVisualizeTools.jl",
        pages = [
            "Home" => "index.md",
        ]
    )
    return if !isinteractive()
        deploydocs(; repo = "github.com/WIAS-PDELib/GridVisualizeTools.jl.git", devbranch = "main")
    end
end

mkdocs()
