#!/bin/bash

# save the path for the top dir of the HIJING files
# save the absolute path of the top directory
TOPDIR=$(realpath $1)

STARING_DIR=$(pwd)


# procces all the HIJING_LBF_test_small.out files 
while read File; do 
    {
        cd $(dirname "$File")

        while read -r event start_line end_line; do # reads from the awk command and spits the files in singel events
            sed -n "${start_line},${end_line}p" HIJING_LBF_test_small.out > "event_${event}.dat"
        done< <(awk '
            /BEGINNINGOFEVENT/ {
                if (prev != "")
                    print event, prev, NR 

                prev = NR + 2
                event++
            }
            END {
                if (prev != "")
                    print event, prev, NR
            }
            ' HIJING_LBF_test_small.out) # gets the event number, start line and end line of each event and outputs it into stdin of the inner loop

    } & # run the splitting of the file in the background 


done < <(find "$TOPDIR" -type f -name "HIJING_LBF_test_small.out" -print) # find all HIJING_LBF_test_small.out files in the sup directories and output into the stdin of the loop
    
wait # wait for all background processes to finish before continuing
    
cd "$STARING_DIR"

return 0