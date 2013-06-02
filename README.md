Minecraft Solo
==============

A quick and dirty chef-solo setup for setting up a minecraft server.

Getting Started
---------------

Something things you'll need to get started:

  * A small server/vps (something with at least 1G of RAM)
  * Chef installed on the above server
  * Patience

Install Chef on the server
--------------------------

Follow the recommended instructions for your sever here:

http://www.opscode.com/chef/install/

Deploy the chef-solo stuff and run chef-solo
---------------------------------------------

    $ ./dploy.sh <hostname_or_ip>

This will attempt to ssh to your server, upload all the needed files, and run
chef-solo. If you don't want to ssh to the server as the current `$USER`, set
`DEPLOY_USER='user'` before you run the script, or export it in your shell rc file.

That should do it.

Configuring
-----------

Basically this repo is just a way to deploy the chef-minecraft cookbook easily with
chef-solo. Any attribute for that cookbook, found here:
https://github.com/gregf/cookbook-minecraft/blob/master/attributes/default.rb,
can be set in the `solo.js`. Most importantly, you'll probably need an
operator or two defined. You may also need to define how much memory to
allocate to the jvm.
