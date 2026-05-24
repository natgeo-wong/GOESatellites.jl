"""
    GOESAmazon{ST<:AbstractString, DT<:TimeType} <: GOESDataset

Specifies a downloadable (from Amazon Web Services) GOES (Geostationary Operational Environmental Satellite) dataset with the following fields:
* `satellite` : An `Int` specifying the satellite ID (valid satellites are GOES 16-19)
* `bucket`    : An `AbstractString` specifying the S3 bucket name (derived from the satellite ID)
* `product`   : An `AbstractString` specifying the product name
* `path`      : An `AbstractString` specifying the local directory path where data will be stored
* `mask`      : An `AbstractString` specifying the directory path for storing lon/lat mask files
* `sector`    : An `AbstractString` specifying the sector name
* `sectorID`  : An `AbstractString` specifying the sector ID
* `start`     : An `TimeType` specifying the default start date for the data query
* `stop`      : An `TimeType` specifying the default end date for the data query
"""
struct GOESAmazon{ST<:AbstractString, DT<:TimeType} <: GOESDataset
    satellite :: Int
    bucket    :: ST
    product   :: ST
    name      :: ST
    path      :: ST
    mask      :: ST
    sector    :: ST
    sectorID  :: ST
    start     :: DT
    stop      :: DT
end

"""
    GOESCustom{ST<:AbstractString, DT<:TimeType} <: GOESDataset

Specifies a custom GOES (Geostationary Operational Environmental Satellite) dataset calculated from available GOES data that can be downloaded using the `GOESAmazon` type:
* `satellite` : An `Int` specifying the satellite ID (valid satellites are GOES 16-19)
* `bucket`    : An `AbstractString` specifying the S3 bucket name (derived from the satellite ID)
* `product`   : An `AbstractString` specifying the product name
* `path`      : An `AbstractString` specifying the local directory path where data will be stored
* `mask`      : An `AbstractString` specifying the directory path for storing lon/lat mask files
* `sector`    : An `AbstractString` specifying the sector name
* `sectorID`  : An `AbstractString` specifying the sector ID
* `start`     : An `TimeType` specifying the default start date for the data query
* `stop`      : An `TimeType` specifying the default end date for the data query
"""
struct GOESCustom{ST<:AbstractString, DT<:TimeType} <: GOESDataset
    satellite :: Int
    bucket    :: ST
    product   :: ST
    name      :: ST
    path      :: ST
    mask      :: ST
    sector    :: ST
    sectorID  :: ST
    start     :: DT
    stop      :: DT
end

"""
    GOESDataset(
        product   :: ST;
        sector    :: ST = "F",
        satellite :: Int,
        path      :: ST = goespath(homedir()),
        verbose   :: Bool = false,
    ) where {ST <: AbstractString} -> GOESDataset{ST,DT}

Retrieve the details of a `GOESDataset` specification for querying and downloading GOES data.

Arguments
=========
* `product` : An `AbstractString` specifying the GOES Dataset identifier

Keyword Arguments
=================
* `sector`    : An `AbstractString` specifying the sector ID (e.g., "F" for Full Disk)
* `satellite` : An `AbstractString` specifying the satellite ID (e.g., 16 for GOES-16)
* `path`      : An `AbstractString` specifying the data directory path where downloaded data will be, with the default given by `goespath(homedir())`
* `verbose`   : If `true`, display additional logging output
"""
function GOESDataset(
    product   :: ST;
    sector    :: ST = "F",
    satellite :: Int,
    path      :: ST = goespath(homedir()),
    verbose   :: Bool = false,
) where {ST <: AbstractString}

    IDs,goespaths = listall(goespath(path),verbose)
    ii = findall(product.==IDs)[1]
    details = JSON.parse(read(joinpath(goespaths[ii],"$product.json"),String))

    checkvalid(details,satellite,sector)

    mask = joinpath(goespath(path),"mask");  if !isdir(mask); mkpath(mask) end
    path = joinpath(goespath(path),product); if !isdir(path); mkpath(path) end

    if details.aws

        return GOESAmazon{ST,Date}(
            satellite, "noaa-goes$satellite", product, details["name"], path, mask,
            sectorname(sector), sector,
            parse(Date,details["$satellite"]["sector"]["$sector"]["start"]),
            parse(Date,details["$satellite"]["sector"]["$sector"]["end"])
        )

    else

        return GOESCustom{ST,Date}(
            satellite, "noaa-goes$satellite", product, details["name"], path, mask,
            sectorname(sector), sector,
            parse(Date,details["$satellite"]["sector"]["$sector"]["start"]),
            parse(Date,details["$satellite"]["sector"]["$sector"]["end"])
        )

    end

