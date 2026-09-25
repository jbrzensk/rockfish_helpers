#!/bin/bash
# Decomposition Finder for MOM6 / FMS
#
# FMS (mpp_define_domains) does NOT require NIPROC to divide NIGLOBAL:
# leftover points are spread so tiles differ by at most one cell per
# direction. Tile extents are shown as a range where uneven.
#
# Constraints applied:
#   - each tile must be >= HALO cells wide (FMS exchanges with immediate
#     neighbours only)
#   - each tile must be >= MIN_TILE cells wide (your efficiency preference)
#   - optional cap on NIPROC*NJPROC
#
# Columns:
#   HALO/T  halo cells per compute cell for the smallest tile. This is the
#           real cost (redundant work + communication volume) and rises
#           with rank count by design; compare it ACROSS rank counts.
#   ASPECT  TILE_X / TILE_Y, size-independent shape measure. 1.0 = square.
#           Values a bit above 1 are fine (i is the inner Fortran loop);
#           much below 1 or above ~2-3 is worth avoiding. Compare WITHIN
#           a rank count.
#
# Actual PE count with a MASKTABLE is RANKS minus masked land tiles:
#   check_mask --grid_file ocean_mosaic.nc --ocean_topog topog.nc --layout 24,20

NX=${1:-360}         # NIGLOBAL
NY=${2:-320}         # NJGLOBAL
HALO=${3:-4}         # NIHALO/NJHALO
MIN_TILE=${4:-10}    # smallest acceptable compute-domain extent
MAX_RANKS=${5:-0}    # 0 = no limit

echo "Grid: ${NX}x${NY}  Halo: ${HALO}  Min tile: ${MIN_TILE}  Max ranks: ${MAX_RANKS}"
echo
printf "%-7s %-7s %-7s %-9s %-9s %-7s %-7s\n" NIPROC NJPROC RANKS TILE_X TILE_Y HALO/T ASPECT

for (( XP=1; XP<=NX; XP++ )); do
  MINX=$(( NX / XP ))
  MAXX=$(( (NX + XP - 1) / XP ))
  (( MINX < MIN_TILE || MINX < HALO )) && break     # tiles only shrink from here

  for (( YP=1; YP<=NY; YP++ )); do
    MINY=$(( NY / YP ))
    MAXY=$(( (NY + YP - 1) / YP ))
    (( MINY < MIN_TILE || MINY < HALO )) && break
    R=$(( XP * YP ))
    (( MAX_RANKS > 0 && R > MAX_RANKS )) && break

    TX=$MINX; (( MAXX != MINX )) && TX="${MINX}-${MAXX}"
    TY=$MINY; (( MAXY != MINY )) && TY="${MINY}-${MAXY}"

    read -r OVH ASP < <(awk -v h="$HALO" -v x="$MINX" -v y="$MINY" \
          'BEGIN { printf "%.2f %.2f\n", ((x+2*h)*(y+2*h) - x*y) / (x*y), x/y }')

    printf "%-7s %-7s %-7s %-9s %-9s %-7s %-7s\n" "$XP" "$YP" "$R" "$TX" "$TY" "$OVH" "$ASP"
  done
done | sort -n -k3,3 -k6,6
