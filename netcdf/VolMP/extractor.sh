#!/usr/bin/env bash
# ======================================================================
# NAME
#
#   extractor.sh
#
# DESCRIPTION
#
#   A bash shell utility to extract data from the netCDF files.
#
#   EXAMPLE:
#
# USAGE
#
#   ./extractor.sh
#
# ----------------------------------------------------------------------
#
# FUNCTIONS
# average_depth takes a level 'X' and two file names, and returns the weighted mean
# over the vertical levels 0-X. The input file is expected to have only one variable
# to average across.
integrate_0_to_depth() {
    local depth_to_integrate=$1
    local input_file=$2
    local output_file=$3

    # Check if input file is provided
    if [[ -z "$input_file" ]]; then
        echo "Usage: integrate_0_to_depth <depth_in_m> <input_file.nc> <output_file.nc>"
        return 1
    fi

    cdo vertsum -select,levrange=0,"$depth_to_integrate" "$input_file" "$output_file"

    # Inform the user about the output file
    echo "Integrated data saved to $output_file"
}
average_0_depth() {
    local depth_to_average=$1
    local input_file=$2
    local output_file=$3

    # Check if input file is provided
    if [[ -z "$input_file" ]]; then
        echo "Usage: average_0_depthm <depth_in_m> <input_file.nc> <output_file.nc>"
        return 1
    fi

    # Compute the average between 0 and 100 meters and save it to output_file
    cdo vertmean -select,levrange=0,"$depth_to_average" "$input_file" "$output_file"
    #cdo vertmean -sellevel,0,"$depth_to_average" "$input_file" "$output_file"

    # Inform the user about the output file
    echo "Averaged data saved to $output_file"
}
# ----------------------------------------------------------------------

NDET_VAR="N_det"     # POC/Detritus flux to the seafloor, toijl file [kg/kg]
HERB="Herb"          # pelagic mesozooplankton biomass, toijl file [kg/kg]
TEMP_VAR="pot_temp"  # pelagic temperature, oijl file [C]
MASS="mo"            # Ocean Mass per layer, oijl file  [kg]
# An array of depth values to find averages over
DEPTHS=(100 150 200)

# Loop through all files matching the pattern MONYEAR.text
for file in [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*.nc; do
    
    # Extract the year, month, and day from filename
    year="${file:0:4}"
    mon="${file:4:2}"
    day="${file:6:2}"
 
    # ignoring the dot in the filename
    rest_of_filename="${file:9}"

    echo "File read in as : $file"
    echo "Month : $mon"
    echo "Year : $year"
    echo "Other name : $rest_of_filename"

    FILEDATE="${year}${mon}${day}"

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    #                    Mass of water per layer                      #
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    if [[ $rest_of_filename == oijlVol* ]]; then
	    
	    echo "extracting mass of water per layer"
	    MASSFILE="${FILEDATE}.VolFluid.nc"
	    cdo -selname,$MASS $file $MASSFILE
    fi


    if [[ $rest_of_filename == toij* ]]; then
	    echo "this is a toij file"
	    
	    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    #               Herbivores in different depth bins                #
	    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    HERBFILE="${FILEDATE}.${HERB}.nc"
	    HERBFILE_BND="${FILEDATE}.${HERB}_bnd.nc"

	    # select just the variable for herbivores
	    cdo -selname,$HERB $file $HERBFILE
	    # add layer bounds dimension for weighted averaging
	    echo "Adding layer bounds for vertical summing."
	    ncap2 -s 'defdim("zoc_bnd",2); zoc_bnds=make_bounds(zoc,$zoc_bnd,"zoc_bnds");' \
		   $HERBFILE $HERBFILE_BND 
            
	    # Merge mass and Herbivore into one temporary file
            MASSHERBFILE=tempfile1.nc
            cdo merge "$MASSFILE" "$HERBFILE_BND" "$MASSHERBFILE"
            # Convert Herb to kg/m^3
            WEIGHTFILE=tempfile2.nc
            cdo expr,'Herb_wt=mo*Herb' "$MASSHERBFILE" "$WEIGHTFILE"
	    
	    for depth in "${DEPTHS[@]}"; do
		    echo "Writing depth integrated file for: $depth meters"
		    HERBFILE_DEPTH="${FILEDATE}.${HERB}_${depth}m.nc"
		    
		    # Now integrate over desired depth
		    echo "File to write will be ${HERBFILE_DEPTH}"
		    integrate_0_to_depth $depth $WEIGHTFILE $HERBFILE_DEPTH 
		    cdo setattribute,Herb_wt@units="kg/m2" $HERBFILE_DEPTH $HERBFILE_DEPTH
		    LONGSTRING="HERB INTEGRATED OVER TOP ${depth}m"
		    echo "Longstring == ${LONGSTRING}"
		    cdo setattribute,Herb_wt@long_name="$LONGSTRING" $HERBFILE_DEPTH $HERBFILE_DEPTH

	    done
	    
	    rm -rf $HERBFILE $HERBFILE_BND
            rm -rf $MASSHERBFILE $WEIGHTFILE

	    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    #         Calculating the Detritus on the ocean floor             #
	    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    NDETFILE="${FILEDATE}.$NDET_VAR.nc"
	    NDET_BOTTOMFILE="${FILEDATE}.${NDET_VAR}_bot.nc"
	
	    cdo -selname,$NDET_VAR $file $NDETFILE
	    echo "Finding bottom values for detritus."
	    cdo -v bottomvalue $NDETFILE $NDET_BOTTOMFILE

	    rm -f $NDETFILE

    elif [[ $rest_of_filename == oijl* ]]; then
	    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    #         Calculating the temperature in bins/floor               #
	    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    echo "Found temperature file."
	    TEMPFILE="${FILEDATE}.$TEMP_VAR.nc"
	    TEMPFILE_BND="${FILEDATE}.${TEMP_VAR}_bnd.nc"
	    TEMP_BOTTOMFILE="${FILEDATE}.${TEMP_VAR}_bot.nc"
		
	    cdo -selname,$TEMP_VAR $file $TEMPFILE

	    # Bottom values
	    echo "Extracting bottom temperature values."
	    cdo -v bottomvalue $TEMPFILE $TEMP_BOTTOMFILE

	    # add layer bounds dimension for weighted averaging in vertical
	    echo "Adding layer bounds for vertical mean"
            ncap2 -s 'defdim("zoc_bnd",2); zoc_bnds=make_bounds(zoc,$zoc_bnd,"zoc_bnds");' \
                   $TEMPFILE $TEMPFILE_BND

	    for depth in "${DEPTHS[@]}"; do
		    echo "Writing depth averaged temperature file for: $depth meters"
		    TEMPFILE_DEPTH="${FILEDATE}.${TEMP_VAR}_mn_${depth}m.nc"
		    echo "File to write will be ${TEMPFILE_DEPTH}"
		    average_0_depth $depth $TEMPFILE_BND $TEMPFILE_DEPTH 
		    LONGSTRING="MEAN OCEAN POTENTIAL TEMPERATURE OF TOP ${depth}m"
		    echo "Longstring == ${LONGSTRING}"
		    cdo setattribute,pot_temp@long_name="$LONGSTRING" $TEMPFILE_DEPTH $TEMPFILE_DEPTH
	    done
    	    
	    rm -f $TEMPFILE $TEMPFILE_BND
    
    else
	    echo "this is NOT a toij OR oijl file"
	    echo ""
    fi

done
