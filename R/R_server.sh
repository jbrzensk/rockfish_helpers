#!/usr/bin/env bash
# ======================================================================
# NAME
#
#   R_server.sh
#
# DESCRIPTION
#
#   A bash shell utility to run R server on rockfish, in a container,
#   and generate the appropriate command line to visualize on a remote
#   web browser. This script generates some directories, so for sanity
#   you should run this in the same location each time.
#
#  More R libraries can be downloaded by running the command:
#
#     singularity pull docker://rocker/rXXXX
#
#  where XXXX is a specific R instance found at 
#  https://rocker-project.org/, and change the name of
#  R_CONTAINER in the script below.
#
#
# USAGE
#
#   To start a R instance in a container on a specific port
#
#     ./R_server.sh
#
# LAST UPDATED
#
#   October 7, 2024
#
# ----------------------------------------------------------------------
# Singularity R container version
R_CONTAINER=/home/jabrzenski/USER/containers/rstudio_4.2.2.sif

WORKING_DIR=$(pwd)
USER_NAME=$(whoami)
NODE=$(hostname -s)
CLUSTER=$(hostname -f | awk -F"." '{print $2}')

# Check if singularity module has been loaded
if ! command -v singularity 2>&1 >/dev/null
then
    echo "singularity could not be found"
    echo "please run: "
    echo "           module load singularity"
    echo "before running this script"
    echo ""
    exit 1
fi


# Make run and var directory to store R specific files
if [ -d $WORKING_DIR/run ]; then
	echo "run directory exists"
else
	echo "making run directory..."
	mkdir -p run
fi

if [ -d /var-lib-rstudio-server ]; then
	echo "var-lib-rstudio-server exists."
else
	echo "making var-lib-rstudio-server directory..."
	mkdir -p var-lib-rstudio-server
fi

# Create and store database.conf file
CONF_FILE=database.conf
if grep -q "^directory=/var/lib/rstudio-server$" "$CONF_FILE"; then
	echo "found appropriate database.conf file"
else
	echo "making dabase.conf file"
	printf 'provider=sqlite\ndirectory=/var/lib/rstudio-server\n' > database.conf
fi

# Pick random port to start Rserver on
PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')

singularity exec    --bind run:/run,var-lib-rstudio-server:/var/lib/rstudio-server,database.conf:/etc/rstudio/database.conf    $R_CONTAINER    /usr/lib/rstudio-server/bin/rserver --server-user=$(whoami) --www-port $PORT &

# Last spawned process, mostly works
PID=$!

cat 1>&2 <<END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. SSH tunnel from your workstation using the following command:

   ssh -N -L 8787:${HOSTNAME}:${PORT} ${USER_NAME}@${NODE}.${CLUSTER}.edu 

   and point your web browser to http://localhost:8787

When done using RStudio Server, terminate the container job by:

1. Exit the RStudio Session ("power" button in the top right corner of the RStudio window)
2. In the current window, you need to kill the 'starter' program.
   Run the following command:

       kill -9 ${PID}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
END
