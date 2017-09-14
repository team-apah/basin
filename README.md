# Cahokia
Backend Server for WotUS Map.
At its heart it uses [GRASS GIS](https://grass.osgeo.org/) to take
Digital Elevation Models from the USGS to produce simulated accumulation data
and in turn, the maps that mark a waterway being protected if it met a threshold
for amount of water flow.

[Main Website](https://wotus.isg.siue.edu)

[Frontend](https://github.com/team-apah/map)

[Server API](doc/cahokia_api.md)

## Manual Invocation

* This assumes:
    * A standard Linux Distribution
    * GRASS GIS 7.2 installed
    * `PATH_TO_DEMS` is the path to directory containing the IMG files.
    * `QVALUE` is the value threshold to highlight on the maps.

```
$ ./import PATH_TO_DEMS
...
$ ./wotus QVALUE
```

`wotus` can be run multiple times for each Q Value desired.

`./grass_gui` can be used to view the files through the GRASS GUI.
