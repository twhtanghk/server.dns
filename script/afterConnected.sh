#!/bin/sh

export CISCO_SPLIT_INC=0

root=~/git/server.dns
HOSTNAME=`hostname`

cd ${root}
. script/user.sh
node_modules/.bin/coffee script/record.coffee -u ${oauth2user} -p ${oauth2pass} --del vpn.net ${HOSTNAME} A 
node_modules/.bin/coffee script/record.coffee -u ${oauth2user} -p ${oauth2pass} --add vpn.net ${HOSTNAME} A ${INTERNAL_IP4_ADDRESS}

. /usr/share/vpnc-scripts/vpnc-script