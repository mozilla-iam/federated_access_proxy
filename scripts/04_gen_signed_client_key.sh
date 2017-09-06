#!/bin/bash
source $(dirname ${BASH_SOURCE[0]})/settings.conf || {
	echo "settings.conf file required"
	exit 127
}

cd $(dirname ${BASH_SOURCE[0]})

[ -f ${CA_USER_KEY} ] || {
	echo "No ${CA_USER_KEY} found, I can't sign without a CA!"
	exit 128
}

[ $# -lt 1 ] && {
	echo "USAGE $0 <username>"
	exit 127
}

USERNAME=$1

mkdir -p "${USER_KEY_DIR}"
chmod 0700 "${USER_KEY_DIR}"
# Jusst in case, event thus this is not supposed to happen.
rm -f ${USER_KEY_FILE}*

# This key is meant to be directly stored in the ssh-agent, and never on disk after creation, hence the empty passphrase
ssh-keygen -t ${USER_KEY_ALG} -b ${USER_KEY_BIT} -C "${USER_KEY_COMMENT}" -f ${USER_KEY_FILE} -N '' || {
	echo "Failed to create user key"
	exit 126
}
# This is the signature of the key
ssh-keygen -s ${CA_USER_KEY} -I user_username -n ${USERNAME} -V ${USER_KEY_EXPIRATION} ${USER_KEY_FILE} || {
	echo "Failed to sign user key"
	rm -f ${USER_KEY_FILE}*
	exit 125
}

echo "Key and certificate generated for user ${USERNAME}, please securely remove them after use:"
ls -la ${USER_KEY_DIR}
