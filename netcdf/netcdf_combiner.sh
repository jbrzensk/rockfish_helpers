#!/usr/bin/env bash
# ======================================================================
# NAME
#
#   netcdf_combiner.sh
#
# DESCRIPTION
#
#   A bash shell utility to combine N subdomains into a global netCDF
#   file. This is meant to run as a companion to netcdf_splitter.
#
# USAGE
#
#   Combine netCDF files split by longitude
#
#     ./netcdf_combiner.sh N in_filename_stem out_filename
#
# LAST UPDATED
#
#   September 25, 2024
#
# ----------------------------------------------------------------------
generate_array() {
    local start=$1
    local end=$2
    local num_elements=$3

    # Round tot his many significant digits, changeable
    local round_to_this_digit=3

    # Calculate the increment (step size)
    local increment=$(echo "scale=$round_to_this_digit; ($end - $start) / ($num_elements - 1)" | bc)

    local result=()

    # Populate the array
    for (( i=0; i<num_elements; i++ )); do
        value=$(echo "scale=$round_to_this_digit; $start + $i * $increment" | bc)
        result+=($value)
    done

    # Print the array, basically returns the array as output, which is saved to a variable.
    echo "${result[@]}"
}

###########################################################
# netcdf splitter                                         #
###########################################################


# CHECK IF THE CORRECT NUMBER OF ARGUMENTS ARE PROVIDED
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <num_files> <in_file_stem> <out_file>"
    echo "num_files     : number of smaller files"
    echo "in_file_stem  : input filename stem, filename_#. Just the filename, no _"
    echo "out_file      : outfile name"
    echo ""
    exit 1
fi

# ASSIGN ARGUMENTS TO VARIABLES
NUM_FILES="$1"
IN_FILE_STEM="$2"
OUT_FILE="$3"

# CHECK TO SEE NUM_FILES > 1
if (( ! NUM_FILES > 1 )); then
    echo "Num files == 1, use same file."
    echo "exiting..."
fi


echo
echo "Input file stem is ${IN_FILE_STEM}."
echo

# CHECK TO SEE IF FILE EXISTS
if [ -z "$2" ]; then
    echo "input file does not exist, exiting..."
    exit 1
else
    echo "Found input file, continuing..."
fi


# Change record dimension to Longitude for concatenating
for ((i = 1; i <= NUM_FILES; i++)); do
    
    SMALL_FILE1="${IN_FILE_STEM}"_"${i}".nc
    #SMALL_REDEFINED="${SMALL_FILE1}"_xdim.nc
    SMALL_REDEFINED="${IN_FILE_STEM}"_"${i}"_xdim.nc


    echo "ncpdq -a lon,time "${SMALL_FILE1}" "${SMALL_REDEFINED}""

    ncpdq -a lon,time "${SMALL_FILE1}" "${SMALL_REDEFINED}"

done

for ((i = 1; i < NUM_FILES; i++)); do
	
	if (( i == 1 )); then
    	SMALL_FILE1="${IN_FILE_STEM}"_"${i}"_xdim.nc
    else 
    	SMALL_FILE1=$OUT_FILE
    fi

    SMALL_FILE2="${IN_FILE_STEM}"_$(($i+1))_xdim.nc
    echo "Output file is ${OUT_FILE}"
    echo "ncrcat "${SMALL_FILE1}" "${SMALL_FILE2}" "${OUT_FILE}" "
    
    ncrcat -A -h "${SMALL_FILE1}" "${SMALL_FILE2}" "${OUT_FILE}"

done

echo "Revert time as record dimension"

ncpdq -a time,lon "${OUT_FILE}" "${OUT_FILE}".nc

rm -f "${OUT_FILE}"






