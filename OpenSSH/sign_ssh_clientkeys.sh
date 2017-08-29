#!/bin/bash

CLIENT_CA="client_ca"
CA_EXPIRE="+1h"

[ -f ${CLIENT_CA} ] || {
	echo "No $(CLIENT_CA) found, I can't sign without a CA!"
	exit 128
}

[ $# -lt 2 ] && {
	echo "USAGE $0 <username> <keyfile>"
	exit 127
}

ssh-keygen -s ${CLIENT_CA} -I user_username -n $1 -V ${CA_EXPIRE} $2
