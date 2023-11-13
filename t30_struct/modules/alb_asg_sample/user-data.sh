#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
opts="-o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef -y --allow-downgrades --allow-remove-essential --allow-change-held-packages"
apt-get  update
apt-get $opts upgrade
apt-get $opts install ec2-instance-connect vim busybox less

cat > index.html <<EOF
<h1>Hello, World</h1>
EOF
nohup busybox httpd -f -p ${server_port} &
