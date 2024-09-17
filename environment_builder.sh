#!/bin/sh
###########################################################
# Python Environment Builder                              #
###########################################################
#
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#
echo
echo
echo This script simplifies building a Python environment 
echo for you, that can interact with ESMF and netCDF files.
echo It will come with many libraries pre-installed.
echo
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
    echo a specific location, lpease run this script from
    echo that directory. Exiting...
    echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    exit
fi


################################################################
## PICKING PYTHON VERSION
################################################################
FILELIST=($(ls -1 /usr/bin/python*))
echo
echo Found the following Python versions on the computer:
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

for i in "${!FILELIST[@]}"; do
    echo "$((i)): ${FILELIST[i]}"
done
NUM_PYTHONS=$((i+1))

echo
#echo Which would you like to use for the environment?
# echo There are $NUM_PYTHONS pythons.
echo Please note, for ESMF and xESMF, you need to choose the Python3.12

CHOICE=0

while [ "$CHOICE" -eq 0 ];
do
    read -r -p "Which Python would you like to use for the environment?(number)" PYTHON_CHOICE
    if (( $PYTHON_CHOICE <= $i )); then
	    echo "You chose "${FILELIST[$PYTHON_CHOICE]}"".
	    CHOICE=1
    else
	    echo "${PYTHON_CHOICE} is not a valid option, please choose again."
    fi
done


################################################################
## BUILD PYTHON ENVIRONEMNT
################################################################
PYTHON_CMD="${FILELIST[${PYTHON_CHOICE}]}"
echo
#echo "Python command file is ${PYTHON_CMD}"
#echo
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
#echo We are currently in environment:
#INVENV=$(python -c 'import sys; print ("1" if hasattr(sys, "real_prefix") else "0")')

#echo "${INVENV}"
#which python
#which pip
#echo
#sleep 5

echo Loading and installing EMSRF and MOM specific helpers
echo
echo pip install -r mom_requirements.txt
echo
# ACTUAL PIP INSTALL COMMAND, SHOULD CORRECTLY REFERENCE JAREDS
# FILES IN HIS OWN FOLDER. SHOULD HAVE READ ACCES TO THEM.
if [ ! -f mom_requirements.txt ]; then
    echo "Moving mom_requirements.txt file here..."
    cp "${SCRIPT_DIR}"/mom_requirements.txt .
fi

pip install -r mom_requirements.txt

sleep 5
echo

deactivate

echo
echo done.

################################################################
## FINAL HELPER ISNTRUCTIONS
################################################################
echo You can load the environment with the command:
echo "source $PYTHON_ENV_ROOT/$ENV_NAME/bin/activate"
echo 
echo "You can get out of the environment by running the command:"
echo deactivate
echo
echo
echo NOTE: To use the ESMR library, you need gcc13 installed.
echo Either \'module load use.own\' and \'module load openmp\'
echo or make sure gcc -v returns \> 13. Otherwise, xemsf will
echo not work in Python.
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

