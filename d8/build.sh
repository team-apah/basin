#!/bin/bash

execute_path="./build/bin/basin_d8"
# Default options
force_option=false
run_option=false

function error { echo >&2 "$@"; exit 1; }

function join { local IFS="$1"; shift; echo "$*"; }

function require {
    declare -a missing_programs
    for i in "$@"
    do
        if ! command -v $i >/dev/null 2>&1
        then
            missing_programs=("${missing_programs[@]}" "$i")
        fi
    done
    if [ "${#missing_programs[@]}" -gt 0 ]
    then
        error 'Exiting becuase the following programs are required by this script, but do not appear to be installed: '$(join , "${missing_programs[@]}")
    fi
}

require cmake make

function print_help {
    echo "Agaru bash build script"
    echo "    Runs 'make' if the build directory exists, else make it,"
    echo "    run cmake, then 'make'."
    echo "Options:"
    echo " -h --help    Print this dialog"
    echo " -f --force   Recreate build directory"
    echo " -r --run     Runs the program. The rest of the arguments being passed to it"
    exit 0
}

# Parse Arguments
while [ $# -gt 0 -a "$run_option" = false ]
do
    key="$1"
    case $key in
        -h|--help)
            print_help
            ;;
        -f|--force)
            force_option=true
            ;;
        -r|--run)
            run_option=true
            ;;
        *)
            ;;
    esac
    shift
done
            
if [ "$force_option" = true -a -d "build" ]
then
    rm -fr build
fi

if [ ! -d "build" ]
then
    mkdir -p build
    cd build
    if ! cmake -DCMAKE_BUILD_TYPE=Debug ..
    then
        error "CMake failed, please correct the problem and use \"build.sh -f\" to run again" 
    fi
    make
else
    cd build
    make
fi

cd ..

if [ "$run_option" = true -a -x "$execute_path" ]
then
    $execute_path $@
fi

