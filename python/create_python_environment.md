# Setting Up a Python Environment on a Cluster
Setting up your own Python environment is a good practice; it saves relying on other packages like `conda` to manage things, and in an HPC environment, installing your own libraries without impacting other users is generally thought of as a polite thing to do.

## To Set Up An Environment
To set up your own Python environment, we need somewhere to store all of the information *about* that environment.
Most generally, we make a subdirectory in the `$HOME` directory to store our many possible Python environments.

Assuming you are in the home directory ( run `cd` to be sure ), run the following commands:
- `$ mkdir python_environments`
- `$ cd python_environments`

Now, think of an environment name you will remember.\
We will make the Python environment *SPECIFIC* to a Python version.\
To list the versions of Python available, run:\
- `ls /usr/bin/python*`

This shows us all of the Pythons available on Rockfish. I recommend the latest version, but some libraries are built on older Pythons.

We are going to build a new environment with the environment name and Python version using the following command:
- `$ pythonX.YY -m venv new_environment_name`

This creates a new virtual environment named `new_environment_name`. We make this environment so we can customize Python to our needs and not mess with other users' requirements.

When we want to load the environment, run 
- `$ source ~/python_environments/new_environment_name/bin/activate`

Now, our environment is loaded, and our prompt has the name in parentheses in front of it.

**`(new_environment_name)user@location: $`**

You can `pip install` all of the appropriate modules you need specific to this environment. Make sure to run `pip install jupyter` if you want to use Jupyter Notebooks.

Once Jupyter is installed, you can run an instance of it, but it is very slow. Use the [Jupyter_Notebook_on_Rockfish](Jupyter_Notebook_on_Rockfish.md) to see how to run it on the cluster, and do the visualization on your local computer.
