#!/usr/bin/env bash
# ======================================================================
# NAME
#
#   netcdf_splitter_parallel.sh
#
# DESCRIPTION
#
#   A bash shell utility to split a global netCDF file into N subdomains, 
#   splitting on a longitude value. Output files will be named
#   out_filename_stem_num.nc, where 'num' is 1->N, run in parallel.
#
# USAGE
#
#   Split netCDF into N parts by longitude
#
#     ./netcdf_splitter_parallel.sh N in_filename out_filename_stem
#
# LAST UPDATED
#
#   January 6, 2025
#
# ----------------------------------------------------------------------
generate_array() {
    local start=$1
    local end=$2
    local num_elements=$3

    # Round to this many significant digits, changeable
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
    echo "Usage: $0 <num_files> <in_file> <out_file_stem>"
    echo "num_files     : number of smaller files"
    echo "in_file       : input filename"
    echo "out_file_stem : outfilename shared by all smaller files"
    echo ""
    exit 1
fi

# ASSIGN ARGUMENTS TO VARIABLES
NUM_FILES="$1"
IN_FILE="$2"
OUT_FILE_STEM="$3"

# CHECK TO SEE NUM_FILES > 1
if (( ! NUM_FILES > 1 )); then
    echo "Num files == 1, use same file."
    echo "exiting..."
fi


echo
echo "Input file is ${IN_FILE}."
echo

# CHECK TO SEE IF FILE EXISTS
if [ -z "$2" ]; then
    echo "input file does not exist, exiting..."
    exit 1
else
    echo "Found input file, continuing..."
fi


#SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Run the command and store the output in a variable
output=$(ncdump -h $IN_FILE)


# Use grep to find the first instance of 'val=x' and cut or awk to extract the value of x
LAT=$(echo "$output" | grep -o 'lat = [^ ]*' | head -n 1 | sed 's/lat = //')

# Alternatively, using awk to extract the first match
# val=$(echo "$output" | awk -F'=' '/val=/{print $2; exit}')

# Print the result
if [ -n "$LAT" ]; then
  echo "Latitude = $LAT"
else
  echo "No instance of lat found."
fi



# Use grep to find the first instance of 'val=x' and cut or awk to extract the value of x
LON=$(echo "$output" | grep -o 'lon = [^ ]*' | head -n 1 | sed 's/lon = //')

# Alternatively, using awk to extract the first match
# val=$(echo "$output" | awk -F'=' '/val=/{print $2; exit}')

# Print the result
if [ -n "$LON" ]; then
  echo "Longitude = $LON"
else
  echo "No instance of lon found."
fi

echo
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "This assumes lattitude is going from -$((LAT/2)) to "
echo "$((LAT/2)), and longitude is going from -$((LON/2)) "
echo "to $((LON/2)). Please double check the netCDF file."
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo

LON_ARRAY=($(generate_array -179.5 179.5 360))

#echo "Longitude will be split at the following values:${LON_ARRAY[@]}"

TOTAL_ELEMENTS=${#LON_ARRAY[@]}

# Calculate chunk size (evenly distribute)
CHUNK_SIZE=$((TOTAL_ELEMENTS / NUM_FILES))

# If the total elements are not evenly divisible by N, adjust CHUNK_SIZE to cover all elements
REMAINDER=$((TOTAL_ELEMENTS % NUM_FILES))



echo "Total elements: $TOTAL_ELEMENTS"
echo "Chunk size: $CHUNK_SIZE"
echo "Number of extra elements (remainder): $remainder"

declare -a chunks

# Split the array into N chunks
start_index=0
for ((i = 1; i <= NUM_FILES; i++)); do
    # Determine end index for the current chunk
    end_index=$((start_index + CHUNK_SIZE - 1))

    # Add one more element to some chunks to handle remainder (if any)
    if [ "$i" -le "$REMAINDER" ]; then
        end_index=$((end_index + 1))
    fi

    # Extract the chunk using array slicing
    chunk=("${LON_ARRAY[@]:$start_index:$((end_index - start_index + 1))}")

    # Store the chunk as a space-separated string in the "chunks" array
    chunks[i]="${chunk[*]}"
    
    # Output the chunk
    # echo "Chunk $i: ${chunk[@]}"

    # Update the start index for the next chunk
    start_index=$((end_index + 1))
done

# Output the 2D array (chunks)
#!/bin/bash

export IN_FILE OUT_FILE_STEM  # Export variables for use in the parallel subprocesses

seq 1 "$NUM_FILES" | parallel -j 4 '
    echo "Chunk {}: ${chunks[{}]}"
    SMALL_CHUNK=(${chunks[{}]})
    MIN_LON=${SMALL_CHUNK[0]}
    MAX_LON=${SMALL_CHUNK[-1]}
    OUTFILE="${OUT_FILE_STEM}_{}.nc"
    echo "Output file is ${OUTFILE}"
    ncks -d lon,"${MIN_LON}","${MAX_LON}" "${IN_FILE}" "${OUTFILE}"
'

# for ((i = 1; i <= NUM_FILES; i++)); do
#     echo "Chunk $i: ${chunks[i]}"
#     SMALL_CHUNK=(${chunks[i]})
#     MIN_LON=${SMALL_CHUNK[0]}
#     MAX_LON=${SMALL_CHUNK[-1]}
#     OUTFILE="${OUT_FILE_STEM}"_"${i}".nc
#     echo "Output file is ${OUTFILE}"
#     echo "ncks -d lon,"${MIN_LON}","${MAX_LON}" "${IN_FILE}" "${OUTFILE}" "
#     ncks -d lon,"${MIN_LON}","${MAX_LON}" "${IN_FILE}" "${OUTFILE}" 
# done
