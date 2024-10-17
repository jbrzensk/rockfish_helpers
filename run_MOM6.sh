#!/usr/bin/env bash
# ======================================================================
# NAME
#
#   run_MOM6.sh
#
# DESCRIPTION
#
#   A bash shell utility to help run MOM6 in parallel, prompting for 
#   inputs for the different parameters parallel.sh takes
#
# USAGE
#
#
#     ./run_MOM6.sh
#
# LAST UPDATED
#
#   October 16, 2024
#
# ----------------------------------------------------------------------
FMORT_DEFAULT=0.3
ENCOUNTER_DEFAULT=50
K_DEFAULT=1.0
K50_DEFAULT=1.0

CURRENT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Define some color choices
# echo -e "${RED}This text is red!${NC}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
CYANBOLD='\033[1;36m'
BOLD='\033[0;1m'
NC='\033[0m' # Reset all modes


#FUNCTION TO KILL ALL SPAWNED PROCESSES
cleanup() {
  echo "Terminating all spawned processes..."
  for pid in "${pids[@]}"; do
    kill "$pid" 2>/dev/null
  done
  echo "Check the SCRATCH directory for any stray files."
  exit 0
}

# EMPTY ARRAY 
pids=()

# Trap Ctrl-C (SIGINT) and call cleanup function
trap cleanup SIGINT

echo
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "This script will ask you for some parameters to run then"
echo "parallel MOM6-FEISTY code."
echo "Please run this from the 'exps' directory where MOM6 and"
echo "all of the INPUT files are located."
echo
echo "If there is a DEFAULT option, pushing [ENTER] will"
echo "use the default value."
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "Reading directories...."

################################################################
## SETUP THE LOCATIONS
################################################################
BATS=()    # empty holders for directory names
CCE=()

for dir in BATS*; do
    if [ -d "$dir" ]; then
        BATS+=("$dir")
    fi
done

for dir in CCE*; do
    if [ -d "$dir" ]; then
        CCE+=("$dir")
    fi
done

# Print out possible choices:
echo "Directories in BATS:"
for dir in "${BATS[@]}"; do
    echo "$dir"
done

echo "Directories in CCE:"
for dir in "${CCE[@]}"; do
    echo "$dir"
done

echo "#########################################################################################"
echo "##                        Location  to run                                             ##"
echo "#########################################################################################"
echo What location would you like to run at?
echo "(This is the location folder like CCE_loc1, CCE_loc2...)"
read -p 'Location #: ' LOCATION

# Check to see if choice exists
found=false

for dir in "${BATS[@]}"; do
    if [[ "$dir" == "$LOCATION" ]]; then
        echo -e "${GREEN}Found '$LOCATION' in directory: $dir ${NC}"
        found=true
    fi
done


for dir in "${CCE[@]}"; do
    if [[ "$dir" == "$LOCATION" ]]; then
        echo -e "${GREEN}Found '$LOCATION' in directory: $dir ${NC}"
        found=true
    fi
done

# If the location/folder was not found, print a message and exit
if [ "$found" = false ]; then
    echo "String '$LOCATION' not found in any directory"
    echo "Quitting..."
    echo
    exit 1
fi

################################################################
##  CHECK TO SEE IF OTHER ENVIRONMENTAL VARIABLES ARE SET
################################################################
echo
echo Checking for environmental variables that need to be set
echo

if [ -z "${CEFI_DATASET_LOC}" ]; then
    echo "CEFI_DATASET_LOC is not set, exiting"
    exit 1
elif [ -z "${CEFI_EXECUTABLE_LOC}" ]; then
    echo "CEFI_EXECUTABLE_LOC not set, exiting"
    exit 1
elif [ -z "${SCRATCH_DIR}" ]; then
    echo "SCRATCH_DIR not set, exiting."
    exit 1
elif [ -z "${SAVE_DIR}" ]; then
    echo "SAVE_DIR not set, exiting"
    exit 1
else
    echo -e "${GREEN}Found all environmental variables, continuing...${NC}"
    echo "#########################################################################################"
    echo "CEFI_DATSET_LOC     :: ${CEFI_DATASET_LOC}"
    echo "CEFI_EXECUTABLE_LOC :: ${CEFI_EXECUTABLE_LOC}"
    echo "SCRATCH_DIR         :: ${SCRATCH_DIR}"
    echo "SAVE_DIR            :: ${SAVE_DIR}"
    echo "#########################################################################################"
fi


