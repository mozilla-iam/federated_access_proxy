# Set of example scripts to create your own OpenSSH PKI

These scripts are meant as example and not for production use.

## Server-side setup

- Copy `*-cert.pub` to the corresponding OpenSSH server's host key directories (such as `/etc/ssh/...` on each server)"
- Ensure `/etc/ssh/sshd_config` contains:
  `HostCertificate /etc/ssh/ssh_host_{rsa,ecdsa,...}_key-cert.pub\`
  `TrustedUserCAKeys /etc/ssh/client_ca.pub`
- Restart `sshd` on these hosts (e.g.`systemctl restart sshd`)

## Client-side setup

- Ensure all clients edit their `~/.ssh/known_hosts` with the following for each key type:"
  `@cert-authority example.net ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbml....` where the key is your CA public key
  (e.g. output of `server_ca.pub`)

**NOTE:** It is advised to use wildcards such as "\*.mozilla.com" instead of the host FQDN where it makes sense as
this shortens the amount of host names needing configuration.
