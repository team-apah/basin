export PATH="$HOME/bin:$PATH"

# Geoserver Login
export GEOSERVER_USERNAME="admin"
export GEOSERVER_PASSWORD="geoserver"

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

# Queue
export COMPLETED="$DATA_DIR/completed"
export QUEUE_FILE="$DATA_DIR/queue"
export QUEUE_LOCK="$DATA_DIR/queue_lock"
export MAX_WAIT_TIME=15
export PROCESS_INTERVAL=1
