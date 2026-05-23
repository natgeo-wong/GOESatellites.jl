"""
    download(
        gds   :: GOESDataset;
		start :: Date = gds.start,
		stop  :: Date = gds.stop,
	    overwrite :: Bool = false
    ) -> nothing

Downloads a GOES dataset specified by `gds`. All available variables and data in the dataset will be downloaded (the file will be renamed according to GOES.jl filename conventions).

For the option to subset only specific variables of interest, see the other `download()` method function.

Arguments
=========
- `gds` : A `GOESDataset` specifying the dataset details and default date download range (which can be overridden by the `start` and `stop` keyword arguments)

Keyword Arguments
=================
- `start` : A `Date` specifying the start date for the data query
- `stop` : A `Date` specifying the end date for the data query
- `overwrite` : If `true`, overwrite any existing files
"""
function download(
	gds   :: GOESAmazon;
	start :: Date = gds.start,
	stop  :: Date = gds.stop,
	overwrite :: Bool = false
)

	@info "$(modulelog()) - Establishing AWS connection credentials and region ..."
	aws = AWSConfig(; creds=nothing, region="us-east-1")

	@info "$(modulelog()) - Downloading GOES-$(gds.satellite) $(gds.product) data from $(start) to $(stop)"

	for dt in start : Day(1) : stop

		yr = year(dt)
		doy = dayofyear(dt)
		
		for hr = 0 : 23

			prefix = "$(gds.product)$(gds.sectorID)/$yr/$(@sprintf("%03d",doy))/$(@sprintf("%02d",hr))/"

			keys = s3_list_objects(aws,gds.bucket,prefix)
			for (ii, obj) in enumerate(keys)
				fnc = gdsfnc(gds,dt,hr,ii)
				fol = dirname(fnc); if !isdir(fol); mkpath(fol) end
				if overwrite || !isfile(fnc)
					s3_get_file(aws,gds.bucket,obj["Key"],fnc)
				else
					@info "$(modulelog()) - GOES-$(gds.satellite) $(gds.product) data in $(gds.sector) for $(dt)T$(hr)-step$(ii) exists in $(fnc), and we are not overwriting, skipping to next timestep ..."
				end
			end
		
		end

		flush(stderr)

	end

end

"""
    download(
        gds   :: GOESDataset;
		start :: Date = gds.start,
		stop  :: Date = gds.stop,
	    overwrite :: Bool = false
    ) -> nothing

Downloads a GOES dataset specified by `gds` for a GeoRegion specified by `geo` and variable specified by `gvar`. This method also allows for data compression in chunks for NetCDF in order to save disk space where possible, and compiles data for every individual day.

Arguments
=========
- `gds` : A `GOESDataset` specifying the dataset details and default date download range (which can be overridden by the `start` and `stop` keyword arguments)
- `geo` : A `GeoRegion` specifying the geographic region for which to retrieve data
- `gvar` : A `String` specifying the variable of interest to retrieve

Keyword Arguments
=================
- `start` : A `Date` specifying the start date for the data query
- `stop` : A `Date` specifying the end date for the data query
- `overwrite` : If `true`, overwrite any existing files
- `NT` : The data type for `gvar`
"""
function download(
	gds   :: GOESAmazon,
	geo   :: GeoRegion,
	gvar  :: String;
	start :: Date = gds.start,
	stop  :: Date = gds.stop,
	overwrite :: Bool = false,
	NT = Float32
)

	@info "$(modulelog()) - Establishing AWS connection credentials and region ..."
	aws = AWSConfig(; creds=nothing, region="us-east-1")

	@info "$(modulelog()) - Downloading GOES-$(gds.satellite) $(gds.product) data for $(gvar) in the $(geo.name) GeoRegion from $(start) to $(stop)"
	lon,lat = grid(gds); ntlon,ntlat = size(lon)
	ggrd  = RegionGrid(geo,Point2.(lon,lat)); nlon,nlat = size(ggrd.lon)
	
	@info "$(modulelog()) - Preallocating temporary and final data arrays ..."
	tdata = zeros(NT,ntlon,ntlat)
	vdata = zeros(Float32,nlon,nlat,288)
	t     = zeros(DateTime,288)
	vdict = Vector{Dict}(undef,2)

	for dt in start : Day(1) : stop

		fnc = gdsfnc(gds,geo,gvar,dt)
		jj = 0
		if overwrite || !isfile(fnc)

			yr = year(dt)
			dy = dayofyear(dt)
			for hr = 0 : 23

				prefix = "$(gds.product)$(gds.sectorID)/$yr/$(@sprintf("%03d",dy))/$(@sprintf("%02d",hr))/"
				keys = s3_list_objects(aws,gds.bucket,prefix)
				for obj in keys
					jj += 1
					tfnc = joinpath(gds.path,"tmp-$yr-$dy.nc")
					s3_get_file(aws,gds.bucket,obj["Key"],tfnc)
					ds = NCDataset(tfnc)
					NCDatasets.load!(ds[gvar].var,tdata,:,:); vdict[1] = Dict(ds[gvar].attrib)
					iit   = @view t[jj]; iit .= ds["t"][:]; vdict[2] = Dict(ds["t"].attrib)
					extract!(view(vdata,:,:,jj),tdata,ggrd)
					close(ds)
					rm(tfnc,force=true)
   			 	end
			
			end

			flush(stderr)
			if jj < 288
				vdata[:,:,(jj+1):end] .= NaN
				t[(jj+1):end] .= DateTime(2000,1,1,0,0,0)
			end
			if !iszero(jj)
				save(vdata,t,gvar,dt,gds,geo,ggrd,vdict)
			else
				@info "$(modulelog()) - There is no GOES-$(gds.satellite) $(gds.product) data for $(gvar) in the $(geo.name) GeoRegion during $(dt), skipping to next timestep ..."
			end

		else

			@info "$(modulelog()) - GOES-$(gds.satellite) $(gds.product) data for $(gvar) in the $(geo.name) GeoRegion during $(dt) exists in $(fnc), and we are not overwriting, skipping to next timestep ..."

		end

	end

end