end

"""
    GOEStemplate(
        product   :: ST;
        path      :: ST,
        overwrite :: Bool = false
    ) where {ST <: AbstractString}

Retrieve the details of a `GOESDataset` specification for querying and downloading GOES data.

Arguments
=========
* `product` : An `AbstractString` specifying the GOES Dataset identifier

Keyword Arguments
=================
* `path`      : An `AbstractString` specifying the data directory path where downloaded data will be, with the default given by `goespath(homedir())`
* `overwrite` : If `true`, overwrite existing dataset detail file in the `path`
"""
function GOEStemplate(
    product   :: ST;
    path      :: ST,
    overwrite :: Bool = false
) where {ST <: AbstractString}

    path = goespath(path)
    if !isfile(joinpath(path,"$product.json")) || overwrite
        cp(
            joinpath(goesdir,"template.json"), 
            joinpath(path,"$product.json")
        )
    else
        @warn "The .json details file for the $product Dataset already exists in $path, set overwrite=true to replace it"
    end
    return nothing

end

# """
#     GOESDataset(
#         product :: ST;
#         ID      :: Int,
#         path    :: ST = goespath(homedir()),
#     ) where {ST <: AbstractString} -> GOESDataset{ST,DT}

# Retrieve the details of a `GOESDataset` specification for querying and downloading GOES data.

# Arguments
# =========
# * `ID`      : An `Int` specifying the satellite ID (valid satellites are GOES 16-19)

# Keyword Arguments
# =================
# * `product` : An `AbstractString` specifying the product name
# * `path`    : An `AbstractString` specifying the data directory path where downloaded data will be, with the default given by `goespath(homedir())`
# """
# function GOESDataset(;
#     product :: ST,
#     name    :: ST,
#     path    :: ST = goespath(homedir()),
#     start   :: Date = Date(2000,1,1),
#     stop    :: Date = Date(2000,1,1)
# ) where {ST <: AbstractString}

#     mask = joinpath(goespath(path),"mask")
#     if !isdir(mask); mkpath(mask) end

#     path = joinpath(goespath(path),product)
#     if !isdir(path); mkpath(path) end

#     return GOESCustom{ST,Date}(
#         0, "N/A", product, name, path, mask,
#         "N/A", "N/A", start, stop
#     )

# end

function show(
    io  :: IO,
    gds :: GOESDataset
)

    print(io,
		"The GOES Dataset has the following properties:\n",
		"    Satellite ID (satellite) : ", gds.satellite, '\n',
		"    Bucket          (bucket) : ", gds.bucket, '\n',
		"    Product ID     (product) : ", gds.product, '\n',
		"    Product Sector  (sector) : ", gds.sector, '\n',
		"    Directory         (path) : ", gds.path, '\n',
		"    Mask Directory    (mask) : ", gds.mask, '\n',
		"    Date Begin       (start) : ", gds.start, '\n',
		"    Date End          (stop) : ", gds.stop , '\n',
	)

end

###

function checkvalid(
    details   :: JSON.Object,
    satellite :: Int,
    sector    :: AbstractString
)

    if !haskey(details, "$satellite")
        error("$(modulelog()) - GOES-$satellite did not produce the dataset $(details.ID)")
    end

    if !haskey(details["$satellite"]["sector"], "$sector")
        error("$(modulelog()) - GOES-$satellite does not have the $sector Sector defined for the $(details.ID) dataset")
    end

end

sectorname(sectorID :: AbstractString) = if sectorID == "C"
    return "CONUS"
elseif sectorID == "F"
    return "Full Disk"
elseif sectorID == "M"
    return "Mesoscale"
else
    error("$(modulelog()) - Sector ID not recognized")
end