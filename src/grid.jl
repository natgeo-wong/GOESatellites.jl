function grid(gds :: GOESDataset)

    if gds.satellite == 16 || gds.satellite == 19
        position = "east"
    elseif gds.satellite == 17 || gds.satellite == 18
        position = "west"
    end

    if gds.sectorID == "C"
        sector = "conus"
    elseif gds.sectorID == "F"
        sector = "fulldisk"
    elseif gds.sectorID == "M"
        error("$(modulelog()) - Coordinates for Mesoscale sectors are not uniquely defined and must be converted directly")
    end
    fzip = joinpath(gds.mask,"goes_$(position)-$(sector).zip")
    fnc  = joinpath(gds.mask,"goes_$(position)-$(sector).nc")
    if !isfile(fnc); downloadgrid(gds,fzip,fnc) end
    
    ds = NCDataset(fnc)
    lon = nomissing(ds["longitude"][:,:],NaN)
    lat = nomissing(ds["latitude"][:,:], NaN)
    close(ds)

    return lon,lat

end

function downloadgrid(
    gds  :: GOESDataset, 
    fzip :: AbstractString, 
    fnc  :: AbstractString
)

    @info "$(modulelog()) - Downloading the relevant longitude and latitude grid for GOES Satellite $(gds.satellite) and Sector $(gds.sector)"

    if gds.satellite == 16 || gds.satellite == 19
        position = 19
    elseif gds.satellite == 17 || gds.satellite == 18
        position = 18
    end

    if gds.sectorID == "C"
        sector = "conus"
    elseif gds.sectorID == "F"
        sector = "full_disk"
    end

    download("https://www.star.nesdis.noaa.gov/atmospheric-composition-training/documents/goes$(position)_abi_$(sector)_lat_lon.zip", fzip)

    fdir = dirname(fnc)
    run(`unzip $fzip -d $fdir`); rm(fzip,force=true)

    mv(joinpath(fdir,"goes$(position)_abi_$(sector)_lat_lon.nc"), fnc)

    return nothing

end

function RegionGrid(
    gds :: GOESDataset,
    geo :: GeoRegion
)

    gID = joinpath(gds.path,"$(gds.satellite)$(gds.sectorID)-$(geo.ID).jld2")
    if isfile(gID)
        return load_object(gID)
    else
        lon,lat = grid(gds)
        ggrd = RegionGrid(geo,Point2.(lon,lat))
        save_object(gID,ggrd)
        return ggrd
    end

end

function nearest(
    pnt :: Point2,
    gds :: GOESDataset;
    n   :: Int = 1
)

    glon,glat = grid(gds)
    glon = glon[:]
    glat = glat[:]
    gx = cosd.(glon) .* cosd.(glat)
    gy = sind.(glon) .* cosd.(glat)
    gz = sind.(glat)

    plon,plat = pnt[1],pnt[2]
    px = cosd.(plon) * cosd.(plat)
    py = sind.(plon) * cosd.(plat)
    pz = sind.(plat)

    if isone(n)
        return argmin(abs.((gx.-px).^2 .+ (gy.-py).^2 .+ (gz.-pz).^2))
    else
        return findall(≤(n),sortperm(abs.((gx.-px).^2 .+ (gy.-py).^2 .+ (gz.-pz).^2)))
    end

end