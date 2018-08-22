#!/bin/bash

node_def="/var/local/bash-enc/nodes/${1}.yaml"

[ -f $node_def ] && cat $node_def
