# Cahokia
Backend Server for [WotUS Map](https://wotus.isg.siue.edu).
It uses [GRASS GIS](https://grass.osgeo.org/) and
[Geoserver](https://geoserver.org/) to give an idea of what land would fall
under environmental regulations depending on the amount of water flowing
though it on average.

## Prerequisites
* Cahokia assumes a "standard" Linux Distribution.
    * It specifically was developed on Arch Linux for use on CentOS and Ubuntu.
    Problems on Arch Linux prevent Geoserver part of the stack from working
    under Apache user "httpd" for unknown reasons.
    * In addition to GNU bash and GNU Coreutils, Commands used:
        * `grep`
        * `wget`
        * `curl`
        * `flock`
* GRASS 7.2
    * This can probably use later versions or maybe even earlier versions of 7,
but this would require at least modification of `grass_eviroment.sh`.
It might also have to be modified based on where GRASS directory was placed when it was installed.
* A DEM and Accumulation Rasters of the desired area.
    * This is covered in [Generating an Accumulation Raster](doc/accumulation.md).
* For the full stack to work you need a Apache httpd Server that is PHP enabled.
    * For consideration of WotUS Map as a Server, see
[WotUS Setup](https://github.com/team-apah/wotus_setup).
    
## Documentation

[Server API](doc/cahokia_api.md)

[Generating an Accumulation Raster](doc/accumulation.md)

[Generating a WotUS Raster Mannually](doc/manual_invocation.md)

## The Other Repositories

[Frontend Repository](https://github.com/team-apah/map)

[Regular and Docker Setup Scripts](https://github.com/team-apah/wotus_setup)

