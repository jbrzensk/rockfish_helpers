#!/usr/bin/env bash
# ======================================================================
# NAME
#
#   environment_builder.sh
#
# DESCRIPTION
#
#   A bash shell utility to help you create a Python environment on 
#   your Linux machine
#
# USAGE
#
#   Create a Python Environment in the local folder
#
#     ./environemnt_builder.sh
#
# LAST UPDATED
#
#   September 25, 2024
#
# ----------------------------------------------------------------------

###########################################################
# Python Environment Builder                              #
###########################################################

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo This script simplifies building a Python environment 
echo for you, that can interact with ESMF and netCDF files.
echo It will come with many libraries pre-installed.
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo
echo What would you like the environment called?

read -p 'Environment Name: ' ENV_NAME

echo
echo The environment will be called $ENV_NAME
echo

################################################################
## CREATING THE DIRECTORY
################################################################

PYTHON_ENV_ROOT=$(pwd)

echo "New folder will be created at $PYTHON_ENV_ROOT/$ENV_NAME"
read -r -p "Is this desired?  [y/N] " RESPONSE
echo
echo

if [[ "$RESPONSE" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo creating directories
else
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    echo OK. Not making the directory. If you want this in
    echo a specific location, please run this script from
    echo that directory. Exiting...
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    exit
fi


################################################################
## PICKING PYTHON VERSION
################################################################
echo
echo
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo Choose a Python version to use:
echo
echo
echo "If using ESMF, Python must be >= 3.12"
echo
echo "If you do not see python3.12, maybe try 'ml python'?"
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo

# Get the system default Python version
SYSTEM_PYTHON=$(command -v python3)
SYSTEM_VERSION=$($SYSTEM_PYTHON --version 2>/dev/null | awk '{print $2}')

# Find available Python versions in /usr/bin
AVAILABLE_PYTHONS=($(ls /usr/bin/python* 2>/dev/null))

# Combine system Python with available ones
CHOICES=("(System Default: $SYSTEM_VERSION)")
PYTHON_PATHS=("$SYSTEM_PYTHON")  # Store paths separately for easy selection

for py in "${AVAILABLE_PYTHONS[@]}"; do
    VERSION=$($py --version 2>/dev/null | awk '{print $2}')
    CHOICES+=("$py ($VERSION)")
    PYTHON_PATHS+=("$py")
done

# Display the choices in a selectable menu
echo "Select a Python version to use:"
select choice in "${CHOICES[@]}"; do
    if [[ -n "$choice" ]]; then
        # Extract the corresponding Python binary path
        INDEX=$((REPLY - 1))  # Adjust for zero-based indexing
        PYTHON_CMD="${PYTHON_PATHS[$INDEX]}"
        echo "You selected: $PYTHON_CMD"
        export PYTHON_CMD  # Make it available for the session
        break
    else
        echo "Invalid selection. Try again."
    fi
done

################################################################
## BUILD PYTHON ENVIRONEMNT
################################################################

#PYTHON_CMD="${FILELIST[${PYTHON_CHOICE}]}"

echo
echo Building environment
echo
echo "${PYTHON_CMD}" -m venv "${ENV_NAME}"

"${PYTHON_CMD}" -m venv "${ENV_NAME}"

echo
echo Environment built
echo Loading environment....
echo
sleep 1

# LOAD NEW ENVIRONMENT
source "${PYTHON_ENV_ROOT}"/"${ENV_NAME}"/bin/activate
echo

echo Loading and installing EMSRF and MOM specific helpers
echo
echo pip install -r mom_requirements.txt
echo

# ACTUAL PIP INSTALL COMMAND, SHOULD CORRECTLY REFERENCE JAREDS
# FILES IN HIS OWN FOLDER. SHOULD HAVE READ ACCES TO THEM.

# Look for existing mom_requirements
if [ -f mom_requirements.txt ]; then
    echo "Moving existing mom_requirements to OLD_mom_requirements.txt..."
    mv mom_requirements.txt OLD_mom_requirements.txt
fi	

echo "Moving mom_requirements.txt file here..."
cp "${SCRIPT_DIR}"/mom_requirements.txt .

# CHECK TO SEE WHAT SERVER WE ARE ON, CHANGE PATH APPROPRIATELY
SERVER_NAME=$(hostname)

# ROCKFISH
# esmpy @ file:///home/jabrzenski/esmf/src/addon/esmpy
# MONKFISH
# esmpy @ file:///home/jabrzenski/Programs/esmf/src/addon/esmpy

if [[ "$SERVER_NAME" == "rockfish" ]]; then
    ESMPY_PATH="file:///home/jabrzenski/esmf/src/addon/esmpy"
elif [[ "$SERVER_NAME" == "monkfish" ]]; then
    ESMPY_PATH="file:///home/jabrzenski/Programs/esmf-8.5.0/src/addon/esmpy"
else
    NEW_PATH="file:///default/path/to/esmpy"
fi

sed -i "s|esmpy @ file://.*|esmpy @ $ESMPY_PATH|" mom_requirements.txt

pip install -r mom_requirements.txt

sleep 5
echo

deactivate

echo
echo done.

################################################################
## FINAL HELPER INSTRUCTIONS
################################################################

echo You can load the environment with the command:
echo "source $PYTHON_ENV_ROOT/$ENV_NAME/bin/activate"
echo 
echo "You can get out of the environment by running the command:"
echo deactivate
echo
echo
echo NOTE:

if [[ "$SERVER_NAME" == "rockfish" ]]; then
    echo ROCKFISH: To use the ESMR library, you need gcc13 installed.
    echo Either \'module load use.own\' and \'module load openmp\'
    echo or make sure gcc -v returns \> 13. Otherwise, xemsf will
    echo not work in Python.
    echo
fi

if [[ "$SERVER_NAME" == "monkfish" ]]; then
echo MONKFISH: please load the ESMF module with
echo " 'module load esmf' "
echo
fi

echo 
echo done.
echo


# If you want to save your surrent Python setup to load on
# another environment, run the following
#  pip freeze > requirements.txt
#
# This will save the everything installed with pip in 
# requirements.txt. Then, when building a new environment,
# you run the command:
#  pip install -r requirements.txt
# and pip will attempt to install all of your other files

