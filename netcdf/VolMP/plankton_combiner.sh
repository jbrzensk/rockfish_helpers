#!/usr/bin/env bash
# ======================================================================
# NAME
#
#   plankton_combiner.sh
#
# DESCRIPTION
#
#   A bash shell utility to combine data from the netCDF files.
#
#   EXAMPLE:
#   
#   Combine the files with the prefixes given in the global variables
#   below. Other files will be skipped. There is a limit to what CDO
#   can combine, but it has not been reached yet.
#
# USAGE
#
#   ./plankton_combiner.sh 
#
# LAST UPDATED
#
#   October 28, 2024
#
# ----------------------------------------------------------------------
#
# Files handles
Combine_timeseries() {
    local file_stub=$1

    # Check if input file is provided
	if [ "$#" -ne 1 ]; then
	    echo "Usage: $0 <Filestem> "
	    echo "<Filestem> is the filestem name shared by all of the files to be combined."
	    echo ""
	    echo ""
	    exit 1
	fi

	NEWFILE="1925.${file_stub}.nc"

	echo "Combining files with ${file_stub}"
	ncecat -O -u time *"$file_stub"* "$NEWFILE"

	ncatted -O -a fromto,global,o,c,"From: 1925 Jan 1 hr 0  To: 1925 Dec 31 hr 0" "$NEWFILE"
	cdo settaxis,1925-01-01,12:00:00,1mon "$NEWFILE" "$NEWFILE"

    # Inform the user about the output file
    echo "Integrated data saved to $NEWFILE"
}

# We call the function above with the filestems in the following list
filestubs=("Cocc_100m" "Cocc_150m" "Cocc_200m" "Diat_100m" "Diat_150m" "Diat_200m" "Chlo_100m" "Chlo_150m" "Chlo_200m" "Cyan_100m" "Cyan_150m" "Cyan_200m")
echo "Filestubs:"
echo "${filestubs[@]}"




for file in "${filestubs[@]}"; do
	Combine_timeseries $file
done
