using Test, Documenter, GridVisualizeTools, ColorTypes, Colors

DocMeta.setdocmeta!(GridVisualizeTools, :DocTestSetup, :(using GridVisualizeTools, ColorTypes, Colors); recursive = true)
doctest(GridVisualizeTools)

if isdefined(Docs, :undocumented_names) # >=1.11
    @testset "UndocumentedNames" begin
        @test isempty(Docs.undocumented_names(GridVisualizeTools))
    end
end
