function save(
	data :: AbstractArray{NT,3},
	t    :: Vector{DateTime},
	gvar :: String,
	dt   :: TimeType,
	gds  :: GOESDataset,
	geo  :: GeoRegion,
	ggrd :: RegionGrid,
	dict :: Vector{Dict}
) where NT <: Real

	@info "$(modulelog()) - Saving GOES-$(gds.satellite) $(gds.product) data for $(gvar) in the $(geo.name) GeoRegion during $(dt)"

	fnc = gdsfnc(gds,geo,gvar,dt)
	if !isdir(dirname(fnc)); mkpath(dirname(fnc)) end
	if isfile(fnc)
		@info "$(modulelog()) - Overwrite stale NetCDF file $(fnc) ..."
        rm(fnc)
	end
	@info "$(modulelog()) - Creating NetCDF file $(fnc) ..."
	pds = NCDataset(fnc,"c",attrib = Dict(
        "naming_authority"     	 => "gov.nesdis.noaa",
		"Conventions"          	 => "CF-1.7",
		"Metadata_Conventions" 	 => "Unidata Dataset Discovery v1.0",
		"standard_name_vocabulary" => "CF Standard Name Table (v35, 20 July 2016)",
		"institution"          	 => "DOC/NOAA/NESDIS > U.S. Department of Commerce, National Oceanic and Atmospheric >Administration, National Environmental Satellite, Data, and Information Services>",
		"project"              	 => "GOES",
		"license"              	 => "Unclassified data.  Access is restricted to approved users only.",
		"processing_level"     	 => "National Aeronautics and Space Administration (NASA) L2",
		"production_data_source" => "Realtime"
    ))

	nlon,nlat = size(ggrd.lon)
	pds.dim["longitude"] = nlon
	pds.dim["latitude"]  = nlat
	pds.dim["time"]      = 288

	dict[1]["_FillValue"] = NT(dict[1]["_FillValue"])
	dict[2]["units"] = "minutes since 2000-01-01 00:00:00"

	nclon = defVar(pds,"longitude",Float32,("longitude","latitude"),attrib = Dict(
	    "units"         => "degrees_east",
	    "standard_name" => "longitude",
	))

	nclat = defVar(pds,"latitude",Float32,("longitude","latitude"),attrib = Dict(
	    "units"         => "degrees_north",
	    "standard_name" => "latitude",
	))

	ncvar = defVar(pds,gvar,NT,("longitude","latitude","time"),chunksizes=(nlon,nlat,12),deflatelevel=5,attrib = dict[1])
	
	nct = defVar(pds,"time",Float64,("time",),attrib = dict[2])

	nclon[:,:] = ggrd.lon
	nclat[:,:] = ggrd.lat
	nct[:] = t
	ncvar.var[:,:,:] = data

	close(pds)

	@info "$(modulelog()) - GOES-$(gds.satellite) $(gds.product) data for $(gvar) in the $(geo.name) GeoRegion during $(dt) has been saved into $(fnc)"

end