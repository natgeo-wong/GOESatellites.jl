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
function extract(
	geo   :: GeoRegion,
	gds   :: GOESAmazon,
	gvar  :: String,
	pgeo  :: GeoRegion;
	start :: Date = gds.start,
	stop  :: Date = gds.stop,
	overwrite :: Bool = false,
)

	@info "$(modulelog()) - Extract GOES-$(gds.satellite) $(gds.product) data for $(gvar) in the $(geo.name) GeoRegion from $(pgeo.name) during $(start) to $(stop)"
	pgrd  = RegionGrid(gds,pgeo); ntlon,ntlat = size(pgrd.lon)
	ggrd  = RegionGrid(gds,geo)
	ggrd  = RegionGrid(geo,Point2.(pgrd.lon,pgrd.lat)); nlon,nlat = size(ggrd.lon)
	
	@info "$(modulelog()) - Preallocating temporary and final data arrays ..."
	tdata = zeros(Float32,ntlon,ntlat,288)
	vdata = zeros(Float32,nlon,nlat,288)
	t     = zeros(DateTime,288)
	vdict = Vector{Dict}(undef,2)

	flush(stderr)

	for dt in start : Day(1) : stop

		@info "$(modulelog()) - Extracting GOES-$(gds.satellite) $(gds.product) data for $(gvar) in the $(geo.name) GeoRegion from the $(pgeo.name) GeoRegion during $(dt)"; flush(stderr)
		tfnc = gdsfnc(gds,pgeo,gvar,dt)
		nfnc = gdsfnc(gds,geo,gvar,dt)
		
		if isfile(tfnc)
			
			if overwrite || !isfile(nfnc)

				ds = NCDataset(tfnc)
				NCDatasets.load!(ds[gvar].var,tdata,:,:,:); vdict[1] = Dict(ds[gvar].attrib)
				extract!(vdata,tdata,ggrd)
				t .= ds["time"][:]; vdict[2] = Dict(ds["time"].attrib)
				close(ds)

				save(vdata,t,gvar,dt,gds,geo,ggrd,vdict)

			else

				@info "$(modulelog()) - GOES-$(gds.satellite) $(gds.product) data for $(gvar) in the $(geo.name) GeoRegion during $(dt) exists in $(nfnc), and we are not overwriting, skipping to next timestep ..."

			end

		else

			@warn "$(modulelog()) - GOES-$(gds.satellite) $(gds.product) data for $(gvar) in the $(pgeo.name) GeoRegion during $(dt) does not exist in $(tfnc), and we are not overwriting, skipping to next timestep ..."

		end

	end

end