#!/bin/bash

: ${DEPLOY_USER:=$USER}

function tar_sync {
    # Deprecating this because it's slow. Good times though.
    local hostname=$1; shift;
    tar cj . | ssh -o 'StrictHostKeyChecking no' "$DEPLOY_USER@$HOST" '
        sudo rm -rf ~/chef &&
        mkdir ~/chef &&
        cd ~/chef &&
        tar xj &&
        sudo CHEF_USER=$USER /usr/bin/chef-solo -c solo.rb -j solo.js'
}

function rsync_sync {
    # Make this less greedy. Generate a file list or something
    local hostname=$1; shift;
    rsync -av -H --progress --delete . $DEPLOY_USER@$hostname:~/chef
    run_chef_solo $hostname;
}

function run_chef_solo {
    local hostname=$1; shift;
    ssh -o 'StrictHostKeyChecking no' "$DEPLOY_USER@$hostname" 'cd ~/chef && sudo CHEF_USER=$USER /usr/bin/chef-solo -c solo.rb -j solo.js'
}

function main {
    local hostname=$1; shift;
    echo "Running chef-solo with the contents of this repo on $DEPLOY_USER@$hostname"
    rsync_sync $hostname;
}

main $*;
