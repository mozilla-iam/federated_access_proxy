[![Build Status](https://travis-ci.org/mozilla-iam/federated_access_proxy.svg?branch=master)](https://travis-ci.org/mozilla-iam/federated_access_proxy)

# STATUS: POC

# Federated Access Proxy

![Diagram](/docs/images/hl_diagram.png?raw=true "High-level diagram")

This is a BeyondCorp-style federated access proxy.  Beyond corp is a [USENIX white
paper](https://www.usenix.org/system/files/login/articles/login_dec14_02_ward.pdf)/[concept](https://research.google.com/pubs/pub43231.html)
from 2014, by R.WARD explaining Google's next-gen network perimeter: there is none.  Instead of using network access
control to create a guarded perimeter where only trusted users have access (such as via VPN tunnel, which provides
network access), beyond corp uses things like:

- HTTPS as a transport for all communications to the trusted environment (usually through an HTTPS reverse-proxy
  listening on the Internet).
- Web based authentication (usually with OpenID Connect or SAML w/ 2FA, or any enterprise single sign on solution).
- Direct authentication to the service (zero network trust) all authentication and encryption are end-to-end without any exception.
- No permanent credentials stored on the user's machine, only ephemeral credentials.
- No VPN required (optional).

This federated access proxy implements this (with optional transport proxying for compatibility and latency reasons, for
example SSH protocol can be proxied over HTTPS, or not proxied, at the choice of the operator).

The concepts and code behind the federated acecss proxy can be applied to any command-line client for any protocol that
requires some kind of access token as proof of being authenticated/identified with an identity provider.

# Deployment

## Docker
- `cd Docker`
- Build the image
  - `make` 
- Start the dev local image
  - Populate `compose/local.env` as desired, these are the credstash variables mainly, such as `flask_secret=...` or
    `client_secret=...`
  - `make compose`
- Start the stage, prod images (uses remote image, feel free to override it)
  - `make compose-staging`, `make compose-production`, ...

## Cloudformation
- `./deploy-{dev,prod,...}.sh`
- it reads from `cloudformation/*`

## Credstash

See https://github.com/fugue/credstash for setup.

Values required:
- `accessproxy.flask_secret`
- `accessproxy.discovery_url`
- `accessproxy.client_secret`
- `accessproxy.client_id`
