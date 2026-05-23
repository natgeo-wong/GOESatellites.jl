using GOESatellites
using Documenter
using DocumenterVitepress

makedocs(;
    modules  = [GOESatellites],
    authors  = "Nathanael Wong <natgeo.wong@outlook.com>",
    sitename = "GOESatellites.jl",
    doctest  = false,
    warnonly = true,
    format   = DocumenterVitepress.MarkdownVitepress(
        repo="github.com/natgeo-wong/GOESatellites.jl",
        devbranch="main",
        devurl = "dev"
    ),
    pages=[
        "Home" => "index.md",
        "API"  => "api.md",
    ],
)
# and for deploying use

DocumenterVitepress.deploydocs(;
    repo="github.com/natgeo-wong/GOESatellites.jl",
    target = joinpath(@__DIR__, "build"),
    branch = "gh-pages",
    devbranch="main",
    push_preview = true,
)