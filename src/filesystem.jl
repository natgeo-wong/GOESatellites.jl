"""
    gdsfnc(
        gds :: GOESDataset,
        dt  :: TimeType,
        hr  :: Int,
        ii  :: Int
    ) -> String

Returns of the path of the file for the GOES dataset specified by `gds` for a GeoRegion specified by `geo` at a date specified by `dt`.

Arguments
=========
- `gds` : a `GOESDataset` specifying the dataset details and date download range
- `dt` : a `TimeType` specifying the date for which to retrieve data
- `hr` : an `Int` specifying the hour for which to retrieve data
- `ii` : an `Int` specifying the step for which to retrieve data
"""
function gdsfnc(
    gds :: GOESDataset,
    dt  :: TimeType,
    hr  :: Int,
    ii  :: Int
)

    fol = joinpath(gds.path,gds.sectorID,yrmo2dir(dt))
    fnc = "GOES$(gds.satellite)" * "-" * gds.product * "-" * gds.sectorID * "-" *
          ymd2str(dt) * "T" * @sprintf("%02d",hr) * "-step" * @sprintf("%02d",ii) * ".nc"
    return joinpath(fol,fnc)

end

"""
    gdsfnc(
        gds :: GOESDataset,
        geo :: GeoRegion,
        var :: String,
        dt  :: TimeType
    ) -> String

Returns of the path of the file for the GOES dataset specified by `gds` for a GeoRegion specified by `geo` at a date specified by `dt`.

Arguments
=========
- `gds` : a `GOESDataset` specifying the dataset details and date download range
- `geo` : a `GeoRegion` (see [GeoRegions.jl](https://github.com/JuliaClimate/GeoRegions.jl)) that sets the geographic bounds of the data array in lon-lat
- `var` : a `String` specifying the variable of interest
- `dt`  : A specified date. The NCDataset retrieved may will contain data for the date, although it may also contain data for other dates depending on the `GOESDataset` specified by `gds`
"""
function gdsfnc(
    gds :: GOESDataset,
    geo :: GeoRegion,
    var :: String,
    dt  :: TimeType
)

    fol = joinpath(gds.path,geo.ID,yrmo2dir(dt))
    fnc = "GOES$(gds.satellite)" * "-" * gds.product * "-" * geo.ID * "-" * 
           var * "-" * ymd2str(dt) * ".nc"
    return joinpath(fol,fnc)

end