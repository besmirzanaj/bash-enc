#!/bin/bash

node_def="/var/local/enc/nodes/${1}.yaml"

[ -f $node_def ] && cat $node_def
