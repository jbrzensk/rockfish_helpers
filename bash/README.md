# BASH helpers

## Custom .bashrc commands
You can setup your custom commands by editing the ```.bashrc``` file in your home folder on a server.

For example, maybe we want to list files by modification time in human-readable format, with all the long listing information.
We are tired of running ```ls -altrh``` and would like something shorter.

You can edit the ```.bashrc``` file located in your home folder.
To edit using nano, we could run the command:
```nano ~/.bashrc```

In the editor, there are already some lines that say
```alias XX=yyyyyyy```

we are going to add our own to this. Add the line:

```alias lr='ls -alrFht'```

Push ```Ctrl-X``` to exit, and say ```Y``` to accept the changes.

Now we reload the ```.bashrc``` file with:

```source ~/.bashrc```, and run our new shortcut command ```lr```.


## catch_example
A sample bash script showing how to kill multiple processes with a single Ctrl-C.

