# Python helpers for rockfish    

## [Creating a virtual Environment on Rockfish](create_python_environment.md)
Text file for creating a virtual Python environment on any cluster, including Rockfish.

## [Running a Jupyter Notebook Remotely on Rockfish](Jupyter_Notebook_on_Rockfish.md)
Text file for how to spin up your own Jupyter session on a cluster. Applies to any cluster, not just Rockfish.

### [environment_builder.sh](environment_builder.sh):
This function builds an environment for MOM analysis. The code can be reused to build other environments for other projects. It also included a mom_requirements.txt file, which has everything pip needs to create an environment for running the diagnostics in the MOM6 diagnostics folder.

### [jupyter_notebook_helper](jupyter_notebook_helper.sh):
This is a script for starting a Jupyter notebook instance. It also gives the command to SSH tunnel into Rockfish to your Jupyter instance.
