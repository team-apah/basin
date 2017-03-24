#!/bin/bash

# Setup ======================================================================

GRASS_COMMAND='grass72'

THRESHOLD='20000'
TILE_DIR='wotus_tiles'
RESIZE=8

# Reference Coordinate System
REFERENCE='epsg:4269' # aka NAD 83
# https://en.wikipedia.org/wiki/North_American_Datum

# Create Data Directory and cd into it
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME_NAME='data'
export HOME="$SCRIPT_DIR/$HOME_NAME"
mkdir -p $HOME; cd $HOME

# Log
if [ "$1" != "--gui" ]
then
    exec > >(tee -i logs/$(date +"%Y_%m_%d_%H_%M_%S")'.log')
    exec 2>&1
    date
    FILES=$(find $1 -name '*.img' | xargs realpath)
fi

export GISDBASE="$HOME/grassdata"
export GISRC="$HOME/.grassrc"
LOCATION='generate_location'
MAPSET='generate_mapset'

#generate GISRCRC
echo "GISDBASE: $GISDBASE" > "$GISRC"
echo "LOCATION_NAME: $LOCATION" >> "$GISRC"
echo "MAPSET: $MAPSET" >> "$GISRC"
echo "GRASS_GUI: text" >> "$GISRC"

#For the temporal modules
export TGISDB_DRIVER=sqlite
export TGISDB_DATABASE="$GISDBASE/$LOCATION/PERMANENT/tgis/sqlite.db"

# path to GRASS binaries and libraries:
export GISBASE="/opt/grass"

export GRASS_PYTHON="$GISBASE/bin/python"
export GRASS_MESSAGE_FORMAT=plain
export GRASS_TRUECOLOR=TRUE
export GRASS_TRANSPARENT=TRUE
export GRASS_PNG_AUTO_WRITE=TRUE
export GRASS_GNUPLOT='gnuplot -persist'
export GRASS_WIDTH=640
export GRASS_HEIGHT=480
export GRASS_HTML_BROWSER=firefox
export GRASS_PAGER=cat
export GRASS_WISH=wish
        
export PATH="$GISBASE/bin:$GISBASE/scripts:$PATH"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GISBASE/lib"
export PYTHONPATH="$GISBASE/etc/python:$PYTHONPATH"
export MANPATH=$MANPATH:$GISBASE/man

# use process ID (PID) as lock file number:
export GIS_LOCK=$$

# Action =====================================================================

# Create mapset if it doesn't exist
LOCATION_PATH="$GISDBASE/$LOCATION"
MAPSET_PATH="$LOCATION_PATH/$MAPSET"
if [ ! -d $GISDBASE ]
then
    mkdir -p $GISDBASE
    $GRASS_COMMAND -text -c "$REFERENCE" "$LOCATION_PATH" -e
    $GRASS_COMMAND -text -c "$MAPSET_PATH" -e
fi

if [ "$1" = "--gui" ]
then
    $GRASS_COMMAND -gui "$MAPSET_PATH"
    exit
fi

# Print Version
g.version

date

# Import DEMs
echo " ========== Importing =========="
for i in $FILES
do
    printf ' ----- "%s"\n' "$i"
    name=orginal_$(basename "$i" '.img')
    r.in.gdal input="$(realpath $i)" output="$name"
done

date
# Merge DEMs into master DEM
echo " ========== Merge =========="
export MAPS=`g.list type=raster sep=, pat="orginal_*"` 
g.region rast="$MAPS" -p
r.patch --overwrite in="$MAPS" out="raw_master"

## Resize Master
#echo " ========== Resize =========="
##master_info="$(r.info -g raw_master)"
##master_rows=$(echo "$master_info" | grep -o 'rows.*$' | grep -o '[0-9]\+')
##master_cols=$(echo "$master_info" | grep -o 'cols.*$' | grep -o '[0-9]\+')
##master_rows=$(expr $master_rows / $RESIZE)
##master_cols=$(expr $master_cols / $RESIZE)
#g.region rast=raw_master -p
#r.resamp.rst\
#    input=raw_master\
#    ew_res=60\
#    ns_res=60\
#    elevation=scaled_master

date
# Fill master
echo " ========== Fill =========="
echo " = THIS WILL PROBABLY TAKE A WHILE!"
echo " =========================="
r.fill.dir\
    --overwrite\
    input="raw_master"\
    output="master"\
    direction="direction"\
    areas="fill_problems"

# Get Flow Accumulation
date
echo " ========== Flow Accumulation =========="
r.watershed ele=master acc=accumulation

# WOTUS
date
echo " ========== WOTUS Determine =========="
# Determine
r.mapcalc \
    --overwrite\
    expression="wotus=if(accumulation > $THRESHOLD, 1, if(accumulation >= 0, null(), 0))"

# Apply Colors
WOTUS_COLORS="$HOME/wotus_colors"
echo '0 255:0:0' > $WOTUS_COLORS # Error
echo '1 0:0:0' >> $WOTUS_COLORS # WOTUS

r.colors\
    rules="$WOTUS_COLORS"\
    map=wotus

date
echo " ========== EXPORT =========="
r.out.gdal input=wotus output=wotus.gtiff

date
echo " ========== TILES GENERATION =========="
gdal_translate -of vrt -expand rgba wotus.gtiff temp.vrt
gdal2tiles.py -v -w leaflet temp.vrt $TILE_DIR

echo " ========== DONE =========="
date

# Cleanup ====================================================================
sleep 1

# run GRASS' cleanup routine
$GISBASE/etc/clean_temp

# remove session tmp directory:
rm -rf /tmp/grass6-$USER-$GIS_LOCK
