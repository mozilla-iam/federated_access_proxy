#!/usr/bin/env python
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Contributors: Guillaume Destuynder <gdestuynder@mozilla.com>

from flask import Flask, request, session, jsonify
from flask_session import Session
import logging
import os
import sys
import time

app = Flask(__name__)
app.logger.addHandler(logging.StreamHandler(sys.stdout))
app.logger.setLevel(logging.DEBUG)
app.config.from_pyfile('accessproxy.cfg', silent=True)
Session(app)

def verify_cli_token(cli_token, session=session):
    """
    Check the cli_token provided is valid and matches the HTTP session, else clear session / bail
    """
    if (session.get('cli_token')):
        if (cli_token != session.get('cli_token')):
            app.logger.error('User with same session provided a new cli_token, destroying session')
            session.clear()
            return False
        return True
    else:
        return False


@app.route('/', methods=['GET'])
def main():
    """
    Expects ?type=ssh&host={}&port={}&cli_token={}
    """

    # GET parameter set up
    required_params = ['type', 'host', 'port', 'cli_token']
    params = request.args.to_dict()
    if set(required_params) != set(params.keys()):
        return 'Incorrect GET parameters'
    cli_token = params.get('cli_token')
    ssh_host = params.get('host')
    ssh_port = params.get('port')


    # Reverse OIDC Proxy headers set up
    required_headers = ['X-Forwarded-User', 'X-Forwarded-Groups']
    print(request.headers.keys())
    if not set(required_headers).issubset(request.headers.keys()):
        return 'Incorrect HEADERS'
    user = request.headers.get('X-Forwarded-User')
    groups = request.headers.get('X-Forwarded-Groups')

    # Session set up
    session['username'] = user
    session['groups'] = groups
    if (session.get('cli_token') == None):
        session['cli_token'] = cli_token
    else:
        if not verify_cli_token(cli_token):
            return 'cli token verification failure - access denied', 403
    # Reverse proxy cookie
    ap_session = request.cookies.get('oidc_session')
    
    session['ap_session'] = ap_session

    app.logger.info('New user logged in {} (sid {}) requesting access to {}:{}'.format(user, session.sid, ssh_host, ssh_port))
    app.logger.debug(str(ap_session))

    return '<html><head><title>Access Proxy</title></head><body>Welcome to the access proxy.<br/>Parameters: {}<br/>User: {}<br/>Groups: {}<br/>Session: {}<br/><p>You may now close this window</p></body></html>'.format(str(params), user, groups, str(session).strip('<>'))

@app.route('/api/session', methods=['GET'])
def api_session():
    """
    Used to return the reverse proxy cookie for the cli client to authenticate
    """
    cli_token = request.args.get('cli_token')
    response = {'cli_token_authenticated': False,
               'ap_session': ''}

    # Attempt to load local session - this only works for file system sessions
    # See https://github.com/pallets/werkzeug/blob/master/werkzeug/contrib/cache.py for format
    # XXX FIXME replace this by a custom session handler for Flask
    from werkzeug.contrib.cache import FileSystemCache
    import pickle
    cache = FileSystemCache(app.config['SESSION_FILE_DIR'], threshold=app.config['SESSION_FILE_THRESHOLD'], mode=app.config['SESSION_FILE_MODE'])
    found = False
    for fn in cache._list_dir():
         with open(fn, 'rb') as f:
             fot = pickle.load(f)
             local_session = pickle.load(f)
             if type(local_session) is not dict:
                 continue
             if local_session.get('cli_token') == cli_token:
                 found = True
                 break
    # Is the client pooling, waiting for the user to log in interactively?
    if not found:
        app.logger.debug('We do not yet have session data for the cli client')
        return jsonify(response), 202

    if not verify_cli_token(cli_token, session=local_session):
        return 'cli token verification failure - access denied', 403

    if (local_session.get('sent_ap_session')):
        app.logger.error('Same cli client tried to get the ap_session data more than once (security risk), destroying session')
        session.clear()
        return 'Session was already issued, access denied', 403

    response['ap_session'] = local_session.get('ap_session')
    response['cli_token_authenticated'] =  True
    session['sent_ap_session'] = True
    app.logger.debug('Delivering session data to cli client')
    return jsonify(response), 200

@app.route('/api/ping')
def api_ping():
    return jsonify({'PONG': time.time()}), 200

@app.route('/api/ssh/', methods=['GET'])
def api_ssh():
    """
    Requests a new, valid SSH certificate
    """

    # GET parameter set up
    required_params = ['type', 'host', 'port', 'cli_token']
    params = request.args.to_dict()
    if set(required_params) != set(params.keys()):
        return 'Incorrect GET parameters'
    cli_token = request.args.get('cli_token')
    if not verify_cli_token(cli_token):
        return 'Access denied', 403

    response = {'certificate': {'private_key': '', 'public_key': ''}}

    return jsonify(response), 200
