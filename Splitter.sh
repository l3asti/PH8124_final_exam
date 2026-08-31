#!/bin/bash

# save the path for the top dir of the HIJING files
# save the absolute path of the top directory
TOPDIR=$(realpath $1)

STARING_DIR=$(pwd)

# check if at least one argument is provided
if [ $# -ne 1 ]; then
    echo "Exectly one argument is required: the path to the top directory of the HIJING files." >&2
    exit 1
fi

# check if provided path is a directory
if [ ! -d "$TOPDIR" ]; then
    echo "The provided path is not a directory." >&2
    exit 1
fi


# iff neccersery remove / from input argument to not get TOPDIR//*
if [[ $TOPDIR == */ ]]; then
    TOPDIR="${TOPDIR%/}"
fi

# loop throug all sup diractory 
# find all sub directery and count the lines of the output
n_SUBDIRS=$(find "$TOPDIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
if [[ $n_SUBDIRS -ne 10 ]]; then
    echo "Data not complet or too many sub directories. Expected 10 sub directories, found $n_SUBDIRS." >&2
    exit 1
fi
for dir in "$TOPDIR"/*; do
    if [ -d "$dir" ]; then
        # check if HIJING_LBF_test_small.out exists in the subdirectory
        if [ ! -e "$dir/HIJING_LBF_test_small.out" ]; then
            echo "No HIJING_LBF_test_small.out found in $dir" >&2
            exit 1
        fi

        # spliting of individual files
        cd "$dir"
        # echo "Processing directory: $dir"


        # gets the line number and the privious line number and prints it in a temp file
        # after the file gets read and each line calls sed to spilit the file 
        awk '
            /BEGINNINGOFEVENT/ {
                if (prev != "")
                    print event, prev, NR 

                prev = NR + 1
                event++
            }
            END {
                if (prev != "")
                    print event, prev, NR
            }
            ' HIJING_LBF_test_small.out |
            while read -r event start_line end_line; do
                sed -n "${start_line},${end_line}p" HIJING_LBF_test_small.out > "event_${event}.dat"
            done
    fi

    # return to the starting directory
    cd "$STARING_DIR"
done