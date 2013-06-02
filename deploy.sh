#!/bin/bash

HOST="$1"
: ${DEPLOY_USER:=$USER}

tar cj . | ssh -o 'StrictHostKeyChecking no' "$DEPLOY_USER@$HOST" '
    sudo rm -rf ~/chef &&
    mkdir ~/chef &&
    cd ~/chef &&
    tar xj &&
    sudo CHEF_USER=$USER /usr/bin/chef-solo -c solo.rb -j solo.js'