################################################################
## PICKING Years CHOICES
################################################################
YEAR_CHOICE=0
echo "#########################################################################################"
echo "##                                 Years to run                                        ##"
echo "#########################################################################################"
while [ "$YEAR_CHOICE" -eq 0 ];
do
    read -r -p "How many years would you like to run?  " YEARS
    echo
    if (( "$YEARS" < 1 )); then
        echo "must choose years >= 1, please choose again"
        echo
    fi
    if (( "$YEARS" >= 1 )); then
        echo -e "${GREEN}Running simulation for ${YEARS} years.${NC}"
        YEAR_CHOICE=1
    fi
done

################################################################
## PICKING Fish Mortality
################################################################
FMORT_CHOICE=0
echo "#########################################################################################"
echo "##                                   Fish Mortality                                    ##"
echo "#########################################################################################"
while [ "$FMORT_CHOICE" -eq 0 ];
do
    read -r -p "How many fish mortality values would you like to try? " FMORT_DISC
    echo
    if (( "$FMORT_DISC" < 1 )); then
        echo "must choose fish mortality values >= 1, please choose again"
        echo
    fi
    if (( "$FMORT_DISC" >= 1 )); then
        echo "Trying  ${FMORT_DISC} values for fish mortality"
        echo
        FMORT_CHOICE=1
    fi
done

FMORT_ARRAY=0
ERROR=0
if (( "$FMORT_DISC" > 1 )); then
    while [ "$FMORT_ARRAY" -eq 0 ];
    do
        echo "You want to try ${FMORT_DISC} different fMort values."
        read -r -p "What should fMort START at ( >= 0.0 )? " FMORT_START
        echo
        read -r -p "What should fMort END at ( <= 1.0 )? " FMORT_END

        if [[ "$FMORT_START" =~ ^0(\.[0-9]+)?$|^1(\.0+)?$ ]]; then
            ERROR=0
            #echo "Fmort start value $FMORT_START is between 0 and 1 (inclusive)"
        else
            echo "FMort start value $FMORT_START is not between 0 and 1 (inclusive), please try again..."
            ERROR+=1
        fi

        if [[ "$FMORT_END" =~ ^0(\.[0-9]+)?$|^1(\.0+)?$ ]]; then
            echo Valid ending value
            #echo "Fmort end value $FMORT_END is between 0 and 1 (inclusive)"
        else
            echo "FMort end value $FMORT_END is not between 0 and 1 (inclusive), please try again..."
            ERROR+=1
        fi
        if [[ "$FMORT_START" < "$FMORT_END" ]] && [[ $ERROR == 0 ]]; then
            echo -e "${GREEN}Using ${FMORT_DISC} fish mortality values between ${FMORT_START} and ${FMORT_END}${NC}"
            FMORT_ARRAY=1
        else
            echo "You need to choose an ending value that is larger than the starting value."
            echo "Please try again"
            echo
        fi

    done
else
    read -r -p "What would you like the fMort parameter to be ( 0.0 <= fmort <= 1.0, DEFAULT=${FMORT_DEFAULT}) ?" FMORT_START

    if [[ "$FMORT_START" =~ ^0(\.[0-9]+)?$|^1(\.0+)?$ ]]; then
        echo -e "${GREEN}Using fMort=${FMORT_START}${NC}"
    else
        echo -e "${GREEN}Using default value fMort=${FMORT_DEFAULT}${NC}"
        FMORT_START="$FMORT_DEFAULT"
        FMORT_END="$FMORT_DEFAULT"
    fi
fi

################################################################
## PICKING Fish Encounters
################################################################
ENC_CHOICE=0
echo "#########################################################################################"
echo "##                                   Fish Encounter                                    ##"
echo "#########################################################################################"
while [ "$ENC_CHOICE" -eq 0 ];
do
    read -r -p "How many encounter values would you like to try  " ENCOUNTER_DISC
    echo
    if (( "$ENCOUNTER_DISC" < 1 )); then
        echo "must choose number of enconter tries values >= 1, please choose again"
        echo
    fi
    if (( "$ENCOUNTER_DISC" >= 1 )); then
        echo "Trying  ${ENCOUNTER_DISC} values for fish encounters"
        echo
        ENC_CHOICE=1
    fi
done

ENC_ARRAY=0
ERROR=0
if (( "$ENCOUNTER_DISC" > 1 )); then
    while [ "$ENC_ARRAY" -eq 0 ];
    do
        echo You want to run multiple runs for different encounter values.
        read -r -p "What should encounter START at (>=30) ? " ENCOUNTER_START
        echo
        read -r -p "What should encounter END at (<=120) ? " ENCOUNTER_END
        echo

        if (( "$ENCOUNTER_START" >= 30 && "$ENCOUNTER_START" <= 110 ));  then
            ERROR=0
        else
            echo "Encounter start value $ENCOUNTER_START is not between 30 and 120 (inclusive), please try again..."
            ERROR+=1
        fi

        if (( "$ENCOUNTER_END" >= 30 && "$ENCOUNTER_END" <= 110 )); then
            echo
        else
            echo "Encounter end value $ENCOUNTER_END is not between 30 and 120 (inclusive), please try again..."
            ERROR+=1
        fi
        
        if [[ "$ENCOUNTER_START" < "$ENCOUNTER_END" ]] && [[ $ERROR == 0 ]]; then
            echo -e "${GREEN}Using ${ENCOUNTER_DISC} encounter values between ${ENCOUNTER_START} and ${ENCOUNTER_END}${NC}"
            ENC_ARRAY=1
        else
            echo "You need to choose an ending value that is larger than the starting value."
            echo "Please try again"
            echo
        fi
    done
