#!/bin/bash
source settings.conf || {
	echo "settings.conf file required"
	exit 127
}

[ -f ${CA_HOST_KEY} ] || {
	echo "No $(CA_HOST_KEY) found, I can't sign without a CA!"
	exit 128
}

[ $# -lt 2 ] && {
	echo "USAGE $0 <ssh_host_cn> <ssh_host_key.pub> [ssh_host_key.pub] ..."
	exit 127
}

HOST_CN=$1
shift

for i in $*; do
	ssh-keygen -s ${CA_HOST_KEY} -I host_auth_server -h -n ${HOST_CN} -V ${HOST_KEY_EXPIRATION} "$i"
done
