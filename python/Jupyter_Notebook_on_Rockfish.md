# **How to run a Jupyter Notebook instance on rockfish.ucsd.edu**
To do this, we need TWO SSH instances to access Rockfish.

- Windows: Two PowerShell instances
- Mac: Two command prompt instances
- Linux: Two shell instances

***In the first SSH window,***

You will SSH into Rockfish. Load your Python environment:

`$ source ~/python_environments/cool_enviro_you_made/bin/activate`

We will run Jupyter Notebook and tell Rockfish which port to send the information to our computer. The port you pick should be random from 2000 to 9000 so you do not conflict with other people on the cluster. I am going to use PORT=1234 for this example.

To start Jupyter Notebooks, we will run the following command:\
`$jupyter-notebook --port=1234 --ip=rockfish --no-browser`

This tells Rockfish to start a Jupyter Notebook instance using Rockfish's IP address and port 1234 to send data.

Make a note of the website addresses Jupyter Notebooks prints to the screen. Look for the one that starts:\
[`http://127.0.0.1:8108/tree?token=really-long-letters-numbers`](http://127.0.0.1:8108/tree?token=really-long-letters-numbers)\
We are going to need that to login with our browser.

***In the second ssh window:***\
We are going to SSH tunnel, connecting the port Jupyter Notebook is using on Rockfish to the same port on our local computer.

`$ssh -L 1234:rockfish:1234 username@rockfish.ucsd.edu`

This command uses SSH to link port 1234 on Rockfish to 1234 locally, and it logs in using the username and password provided.
If all goes well, nothing will happen. Open a browser on your local computer, and copy and paste the URL Jupyter printed on SSH screen 1.

If all goes well, you should have a browser window showing an instance of jupyter notebook running on Rockfish.
