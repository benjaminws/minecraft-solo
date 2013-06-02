Minecraft Solo
==============

A quick and dirty chef-solo setup for setting up a minecraft server.

Getting Started
---------------

Make sure you have a server. The cookbook only supports debian/ubuntu for now :(

Now run the deploy script.

    $ ./dploy.sh <hostname_or_ip>

This will attempt to ssh to your server, upload all the needed files, and run
chef-solo. If you don't want to ssh to the server as the current `$USER`, set
`DEPLOY_USER='user'` before you run the script, or export it in your shell rc file.

That should do it.
