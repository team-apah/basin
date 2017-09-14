#!/bin/bash

# Given a valid GRASS Environment with a finished accumulation Raster,
# Create a colored map highlighted where the flow value exceeds the
# argument

# CD into Data Directory as $HOME
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME_NAME='data'
export HOME="$SCRIPT_DIR/$HOME_NAME"
cd $HOME

# Enable Log
mkdir -p logs
exec > >(tee -i logs/$(date +"%Y_%m_%d_%H_%M_%S")'.log')
exec 2>&1
date

# Set Up Environment
source ../grass_enviroment.sh

# Create new raster with Wotus Value
date
echo " ========== WOTUS Determine =========="
echo " ========== $1"
EXPR="wotus_$1=if(accumulation > $1, 1, if(accumulation >= 0, null(), 0))"
echo $EXPR
r.mapcalc \
    --overwrite\
    expression="$EXPR"

# Apply Colors to new map
#WOTUS_COLORS="$HOME/tmp/wotus_colors"
#echo "0 $WOTUS_COLOR" > $WOTUS_COLORS # Error
#echo "1 $WOTUS_COLOR" >> $WOTUS_COLORS # WOTUS
#r.colors\
#    rules="$WOTUS_COLORS"\
#    map=wotus_$1

# Export to TIFF
date
echo " ========== EXPORT =========="
r.out.gdal\
    --overwrite\
    input=wotus_$1\
    output=tmp/wotus_$1.gtiff
#gdal_translate -expand rgba tmp/_wotus_$1.tif tmp/wotus_$1.tif

mv tmp/wotus_$1.gtiff .
# Generate tiles for Leaflet
#date
#echo " ========== TILES GENERATION =========="
#gdal2tiles.py -v -w leaflet tmp/temp_$1.vrt $WOTUS_MAPS_DIR$1
#date

# Clean Up
grass_cleanup
