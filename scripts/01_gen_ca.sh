#!/bin/bash
source settings.conf || {
	echo "settings.conf file required"
	exit 127
}

function keygen()
{
	ssh-keygen -t ${CA_KEY_ALG} -b ${CA_KEY_BIT} -C "${CA_HOST_COMMENT}" $*
}

keygen -f "${CA_HOST_KEY}" || {
	echo "Failed to create server CA"
	exit 127
}
echo "Protect ${CA_HOST_KEY} private key file as you would \`/etc/ssh/ssh_host_keys\`"
