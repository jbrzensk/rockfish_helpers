#!/usr/bin/env bash
# ======================================================================
# NAME
#
#   jupyter_notebook_helper.sh
#
# DESCRIPTION
#
#   A besh shell utility to help you create a Jupyter Notebook
#   instance on a remote computer, and returns the ssh command
#   which will connect with the Jupyter Notebook instance 
#   generated.
#
# USAGE
#
#   Start Jupyter Notebook Instance
#
#     ./jupyter_notebook_helper.sh
#
# LAST UPDATED
#
#   Sptember 25, 2024
#
# ----------------------------------------------------------------------
#
# GET INFO ABOUT CURRENT MACHINE ENVIRONMENT
#
# Picking a random port. Does rockfish have these open??
# This picks a port, and rockfish decides the closest to use.
port=$(shuf -i8000-9999 -n1)
node=$(hostname -s)
user=$(whoami)

#cluster=$(hostname -f | awk -F"." '{print $2}')
# cluster not shown on monkfish.
cluster="ucsd"

# print tunneling instructions jupyter-log
echo -e "
For Windows, use another instance of the WSL, or powershell.
MacOS or linux, terminal command to create your ssh tunnel.
Run this command:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ssh -N -L ${port}:${node}:${port} ${user}@${node}.${cluster}.edu
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Windows MobaXterm info (if you need it):
Forwarded port:same as remote port
Remote server: ${node}
Remote port: ${port}
SSH server: ${node}.${cluster}.edu
SSH login: $user
SSH port: 22
Use a Browser on your local machine to go to:
localhost:${port}  (prefix w/ https:// if using password)
"

# load modules or conda environments here

# Run Jupyter Notebook
jupyter-notebook --no-browser --port=${port} --ip=${node}
