#!/bin/bash
source $(dirname ${BASH_SOURCE[0]})/settings.conf || {
	echo "settings.conf file required"
	exit 127
}

cd $(dirname ${BASH_SOURCE[0]})

function keygen()
{
	ssh-keygen -N '' -t ${CA_KEY_ALG} -b ${CA_KEY_BIT} -C "${CA_USER_COMMENT}" $*
}

keygen -f "${CA_USER_KEY}" || {
	echo "Failed to create client CA"
	exit 127
}
echo "Protect ${CA_USER_KEY} private key file with the upmost level of care. It is extremely sensitive and can give access to ANY host trusting it's public key."
