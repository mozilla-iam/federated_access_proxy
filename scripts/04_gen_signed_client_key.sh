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
	echo "USAGE $0 <username> [group,group,...]"
	exit 127
}

USERNAME=$1
GROUP_DATA=$2

# SSHKEY_CERT_MAX_PRINCIPALS is 256 (we reserve one for the user name so 255 are left to use for group data)
# Groups are comma separated
tmp="${GROUP_DATA//[^,]}"
[ ${#tmp} -gt 255 ] && {
        echo "Too many groups passed for us to handle, maximum is 255"
        exit 129
}

# Generate serial file if it does not exist.
# This is used to count and reference all certificates generated
serial=0
[ -f ${CA_USER_SERIAL_FILE} ] && {
    serial=$(cat "${CA_USER_SERIAL_FILE}")
}
serial=$((serial + 1))
echo $serial > "${CA_USER_SERIAL_FILE}"

mkdir -p "${USER_KEY_DIR}"
chmod 0700 "${USER_KEY_DIR}"
# Just in case, event thus this is not supposed to happen.
rm -f ${USER_KEY_FILE}*

# This key is meant to be directly stored in the ssh-agent, and never on disk after creation,
# hence the empty passphrase
ssh-keygen -t ${USER_KEY_ALG} -b ${USER_KEY_BIT} -C "${USER_KEY_COMMENT}" -f ${USER_KEY_FILE} -N '' || {
	echo "Failed to create user key"
	exit 126
}

# This is the signature of the key
ssh-keygen -z ${serial} -s ${CA_USER_KEY} -I "user_key_${USERNAME}" -n "${USERNAME}${GROUP_DATA}" \
    -V ${USER_KEY_EXPIRATION} ${USER_KEY_FILE} || {
	echo "Failed to sign user key"
	rm -f ${USER_KEY_FILE}*
	exit 125
}

# Optional: Collect certificates we issued in case we need to revoke them later
# mkdir -p certs
#cp ${USER_KEY_FILE}-cert.pub ./certs

echo "Key and certificate generated for user ${USERNAME}, please securely remove them after use:"
ls -la ${USER_KEY_DIR}
