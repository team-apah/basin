# Include commands
export PATH="$HOME/bin:$PATH"

# Reference Coordinate System
export GEO_REFERENCE='EPSG:4269' # aka NAD 83
# https://en.wikipedia.org/wiki/North_American_Datum

# Locations
export DATA_DIR="$HOME/data"
mkdir -p $DATA_DIR
export WOTUS_DIR="$DATA_DIR/wotus"
mkdir -p $WOTUS_DIR
export LOGS_DIR="$DATA_DIR/logs"
mkdir -p $LOGS_DIR

# Load Extra Configuration From File
eval "$(read_config defaults.json $DATA_DIR/config.json)"

# Mark as being the cahokia enviroment
export CAHOKIA=true