else
    read -r -p "What would you like the encounter parameter to be (default=${ENCOUNTER_DEFAULT}) ?" ENCOUNTER_START
    if [[ "$ENCOUNTER_START" =~ ^-?[0-9]+$ ]]; then
        if (( "$ENCOUNTER_START" >= 30 && "$ENCOUNTER_START" <= 110 ));  then
            echo -e "${GREEN}Using value encounter=${ENCOUNTER_START}${NC}"
        else
            echo -e "${GREEN}Using default value encounter=${ENCOUNTER_DEFAULT}${NC}"
            ENCOUNTER_START="$ENCOUNTER_DEFAULT"
            ENCOUNTER_END="$ENCOUNTER_DEFAULT"
        fi
    else
        echo -e "${GREEN}Using default value encounter=${ENCOUNTER_DEFAULT}${NC}"
        ENCOUNTER_START="$ENCOUNTER_DEFAULT"
        ENCOUNTER_END="$ENCOUNTER_DEFAULT"
    fi
fi

################################################################
## PICKING K exponent
################################################################
K_CHOICE=0
echo "#########################################################################################"
echo "##                                K Exponent                                           ##"
echo "#########################################################################################"
while [ "$K_CHOICE" -eq 0 ];
do
    read -r -p "How many K exponent values would you like to try  " K_DISC
    echo

    if (( "$K_DISC" < 1 )); then
        echo "must choose number of K exponents tries values >= 1, please choose again"
        echo
    fi
    if (( "$K_DISC" >= 1 )); then
        echo "Trying  ${K_DISC} values for K exponent"
        echo
        K_CHOICE=1
    fi
done

K_ARRAY=0
ERROR=0
if (( "$K_DISC" > 1 )); then
    while [ "$K_ARRAY" -eq 0 ];
    do
        echo You want to run multiple runs for different encounter values.
        read -r -p "What should K START at (>=1) ? " K_START
        echo
        read -r -p "What should K END at (<=20) ? " K_END
        echo
        
        if (( $(echo "$K_START >= 1 && $K_START <= 20" | bc -l) )); then
            ERROR=0
        else
            echo "K start value $K_START is not between 1 and 20 (inclusive), please try again..."
            ERROR+=1
        fi

        if (( $(echo "$K_END >= 1 && $K_END <= 20" | bc -l) )); then
            echo
        else
            echo "K end value $K_END is not between 1 and 20 (inclusive), please try again..."
            ERROR+=1
        fi
        if (( $(echo "$K_START < $K_END" | bc -l) )) && [[ $ERROR == 0 ]]; then
            echo -e "${GREEN}Using ${K_DISC} K values between ${K_START} and ${K_END}${NC}"
            K_ARRAY=1
        else
            echo "You need to choose an ending value that is larger than the starting value."
            echo "Please try again"
            echo
        fi

    done
else
    read -r -p "What would you like the K exponent parameter to be ( 0.0 <= K <= 20.0, DEFAULT=${K_DEFAULT}) ?" K_START
    if [[ "$K_START" =~ ^-?[0-9]+$ ]]; then
        if (( $( echo "$K_START >= 1 && $K_START <= 20" | bc -l ) )); then
            echo -e "${GREEN} Using K value ${K_START}${NC}"
        else
            echo -e "${GREEN}Using default value K=${K_DEFAULT}${NC}"
            K_START="$K_DEFAULT"
            K_END="$K_DEFAULT"
        fi
    else
        echo -e "${GREEN}Using default value K=${K_DEFAULT}${NC}"
        K_START="$K_DEFAULT"
        K_END="$K_DEFAULT"
    fi
fi

################################################################
## PICKING K50 exponent
################################################################
K50_CHOICE=0
echo "#########################################################################################"
echo "##                            K50 Exponent                                             ##"
echo "#########################################################################################"
while [ "$K50_CHOICE" -eq 0 ];
do
    read -r -p "How many K50 exponent values would you like to try  " K50_DISC
    echo
    if (( "$K50_DISC" < 1 )); then
        echo "must choose number of K50 exponents tries values >= 1, please choose again"
        echo
    fi
    if (( "$K50_DISC" >= 1 )); then
        echo "Trying  ${K50_DISC} values for K50 exponent"
        echo
        K50_CHOICE=1
    fi
