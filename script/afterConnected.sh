#!/bin/sh

export CISCO_SPLIT_INC=0

root=~/git/server.dns
HOSTNAME=`hostname`

cd ${root}
. script/user.sh

case "${reason}" in

  connect)
    node_modules/.bin/coffee script/record.coffee -u ${oauth2user} -p ${oauth2pass} --add vpn.net ${HOSTNAME} A ${INTERNAL_IP4_ADDRESS}
    echo "nameserver ${INTERNAL_IP4_DNS}" |resolvconf -a tun0.vpn
    ;;

  disconnect)
    echo "nameserver ${INTERNAL_IP4_DNS}" |resolvconf -d tun0.vpn 
    node_modules/.bin/coffee script/record.coffee -u ${oauth2user} -p ${oauth2pass} --del vpn.net ${HOSTNAME} A
    ;;

esac

unset INTERNAL_IP4_DNS

. /usr/share/vpnc-scripts/vpnc-script