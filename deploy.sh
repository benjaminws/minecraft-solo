#!/bin/bash

host="$1"

tar cj . | ssh -o 'StrictHostKeyChecking no' "$host" '
    sudo rm -rf ~/chef &&
    mkdir ~/chef &&
    cd ~/chef &&
    tar xj &&
    sudo CHEF_USER=$USER /usr/bin/chef-solo -c solo.rb -j solo.js'
