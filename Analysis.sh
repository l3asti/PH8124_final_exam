#!/bin/bash

TOPDIR=$(realpath $1)

STARING_DIR=$(pwd)


rm -f "$TOPDIR"/AnalysisResults.root # delete existing AnalysisResults.root file to avoid appending to old data if exists



while read file; do # loop over all HIJING_LBF_test_small.root files

    root -l -b -q "$STARING_DIR/readDataFromTTree.C(\"$file\", \"$TOPDIR\")" > /dev/null # run Root macro for the analysis chain

done < <(find "$TOPDIR" -type f -name "HIJING_LBF_test_small.root" -print)


# run the root script to output histograms and save p_t mean over cout into array
mean=($(root -l -b -q "$STARING_DIR/printResults.C(\"$TOPDIR/AnalysisResults.root\", \"$TOPDIR\")" | grep "^[0-9]"))  

# output mean pT for each particle type to the console
echo -e "Average pT \033[1mfor\033[0m the whole dataset:"
printf "%-10s= %s GeV/c\n" "o pions" "${mean[0]}"
printf "%-10s= %s GeV/c\n" "o kaons" "${mean[1]}"
printf "%-10s= %s GeV/c\n" "o protons" "${mean[2]}"


cd "$STARING_DIR"

return 0