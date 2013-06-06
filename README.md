Minecraft Solo
==============

A quick and dirty chef-solo setup for setting up a minecraft server.

Getting Started
---------------

Something things you'll need to get started:

  * A smallish debian/ubuntu instance (something with at least 1G of RAM)
  * Chef installed on the above server
  * Patience

Note that I hope to get RHEL support soon, but feel free to help
(https://github.com/benjaminws/minecraft-solo/issues/2)

Install Chef on the server
--------------------------

Follow the recommended instructions for your sever here:

http://www.opscode.com/chef/install/

Install the needed gems
-----------------------

This assumes you use a version manager like rbenv, rvm, or some other thing that is
probably wrong.

    $ gem install bundler
    $ bundle install

Install the needed cookbooks
----------------------------

    $ bundle exec berks install --path ./cookbooks

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

can be set in the `solo.js`.

Additionally, any attribute here:

http://www.minecraftwiki.net/wiki/Server.properties

can be set in `solo.js` as well.

Most importantly, you'll probably need an operator or two defined. You
may also need to define how much memory you wish to allocate the JVM. On a 1G
machine, 768MB should be plenty for a few users with conservative setting.
