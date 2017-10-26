# Generating a Accumulation Raster

Before WotUS map can be used, there has to be a GRASS data directory setup
with a raster called "accumulation". This raster is a grid containing the
amount of water that flows though a location. Making this takes a hours for
a significant area, but once done, doesn't have to be done again. (Unless you
accidentally deleted it like I did while working on this).

## Getting the Digital Elevation Model

* As of writing IMG files of Digital Elevation Models (DEMs) can be found at
[https://viewer.nationalmap.gov/basic](USGS's National Map site):
    * Select "Elevation Products (3DEP)"
    * Select your desired resolution (greater resolution will
take much much longer to process but will be more detailed)
    * **IMPORTANT:** Select **IMG** File Format
    * Click "Find Products" and you should be able to choose from one degree
latitude by longitude area of the contiguous United States.

`PATH_TO_DEMS` is the path to directory containing the IMG DEM files.

**TODO**
