# rockfish_helpers

Scripts and environments for the rockfish server at SIO

This is separated into multiple folders:

## [python](/python): Python helpers for rockfish    

[environment_builder](/python/environment_builder.sh): This function builds an environment for MOM analysis. The code can be reused to build other environments for other projects. It also included a *[mom_requirements.txt]*(/python/mom_requirements.txt) file, which has everything pip needs to create an environment for running the diagnostics in the MOM6 diagnostics folder.
  
- [jupyter_notebook_helper](/python/jupyter_notebook_helper.sh): This is a script for starting a Jupyter notebook instance. It also gives the command to SSH tunnel into Rockfish to your Jupyter instance.
