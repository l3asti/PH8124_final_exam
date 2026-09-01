#!/bin/bash

TOPDIR=$(realpath $1)

[[ ! -d "$TOPDIR" ]] && echo "The provided path is not a directory." >&2 && return 6

[[ $TOPDIR == */ ]] && TOPDIR="${TOPDIR%/}" # gets rid of the trailing / in the input argument if it exists

source Splitter.sh "$TOPDIR" && echo "Done with Splitter.sh" || return 5
source Filter.sh "$TOPDIR" && echo "Done with Filter.sh" || return 4
source Transfer.sh "$TOPDIR" && echo "Done with Transfer.sh" || return 3
source Analysis.sh "$TOPDIR" && echo "Done with Analysis.sh" || return 2

return 0