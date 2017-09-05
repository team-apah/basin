# Setup ======================================================================

GRASS_COMMAND='grass72'

TILE_DIR='wotus_tiles'
RESIZE=8
WOTUS_COLOR='255:102:255'

# Reference Coordinate System
REFERENCE='epsg:4269' # aka NAD 83
# https://en.wikipedia.org/wiki/North_American_Datum

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

# Cleanup ====================================================================
function grass_cleanup {
    sleep 1

    # run GRASS' cleanup routine
    $GISBASE/etc/clean_temp

    # remove session tmp directory:
    rm -rf /tmp/grass6-$USER-$GIS_LOCK
}
