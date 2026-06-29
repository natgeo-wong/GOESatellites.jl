module GOESatellites

## Base Modules Used
using DelimitedFiles
using Logging
using Printf
using Statistics

import Base: show, read, download
import RegionGrids: RegionGrid, nearest, extract

## Modules Used
using AWS
using AWSS3
using Glob
using JLD2
using JSON
using PrettyTables
using RegionGrids

## Reexporting exported functions within these modules
using Reexport
@reexport using Dates
@reexport using NCDatasets
@reexport using GeoRegions

## Exporting the following functions:
export
        GOESDataset, GOESDetails, GOEStemplate,

        download, read, grid, extract,
        RegionGrid, nearest,

        tableGOESDatasets, tableGOESVariables, tableGOESSatellites

## Abstract Types

abstract type GOESDataset end
abstract type GOESVariable end

## GOES.jl setup and logging preface

modulelog() = "$(now()) - GOES.jl"
goesdir = joinpath(@__DIR__,".files")
goespath(path) = splitpath(path)[end] !== "GOES" ? joinpath(path,"GOES") : path

## Including Relevant Files

include("dataset.jl")
include("grid.jl")
include("download.jl")
include("extract.jl")
include("save.jl")
include("read.jl")
include("list.jl")
include("filesystem.jl")
# include("tables.jl")
include("backend.jl")

end
