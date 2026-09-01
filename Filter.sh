#!/bin/bash


TOPDIR=$(realpath $1)

STARING_DIR=$(pwd)

# find all the sub directories and starts a sub background procces for each
# filltes each event_*.dat for primary particles
while read dir; do
    {   
        while read File; do 
        cd $(dirname "$File")

        # get currend file number from basename and grabbing all the digits from it
        filenumber=$(basename "$File" | grep -o '[0-9]*')

        # makes a temp backup of the .dat files bevor filtering
        BackupFile="backup_${filenumber}.dat"
        cp $File $BackupFile

        awk '{if ($3 == 0) print $2" "$5" "$6" "$7" "$8}' < "$BackupFile" > "$File"



        done < <(find "$dir" -type f -name "event_*.dat" -print ) # gets the output of the find command and inputs it into the stdin of the loop

    } &  # puts the processes in the background 
done < <(find "$TOPDIR" -mindepth 1 -type d -print) 

wait # wait for all background processes to finish before continuing

rm -r "$TOPDIR"/*/backup_*.dat # cleans up the backup files

cd "$STARING_DIR"

return 0
