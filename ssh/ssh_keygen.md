# Key Generation for SSH

This will explain the steps to setup a ssh key on a remote server, so you do not have to type your password to login from a specific computer.

**NOTE: This must be done from each computer you wish to login from**
**NOTE 2: This has been tested for Linux, and Windows using MobeXTerm**

## 1) Check for existing keys

open a command prompt, and check for existing ssh keys by running the command:
```ls ~/.ssh/id_rsa*```
If you see entries like ```id_rsa``` or ```id_rsa.pub``` then you have a public key setup and can skip to step [3](#3-copy-public-key-to-the-remote-server)

## 2) Create public key

To create a new public key, run the command:
```ssh-keygen -t rsa -b 4096 -C "your_email@example.com"```

It will ask you if the default location is ok, say 'yes'. It will ask for a passphrase, you can push 'enter' twice to not have a passphrase. This creates a cool little graphic of your rsa public key.
```
+--[ RSA 4096]----+
|            o.o  |
|            .= E.|
|             .B.o|
|              .= |
|        S     = .|
|       . o .  .= |
|        . . . oo.|
|             . o+|
|              .o.|
+-----------------+
```
## 3) Copy public key to the remote server
Now we copy our key, saved in the default location, to the remote server of our choice.
Run the command:

``` ssh-copy-id yourusername@server.location.edu```

It will ask you for your password ( last time! ), and then confirm the new kay was added to the remote server!

