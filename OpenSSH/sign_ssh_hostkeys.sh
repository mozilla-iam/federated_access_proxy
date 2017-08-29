#!/bin/bash

SERVER_CA="server_ca"
CA_EXPIRE="+64w"

[ -f ${SERVER_CA} ] || {
	echo "No $(SERVER_CA) found, I can't sign without a CA!"
	exit 128
}

[ $# -lt 2 ] && {
	echo "USAGE $0 <ssh_host_cn> <ssh_host_key.pub> [ssh_host_key.pub] ..."
	exit 127
}

HOST_CN=$1
shift

for i in $*; do
	ssh-keygen -s ${SERVER_CA} -I host_auth_server -h -n ${HOST_CN} -V ${CA_EXPIRE} "$i"
done
