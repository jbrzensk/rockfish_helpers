#!/usr/bin/env bash
# ======================================================================
# NAME
#
#   combiner.sh
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
#   ./combiner.sh 
#
# LAST UPDATED
#
#   October 21, 2024
#
# ----------------------------------------------------------------------
#
# Files handles
NDET="N_det_bot"
HERB100="Herb_100m"
HERB150="Herb_150m"
HERB200="Herb_200m"
TEMP100="pot_temp_mn_100"
TEMP150="pot_temp_mn_150"
TEMP200="pot_temp_mn_200"
TEMPBOT="pot_temp_bot"


ncecat -O -u time *"$NDET"* 1925.N_det_bot.nc
ncecat -O -u time *"$HERB100"* 1925.Herb_int_100m.nc
ncecat -O -u time *"$HERB150"* 1925.Herb_int_150m.nc
ncecat -O -u time *"$HERB200"* 1925.Herb_int_200m.nc
ncecat -O -u time *"$TEMP100"* 1925.Temp_mn_100m.nc
ncecat -O -u time *"$TEMP150"* 1925.Temp_mn_150m.nc
ncecat -O -u time *"$TEMP200"* 1925.Temp_mn_200m.nc
ncecat -O -u time *"$TEMPBOT"* 1925.Temp_bot.nc

#cdo setattribute,global@fromto="From: 1925 Jan 1, hr 0  To: 1925 Dec 31, hr 0" 1925.N_det_bot.nc
ncatted -O -a fromto,global,o,c,"From: 1925 Jan 1 hr 0  To: 1925 Dec 31 hr 0" 1925.N_det_bot.nc
cdo settaxis,1925-01-01,12:00:00,1mon 1925.N_det_bot.nc 1925.N_det_bot.nc

ncatted -O -a fromto,global,o,c,"From: 1925 Jan 1 hr 0  To: 1925 Dec 31 hr 0" 1925.Herb_int_100m.nc
cdo settaxis,1925-01-01,12:00:00,1mon 1925.Herb_int_100m.nc 1925.Herb_int_100m.nc

ncatted -O -a fromto,global,o,c,"From: 1925 Jan 1 hr 0  To: 1925 Dec 31 hr 0" 1925.Herb_int_150m.nc
cdo settaxis,1925-01-01,12:00:00,1mon 1925.Herb_int_150m.nc 1925.Herb_int_150m.nc

ncatted -O -a fromto,global,o,c,"From: 1925 Jan 1 hr 0  To: 1925 Dec 31 hr 0" 1925.Herb_int_200m.nc
cdo settaxis,1925-01-01,12:00:00,1mon 1925.Herb_int_200m.nc 1925.Herb_int_200m.nc

ncatted -O -a fromto,global,o,c,"From: 1925 Jan 1 hr 0  To: 1925 Dec 31 hr 0" 1925.Temp_mn_100m.nc
cdo settaxis,1925-01-01,12:00:00,1mon 1925.Temp_mn_100m.nc 1925.Temp_mn_100m.nc

ncatted -O -a fromto,global,o,c,"From: 1925 Jan 1 hr 0  To: 1925 Dec 31 hr 0" 1925.Temp_mn_150m.nc
cdo settaxis,1925-01-01,12:00:00,1mon 1925.Temp_mn_150m.nc 1925.Temp_mn_150m.nc

ncatted -O -a fromto,global,o,c,"From: 1925 Jan 1 hr 0  To: 1925 Dec 31 hr 0" 1925.Temp_mn_200m.nc
cdo settaxis,1925-01-01,12:00:00,1mon 1925.Temp_mn_200m.nc 1925.Temp_mn_200m.nc

ncatted -O -a fromto,global,o,c,"From: 1925 Jan 1 hr 0  To: 1925 Dec 31 hr 0" 1925.Temp_bot.nc
cdo settaxis,1925-01-01,12:00:00,1mon 1925.Temp_bot.nc 1925.Temp_bot.nc
