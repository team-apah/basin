#!/bin/bash

# Create Data Directory and cd into it
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME_NAME='data'
export HOME="$SCRIPT_DIR/$HOME_NAME"
mkdir -p $HOME

# Log
exec > >(tee -i logs/$(date +"%Y_%m_%d_%H_%M_%S")'.log')
exec 2>&1
date

cd $HOME
source grass_enviroment.sh

echo " ========== WOTUS Determine =========="
echo " ========== $1"
EXPR="wotus_$1=if(accumulation > $1, 1, if(accumulation >= 0, null(), 0))"
echo $EXPR
# Determine
r.mapcalc \
    --overwrite\
    expression="$EXPR"

# Apply Colors
WOTUS_COLORS="$HOME/wotus_colors"
echo "0 $WOTUS_COLOR" > $WOTUS_COLORS # Error
echo "1 $WOTUS_COLOR" >> $WOTUS_COLORS # WOTUS

r.colors\
    rules="$WOTUS_COLORS"\
    map=wotus_$1

date
echo " ========== EXPORT =========="
r.out.gdal\
    --overwrite\
    input=wotus_$1\
    output=wotus_$1.gtiff

date
echo " ========== TILES GENERATION =========="
gdal_translate -of vrt -expand rgba wotus_$1.gtiff temp_$1.vrt
gdal2tiles.py -v -w leaflet temp_$1.vrt $1'_'$TILE_DIR
date

grass_cleanup
