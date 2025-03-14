#!/usr/bin/env bash
# ======================================================================
# NAME
#
#   parallel_downloader.sh
#
# DESCRIPTION
#
#   A bash shell script to download a list of files, given as a command
#   line argument, in parallel, using the bash command parallel and the
#   rsync command. F
#
# USAGE
#
#   Download the files in filelist.txt using N processes:
#
#     ./download_parallel N filelist.txt
#
# LAST UPDATED
#
#   January 22, 2025
#
# ----------------------------------------------------------------------
# Remote server details
# For ease, setup the ssh keys so you are not asked for the password!
# [ CHANGE ME ]
# Use monkfish to download the test files in filelist
REMOTE_SERVER="user@monkfish.ucsd.edu"

# Destination directory where files will be downloaded
# [ CHANGE ME ]
# Use a location on rockfish to save the test files.
DEST_DIR="/home/user/location"
# ----------------------------------------------------------------------

# CHECK IF THE CORRECT NUMBER OF ARGUMENTS ARE PROVIDED
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <num_processes> <filelist_file>"
    echo "num_processes : Num of compute cores to use"
    echo "filelist_file : Name of text file containing the files to download"
    echo ""
    exit 1
fi

# Number of parallel downloads
NUM_PARALLEL=$1

# File containing the list of file paths to download
FILE_LIST=$2

# Check if the file list exists and is not empty
if [[ ! -f "$FILE_LIST" ]]; then
    echo "Error: File list '$FILE_LIST' does not exist."
    exit 1
fi

if [[ ! -s "$FILE_LIST" ]]; then
    echo "Error: File list '$FILE_LIST' is empty."
    exit 1
fi


# Ensure the destination directory exists
mkdir -p "$DEST_DIR"

# Export the variables so they're accessible to parallel
export REMOTE_SERVER DEST_DIR

# Use parallel to run rsync for each file path
cat "$FILE_LIST" | parallel --line-buffer --keep-order -j "$NUM_PARALLEL" rsync -avzP "$REMOTE_SERVER:{}" "$DEST_DIR/"

