# bash-enc
A quick and dirty ENC (external node classifier) for puppet.

This is an effort to have a quick enc for a small server farm (e.g less than 50 hosts and without r10k) but that will solve issues of node belonging to an environment and which classes are applicable to a specific node.

In conjuction with https://github.com/besmirzanaj/puppet-master this is a working document and also a live lab test bed for puppet learning.

The code was adopted from here https://codingbee.net/tutorials/puppet/puppet-external-node-classifiers-enc.

## Setup
Let's set this up anywhere out of puppet server config or bin files:

    [ -d /var/local/ ] || mkdir -p /var/local/
    cd /var/local/
    git clone https://github.com/besmirzanaj/bash-enc

Now we can place node definitions in <code>/var/local/bash-enc/nodes/</code> folder. 

In https://github.com/besmirzanaj/puppet-master I have made sure to create the roles/profiles model to manage node configurations. Let's assume we need to build a classical web application with apache as frontend and a mariadb database. We need at least two nodes for each role.

Node <code>vps1.cloudalbania.com</code> will be our web server and <code>vps3.cloudalbania.com</code> will be our database server. We will assume all modules are in place and available and that we have at least three profiles for our two roles:
    
    profile common: a common profile containng all basic modules applicable to all nodes
    profile web : web server customization profile
    profile mariadb: a profile for mariadb indtance management
    
We are arranging these profiles as we mentioned earlier in two roles:

    role maria-db
    role web
    
Here is their location in <code>production</code> environment. The content is available in the relative [repo](https://github.com/besmirzanaj/puppet-master).

    [root@vps4 ~]# ll /etc/puppetlabs/code/environments/production/modules/profile/manifests/
    total 12
    -rw-r--r--. 1 root root 373 Aug 21 17:48 common.pp
    -rw-r--r--. 1 root root 539 Jul 20 00:20 maria-db.pp
    -rw-r--r--. 1 root root  50 Aug 20 16:56 web.pp

and here are the roles:

    [root@vps4 ~]# ll /etc/puppetlabs/code/environments/production/modules/role/manifests/
    total 12
    -rw-r--r--. 1 root root 55 Aug 21 17:52 maria-db.pp
    -rw-r--r--. 1 root root 53 Aug 21 17:53 puppet.pp
    -rw-r--r--. 1 root root 75 Aug 21 17:47 web.pp

## ENC configuration
Let's change puppet server to read node classifications from the new enc. Add the following to your puppet.conf.

   cat  /etc/puppetlabs/puppet/puppet.conf
   ...
   node_terminus = exec
   external_nodes = /var/local/bash-enc/enc.sh
   
Now let's add our node classifications in <code>/var/local/bash-enc/nodes/</code>. Based on the [Puppet ENC documentation](https://puppet.com/docs/puppet/5.5/nodes_external.html) we can define our nodes like this:

Web node:

    [root@vps4 ~]# cat /var/local/bash-enc/nodes/vps1.cloudalbania.com.yaml
    ---
    classes:
      - role::web
    environment: production

DB node:

    [root@vps4 ~]# cat /var/local/bash-enc/nodes/vps3.cloudalbania.com.yaml
    ---
    classes:
      - role::maria-db
    environment: production

And that's it. Now we have a bare minimum working ENC. You can try out the ENC functionality by checking the output of the ENC itself:

    22:27 # /var/local/bash-enc/enc.sh vps3.cloudalbania.com
    ---
    classes:
      - role::maria-db
    environment: production



