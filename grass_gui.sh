#!/bin/bash
source grass_enviroment.sh
$GRASS_COMMAND -f -gui "$MAPSET_PATH"
grass_cleanup
