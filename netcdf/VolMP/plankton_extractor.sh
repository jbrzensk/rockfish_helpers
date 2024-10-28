#!/usr/bin/env bash
# ======================================================================
# NAME
#
#   plankton_extractor.sh
#
# DESCRIPTION
#
#   A bash shell utility to extract plankton data from the netCDF files.
#   Thesea er all located i nthe toijl files.
#
#   EXAMPLE:
#
# USAGE
#
#   ./plankton_extractor.sh
#
# ----------------------------------------------------------------------
# Plankton names to try and extract
# Diat == Diatoms
# Chlo == Chlorophytes
# Cyan == Cyanobacteria
# Cocc == Coccolithophores

DIAT_VAR="Diat"     # Diatoms, toijl file [kg/kg]
CHLO_VAR="Chlo"     # Chlorophytes, toijl file [kg/kg]
CYAN_VAR="Cyan"     # Cyanobacteria, toijl file [kg/kg]
COCC_VAR="Cocc"     # Coccolithophores, toijl file [kg/kg]
MASS="mo"           # Ocean Mass per layer, needed to give weighted integral, oijl file  [kg]

# An array of depth values to find averages over
DEPTHS=(100 150 200)
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
	    
	    echo "Diatom Extraction"
	    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    #               Diatoms in different depth bins                #
	    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    DIATFILE="${FILEDATE}.${DIAT_VAR}.nc"
	    DIATFILE_BND="${FILEDATE}.${DIAT_VAR}_bnd.nc"

	    # select just the variable for diatoms
	    cdo -selname,$DIAT_VAR $file $DIATFILE
	    # add layer bounds dimension for weighted averaging
	    echo "Adding layer bounds for vertical summing."
	    ncap2 -s 'defdim("zoc_bnd",2); zoc_bnds=make_bounds(zoc,$zoc_bnd,"zoc_bnds");' \
		   $DIATFILE $DIATFILE_BND 
            
	    # Merge mass and diatoms into one temporary file
            MASSHERBFILE=tempfile1.nc
            cdo merge "$MASSFILE" "$DIATFILE_BND" "$MASSHERBFILE"
            # Convert Diat to kg/m^3
            WEIGHTFILE=tempfile2.nc
            cdo expr,'Diat_wt=mo*Diat' "$MASSHERBFILE" "$WEIGHTFILE"
	    
	    for depth in "${DEPTHS[@]}"; do
		    echo "Writing depth integrated file for: $depth meters"
		    DIATFILE_DEPTH="${FILEDATE}.${DIAT_VAR}_${depth}m.nc"
		    
		    # Now integrate over desired depth
		    echo "File to write will be ${DIATFILE_DEPTH}"
		    integrate_0_to_depth $depth $WEIGHTFILE $DIATFILE_DEPTH 
		    cdo setattribute,Diat_wt@units="kg/m2" $DIATFILE_DEPTH $DIATFILE_DEPTH
		    LONGSTRING="Diatoms INTEGRATED OVER TOP ${depth}m"
		    echo "Longstring == ${LONGSTRING}"
		    cdo setattribute,Diat_wt@long_name="$LONGSTRING" $DIATFILE_DEPTH $DIATFILE_DEPTH

	    done
	    rm -rf $DIATFILE $DIATFILE_BND
        rm -rf $MASSHERBFILE $WEIGHTFILE

	    echo "Chlorophytes Extraction"
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    #               Chlorophytes in different depth bins              #                  #
	    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    CHLOFILE="${FILEDATE}.${CHLO_VAR}.nc"                                                #
	    CHLOFILE_BND="${FILEDATE}.${CHLO_VAR}_bnd.nc"                                        #

	    # select just the variable for chlorophytes
	    cdo -selname,$CHLO_VAR $file $CHLOFILE                                               #
	    # add layer bounds dimension for weighted averaging
	    echo "Adding layer bounds for vertical summing."
	    ncap2 -s 'defdim("zoc_bnd",2); zoc_bnds=make_bounds(zoc,$zoc_bnd,"zoc_bnds");' \
		   $CHLOFILE $CHLOFILE_BND                                                           #
            
	    # Merge mass and Chlorophytes into one temporary file
            MASSHERBFILE=tempfile1.nc
            cdo merge "$MASSFILE" "$CHLOFILE_BND" "$MASSHERBFILE"                            #
            # Convert to kg/m^3
            WEIGHTFILE=tempfile2.nc 
            cdo expr,'Chlo_wt=mo*Chlo' "$MASSHERBFILE" "$WEIGHTFILE"                         #
	    
	    for depth in "${DEPTHS[@]}"; do
		    echo "Writing depth integrated file for: $depth meters"
		    CHLOFILE_DEPTH="${FILEDATE}.${CHLO_VAR}_${depth}m.nc"                            #
		    
		    # Now integrate over desired depth
		    echo "File to write will be ${CHLOFILE_DEPTH}"                                   #
		    integrate_0_to_depth $depth $WEIGHTFILE $CHLOFILE_DEPTH                          #
		    cdo setattribute,Chlo_wt@units="kg/m2" $CHLOFILE_DEPTH $CHLOFILE_DEPTH           #
		    LONGSTRING="Chlorophytes INTEGRATED OVER TOP ${depth}m"                          #
		    echo "Longstring == ${LONGSTRING}"
		    cdo setattribute,Chlo_wt@long_name="$LONGSTRING" $CHLOFILE_DEPTH $CHLOFILE_DEPTH #

	    done
	    rm -rf $CHLOFILE $CHLOFILE_BND                                                       #
        rm -rf $MASSHERBFILE $WEIGHTFILE
   
   
   	    echo "Cyanobacteria Extraction"
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    #               Cyanobacteria in different depth bins             #                  #
	    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    CYANFILE="${FILEDATE}.${CYAN_VAR}.nc"                                                #
	    CYANFILE_BND="${FILEDATE}.${CYAN_VAR}_bnd.nc"                                        #

	    # select just the variable for chlorophytes
	    cdo -selname,$CYAN_VAR $file $CYANFILE                                               #
	    # add layer bounds dimension for weighted averaging
	    echo "Adding layer bounds for vertical summing."
	    ncap2 -s 'defdim("zoc_bnd",2); zoc_bnds=make_bounds(zoc,$zoc_bnd,"zoc_bnds");' \
		   $CYANFILE $CYANFILE_BND                                                           #
            
	    # Merge mass and Cyanobacteria into one temporary file
            MASSHERBFILE=tempfile1.nc
            cdo merge "$MASSFILE" "$CYANFILE_BND" "$MASSHERBFILE"                            #
            # Convert to kg/m^3
            WEIGHTFILE=tempfile2.nc 
            cdo expr,'Cyan_wt=mo*Cyan' "$MASSHERBFILE" "$WEIGHTFILE"                         #
	    
	    for depth in "${DEPTHS[@]}"; do
		    echo "Writing depth integrated file for: $depth meters"
		    CYANFILE_DEPTH="${FILEDATE}.${CYAN_VAR}_${depth}m.nc"                            #
		    
		    # Now integrate over desired depth
		    echo "File to write will be ${CYANFILE_DEPTH}"                                   #
		    integrate_0_to_depth $depth $WEIGHTFILE $CYANFILE_DEPTH                          #
		    cdo setattribute,Cyan_wt@units="kg/m2" $CYANFILE_DEPTH $CYANFILE_DEPTH           #
		    LONGSTRING="Cyanobacteria INTEGRATED OVER TOP ${depth}m"                         #
		    echo "Longstring == ${LONGSTRING}"
		    cdo setattribute,Cyan_wt@long_name="$LONGSTRING" $CYANFILE_DEPTH $CYANFILE_DEPTH #

	    done
	    rm -rf $CYANFILE $CYANFILE_BND                                                       #
        rm -rf $MASSHERBFILE $WEIGHTFILE
   
      	echo "Coccolithophores Extraction"
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    #            Coccolithophores in different depth bins             #                  #
	    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	    COCCFILE="${FILEDATE}.${COCC_VAR}.nc"                                                #
	    COCCFILE_BND="${FILEDATE}.${COCC_VAR}_bnd.nc"                                        #

	    # select just the variable for chlorophytes
	    cdo -selname,$COCC_VAR $file $COCCFILE                                               #
	    # add layer bounds dimension for weighted averaging
	    echo "Adding layer bounds for vertical summing."
	    ncap2 -s 'defdim("zoc_bnd",2); zoc_bnds=make_bounds(zoc,$zoc_bnd,"zoc_bnds");' \
		   $COCCFILE $COCCFILE_BND                                                           #
            
	    # Merge mass and Coccolithophores into one temporary file
            MASSHERBFILE=tempfile1.nc
            cdo merge "$MASSFILE" "$COCCFILE_BND" "$MASSHERBFILE"                            #
            # Convert to kg/m^3
            WEIGHTFILE=tempfile2.nc 
            cdo expr,'Cocc_wt=mo*Cocc' "$MASSHERBFILE" "$WEIGHTFILE"                         #
	    
	    for depth in "${DEPTHS[@]}"; do
		    echo "Writing depth integrated file for: $depth meters"
		    COCCFILE_DEPTH="${FILEDATE}.${COCC_VAR}_${depth}m.nc"                            #
		    
		    # Now integrate over desired depth
		    echo "File to write will be ${COCCFILE_DEPTH}"                                   #
		    integrate_0_to_depth $depth $WEIGHTFILE $COCCFILE_DEPTH                          #
		    cdo setattribute,Cocc_wt@units="kg/m2" $COCCFILE_DEPTH $COCCFILE_DEPTH           #
		    LONGSTRING="Coccolithophores INTEGRATED OVER TOP ${depth}m"                         #
		    echo "Longstring == ${LONGSTRING}"
		    cdo setattribute,Cocc_wt@long_name="$LONGSTRING" $COCCFILE_DEPTH $COCCFILE_DEPTH #

	    done
	    rm -rf $COCCFILE $COCCFILE_BND                                                       #
        rm -rf $MASSHERBFILE $WEIGHTFILE
   

    else
	    echo "this is NOT a toij OR oijl file"
	    echo ""
    fi

done
