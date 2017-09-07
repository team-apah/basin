#!/bin/bash

# Given a valid GRASS Enviroment with a finished accumulation Raster,
# Create a colored map highlighted where the flow value exceeds the
# argumnet

# Create Data Directory and cd into it
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME_NAME='data'
export HOME="$SCRIPT_DIR/$HOME_NAME"
mkdir -p $HOME

# Enable Log
exec > >(tee -i logs/$(date +"%Y_%m_%d_%H_%M_%S")'.log')
exec 2>&1
date

# Set Up Enviroment
cd $HOME
source grass_enviroment.sh

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
WOTUS_COLORS="$HOME/wotus_colors"
echo "0 $WOTUS_COLOR" > $WOTUS_COLORS # Error
echo "1 $WOTUS_COLOR" >> $WOTUS_COLORS # WOTUS
r.colors\
    rules="$WOTUS_COLORS"\
    map=wotus_$1

# Export to TIFF
date
echo " ========== EXPORT =========="
r.out.gdal\
    --overwrite\
    input=wotus_$1\
    output=wotus_$1.gtiff

# Generate tiles for Leaflet
date
echo " ========== TILES GENERATION =========="
gdal_translate -of vrt -expand rgba wotus_$1.gtiff temp_$1.vrt
gdal2tiles.py -v -w leaflet temp_$1.vrt $1'_'$TILE_DIR
date

# Clean Up
grass_cleanup
