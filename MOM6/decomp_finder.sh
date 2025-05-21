#!/usr/bin/env bash
# ======================================================================
# NAME
#
#  decomp_finder.sh 
#
# DESCRIPTION
#
#   Decomposition Finder ( for MOM6 type grids )
# 
#   This program finds all decompositions of a domain. In parallel
#   simulations, the domain is decomposed into subdomains. The size of
#   these subdomains plays a significant role in time of computation. 
#   Generally, you want to maximize the number of processes used and 
#   minimize the overhead of halo regions. Square domains are generally
#   desired as well for even processing in X,Y directions.
#
#   This program decomposes the domain in NxM grids, starting from 1x1
#   and incresing, showing the resulting subdomain sizes. If the 
#   subdomain size is larger than the minimum defined area, it PASSes.
#
#   The idea is to maximize the ranks used, and the uniformity of the
#   subdomain. A uniform subdomain can increase the efficiency by up
#   to 25% over a long rectabgular domain.
#
# USAGE
#
#   To show all possible decompositions of a 300x400 grid, with a halo
#   of 4 cells, and a minimum area of 10x10 cells, 
#
#     ./decomp_finder.sh 300 400 4 10
#
# LAST UPDATED
#
#   May 19, 2025
#
# ----------------------------------------------------------------------
#
# If no inputs are given, default to 360x320 grid ( 1 degree nominal )
# with a halo of 4 cells, and a minimum area of 10x10 for each subdomain.

# Inputs
NX=${1:-360}
NY=${2:-320}
HALO=${3:-4}
MIN_INNER=${4:-10}

echo "Grid size: ${NX}x${NY}, Halo: ${HALO}, Min interior: ${MIN_INNER}x${MIN_INNER}"
echo
printf "%-8s %-8s %-8s %-10s %-10s %-10s\n" "X_PROC" "Y_PROC" "RANKS" "TILE_X" "TILE_Y" "VALID"

# Loop over possible divisors
for X_PROC in $(seq 1 $NX); do
  if (( NX % X_PROC != 0 )); then continue; fi
  TILE_X=$(( NX / X_PROC ))

  for Y_PROC in $(seq 1 $NY); do
    if (( NY % Y_PROC != 0 )); then continue; fi
    TILE_Y=$(( NY / Y_PROC ))

    # Check interior size after halo
    INNER_X=$(( TILE_X - 2 * HALO ))
    INNER_Y=$(( TILE_Y - 2 * HALO ))

    if (( INNER_X >= MIN_INNER && INNER_Y >= MIN_INNER )); then
      VALID="YES"
    else
      VALID="NO"
    fi

    RANKS=$(( X_PROC * Y_PROC ))
    printf "%-8s %-8s %-8s %-10s %-10s %-10s\n" "$X_PROC" "$Y_PROC" "$RANKS" "$TILE_X" "$TILE_Y" "$VALID"
  done
done | sort -nk3
