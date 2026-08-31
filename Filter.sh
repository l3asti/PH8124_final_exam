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



# find all the sub directories and starts a sub background procces for each
# filltes each event_*.dat for primary particles
while read dir; do
    echo "Processing directory: $dir"
    {   
        while read File; do 
        cd $(dirname "$File")

        # gets currend file number by replasing all non digits characters with nothing
        filenumber=$(basename "$File" | grep -o '[0-9]*')

        # makes a temp backup of the .dat files bevor filtering
        BackupFile="backup_${filenumber}.dat"
        cp $File $BackupFile

        awk '{if ($3 == 0) print $0}' < "$BackupFile" > "$File"



        done < <(find "$dir" -type f -name "event_*.dat" -print ) # gets the output of the find command and inputs it into the stdin of the loop

    } &  # puts the processes in the background 


done < <(find "$TOPDIR" -mindepth 1 -type d -print) 

wait # wait for all background processes to finish before continuing

rm -r "$TOPDIR"/*/backup_*.dat # cleans up the backup files

cd "$STARING_DIR"
