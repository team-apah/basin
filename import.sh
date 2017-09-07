#!/bin/bash

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

FILES=$(find "$(realpath $1)" -name '*.img')

# Set Up Enviroment
source grass_enviroment.sh

# Import DEMs
date
echo " ========== Importing =========="
for i in $FILES
do
    printf ' ----- "%s"\n' "$i"
    name=orginal_$(basename "$i" '.img')
    r.in.gdal input="$(realpath $i)" output="$name"
done

# Merge DEMs into master DEM
date
echo " ========== Merge =========="
export MAPS=`g.list type=raster sep=, pat="orginal_*"` 
g.region rast="$MAPS" -p
r.patch --overwrite in="$MAPS" out="raw_master"

# Resize Master
# date
#echo " ========== Resize =========="
#master_info="$(r.info -g raw_master)"
#master_rows=$(echo "$master_info" | grep -o 'rows.*$' | grep -o '[0-9]\+')
#master_cols=$(echo "$master_info" | grep -o 'cols.*$' | grep -o '[0-9]\+')
#master_rows=$(expr $master_rows / $RESIZE)
#master_cols=$(expr $master_cols / $RESIZE)
# g.region rast=raw_master -p
# r.resamp.rst\
#     input=raw_master\
#     ew_res=60\
#     ns_res=60\
#     elevation=scaled_master

# Fill master
date
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

date
echo " ========== DONE =========="

grass_cleanup
