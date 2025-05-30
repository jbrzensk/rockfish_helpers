# BASH helpers

## Custom .bashrc commands
You can setup your custom commands by editing the ```.bashrc``` file in your home folder on a server.

For example, we may want to list files by modification time in human-readable format, with all the long listing information.
We are tired of running ```ls -altrh``` and would like something shorter.

You can edit the ```.bashrc``` file in your home folder.
To edit using nano, we could run the command:
```nano ~/.bashrc```

In the editor, there are already some lines that say
```alias XX=yyyyyyy```

We are going to add our own to this. Add the line:

```alias lr='ls -alrFht'```

Push ```Ctrl-X``` to exit, and say ```Y``` to accept the changes.

Now we reload the ```.bashrc``` file with:

```source ~/.bashrc```, and run our new shortcut command ```lr```.


## catch_example
A sample bash script showing how to kill multiple processes with a single Ctrl-C.

Navigate to the ```catch_example``` folder and run the command:
```./parent.sh```

This starts a parent process, which spawns five child processes. These five processes were spawned from the original parent process, and the interface is updated every few seconds to show that they are still running.

Usually, you would need to kill off each child process individually, but the parent tracks the PIDs of the child processes, and when the parent is killed, it also kills the PIDs it spawned, using the ```cleanup``` function in parent.sh You can add this tracking to your bash script to help kill many processes that are spawned in parallel.

## color_text
Some bash scripts show how to display text and special characters in colors.

Navigate to the ```color_text``` folder and run the commands:

```./color_text.sh```
- Will display some basic examples of colorizing text with ```echo``` and ```printf``` statements. It also shows how to make functions and display those with ```printf``` commands

```rf_splash.sh```
- A representation of the rockfish splash screen will be displayed.

```print256colors.sh```
- Prints out all 256 colors a Linux bash display can show. Color codes can be used; see ```rf_splash.sh``` for examples of using the color codes.

## parallel_download
An example of how to download, in parallel, a set of files from one remote server, to the current server.
It is currently setup to download 10-2GB files from monkfish to rockfish.
(You must have ssh keys setup between rockfish nad monkfish to run the example)
- Login to rockfish and navigate to wherever you have rockfish_helpers/bash/parallel_download
- Edit the parallel_download.sh file to reflet your user name, and the full install location.
- View the filenames.txt file ( ```cat filenames.txt``` ) to see where the desired files are located.
- To download the 10 files in parallel, run ```./parallel_download.sh 10 filenames.txt```
- You will see output for only the first parallel file ( the others are done in the background )
  
