#!/bin/bash

# Open GRASS GIS GUI in the Cahokia/WotUS GRASS Enviroment

# Create Data Directory and cd into it
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME_NAME='data'
export HOME="$SCRIPT_DIR/$HOME_NAME"
mkdir -p $HOME
cd $HOME

# Set Up GRASS ENVIROMENT
source grass_enviroment.sh

# Run GRASS
$GRASS_COMMAND -f -gui "$MAPSET_PATH"

# Ceanup
grass_cleanup
