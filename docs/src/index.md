```@raw html
---
layout: home

hero:
  name: "GOESatellites.jl"
  text: "Managing GOES Datasets in Julia"
  tagline: Download and manipulate datasets from the Geostationary Operational Environmental Satellites.
  image:
    src: /logo.png
    alt: GOES
  actions:
    - theme: brand
      text: Getting Started
      link: /basics
    - theme: alt
      text: Datasets
      link: /datasets/intro
    - theme: alt
      text: Tutorials
      link: /using/download
    - theme: alt
      text: View on Github
      link: https://github.com/natgeo-wong/GOESatellites.jl

features:
  - title: Simple and Intuitive
    details: GOESatellites.jl aims to be simple and intuitive to the user, with basic functions like `download()` and `read()`.
  - title: Region of Interest
    details: You don't have to download the whole spatial dataset - GOESatellites.jl will subset for your (Geo)Region of interest, saving you time and disk space for small domains.
  - title: Comprehensive
    details: GOESatellites.jl supports hourly, daily, and monthly ERA5 products for both single-level and pressure-level variables.
---
```

## Introduction

GOESatellites.jl builds upon the [GeoRegions Ecosystem](https://github.com/GeoRegionsEcosystem) to streamline the following processes:
* downloads of GOES datasets using Amazon Web Services S3 protocols
* basic analysis of said datasets
* perform all the above operations innately over a given geographical region using the [GeoRegions.jl](https://github.com/GeoRegionsEcosystem/GeoRegions.jl) package

## Installation Instructions

The latest version of GOESatellites.jl can be installed using the Julia package manager (accessed by pressing `]` in the Julia command prompt)
```julia-repl
julia> ]
(@v1.10) pkg> add GOES
```

You can update `GOESatellites.jl` to the latest version using
```julia-repl
(@v1.10) pkg> update GOES
```

And if you want to get the latest release without waiting for me to update the Julia Registry (although this generally isn't necessary since I make a point to release patch versions as soon as I find bugs or add new working features), you may fix the version to the `main` branch of the GitHub repository:
```julia-repl
(@v1.10) pkg> add GOES#main
```

## Getting help
If you are interested in using `GOESatellites.jl` or are trying to figure out how to use it, please feel free to ask me questions and get in touch!  Please feel free to [open an issue](https://github.com/natgeo-wong/GOESatellites.jl/issues/new) if you have any questions, comments, suggestions, etc!