done

K50_ARRAY=0
ERROR=0
if (( "$K50_DISC" > 1 )); then
    while [ "$K50_ARRAY" -eq 0 ];
    do
        echo You want to run multiple runs for different encounter values.
        read -r -p "What should K50 START at (>=1) ? " K50_START
        echo
        read -r -p "What should K50 END at (<=20) ? " K50_END
        echo

        if (( $(echo "$K50_START >= 1 && $K50_START <= 20" | bc -l) )); then
            ERROR=0
        else
            echo "K50 start value $K50_START is not between 1 and 20 (inclusive), please try again..."
            ERROR+=1
        fi

        if (( $(echo "$K50_END >= 1 && $K50_END <= 20" | bc -l) )); then
            echo
        else
            echo "K50 end value $K50_END is not between 1 and 20 (inclusive), please try again..."
            ERROR+=1
        fi
        if (( $(echo "$K50_START < $K50_END" | bc -l) )) && [[ $ERROR == 0 ]]; then
            echo -e "${GREEN}Using ${K50_DISC} K50 values between ${K50_START} and ${K50_END}${NC}"
            K50_ARRAY=1
        else
            echo "You need to choose an ending value that is larger than the starting value."
            echo "Please try again"
            echo
        fi

    done
else
    read -r -p "What would you like the K50 exponent parameter to be ( 0.0 <= K50 <= 20.0, DEFAULT=${K50_DEFAULT}) ?" K50_START
    if [[ "$K50_START" =~ ^-?[0-9]+$ ]]; then
        if (( $( echo "$K50_START >= 1 && $K50_START <= 20" | bc -l ) )); then
            echo -e "${GREEN} Using K50 value ${K50_START}${NC}"
        else
            echo -e "${GREEN}Using default value K50=${K50_DEFAULT}${NC}"
            K50_START="$K50_DEFAULT"
            K50_END="$K50_DEFAULT"
        fi
    else
        echo -e "${GREEN}Using default value K50=${K50_DEFAULT}${NC}"
        K50_START="$K50_DEFAULT"
        K50_END="$K50_DEFAULT"
    fi
fi
echo "#########################################################################################"
echo "#########################################################################################"
echo This will now run the following command for the parallel
echo runner. You can save this command for later if you want
echo to run with the same parameters, and not go through this
echo again.
echo "#########################################################################################"
echo -e "${CYANBOLD}./parallel_loop.sh \
${LOCATION} ${YEARS} \
${FMORT_DISC} ${FMORT_START} ${FMORT_END} \
${ENCOUNTER_DISC} ${ENCOUNTER_START} ${ENCOUNTER_END} \
${K_DISC} ${K_START} ${K_END} \
${K50_DISC} ${K50_START} ${K50_END} ${NC}"
echo "#########################################################################################"
echo
echo

TOTAL_RUNS=$(( FMORT_DISC * ENCOUNTER_DISC * K_DISC * K50_DISC ))

echo -e "${YELLOW}This command will now run ${TOTAL_RUNS} MOM6 individual programs for ${YEARS} years each."
read -r -p "Is this desired?  [y/N] " RESPONSE
echo -e "${NC}"
echo

if [[ "$RESPONSE" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo running MOM6-FEISTY...
    ./parallel_loop.sh \
    "${LOCATION}" "${YEARS}" \
    "${FMORT_DISC}" "${FMORT_START}" "${FMORT_END}" \
    "${ENCOUNTER_DISC}" "${ENCOUNTER_START}" "${ENCOUNTER_END}" \
    "${K_DISC}" "${K_START}" "${K_END}" \
    "${K50_DISC}" "${K50_START}" "${K50_END}"
    pids+=($!)
    
else
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo OK. Not running the program. You can always save
    echo the run command for later use.
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    exit
fi

# echo "./parallel_run.sh \
# LOCATION YEARS \
# FMORT_DISC FMORT_START FMORT_END \
# ENC_DISC ENCOUNTER_START ENCOUNTER_END \
# K_DISC K_START K_END \
# K50_DISC K50_START K50_END"

# echo "./parallel_run.sh \
# ${LOCATION} ${YEARS} \
# ${FMORT_DISC} ${FMORT_START} ${FMORT_END} \
# ${ENC_DISC} ${ENCOUNTER_START} ${ENCOUNTER_END} \
# ${K_DISC} ${K_START} ${K_END} \
# ${K50_DISC} ${K50_START} ${K50_END}"

