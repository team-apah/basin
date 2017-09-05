#!/bin/bash

# Returns
#      1 if the arguments are invalid
#      2 if a lock couldn't be established
#     10 if the argument is already queued

export QUEUE_FILE='queue'
export QUEUE_LOCK='queue_lock'
export MAX_WAIT_TIME=15
export PROCESS_INTERVAL=1

function print_help {
    echo 'queue.sh:'
    echo '    serve'
    echo '         Serve as the queue processer.'
    echo '    add VALUE'
    echo '         Add VALUE to the queue.'
    echo '    -h'
    echo '         Print this message.'
}

set -e

# Create Queue File
if [ ! -f $QUEUE_FILE ]
then
    touch $QUEUE_FILE
fi

# Check for no Arguemnts
if [ $# -eq 0 ]
then
    print_help 1>&2
    exit 1
fi

# Check for help arguemnt
if [ "$1" = '-h' ]
then
    print_help
    exit 0
fi

# Check for add arguemnt
if [ "$1" = 'add' ] 
then
    # Check for second arguemnt to add to queue
    if [ $# -ne 2 ]
    then
        print_help 1>&2
        exit 1
    fi

    (
        # Get Lock on queue
        if flock -x -w $MAX_WAIT_TIME 255
        then
            exit 2
        fi
        # Check if the value is in the queue file
        if grep "^$1\$" $QUEUE_FILE &> /dev/null
        then
            exit 10
        else # Queue the argument
            echo "$1" >> $QUEUE_FILE
        fi
    ) 255>$QUEUE_LOCK
    exit $?
fi

# Check for add arguemnt
if [ "$1" = 'serve' ] 
then
    # Clean up
    trap '{ echo "Process Interupted" ; rm -f $QUEUE_LOCK; exit 1; }' INT

    for (( ; ; ))
    do
        queue="$(cat $QUEUE_FILE)" # Get Queue Contents
        queue_size=$(wc -l < $QUEUE_FILE) # Get Queue Size
        if [ $queue_size -gt 0 ] # If the queue has items
        then # Process the queue head
            item=$(echo "$queue" | head -n 1)

            bash wotus.sh $item

            # Remove Head from queue (As an atomic operation)
            (
                flock -x -w $MAX_WAIT_TIME 255 # Get Lock on Queue
                # Get current queue
                queue="$(cat $QUEUE_FILE)"
                # Write back rest of queue except for head
                echo "$queue" | tail -n +2 > $QUEUE_FILE
            ) 255>$QUEUE_LOCK
        fi
        sleep $PROCESS_INTERVAL
    done
fi
