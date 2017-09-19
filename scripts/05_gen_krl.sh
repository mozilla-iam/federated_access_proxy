#!/bin/bash
# Note: Revocation of user keys, if short lived, is generally not needed

source $(dirname ${BASH_SOURCE[0]})/settings.conf || {
	echo "settings.conf file required"
	exit 127
}

[ -f ${CA_USER_KRL_REVOKED} ] || {
    echo "No ${CA_USER_RKL_REVOKED} found, nothing to revoke"
    exit 129
}

cd $(dirname ${BASH_SOURCE[0]})

[ -f ${CA_USER_KEY}.pub ] || {
	echo "No ${CA_USER_KEY}.pub found, I can't sign without a CA!"
	exit 128
}

IFS="
"
keys=$(cat ${CA_USER_RKL_REVOKED})

for k in ${keys}; do
    [ "${k:0:1}" == "#" ] && continue
    ssh-keygen -k -f ${CA_USER_KRL} -s ${CA_USER_KEY}.pub ${k}
done
unset IFS
