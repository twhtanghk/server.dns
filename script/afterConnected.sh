#!/bin/sh

export CISCO_SPLIT_INC=0
unset INTERNAL_IP4_DNS

root=~/git/server.dns
HOSTNAME=`hostname`

cd ${root}
. script/user.sh

case "${reason}" in

  connect)
    node_modules/.bin/coffee script/record.coffee -u ${oauth2user} -p ${oauth2pass} --add vpn.net ${HOSTNAME} A ${INTERNAL_IP4_ADDRESS}
    ;;

  disconnect)
    node_modules/.bin/coffee script/record.coffee -u ${oauth2user} -p ${oauth2pass} --del vpn.net ${HOSTNAME} A 
    ;;

esac

. /usr/share/vpnc-scripts/vpnc-script