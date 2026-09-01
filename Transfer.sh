#!/bin/bash

# same logic for looking at valide argument as in Splitter.sh
TOPDIR=$(realpath $1)

STARING_DIR=$(pwd)

if [ $# -ne 1 ]; then
    echo "Exectly one argument is required: the path to the top directory of the HIJING files." >&2
    exit 1
fi

if [ ! -d "$TOPDIR" ]; then
    echo "The provided path is not a directory." >&2
    exit 1
fi

if [[ $TOPDIR == */ ]]; then
    TOPDIR="${TOPDIR%/}"
fi

find "$TOPDIR" -type f -name "HIJING_LBF_test_small.root" -delete # delete existing root files (problem wiht cical naming in root files)

while read dir; do 
    {
        cd "$dir"
        while read file; do 
            # Call the ROOT macro to import the ASCII file into a TTree
            root -l -b -q "$STARING_DIR/importASCIIfileIntoTTree.C(\"$(basename "$file")\", \"$dir\")" > /dev/null

        done < <(find "$dir" -name "event_*.dat" -type f -print) # gets the output of the find command and inputs it into the stdin of the loop
    } &
done < <(find "$TOPDIR" -mindepth 1 -type d -print) # gets the output of the find command and inputs it into the stdin of the loop

wait # wait for all background processes to finish before continuing

find "$TOPDIR" -type f -name "event_*.dat" -delete # delete the event_*.dat files after they have been imported into the root files

cd "$STARING_DIR"

exit 0