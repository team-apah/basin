# HOME must be set to the parent of the data directory before this starts

source "$HOME/cahokia_enviroment.sh"

# Setup ======================================================================

export GRASS_COMMAND='grass72'

WOTUS_COLOR='255:102:255'

export GISDBASE="$DATA_DIR/grassdata"
export GISRC="$DATA_DIR/.grassrc"
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
if [ -d '/opt/grass' ]
then
    export GISBASE="/opt/grass"
elif [ -d '/lib64/grass72' ]
then
    export GISBASE="/lib64/grass72"
elif [ -d '/usr/lib/grass72' ]
then
    export GISBASE='/usr/lib/grass72'
else
    echo 'Couldn't find where GRASS's libraries are' 1>&2
    exit 1
fi

if [ -f "$GISBASE/bin/python" ]
then
    export GRASS_PYTHON="$GISBASE/bin/python"
fi

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
    $GRASS_COMMAND -text -c "$GEO_REFERENCE" "$LOCATION_PATH" -e
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

# Print Version
g.version

