function listall(
    path :: AbstractString = homedir(),
    warn :: Bool = false
)

    IDs    = []
    goespaths = []

    IDs,goespaths = fillinfo(IDs,goespaths,goesdir,warn)
    IDs,goespaths = fillinfo(IDs,goespaths,goespath(path),warn)

    return IDs,goespaths

end

function fillinfo(IDs,goespaths,goespath,warn)

    IDvec = replace.(basename.(glob("*.json",goespath)),".json"=>"")
    nID   = length(IDvec)

    isempty(IDvec) && warn ? (@warn "$(modulelog()) - No custom GOES Datasets are available in $goespath, please check to ensure the path specified is correct.") : nothing
    flush(stderr)

    return vcat(IDs,IDvec),vcat(goespaths,fill(goespath,nID))

end